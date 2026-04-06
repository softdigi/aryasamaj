<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function showLogin()
    {
        return view('admin.auth.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'mobile' => 'required', 'password' => 'required'
        ]);
        // Allow login by mobile or email
        $field = is_numeric($credentials['mobile']) ? 'mobile' : 'email';
        if (Auth::attempt([$field => $credentials['mobile'], 'password' => $credentials['password'], 'is_admin' => 1])) {
            $request->session()->regenerate();
            return redirect()->route('admin.dashboard');
        }
        return back()->withErrors(['mobile' => 'Invalid credentials or not an admin.']);
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        return redirect()->route('admin.login');
    }

    public function showChangePassword()
    {
        return view('admin.auth.change-password');
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required',
            'password' => [
                'required',
                'confirmed',
                Password::min(12)->mixedCase()->numbers()->symbols(),
            ],
        ]);

        $user = Auth::user();

        if (!Hash::check($request->current_password, $user->password)) {
            return back()->withErrors(['current_password' => 'Current password is incorrect.']);
        }

        $user->update(['password' => Hash::make($request->password)]);

        return back()->with('success', 'Password changed successfully.');
    }
}
