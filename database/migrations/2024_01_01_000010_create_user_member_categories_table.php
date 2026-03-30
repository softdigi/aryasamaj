<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_member_categories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('member_category_id')->constrained('member_categories')->onDelete('cascade');
            $table->timestamps();

            $table->unique(['user_id', 'member_category_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_member_categories');
    }
};
