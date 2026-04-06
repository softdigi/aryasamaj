<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Donation;
use App\Models\Feature;
use Illuminate\Support\Facades\Cache;

class HomeController extends Controller
{
    public function index()
    {
        $data = Cache::remember('home_data', 300, function () {
            return [
                'features_sangathan' => Feature::active()->where('section', 'sangathan')->orderBy('sort_order')->get(),
                'features_suvidha'   => Feature::active()->where('section', 'suvidha')->orderBy('sort_order')->get(),
                'top_categories'     => Category::whereNull('parent_id')->active()->orderBy('sort_order')->take(8)->get(),
                'donation'           => Donation::where('status', 'active')->first(),
            ];
        });

        return response()->json(['status' => 'success', 'data' => $data]);
    }
}

