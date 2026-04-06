@extends('layouts.admin')

@section('title', 'Add Event')

@section('content')
<div class="card card-primary" style="max-width:700px;">
    <div class="card-header"><h3 class="card-title"><i class="fas fa-calendar-plus mr-2"></i>Add Event</h3></div>
    <form method="POST" action="{{ route('admin.events.store') }}" enctype="multipart/form-data">
        @csrf
        <div class="card-body">
            @if($errors->any())
                <div class="alert alert-danger"><ul class="mb-0">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>
            @endif
            <div class="form-group">
                <label>Title *</label>
                <input type="text" name="title" class="form-control @error('title') is-invalid @enderror"
                    value="{{ old('title') }}" required>
                @error('title')<span class="invalid-feedback">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="description" class="form-control" rows="4">{{ old('description') }}</textarea>
            </div>
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label>Event Date & Time *</label>
                    <input type="datetime-local" name="event_date"
                        class="form-control @error('event_date') is-invalid @enderror"
                        value="{{ old('event_date') }}" required>
                    @error('event_date')<span class="invalid-feedback">{{ $message }}</span>@enderror
                </div>
                <div class="form-group col-md-6">
                    <label>Status *</label>
                    <select name="status" class="form-control" required>
                        <option value="upcoming" {{ old('status') === 'upcoming' ? 'selected' : '' }}>Upcoming</option>
                        <option value="past" {{ old('status') === 'past' ? 'selected' : '' }}>Past</option>
                        <option value="draft" {{ old('status') === 'draft' ? 'selected' : '' }}>Draft</option>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label>Location</label>
                <input type="text" name="location" class="form-control" value="{{ old('location') }}">
            </div>
            <div class="form-group">
                <label>Image</label>
                <input type="file" name="image" class="form-control-file" accept="image/jpeg,image/png,image/webp">
            </div>
        </div>
        <div class="card-footer">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save mr-1"></i>Save Event</button>
            <a href="{{ route('admin.events.index') }}" class="btn btn-default ml-2">Cancel</a>
        </div>
    </form>
</div>
@endsection
