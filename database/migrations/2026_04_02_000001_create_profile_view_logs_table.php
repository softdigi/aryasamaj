<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profile_view_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->index();
            $table->string('viewer_ip', 45)->nullable();
            $table->timestamp('viewed_at')->useCurrent();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            // Prevent a single IP from counting more than once per day per profile
            $table->index(['user_id', 'viewer_ip']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profile_view_logs');
    }
};
