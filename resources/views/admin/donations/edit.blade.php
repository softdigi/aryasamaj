@extends('layouts.admin')

@section('title', 'Edit Donation Info')

@section('content')
<div class="card" style="max-width:600px;">
    <div class="card-header" style="background:#FF6B00;color:#fff;">
        <h5 class="mb-0"><i class="fas fa-edit mr-1"></i> Edit Donation Info</h5>
    </div>
    <div class="card-body">
        <form method="POST" action="{{ route('admin.donations.update', $donation) }}" enctype="multipart/form-data">
            @csrf @method('PUT')
            <div class="form-group">
                <label>Type <span class="text-danger">*</span></label>
                <select name="type" class="form-control" id="donationType">
                    <option value="bank"  {{ old('type', $donation->type) === 'bank'  ? 'selected' : '' }}>Bank Transfer</option>
                    <option value="upi"   {{ old('type', $donation->type) === 'upi'   ? 'selected' : '' }}>UPI</option>
                    <option value="qr"    {{ old('type', $donation->type) === 'qr'    ? 'selected' : '' }}>QR Code</option>
                </select>
            </div>
            <div class="form-group" id="fieldAccountName">
                <label>Account Name</label>
                <input type="text" class="form-control" name="account_name"
                    value="{{ old('account_name', $donation->account_name) }}">
            </div>
            <div class="form-group" id="fieldAccountNumber">
                <label>Account Number</label>
                <input type="text" class="form-control" name="account_number"
                    value="{{ old('account_number', $donation->account_number) }}">
            </div>
            <div class="form-group" id="fieldIfsc">
                <label>IFSC Code</label>
                <input type="text" class="form-control" name="ifsc_code"
                    value="{{ old('ifsc_code', $donation->ifsc_code) }}">
            </div>
            <div class="form-group" id="fieldUpi">
                <label>UPI ID</label>
                <input type="text" class="form-control" name="upi_id"
                    value="{{ old('upi_id', $donation->upi_id) }}" placeholder="example@upi">
            </div>
            <div class="form-group">
                <label>QR Code Image <small class="text-muted">(leave blank to keep existing)</small></label>
                @if($donation->image)
                    <div class="mb-1">
                        <img src="{{ asset('uploads/donations/' . $donation->image) }}" height="70"
                            style="border-radius:4px;" onerror="this.style.display='none'">
                    </div>
                @endif
                <input type="file" class="form-control-file" name="image" accept="image/*">
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="description" class="form-control" rows="3">{{ old('description', $donation->description) }}</textarea>
            </div>
            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="active"   {{ old('status', $donation->status) === 'active'   ? 'selected' : '' }}>Active</option>
                    <option value="inactive" {{ old('status', $donation->status) === 'inactive' ? 'selected' : '' }}>Inactive</option>
                </select>
            </div>
            <button type="submit" class="btn" style="background:#FF6B00;color:#fff;">
                <i class="fas fa-save mr-1"></i> Update Donation Info
            </button>
            <a href="{{ route('admin.donations.index') }}" class="btn btn-secondary ml-2">Cancel</a>
        </form>
    </div>
</div>
@endsection

@push('scripts')
<script>
(function () {
    const type = document.getElementById('donationType');
    function toggle() {
        const v = type.value;
        document.getElementById('fieldAccountName').style.display   = v === 'bank' ? '' : 'none';
        document.getElementById('fieldAccountNumber').style.display = v === 'bank' ? '' : 'none';
        document.getElementById('fieldIfsc').style.display          = v === 'bank' ? '' : 'none';
        document.getElementById('fieldUpi').style.display           = v === 'upi'  ? '' : 'none';
    }
    type.addEventListener('change', toggle);
    toggle();
})();
</script>
@endpush
