@extends('layouts.admin')

@section('title', 'Edit Event')

@section('content')
<div class="card card-primary" style="max-width:700px;">
    <div class="card-header"><h3 class="card-title"><i class="fas fa-calendar-edit mr-2"></i>Edit Event</h3></div>
    <form method="POST" action="{{ route('admin.events.update', $event) }}" enctype="multipart/form-data">
        @csrf @method('PUT')
        <div class="card-body">
            @if($errors->any())
                <div class="alert alert-danger"><ul class="mb-0">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>
            @endif
            <div class="form-group">
                <label>Title *</label>
                <input type="text" name="title" class="form-control @error('title') is-invalid @enderror"
                    value="{{ old('title', $event->title) }}" required>
                @error('title')<span class="invalid-feedback">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="description" class="form-control" rows="4">{{ old('description', $event->description) }}</textarea>
            </div>
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label>Event Date & Time *</label>
                    <input type="datetime-local" name="event_date"
                        class="form-control @error('event_date') is-invalid @enderror"
                        value="{{ old('event_date', $event->event_date?->format('Y-m-d\TH:i')) }}" required>
                    @error('event_date')<span class="invalid-feedback">{{ $message }}</span>@enderror
                </div>
                <div class="form-group col-md-6">
                    <label>Status *</label>
                    <select name="status" class="form-control" required>
                        @foreach(['upcoming','past','draft'] as $s)
                        <option value="{{ $s }}" {{ old('status', $event->status) === $s ? 'selected' : '' }}>
                            {{ ucfirst($s) }}
                        </option>
                        @endforeach
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label>Location</label>
                <input type="text" name="location" class="form-control" value="{{ old('location', $event->location) }}">
            </div>
            <div class="form-group">
                <label>Image</label>
                @if($event->image)
                    <div class="mb-2">
                        <img src="{{ asset('uploads/events/' . $event->image) }}" style="height:80px;border-radius:6px;">
                    </div>
                @endif
                <input type="file" name="image" class="form-control-file" accept="image/jpeg,image/png,image/webp">
                <small class="text-muted">Leave empty to keep current image.</small>
            </div>
        </div>
        <div class="card-footer">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save mr-1"></i>Update Event</button>
            <a href="{{ route('admin.events.index') }}" class="btn btn-default ml-2">Cancel</a>
        </div>
    </form>
</div>
@endsection
