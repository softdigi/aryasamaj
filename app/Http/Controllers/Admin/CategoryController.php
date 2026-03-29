<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index()
    {
        $cats = Category::with('childrenRecursive')->orderBy('sort_order')->get();
        return view('admin.categories.index', compact('cats'));
    }

    public function create()
    {
        $parents = Category::active()->orderBy('name')->get();
        return view('admin.categories.create', compact('parents'));
    }

    public function store(Request $request)
    {
        $request->validate(['name' => 'required|string|max:150', 'sort_order' => 'integer']);
        $data = $request->only(['name', 'parent_id', 'type', 'sort_order', 'status']);
        if ($request->hasFile('icon')) {
            $data['icon'] = $request->file('icon')->store('categories', 'public_uploads');
        }
        Category::create($data);
        return redirect()->route('admin.categories.index')->with('success', 'Category created!');
    }

    public function edit(Category $category)
    {
        $parents = Category::where('id', '!=', $category->id)->active()->get();
        return view('admin.categories.edit', compact('category', 'parents'));
    }

    public function update(Request $request, Category $category)
    {
        $data = $request->only(['name', 'parent_id', 'type', 'sort_order', 'status']);
        if ($request->hasFile('icon')) {
            $data['icon'] = $request->file('icon')->store('categories', 'public_uploads');
        }
        $category->update($data);
        return redirect()->route('admin.categories.index')->with('success', 'Category updated!');
    }

    public function destroy(Category $category)
    {
        if ($category->hasChildren()) {
            return back()->with('error', 'Cannot delete: category has sub-categories.');
        }
        $category->delete();
        return back()->with('success', 'Category deleted.');
    }
}
