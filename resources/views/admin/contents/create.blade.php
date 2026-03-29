@extends('layouts.admin')

@section('title', 'Upload Content')

@section('content')
<div class="card" style="max-width:650px;">
    <div class="card-header" style="background:#FF6B00;color:#fff;">
        <h5 class="mb-0"><i class="fas fa-upload mr-1"></i> Upload Content</h5>
    </div>
    <div class="card-body">
        <form method="POST" action="{{ route('admin.contents.store') }}" enctype="multipart/form-data">
            @csrf
            <div class="form-group">
                <label>Title <span class="text-danger">*</span></label>
                <input type="text" class="form-control @error('title') is-invalid @enderror"
                    name="title" value="{{ old('title') }}" required>
                @error('title')<span class="invalid-feedback">{{ $message }}</span>@enderror
            </div>
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label>Type <span class="text-danger">*</span></label>
                    <select name="type" id="contentType" class="form-control @error('type') is-invalid @enderror" required>
                        <option value="">— Select Type —</option>
                        @foreach(['pdf','audio','video','image','text'] as $t)
                            <option value="{{ $t }}" {{ old('type') === $t ? 'selected' : '' }}>{{ strtoupper($t) }}</option>
                        @endforeach
                    </select>
                    @error('type')<span class="invalid-feedback">{{ $message }}</span>@enderror
                </div>
                <div class="form-group col-md-6">
                    <label>Category <span class="text-danger">*</span></label>
                    <select name="category_id" class="form-control @error('category_id') is-invalid @enderror" required>
                        <option value="">— Select Category —</option>
                        @foreach($categories as $cat)
                            <option value="{{ $cat->id }}" {{ old('category_id') == $cat->id ? 'selected' : '' }}>
                                {{ $cat->name }}
                            </option>
                        @endforeach
                    </select>
                    @error('category_id')<span class="invalid-feedback">{{ $message }}</span>@enderror
                </div>
            </div>
            <div class="form-group">
                <label>File Upload</label>
                <input type="file" class="form-control-file @error('file') is-invalid @enderror"
                    name="file" id="contentFile">
                <small class="text-muted">Max 50MB. Accepted types change based on content type selected.</small>
                @error('file')<span class="invalid-feedback d-block">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Thumbnail Image</label>
                <input type="file" class="form-control-file @error('image') is-invalid @enderror"
                    name="image" accept="image/*">
                @error('image')<span class="invalid-feedback d-block">{{ $message }}</span>@enderror
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="description" class="form-control" rows="3">{{ old('description') }}</textarea>
            </div>
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label>Author</label>
                    <input type="text" class="form-control" name="author" value="{{ old('author') }}">
                </div>
                <div class="form-group col-md-6">
                    <label>Edition Year</label>
                    <input type="number" class="form-control" name="edition_year" value="{{ old('edition_year') }}"
                        min="1800" max="{{ date('Y') }}">
                </div>
            </div>
            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                </select>
            </div>
            <button type="submit" class="btn" style="background:#FF6B00;color:#fff;">
                <i class="fas fa-upload mr-1"></i> Upload Content
            </button>
            <a href="{{ route('admin.contents.index') }}" class="btn btn-secondary ml-2">Cancel</a>
        </form>
    </div>
</div>
@endsection

@push('scripts')
<script>
document.getElementById('contentType').addEventListener('change', function () {
    const accepts = {
        pdf: '.pdf',
        audio: '.mp3,.wav,.ogg,.aac,.m4a',
        video: '.mp4,.mov,.avi,.mkv,.webm',
        image: 'image/*',
        text: '.txt,.doc,.docx'
    };
    document.getElementById('contentFile').accept = accepts[this.value] || '*';
});
</script>
@endpush
