<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\DonationPayment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class DonationPaymentController extends Controller
{
    /**
     * POST /api/donation/pay
     * Records a completed Razorpay payment after verifying the server-side signature.
     */
    public function store(Request $request)
    {
        $v = Validator::make($request->all(), [
            'razorpay_payment_id' => 'required|string|max:100',
            'razorpay_order_id'   => 'required|string|max:100',
            'razorpay_signature'  => 'required|string|max:256',
            'amount'              => 'required|numeric|min:1',
            'currency'            => 'nullable|string|max:10',
            'notes'               => 'nullable|string|max:500',
        ]);
        if ($v->fails()) {
            return response()->json(['status' => 'error', 'message' => $v->errors()->first()], 422);
        }

        // Verify Razorpay payment signature to prevent forged payment records.
        // The signature is HMAC-SHA256 of "<order_id>|<payment_id>" using the Razorpay key secret.
        $expectedSignature = hash_hmac(
            'sha256',
            $request->razorpay_order_id . '|' . $request->razorpay_payment_id,
            config('services.razorpay.secret')
        );

        if (!hash_equals($expectedSignature, $request->razorpay_signature)) {
            return response()->json(['status' => 'error', 'message' => 'Payment verification failed.'], 422);
        }

        // Prevent recording the same payment twice.
        if (DonationPayment::where('razorpay_payment_id', $request->razorpay_payment_id)->exists()) {
            return response()->json(['status' => 'error', 'message' => 'Payment already recorded.'], 409);
        }

        $payment = DonationPayment::create([
            'user_id'             => $request->user()->id,
            'razorpay_payment_id' => $request->razorpay_payment_id,
            'razorpay_order_id'   => $request->razorpay_order_id,
            'amount'              => $request->amount,
            'currency'            => $request->input('currency', 'INR'),
            'status'              => 'success',
            'notes'               => $request->notes,
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'धन्यवाद! आपका दान प्राप्त हो गया।',
            'data'    => ['id' => $payment->id, 'amount' => $payment->amount],
        ]);
    }
}
