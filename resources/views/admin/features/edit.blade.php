@extends('layouts.admin')

@section('title', 'Edit Feature')

@section('content')
<div class="card" style="max-width:600px;">
    <div class="card-header" style="background:#FF6B00;color:#fff;">
        <h5 class="mb-0"><i class="fas fa-edit mr-1"></i> Edit Feature</h5>
    </div>
    <div class="card-body">
        <form method="POST" action="{{ route('admin.features.update', $feature) }}" enctype="multipart/form-data">
            @csrf @method('PUT')
            <div class="form-group">
                <label>Name (English) <span class="text-danger">*</span></label>
                <input type="text" class="form-control @error('name') is-invalid @enderror"
                    name="name" value="{{ old('name', $feature->name) }}" required>
                @error('name')<span class="invalid-feedback">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Name (Hindi)</label>
                <input type="text" class="form-control" name="name_hindi"
                    value="{{ old('name_hindi', $feature->name_hindi) }}">
            </div>
            <div class="form-group">
                <label>Icon <small class="text-muted">(leave blank to keep existing)</small></label>
                @if($feature->icon)
                    <div class="mb-1">
                        <img src="{{ asset('uploads/' . $feature->icon) }}" height="40" style="border-radius:4px;"
                            onerror="this.style.display='none'">
                        <small class="text-muted d-block">{{ $feature->icon }}</small>
                    </div>
                @endif
                <input type="file" class="form-control-file" name="icon" accept="image/*,.svg">
            </div>
            <div class="form-group">
                <label>Route <span class="text-danger">*</span></label>
                <input type="text" class="form-control @error('route') is-invalid @enderror"
                    name="route" value="{{ old('route', $feature->route) }}" placeholder="/library" required>
                @error('route')<span class="invalid-feedback">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Section</label>
                <select name="section" class="form-control">
                    <option value="">— None —</option>
                    @foreach(['main','sangathan','suvidha','arya_veer'] as $sec)
                        <option value="{{ $sec }}"
                            {{ old('section', $feature->section) === $sec ? 'selected' : '' }}>
                            {{ ucfirst(str_replace('_', ' ', $sec)) }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div class="form-group">
                <label>Sort Order</label>
                <input type="number" class="form-control" name="sort_order"
                    value="{{ old('sort_order', $feature->sort_order) }}" min="0">
            </div>
            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="active" {{ old('status', $feature->status) === 'active' ? 'selected' : '' }}>Active</option>
                    <option value="inactive" {{ old('status', $feature->status) === 'inactive' ? 'selected' : '' }}>Inactive</option>
                </select>
            </div>
            <button type="submit" class="btn" style="background:#FF6B00;color:#fff;">
                <i class="fas fa-save mr-1"></i> Update Feature
            </button>
            <a href="{{ route('admin.features.index') }}" class="btn btn-secondary ml-2">Cancel</a>
        </form>
    </div>
</div>
@endsection
