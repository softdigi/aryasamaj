<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Feature;
use Illuminate\Http\Request;

class FeatureController extends Controller
{
    public function index()
    {
        $features = Feature::orderBy('sort_order')->get();
        return view('admin.features.index', compact('features'));
    }

    public function create()
    {
        return view('admin.features.create');
    }

    public function store(Request $request)
    {
        $request->validate(['name' => 'required', 'route' => 'required|unique:features']);
        Feature::create($request->only(['name', 'name_hindi', 'icon', 'route', 'section', 'sort_order', 'status']));
        return redirect()->route('admin.features.index')->with('success', 'Feature added!');
    }

    public function edit(Feature $feature)
    {
        return view('admin.features.edit', compact('feature'));
    }

    public function update(Request $request, Feature $feature)
    {
        $request->validate([
            'name'  => 'required',
            'route' => 'required|unique:features,route,' . $feature->id,
        ]);
        $data = $request->only(['name', 'name_hindi', 'route', 'section', 'sort_order', 'status']);
        if ($request->hasFile('icon')) {
            $data['icon'] = $request->file('icon')->store('icons', ['disk' => 'public_uploads']);
        }
        $feature->update($data);
        return redirect()->route('admin.features.index')->with('success', 'Feature updated!');
    }

    public function toggle(Feature $feature)
    {
        $feature->update(['status' => $feature->status === 'active' ? 'inactive' : 'active']);
        return back()->with('success', 'Feature status updated.');
    }

    public function updateOrder(Request $request)
    {
        foreach ($request->order as $index => $id) {
            Feature::where('id', $id)->update(['sort_order' => $index + 1]);
        }
        return response()->json(['status' => 'success']);
    }
}
