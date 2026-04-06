<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('events', function (Blueprint $table) {
            $table->id();
            $table->string('title', 200);
            $table->text('description')->nullable();
            $table->dateTime('event_date');
            $table->string('location', 200)->nullable();
            $table->string('image')->nullable();
            $table->enum('status', ['upcoming', 'past', 'draft'])->default('upcoming');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('events');
    }
};
