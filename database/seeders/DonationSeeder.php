<?php

namespace Database\Seeders;

use App\Models\Donation;
use Illuminate\Database\Seeder;

class DonationSeeder extends Seeder
{
    public function run(): void
    {
        Donation::updateOrCreate(['type' => 'bank'], [
            'type' => 'bank',
            'account_name' => 'Rupendra Nishad',
            'account_number' => '32610196934',
            'ifsc_code' => 'SBIN0009416',
            'description' => 'State Bank of India',
            'status' => 'active',
        ]);
        Donation::updateOrCreate(['type' => 'upi'], [
            'type' => 'upi',
            'upi_id' => 'aryasamaj@sbi',
            'account_name' => 'Arya Samaj',
            'status' => 'active',
        ]);
    }
}
