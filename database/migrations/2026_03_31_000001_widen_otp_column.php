<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('otp_logs', function (Blueprint $table) {
            // OTPs are now stored as SHA-256 hashes (64 hex characters).
            $table->string('otp', 64)->change();
        });
    }

    public function down(): void
    {
        Schema::table('otp_logs', function (Blueprint $table) {
            $table->string('otp', 6)->change();
        });
    }
};
