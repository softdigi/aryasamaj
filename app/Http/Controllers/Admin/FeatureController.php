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
