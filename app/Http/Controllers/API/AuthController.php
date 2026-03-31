<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\OtpLog;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // POST /api/send-otp
    public function sendOtp(Request $request)
    {
        $v = Validator::make($request->all(), ['mobile' => 'required|digits:10']);
        if ($v->fails()) return $this->error($v->errors()->first());

        $otp = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);

        OtpLog::updateOrCreate(
            ['mobile' => $request->mobile],
            ['otp' => hash('sha256', $otp), 'expires_at' => now()->addMinutes(5), 'is_used' => 0, 'created_at' => now()]
        );

        // TODO: Integrate SMS gateway (Fast2SMS / MSG91)
        // Send $otp to $request->mobile via SMS API

        return $this->success([], 'OTP sent successfully');
    }

    // POST /api/verify-otp
    public function verifyOtp(Request $request)
    {
        $v = Validator::make($request->all(), [
            'mobile' => 'required|digits:10',
            'otp' => 'required|digits:6',
        ]);
        if ($v->fails()) return $this->error($v->errors()->first());

        $log = OtpLog::where('mobile', $request->mobile)
            ->where('otp', hash('sha256', $request->otp))
            ->where('is_used', 0)
            ->where('expires_at', '>=', now())
            ->first();

        if (!$log) return $this->error('Invalid or expired OTP', 422);

        $log->is_used = 1;
        $log->save();

        $user = User::firstOrCreate(
            ['mobile' => $request->mobile],
            ['name' => 'User ' . $request->mobile, 'status' => 'active']
        );

        if ($user->status === 'blocked') return $this->error('Account blocked. Contact admin.', 403);

        $token = $user->createToken('mobile-app')->plainTextToken;

        return $this->success([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'mobile' => $user->mobile,
                'profile_complete' => (bool) $user->profile_complete,
                'profile_image' => $user->profile_image ? asset('uploads/profiles/' . $user->profile_image) : null,
            ]
        ], 'Login successful');
    }

    // GET /api/profile
    public function profile(Request $request)
    {
        $user = $request->user();
        return $this->success([
            'id' => $user->id,
            'name' => $user->name,
            'mobile' => $user->mobile,
            'email' => $user->email,
            'profile_image' => $user->profile_image ? asset('uploads/profiles/' . $user->profile_image) : null,
        ]);
    }

    // POST /api/logout
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return $this->success([], 'Logged out successfully');
    }

    // Helper: success response
    private function success($data = [], $message = 'Success', $code = 200)
    {
        return response()->json(['status' => 'success', 'message' => $message, 'data' => $data], $code);
    }

    // Helper: error response
    private function error($message = 'Error', $code = 400)
    {
        return response()->json(['status' => 'error', 'message' => $message], $code);
    }
}
