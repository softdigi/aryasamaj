<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Content;
use App\Models\Feedback;
use App\Models\User;

class DashboardController extends Controller
{
    public function index()
    {
        return view('admin.dashboard', [
            'totalUsers'     => User::where('is_admin', 0)->count(),
            'totalCategories'=> Category::count(),
            'totalContents'  => Content::count(),
            'totalFeedback'  => Feedback::count(),
            'unreadFeedback' => Feedback::where('is_read', 0)->count(),
            'recentUsers'    => User::where('is_admin', 0)->latest()->take(5)->get(),
            'recentFeedback' => Feedback::with('user')->latest()->take(5)->get(),
        ]);
    }
}
