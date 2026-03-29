<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Feedback;
use Illuminate\Http\Request;

class FeedbackController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'type' => 'required|in:suggestion,bug,praise,other',
            'value' => 'required|string|min:5|max:1000',
        ]);
        Feedback::create([
            'user_id' => $request->user()?->id,
            'type' => $request->type,
            'value' => $request->value,
        ]);
        return response()->json(['status' => 'success', 'message' => 'Feedback submitted. Thank you!']);
    }
}
