@extends('layouts.admin')

@section('title', 'Contents')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="font-weight-bold" style="color:#FF6B00;">Content Library</h4>
    <a href="{{ route('admin.contents.create') }}" class="btn btn-sm" style="background:#FF6B00;color:#fff;">
        <i class="fas fa-upload mr-1"></i> Upload Content
    </a>
</div>

<div class="card">
    <div class="card-body p-0">
        <table class="table table-hover mb-0">
            <thead class="thead-light">
                <tr>
                    <th>Title</th>
                    <th>Type</th>
                    <th>Category</th>
                    <th>Author</th>
                    <th>Downloads</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($contents as $content)
                <tr>
                    <td>{{ Str::limit($content->title, 40) }}</td>
                    <td>
                        @php
                            $badges = ['pdf'=>'danger','audio'=>'primary','video'=>'purple','image'=>'success','text'=>'secondary'];
                            $badge = $badges[$content->type] ?? 'secondary';
                        @endphp
                        <span class="badge badge-{{ $badge }}">{{ strtoupper($content->type) }}</span>
                    </td>
                    <td>{{ $content->category->name ?? '—' }}</td>
                    <td>{{ $content->author ?? '—' }}</td>
                    <td>{{ $content->download_count ?? 0 }}</td>
                    <td>
                        @if($content->status === 'active')
                            <span class="badge badge-success">Active</span>
                        @else
                            <span class="badge badge-secondary">Inactive</span>
                        @endif
                    </td>
                    <td>
                        <a href="{{ route('admin.contents.edit', $content) }}" class="btn btn-xs btn-info mr-1">
                            <i class="fas fa-edit"></i>
                        </a>
                        <form method="POST" action="{{ route('admin.contents.destroy', $content) }}" class="d-inline"
                              onsubmit="return confirm('Delete this content?')">
                            @csrf @method('DELETE')
                            <button class="btn btn-xs btn-danger"><i class="fas fa-trash"></i></button>
                        </form>
                    </td>
                </tr>
                @empty
                <tr><td colspan="7" class="text-center text-muted py-3">No content uploaded yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    @if($contents->hasPages())
    <div class="card-footer">
        {{ $contents->links() }}
    </div>
    @endif
</div>
@endsection
