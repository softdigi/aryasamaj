<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $parentId = $request->get('parent_id'); // null = root categories

        $cats = Category::where('parent_id', $parentId)
            ->active()
            ->orderBy('sort_order')
            ->get();

        $result = $cats->map(fn($c) => [
            'id'        => $c->id,
            'name'      => $c->name,
            'type'      => $c->type,
            'icon'      => $c->icon ? asset('uploads/categories/' . $c->icon) : null,
            'has_child' => $c->children()->active()->exists(),
        ]);

        return response()->json(['status' => 'success', 'data' => $result]);
    }
}
