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
     * Records a completed Razorpay payment.
     */
    public function store(Request $request)
    {
        $v = Validator::make($request->all(), [
            'razorpay_payment_id' => 'required|string|max:100',
            'razorpay_order_id'   => 'nullable|string|max:100',
            'amount'              => 'required|numeric|min:1',
            'currency'            => 'nullable|string|max:10',
            'notes'               => 'nullable|string|max:500',
        ]);
        if ($v->fails()) {
            return response()->json(['status' => 'error', 'message' => $v->errors()->first()], 422);
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
