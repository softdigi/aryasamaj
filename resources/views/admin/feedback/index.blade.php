@extends('layouts.admin')

@section('title', 'Feedback')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="font-weight-bold" style="color:#FF6B00;">User Feedback</h4>
</div>

<div class="card">
    <div class="card-body p-0">
        <table class="table table-hover mb-0">
            <thead class="thead-light">
                <tr>
                    <th>User</th>
                    <th>Type</th>
                    <th>Message</th>
                    <th>Date</th>
                    <th>Read</th>
                </tr>
            </thead>
            <tbody>
                @forelse($feedbacks as $fb)
                <tr>
                    <td>{{ $fb->user->mobile ?? 'N/A' }}</td>
                    <td>
                        @php
                            $typeBadge = match($fb->type ?? '') {
                                'suggestion' => 'primary',
                                'bug'        => 'danger',
                                'praise'     => 'success',
                                default      => 'secondary'
                            };
                        @endphp
                        <span class="badge badge-{{ $typeBadge }}">{{ ucfirst($fb->type ?? 'other') }}</span>
                    </td>
                    <td title="{{ $fb->message }}">{{ Str::limit($fb->message, 60) }}</td>
                    <td>{{ $fb->created_at->format('d M Y H:i') }}</td>
                    <td>
                        <span class="badge {{ $fb->is_read ? 'badge-secondary' : 'badge-warning' }}">
                            {{ $fb->is_read ? 'Read' : 'New' }}
                        </span>
                    </td>
                </tr>
                @empty
                <tr><td colspan="5" class="text-center text-muted py-3">No feedback received yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    @if($feedbacks->hasPages())
    <div class="card-footer">
        {{ $feedbacks->links() }}
    </div>
    @endif
</div>
@endsection
