@extends('layouts.admin')

@section('title', 'Edit Content')

@section('content')
<div class="card" style="max-width:650px;">
    <div class="card-header" style="background:#FF6B00;color:#fff;">
        <h5 class="mb-0"><i class="fas fa-edit mr-1"></i> Edit Content</h5>
    </div>
    <div class="card-body">
        <form method="POST" action="{{ route('admin.contents.update', $content) }}" enctype="multipart/form-data">
            @csrf @method('PUT')
            <div class="form-group">
                <label>Title <span class="text-danger">*</span></label>
                <input type="text" class="form-control @error('title') is-invalid @enderror"
                    name="title" value="{{ old('title', $content->title) }}" required>
                @error('title')<span class="invalid-feedback">{{ $message }}</span>@enderror
            </div>
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label>Type</label>
                    <input type="text" class="form-control" value="{{ strtoupper($content->type) }}" readonly disabled>
                </div>
                <div class="form-group col-md-6">
                    <label>Category <span class="text-danger">*</span></label>
                    <select name="category_id" class="form-control @error('category_id') is-invalid @enderror" required>
                        <option value="">— Select Category —</option>
                        @foreach($categories as $cat)
                            <option value="{{ $cat->id }}"
                                {{ old('category_id', $content->category_id) == $cat->id ? 'selected' : '' }}>
                                {{ $cat->name }}
                            </option>
                        @endforeach
                    </select>
                    @error('category_id')<span class="invalid-feedback">{{ $message }}</span>@enderror
                </div>
            </div>
            <div class="form-group">
                <label>Replace File <small class="text-muted">(leave blank to keep existing)</small></label>
                @if($content->file)
                    <p class="text-muted small mb-1">Current: {{ basename($content->file) }}</p>
                @endif
                <input type="file" class="form-control-file @error('file') is-invalid @enderror"
                    name="file" id="contentFile">
                @error('file')<span class="invalid-feedback d-block">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Replace Thumbnail <small class="text-muted">(leave blank to keep existing)</small></label>
                @if($content->image)
                    <div class="mb-1">
                        <img src="{{ asset('uploads/' . $content->image) }}" height="50" style="border-radius:4px;">
                    </div>
                @endif
                <input type="file" class="form-control-file @error('image') is-invalid @enderror"
                    name="image" accept="image/*">
                @error('image')<span class="invalid-feedback d-block">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="description" class="form-control" rows="3">{{ old('description', $content->description) }}</textarea>
            </div>
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label>Author</label>
                    <input type="text" class="form-control" name="author"
                        value="{{ old('author', $content->author) }}">
                </div>
                <div class="form-group col-md-6">
                    <label>Edition Year</label>
                    <input type="number" class="form-control" name="edition_year"
                        value="{{ old('edition_year', $content->edition_year) }}"
                        min="1800" max="{{ date('Y') }}">
                </div>
            </div>
            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="active" {{ old('status', $content->status) === 'active' ? 'selected' : '' }}>Active</option>
                    <option value="inactive" {{ old('status', $content->status) === 'inactive' ? 'selected' : '' }}>Inactive</option>
                </select>
            </div>
            <button type="submit" class="btn" style="background:#FF6B00;color:#fff;">
                <i class="fas fa-save mr-1"></i> Update Content
            </button>
            <a href="{{ route('admin.contents.index') }}" class="btn btn-secondary ml-2">Cancel</a>
        </form>
    </div>
</div>
@endsection

@push('scripts')
<script>
const accepts = {
    pdf: '.pdf',
    audio: '.mp3,.wav,.ogg,.aac,.m4a',
    video: '.mp4,.mov,.avi,.mkv,.webm',
    image: 'image/*',
    text: '.txt,.doc,.docx'
};
document.getElementById('contentFile').accept = accepts['{{ $content->type }}'] || '*';
</script>
@endpush
