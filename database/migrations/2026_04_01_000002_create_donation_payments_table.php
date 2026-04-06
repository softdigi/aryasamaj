<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('donation_payments', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable()->index();
            $table->string('razorpay_payment_id', 100)->unique();
            $table->string('razorpay_order_id', 100)->nullable();
            $table->decimal('amount', 10, 2);
            $table->string('currency', 10)->default('INR');
            $table->enum('status', ['success', 'failed', 'pending'])->default('success');
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('donation_payments');
    }
};
