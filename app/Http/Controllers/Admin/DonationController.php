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
        $request->validate([
            'type'           => 'required|string|max:50',
            'account_name'   => 'nullable|string|max:150',
            'account_number' => 'nullable|string|max:50',
            'ifsc_code'      => 'nullable|string|max:20',
            'upi_id'         => 'nullable|string|max:100',
            'description'    => 'nullable|string|max:1000',
            'status'         => 'required|in:active,inactive',
            'image'          => 'nullable|image|mimes:jpeg,jpg,png,webp|max:2048',
        ]);
        $data = $request->only(['type', 'account_name', 'account_number', 'ifsc_code', 'upi_id', 'description', 'status']);
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $filename = 'donation_' . time() . '_' . bin2hex(random_bytes(6)) . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('uploads/donations'), $filename);
            $data['image'] = $filename;
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
        $request->validate([
            'type'           => 'required|string|max:50',
            'account_name'   => 'nullable|string|max:150',
            'account_number' => 'nullable|string|max:50',
            'ifsc_code'      => 'nullable|string|max:20',
            'upi_id'         => 'nullable|string|max:100',
            'description'    => 'nullable|string|max:1000',
            'status'         => 'required|in:active,inactive',
            'image'          => 'nullable|image|mimes:jpeg,jpg,png,webp|max:2048',
        ]);
        $data = $request->only(['type', 'account_name', 'account_number', 'ifsc_code', 'upi_id', 'description', 'status']);
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $filename = 'donation_' . time() . '_' . bin2hex(random_bytes(6)) . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('uploads/donations'), $filename);
            $data['image'] = $filename;
        }
        $donation->update($data);
        return redirect()->route('admin.donations.index')->with('success', 'Donation info updated!');
    }
}
