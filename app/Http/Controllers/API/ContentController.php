<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Content;
use Illuminate\Http\Request;

class ContentController extends Controller
{
    public function index(Request $request)
    {
        $q = Content::with('category')->active();
        if ($request->category_id) $q->where('category_id', $request->category_id);
        if ($request->type) $q->where('type', $request->type);
        if ($request->filled('search')) {
            $s = $request->search;
            $q->where(fn($q) => $q->where('title', 'like', "%$s%")->orWhere('description', 'like', "%$s%"));
        }

        $contents = $q->orderByDesc('created_at')->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $contents->map(fn($c) => $this->format($c)),
            'pagination' => [
                'current_page' => $contents->currentPage(),
                'last_page' => $contents->lastPage(),
                'total' => $contents->total(),
            ]
        ]);
    }

    public function show($id)
    {
        $c = Content::with('category')->active()->findOrFail($id);
        $c->increment('download_count');
        return response()->json(['status' => 'success', 'data' => $this->format($c)]);
    }

    private function format($c): array
    {
        return [
            'id' => $c->id,
            'title' => $c->title,
            'type' => $c->type,
            'file_url' => $c->file_url,
            'image_url' => $c->image_url,
            'description' => $c->description,
            'author' => $c->author,
            'edition_year' => $c->edition_year,
            'download_count' => $c->download_count,
            'category' => ['id' => $c->category_id, 'name' => $c->category?->name],
        ];
    }
}
