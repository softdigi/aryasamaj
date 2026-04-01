<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DonationPayment extends Model
{
    protected $fillable = [
        'user_id', 'razorpay_payment_id', 'razorpay_order_id',
        'amount', 'currency', 'status', 'notes',
    ];

    protected function casts(): array
    {
        return ['amount' => 'decimal:2'];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
