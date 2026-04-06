<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('otp_logs', function (Blueprint $table) {
            $table->id();
            $table->string('mobile', 15);
            $table->string('otp', 6);
            $table->timestamp('expires_at')->nullable();
            $table->tinyInteger('is_used')->default(0);
            $table->timestamp('created_at')->nullable();

            $table->index('mobile');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('otp_logs');
    }
};
