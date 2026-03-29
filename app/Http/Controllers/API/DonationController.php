<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Donation;

class DonationController extends Controller
{
    public function index()
    {
        $donations = Donation::where('status', 'active')->get()->map(fn($d) => [
            'id' => $d->id,
            'type' => $d->type,
            'account_name' => $d->account_name,
            'account_number' => $d->account_number,
            'ifsc_code' => $d->ifsc_code,
            'upi_id' => $d->upi_id,
            'image_url' => $d->image_url,
            'description' => $d->description,
        ]);
        return response()->json(['status' => 'success', 'data' => $donations]);
    }
}
