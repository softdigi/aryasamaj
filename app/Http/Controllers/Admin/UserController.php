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
        if ($request->filled('search')) {
            $search = $request->search;
            $q->where(function ($query) use ($search) {
                $query->where('mobile', 'like', '%' . $search . '%')
                      ->orWhere('name', 'like', '%' . $search . '%');
            });
        }
        $users = $q->latest()->paginate(25);
        return view('admin.users.index', compact('users'));
    }

    public function toggle(User $user)
    {
        $newStatus = $user->status === 'active' ? 'blocked' : 'active';
        $user->forceFill(['status' => $newStatus])->save();
        return back()->with('success', 'User status updated.');
    }
}
