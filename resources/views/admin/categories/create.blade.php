@extends('layouts.admin')

@section('title', 'Add Category')

@section('content')
<div class="card" style="max-width:600px;">
    <div class="card-header" style="background:#FF6B00;color:#fff;">
        <h5 class="mb-0"><i class="fas fa-plus mr-1"></i> Add Category</h5>
    </div>
    <div class="card-body">
        <form method="POST" action="{{ route('admin.categories.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="form-group">
                <label>Name <span class="text-danger">*</span></label>
                <input type="text" class="form-control @error('name') is-invalid @enderror"
                    name="name" value="{{ old('name') }}" required>
                @error('name')<span class="invalid-feedback">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Parent Category</label>
                <select name="parent_id" class="form-control">
                    <option value="">— Root (No Parent) —</option>
                    @foreach($parents as $parent)
                        <option value="{{ $parent->id }}" {{ old('parent_id') == $parent->id ? 'selected' : '' }}>
                            {{ $parent->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="form-group">
                <label>Type</label>
                <input type="text" class="form-control" name="type" value="{{ old('type') }}"
                    placeholder="e.g. main / arya_veer / suvidha">
            </div>
            <div class="form-group">
                <label>Icon (Image)</label>
                <input type="file" class="form-control-file" name="icon" accept="image/*">
            </div>
            <div class="form-group">
                <label>Sort Order</label>
                <input type="number" class="form-control" name="sort_order" value="{{ old('sort_order', 0) }}" min="0">
            </div>
            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="active" {{ old('status') == 'active' ? 'selected' : '' }}>Active</option>
                    <option value="inactive" {{ old('status') == 'inactive' ? 'selected' : '' }}>Inactive</option>
                </select>
            </div>
            <button type="submit" class="btn" style="background:#FF6B00;color:#fff;">
                <i class="fas fa-save mr-1"></i> Save Category
            </button>
            <a href="{{ route('admin.categories.index') }}" class="btn btn-secondary ml-2">Cancel</a>
        </form>
    </div>
</div>
@endsection
