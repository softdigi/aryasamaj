<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Donation;
use App\Models\DonationPayment;
use Illuminate\Http\Request;

class DonationController extends Controller
{
    public function index()
    {
        return view('admin.donations.index', [
            'donations' => Donation::all(),
            'payments'  => DonationPayment::with('user')->orderByDesc('created_at')->paginate(20),
        ]);
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

    public function edit(Donation $donation)
    {
        return view('admin.donations.edit', compact('donation'));
    }

    public function update(Request $request, Donation $donation)
    {
        $data = $request->only(['type', 'account_name', 'account_number', 'ifsc_code', 'upi_id', 'description', 'status']);
        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->getClientOriginalName();
            $request->file('image')->move(public_path('uploads/donations'), $data['image']);
        }
        $donation->update($data);
        return redirect()->route('admin.donations.index')->with('success', 'Donation info updated!');
    }
}
