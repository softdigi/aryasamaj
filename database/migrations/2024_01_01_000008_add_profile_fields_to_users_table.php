<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('username', 80)->nullable()->unique()->after('mobile');
            $table->enum('gender', ['male', 'female', 'other'])->nullable()->after('username');
            $table->date('dob')->nullable()->after('gender');
            $table->string('country', 80)->nullable()->after('dob');
            $table->string('state', 100)->nullable()->after('country');
            $table->string('district', 100)->nullable()->after('state');
            $table->string('tehsil', 100)->nullable()->after('district');
            $table->string('village', 150)->nullable()->after('tehsil');
            $table->string('post_office', 100)->nullable()->after('village');
            $table->string('pincode', 10)->nullable()->after('post_office');
            $table->text('about')->nullable()->after('pincode');
            $table->string('org_type', 100)->nullable()->after('about');
            $table->string('org_name', 150)->nullable()->after('org_type');
            $table->boolean('profile_complete')->default(false)->after('org_name');
            $table->boolean('is_verified')->default(false)->after('profile_complete');
            $table->unsignedInteger('profile_views')->default(0)->after('is_verified');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'username', 'gender', 'dob', 'country', 'state', 'district',
                'tehsil', 'village', 'post_office', 'pincode', 'about',
                'org_type', 'org_name', 'profile_complete', 'is_verified', 'profile_views',
            ]);
        });
    }
};
