@extends('layouts.admin')

@section('title', 'Category Management')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="font-weight-bold" style="color:#FF6B00;">Category Management</h4>
    <a href="{{ route('admin.categories.create') }}" class="btn btn-sm" style="background:#FF6B00;color:#fff;">
        <i class="fas fa-plus mr-1"></i> Add Category
    </a>
</div>

<div class="card">
    <div class="card-body p-0">
        <table class="table table-hover mb-0">
            <thead class="thead-light">
                <tr>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Icon</th>
                    <th>Status</th>
                    <th>Sort</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($cats as $cat)
                    @include('admin.categories._row', ['cat' => $cat, 'depth' => 0])
                @empty
                <tr><td colspan="6" class="text-center text-muted">No categories found.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
