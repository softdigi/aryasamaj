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
            'file'        => [
                'nullable',
                'file',
                'max:51200',
                'mimetypes:application/pdf,audio/mpeg,audio/mp4,audio/ogg,audio/wav,audio/webm,video/mp4,video/webm,video/ogg,image/jpeg,image/png,image/webp,image/gif',
            ],
            'image'       => 'nullable|image|mimes:jpeg,jpg,png,webp|max:2048',
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

    public function edit(Content $content)
    {
        $categories = Category::active()->orderBy('name')->get();
        return view('admin.contents.edit', compact('content', 'categories'));
    }

    public function update(Request $request, Content $content)
    {
        $request->validate([
            'title'       => 'required|string|max:200',
            'category_id' => 'required|exists:categories,id',
            'file'        => [
                'nullable',
                'file',
                'max:51200',
                'mimetypes:application/pdf,audio/mpeg,audio/mp4,audio/ogg,audio/wav,audio/webm,video/mp4,video/webm,video/ogg,image/jpeg,image/png,image/webp,image/gif',
            ],
            'image'       => 'nullable|image|mimes:jpeg,jpg,png,webp|max:2048',
        ]);
        $data = $request->only(['title', 'category_id', 'description', 'author', 'edition_year', 'status']);
        if ($request->hasFile('file')) {
            $folder = match($content->type) { 'pdf' => 'books', 'audio' => 'audio', 'video' => 'videos', default => 'images' };
            $data['file'] = $folder . '/' . $request->file('file')->store($folder, ['disk' => 'public_uploads']);
        }
        if ($request->hasFile('image')) {
            $data['image'] = 'images/' . $request->file('image')->store('images', ['disk' => 'public_uploads']);
        }
        $content->update($data);
        return redirect()->route('admin.contents.index')->with('success', 'Content updated!');
    }

    public function destroy(Content $content)
    {
        $content->delete();
        return back()->with('success', 'Content deleted.');
    }
}
