<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Content;
use Illuminate\Http\Request;

class ContentController extends Controller
{
    public function index()
    {
        $contents = Content::with('category')->latest()->paginate(20);
        return view('admin.contents.index', compact('contents'));
    }

    public function create()
    {
        $categories = Category::active()->orderBy('name')->get();
        return view('admin.contents.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'title'       => 'required|string|max:200',
            'type'        => 'required|in:pdf,audio,video,image,text',
            'category_id' => 'required|exists:categories,id',
            'file'        => 'nullable|file|max:51200', // 50MB
            'image'       => 'nullable|image|max:2048',
        ]);
        $data = $request->only(['title', 'type', 'category_id', 'description', 'author', 'edition_year', 'status']);
        if ($request->hasFile('file')) {
            $folder = match($request->type) { 'pdf' => 'books', 'audio' => 'audio', 'video' => 'videos', default => 'images' };
            $data['file'] = $folder . '/' . $request->file('file')->store($folder, ['disk' => 'public_uploads']);
        }
        if ($request->hasFile('image')) {
            $data['image'] = 'images/' . $request->file('image')->store('images', ['disk' => 'public_uploads']);
        }
        Content::create($data);
        return redirect()->route('admin.contents.index')->with('success', 'Content uploaded!');
    }

    public function destroy(Content $content)
    {
        $content->delete();
        return back()->with('success', 'Content deleted.');
    }
}
