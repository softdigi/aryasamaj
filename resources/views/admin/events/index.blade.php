@extends('layouts.admin')

@section('title', 'Events')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="font-weight-bold" style="color:#FF6B00;">Events</h4>
    <a href="{{ route('admin.events.create') }}" class="btn btn-sm" style="background:#FF6B00;color:#fff;">
        <i class="fas fa-plus mr-1"></i> Add Event
    </a>
</div>

<div class="card">
    <div class="card-body p-0">
        <table class="table table-hover mb-0">
            <thead class="thead-light">
                <tr>
                    <th>Image</th>
                    <th>Title</th>
                    <th>Event Date</th>
                    <th>Location</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($events as $event)
                <tr>
                    <td>
                        @if($event->image)
                            <img src="{{ asset('uploads/events/' . $event->image) }}" alt="Event"
                                style="height:48px;width:72px;object-fit:cover;border-radius:4px;border:1px solid #ddd;">
                        @else
                            <span class="text-muted">—</span>
                        @endif
                    </td>
                    <td>{{ $event->title }}</td>
                    <td>{{ $event->event_date?->format('d M Y, h:i A') }}</td>
                    <td>{{ $event->location ?? '—' }}</td>
                    <td>
                        @if($event->status === 'upcoming')
                            <span class="badge badge-success">Upcoming</span>
                        @elseif($event->status === 'past')
                            <span class="badge badge-secondary">Past</span>
                        @else
                            <span class="badge badge-warning">Draft</span>
                        @endif
                    </td>
                    <td>
                        <a href="{{ route('admin.events.edit', $event) }}" class="btn btn-xs btn-info mr-1">
                            <i class="fas fa-edit"></i>
                        </a>
                        <form method="POST" action="{{ route('admin.events.destroy', $event) }}" class="d-inline"
                            onsubmit="return confirm('Delete this event?')">
                            @csrf @method('DELETE')
                            <button class="btn btn-xs btn-danger"><i class="fas fa-trash"></i></button>
                        </form>
                    </td>
                </tr>
                @empty
                <tr><td colspan="6" class="text-center text-muted py-4">No events yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
    @if($events->hasPages())
    <div class="card-footer">{{ $events->links() }}</div>
    @endif
</div>
@endsection
