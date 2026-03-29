@extends('layouts.admin')

@section('title', 'Add Donation Info')

@section('content')
<div class="card" style="max-width:600px;">
    <div class="card-header" style="background:#FF6B00;color:#fff;">
        <h5 class="mb-0"><i class="fas fa-hand-holding-usd mr-1"></i> Add Donation Info</h5>
    </div>
    <div class="card-body">
        <form method="POST" action="{{ route('admin.donations.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="form-group">
                <label>Type <span class="text-danger">*</span></label>
                <select name="type" class="form-control" id="donationType">
                    <option value="bank" {{ old('type') === 'bank' ? 'selected' : '' }}>Bank Transfer</option>
                    <option value="upi" {{ old('type') === 'upi' ? 'selected' : '' }}>UPI</option>
                    <option value="qr" {{ old('type') === 'qr' ? 'selected' : '' }}>QR Code</option>
                </select>
            </div>
            <div class="form-group" id="fieldAccountName">
                <label>Account Name</label>
                <input type="text" class="form-control" name="account_name" value="{{ old('account_name') }}">
            </div>
            <div class="form-group" id="fieldAccountNumber">
                <label>Account Number</label>
                <input type="text" class="form-control" name="account_number" value="{{ old('account_number') }}">
            </div>
            <div class="form-group" id="fieldIfsc">
                <label>IFSC Code</label>
                <input type="text" class="form-control" name="ifsc_code" value="{{ old('ifsc_code') }}">
            </div>
            <div class="form-group" id="fieldUpi">
                <label>UPI ID</label>
                <input type="text" class="form-control" name="upi_id" value="{{ old('upi_id') }}"
                    placeholder="example@upi">
            </div>
            <div class="form-group">
                <label>QR Code Image</label>
                <input type="file" class="form-control-file" name="image" accept="image/*">
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="description" class="form-control" rows="3">{{ old('description') }}</textarea>
            </div>
            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                </select>
            </div>
            <button type="submit" class="btn" style="background:#FF6B00;color:#fff;">
                <i class="fas fa-save mr-1"></i> Save Donation Info
            </button>
            <a href="{{ route('admin.donations.index') }}" class="btn btn-secondary ml-2">Cancel</a>
        </form>
    </div>
</div>
@endsection
