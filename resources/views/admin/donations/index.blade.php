@extends('layouts.admin')

@section('title', 'Donations')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="font-weight-bold" style="color:#FF6B00;">Donation Management</h4>
    <a href="{{ route('admin.donations.create') }}" class="btn btn-sm" style="background:#FF6B00;color:#fff;">
        <i class="fas fa-plus mr-1"></i> Add Donation Info
    </a>
</div>

<div class="card">
    <div class="card-body p-0">
        <table class="table table-hover mb-0">
            <thead class="thead-light">
                <tr>
                    <th>Type</th>
                    <th>Account Name</th>
                    <th>Account No / UPI</th>
                    <th>IFSC</th>
                    <th>QR Image</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($donations as $donation)
                <tr>
                    <td><span class="badge badge-info">{{ strtoupper($donation->type) }}</span></td>
                    <td>{{ $donation->account_name ?? '—' }}</td>
                    <td>{{ $donation->account_number ?? $donation->upi_id ?? '—' }}</td>
                    <td>{{ $donation->ifsc_code ?? '—' }}</td>
                    <td>
                        @if($donation->image)
                            <img src="{{ asset('uploads/donations/' . $donation->image) }}"
                                alt="QR" style="height:40px;width:40px;object-fit:cover;border-radius:4px;border:1px solid #ddd;">
                        @else
                            <span class="text-muted">—</span>
                        @endif
                    </td>
                    <td>
                        @if($donation->status === 'active')
                            <span class="badge badge-success">Active</span>
                        @else
                            <span class="badge badge-secondary">Inactive</span>
                        @endif
                    </td>
                    <td>
                        <form method="POST" action="{{ route('admin.donations.destroy', $donation) }}" class="d-inline"
                              onsubmit="return confirm('Delete this donation record?')">
                            @csrf @method('DELETE')
                            <button class="btn btn-xs btn-danger"><i class="fas fa-trash"></i></button>
                        </form>
                    </td>
                </tr>
                @empty
                <tr><td colspan="7" class="text-center text-muted py-3">No donation info added yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
