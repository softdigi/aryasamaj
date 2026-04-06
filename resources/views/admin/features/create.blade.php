@extends('layouts.admin')

@section('title', 'Add Feature')

@section('content')
<div class="card" style="max-width:600px;">
    <div class="card-header" style="background:#FF6B00;color:#fff;">
        <h5 class="mb-0"><i class="fas fa-plus mr-1"></i> Add Feature</h5>
    </div>
    <div class="card-body">
        <form method="POST" action="{{ route('admin.features.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="form-group">
                <label>Name (English) <span class="text-danger">*</span></label>
                <input type="text" class="form-control @error('name') is-invalid @enderror"
                    name="name" value="{{ old('name') }}" required>
                @error('name')<span class="invalid-feedback">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Name (Hindi)</label>
                <input type="text" class="form-control" name="name_hindi" value="{{ old('name_hindi') }}">
            </div>
            <div class="form-group">
                <label>Icon (Image/SVG)</label>
                <input type="file" class="form-control-file" name="icon" accept="image/*,.svg">
            </div>
            <div class="form-group">
                <label>Route <span class="text-danger">*</span></label>
                <input type="text" class="form-control @error('route') is-invalid @enderror"
                    name="route" value="{{ old('route') }}" placeholder="/library" required>
                @error('route')<span class="invalid-feedback">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Section</label>
                <select name="section" class="form-control">
                    <option value="">— None —</option>
                    @foreach(['main','sangathan','suvidha','arya_veer'] as $sec)
                        <option value="{{ $sec }}" {{ old('section') === $sec ? 'selected' : '' }}>
                            {{ ucfirst(str_replace('_', ' ', $sec)) }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="form-group">
                <label>Sort Order</label>
                <input type="number" class="form-control" name="sort_order" value="{{ old('sort_order', 0) }}" min="0">
            </div>
            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                </select>
            </div>
            <button type="submit" class="btn" style="background:#FF6B00;color:#fff;">
                <i class="fas fa-save mr-1"></i> Save Feature
            </button>
            <a href="{{ route('admin.features.index') }}" class="btn btn-secondary ml-2">Cancel</a>
        </form>
    </div>
</div>
@endsection
