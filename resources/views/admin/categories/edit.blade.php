@extends('layouts.admin')

@section('title', 'Edit Category')

@section('content')
<div class="card" style="max-width:600px;">
    <div class="card-header" style="background:#1A5C2E;color:#fff;">
        <h5 class="mb-0"><i class="fas fa-edit mr-1"></i> Edit Category</h5>
    </div>
    <div class="card-body">
        <form method="POST" action="{{ route('admin.categories.update', $category) }}" enctype="multipart/form-data">
            @csrf @method('PUT')
            <div class="form-group">
                <label>Name <span class="text-danger">*</span></label>
                <input type="text" class="form-control @error('name') is-invalid @enderror"
                    name="name" value="{{ old('name', $category->name) }}" required>
                @error('name')<span class="invalid-feedback">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Parent Category</label>
                <select name="parent_id" class="form-control">
                    <option value="">— Root (No Parent) —</option>
                    @foreach($parents as $parent)
                        <option value="{{ $parent->id }}" {{ old('parent_id', $category->parent_id) == $parent->id ? 'selected' : '' }}>
                            {{ $parent->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="form-group">
                <label>Type</label>
                <input type="text" class="form-control" name="type" value="{{ old('type', $category->type) }}"
                    placeholder="e.g. main / arya_veer / suvidha">
            </div>
            <div class="form-group">
                <label>Icon (Image)</label>
                @if($category->icon)
                    <div class="mb-2">
                        <img src="{{ asset('uploads/' . $category->icon) }}" alt="Current Icon"
                            style="height:50px;width:50px;object-fit:cover;border-radius:6px;border:1px solid #ddd;">
                        <small class="text-muted ml-2">Current icon</small>
                    </div>
                @endif
                <input type="file" class="form-control-file" name="icon" accept="image/*">
            </div>
            <div class="form-group">
                <label>Sort Order</label>
                <input type="number" class="form-control" name="sort_order" value="{{ old('sort_order', $category->sort_order) }}" min="0">
            </div>
            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="active" {{ old('status', $category->status) === 'active' ? 'selected' : '' }}>Active</option>
                    <option value="inactive" {{ old('status', $category->status) === 'inactive' ? 'selected' : '' }}>Inactive</option>
                </select>
            </div>
            <button type="submit" class="btn" style="background:#1A5C2E;color:#fff;">
                <i class="fas fa-save mr-1"></i> Update Category
            </button>
            <a href="{{ route('admin.categories.index') }}" class="btn btn-secondary ml-2">Cancel</a>
        </form>
    </div>
</div>
@endsection
