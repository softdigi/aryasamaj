<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index()
    {
        return view('admin.events.index', ['events' => Event::orderByDesc('event_date')->paginate(20)]);
    }

    public function create()
    {
        return view('admin.events.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title'      => 'required|string|max:200',
            'description' => 'nullable|string',
            'event_date' => 'required|date',
            'location'   => 'nullable|string|max:200',
            'image'      => 'nullable|image|mimes:jpeg,jpg,png,webp|max:2048',
            'status'     => 'required|in:upcoming,past,draft',
        ]);

        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $name = time() . '_' . $file->getClientOriginalName();
            $file->move(public_path('uploads/events'), $name);
            $data['image'] = $name;
        }

        Event::create($data);
        return redirect()->route('admin.events.index')->with('success', 'Event created!');
    }

    public function edit(Event $event)
    {
        return view('admin.events.edit', compact('event'));
    }

    public function update(Request $request, Event $event)
    {
        $data = $request->validate([
            'title'       => 'required|string|max:200',
            'description' => 'nullable|string',
            'event_date'  => 'required|date',
            'location'    => 'nullable|string|max:200',
            'image'       => 'nullable|image|mimes:jpeg,jpg,png,webp|max:2048',
            'status'      => 'required|in:upcoming,past,draft',
        ]);

        if ($request->hasFile('image')) {
            if ($event->image) @unlink(public_path('uploads/events/' . $event->image));
            $file = $request->file('image');
            $name = time() . '_' . $file->getClientOriginalName();
            $file->move(public_path('uploads/events'), $name);
            $data['image'] = $name;
        }

        $event->update($data);
        return redirect()->route('admin.events.index')->with('success', 'Event updated!');
    }

    public function destroy(Event $event)
    {
        if ($event->image) @unlink(public_path('uploads/events/' . $event->image));
        $event->delete();
        return redirect()->route('admin.events.index')->with('success', 'Event deleted!');
    }
}
