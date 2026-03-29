<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Donation;
use Illuminate\Http\Request;

class DonationController extends Controller
{
    public function index()
    {
        return view('admin.donations.index', ['donations' => Donation::all()]);
    }

    public function create()
    {
        return view('admin.donations.create');
    }

    public function store(Request $request)
    {
        $data = $request->only(['type', 'account_name', 'account_number', 'ifsc_code', 'upi_id', 'description', 'status']);
        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->getClientOriginalName();
            $request->file('image')->move(public_path('uploads/donations'), $data['image']);
        }
        Donation::create($data);
        return redirect()->route('admin.donations.index')->with('success', 'Donation info saved!');
    }
}
