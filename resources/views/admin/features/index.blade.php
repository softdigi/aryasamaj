@extends('layouts.admin')

@section('title', 'Features')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="font-weight-bold" style="color:#FF6B00;">Feature Management</h4>
    <a href="{{ route('admin.features.create') }}" class="btn btn-sm" style="background:#FF6B00;color:#fff;">
        <i class="fas fa-plus mr-1"></i> Add Feature
    </a>
</div>

<div class="card">
    <div class="card-body p-0">
        <table class="table table-hover mb-0" id="featureTable">
            <thead class="thead-light">
                <tr>
                    <th style="width:30px;"></th>
                    <th>Name</th>
                    <th>Hindi Name</th>
                    <th>Section</th>
                    <th>Route</th>
                    <th>Status</th>
                    <th>Sort</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="sortableBody">
                @forelse($features as $feature)
                <tr data-id="{{ $feature->id }}">
                    <td><i class="fas fa-grip-vertical text-muted" style="cursor:grab;"></i></td>
                    <td>{{ $feature->name }}</td>
                    <td>{{ $feature->name_hindi ?? '—' }}</td>
                    <td><span class="badge badge-light">{{ $feature->section ?? '—' }}</span></td>
                    <td><code>{{ $feature->route }}</code></td>
                    <td>
                        @if($feature->status === 'active')
                            <span class="badge badge-success">Active</span>
                        @else
                            <span class="badge badge-secondary">Inactive</span>
                        @endif
                    </td>
                    <td>{{ $feature->sort_order }}</td>
                    <td>
                        <form method="POST" action="{{ route('admin.features.toggle', $feature) }}" class="d-inline">
                            @csrf
                            <button class="btn btn-xs {{ $feature->status === 'active' ? 'btn-warning' : 'btn-success' }}">
                                {{ $feature->status === 'active' ? 'Disable' : 'Enable' }}
                            </button>
                        </form>
                    </td>
                </tr>
                @empty
                <tr><td colspan="8" class="text-center text-muted py-3">No features yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/Sortable.min.js"></script>
<script>
const el = document.getElementById('sortableBody');
if (el) {
    Sortable.create(el, {
        handle: '.fa-grip-vertical',
        animation: 150,
        onEnd: function () {
            const order = [...el.querySelectorAll('tr[data-id]')].map(tr => tr.dataset.id);
            fetch('{{ route('admin.features.order') }}', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
                },
                body: JSON.stringify({ order })
            });
        }
    });
}
</script>
@endpush
