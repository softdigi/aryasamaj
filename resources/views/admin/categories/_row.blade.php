<tr>
    <td>
        @for($i = 0; $i < $depth; $i++) &nbsp;&nbsp;&nbsp; @endfor
        @if($depth > 0) <span class="text-muted">└─</span> @endif
        {{ $cat->name }}
    </td>
    <td><span class="badge badge-light">{{ $cat->type ?? '—' }}</span></td>
    <td>
        @if($cat->icon)
            <img src="{{ asset('uploads/' . $cat->icon) }}" alt="icon" style="height:28px;width:28px;object-fit:cover;border-radius:4px;">
        @else
            <span class="text-muted">—</span>
        @endif
    </td>
    <td>
        @if($cat->status === 'active')
            <span class="badge badge-success">Active</span>
        @else
            <span class="badge badge-secondary">Inactive</span>
        @endif
    </td>
    <td>{{ $cat->sort_order }}</td>
    <td>
        <a href="{{ route('admin.categories.edit', $cat) }}" class="btn btn-xs btn-info">
            <i class="fas fa-edit"></i>
        </a>
        <form method="POST" action="{{ route('admin.categories.destroy', $cat) }}" class="d-inline"
              onsubmit="return confirm('Delete category: {{ addslashes($cat->name) }}?')">
            @csrf @method('DELETE')
            <button class="btn btn-xs btn-danger"><i class="fas fa-trash"></i></button>
        </form>
    </td>
</tr>
@foreach($cat->childrenRecursive as $child)
    @include('admin.categories._row', ['cat' => $child, 'depth' => $depth + 1])
@endforeach
