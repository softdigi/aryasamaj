<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $q = User::where('is_admin', 0);
        if ($request->search) {
            $q->where('mobile', 'like', '%' . $request->search . '%')
              ->orWhere('name', 'like', '%' . $request->search . '%');
        }
        $users = $q->latest()->paginate(25);
        return view('admin.users.index', compact('users'));
    }

    public function toggle(User $user)
    {
        $user->update(['status' => $user->status === 'active' ? 'blocked' : 'active']);
        return back()->with('success', 'User status updated.');
    }
}
