<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['mobile' => '9827898510'],
            [
                'name' => 'Admin',
                'mobile' => '9827898510',
                'password' => Hash::make('Admin@123'),
                'is_admin' => 1,
                'status' => 'active',
            ]
        );
    }
}
