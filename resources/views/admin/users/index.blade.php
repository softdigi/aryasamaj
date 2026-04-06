@extends('layouts.admin')

@section('title', 'Users')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="font-weight-bold" style="color:#FF6B00;">User Management</h4>
</div>

<!-- Search -->
<form method="GET" action="{{ route('admin.users.index') }}" class="mb-3">
    <div class="input-group" style="max-width:400px;">
        <input type="text" class="form-control" name="search"
            value="{{ request('search') }}" placeholder="Search by name or mobile...">
        <div class="input-group-append">
            <button class="btn" style="background:#FF6B00;color:#fff;" type="submit">
                <i class="fas fa-search"></i>
            </button>
            @if(request('search'))
                <a href="{{ route('admin.users.index') }}" class="btn btn-secondary">Clear</a>
            @endif
        </div>
    </div>
</form>

<div class="card">
    <div class="card-body p-0">
        <table class="table table-hover mb-0">
            <thead class="thead-light">
                <tr>
                    <th>#</th>
                    <th>Name</th>
                    <th>Mobile</th>
                    <th>Status</th>
                    <th>Registered</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($users as $user)
                <tr>
                    <td>{{ $users->firstItem() + $loop->index }}</td>
                    <td>{{ $user->name }}</td>
                    <td>{{ $user->mobile }}</td>
                    <td>
                        @if($user->status === 'active')
                            <span class="badge badge-success">Active</span>
                        @else
                            <span class="badge badge-danger">Blocked</span>
                        @endif
                    </td>
                    <td>{{ $user->created_at->format('d M Y') }}</td>
                    <td>
                        <form method="POST" action="{{ route('admin.users.toggle', $user) }}" class="d-inline">
                            @csrf
                            <button class="btn btn-xs {{ $user->status === 'active' ? 'btn-danger' : 'btn-success' }}">
                                {{ $user->status === 'active' ? 'Block' : 'Unblock' }}
                            </button>
                        </form>
                    </td>
                </tr>
                @empty
                <tr><td colspan="6" class="text-center text-muted py-3">No users found.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    @if($users->hasPages())
    <div class="card-footer">
        {{ $users->appends(request()->query())->links() }}
    </div>
    @endif
</div>
@endsection
