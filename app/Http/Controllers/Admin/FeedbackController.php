<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Feedback;

class FeedbackController extends Controller
{
    public function index()
    {
        $feedbacks = Feedback::with('user')->latest()->paginate(30);
        Feedback::where('is_read', 0)->update(['is_read' => 1]);
        return view('admin.feedback.index', compact('feedbacks'));
    }
}
