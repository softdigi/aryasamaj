<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Feature;
use Illuminate\Http\Request;

class FeatureController extends Controller
{
    public function index(Request $request)
    {
        $q = Feature::active()->orderBy('sort_order');
        if ($request->section) $q->where('section', $request->section);
        return response()->json(['status' => 'success', 'data' => $q->get()]);
    }
}
