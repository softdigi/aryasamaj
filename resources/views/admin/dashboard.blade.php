@extends('layouts.admin')

@section('title', 'Dashboard')

@section('content')
<div class="row">
    <div class="col-12 mb-3">
        <h4 class="font-weight-bold" style="color:#FF6B00;">Dashboard Overview</h4>
    </div>
</div>

<!-- Stat Cards -->
<div class="row">
    <div class="col-lg-3 col-6">
        <div class="info-box">
            <span class="info-box-icon bg-warning elevation-1"><i class="fas fa-users"></i></span>
            <div class="info-box-content">
                <span class="info-box-text">Total Users</span>
                <span class="info-box-number">{{ $totalUsers }}</span>
            </div>
        </div>
    </div>
    <div class="col-lg-3 col-6">
        <div class="info-box">
            <span class="info-box-icon elevation-1" style="background-color:#1A5C2E;"><i class="fas fa-folder-open text-white"></i></span>
            <div class="info-box-content">
                <span class="info-box-text">Categories</span>
                <span class="info-box-number">{{ $totalCategories }}</span>
            </div>
        </div>
    </div>
    <div class="col-lg-3 col-6">
        <div class="info-box">
            <span class="info-box-icon bg-info elevation-1"><i class="fas fa-book"></i></span>
            <div class="info-box-content">
                <span class="info-box-text">Contents</span>
                <span class="info-box-number">{{ $totalContents }}</span>
            </div>
        </div>
    </div>
    <div class="col-lg-3 col-6">
        <div class="info-box">
            <span class="info-box-icon bg-danger elevation-1"><i class="fas fa-comments"></i></span>
            <div class="info-box-content">
                <span class="info-box-text">Unread Feedback</span>
                <span class="info-box-number">{{ $unreadFeedback }}</span>
            </div>
        </div>
    </div>
</div>

<!-- Recent Tables -->
<div class="row mt-2">
    <!-- Recent Users -->
    <div class="col-lg-6">
        <div class="card card-outline" style="border-top-color:#FF6B00;">
            <div class="card-header">
                <h5 class="card-title mb-0"><i class="fas fa-users mr-1" style="color:#FF6B00;"></i> Recent Users</h5>
            </div>
            <div class="card-body p-0">
                <table class="table table-sm table-hover mb-0">
                    <thead class="thead-light">
                        <tr>
                            <th>Name</th>
                            <th>Mobile</th>
                            <th>Registered</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($recentUsers as $user)
                        <tr>
                            <td>{{ $user->name }}</td>
                            <td>{{ $user->mobile }}</td>
                            <td>{{ $user->created_at->format('d M Y') }}</td>
                        </tr>
                        @empty
                        <tr><td colspan="3" class="text-center text-muted">No users yet.</td></tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Recent Feedback -->
    <div class="col-lg-6">
        <div class="card card-outline" style="border-top-color:#1A5C2E;">
            <div class="card-header">
                <h5 class="card-title mb-0"><i class="fas fa-comments mr-1" style="color:#1A5C2E;"></i> Recent Feedback</h5>
            </div>
            <div class="card-body p-0">
                <table class="table table-sm table-hover mb-0">
                    <thead class="thead-light">
                        <tr>
                            <th>User</th>
                            <th>Type</th>
                            <th>Message</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($recentFeedback as $fb)
                        <tr>
                            <td>{{ $fb->user->mobile ?? 'N/A' }}</td>
                            <td><span class="badge badge-secondary">{{ $fb->type }}</span></td>
                            <td>{{ Str::limit($fb->message, 40) }}</td>
                        </tr>
                        @empty
                        <tr><td colspan="3" class="text-center text-muted">No feedback yet.</td></tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
