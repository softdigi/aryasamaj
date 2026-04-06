<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Content;
use App\Models\User;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    /**
     * GET /api/search?q=...&type=all|content|category|member
     */
    public function search(Request $request)
    {
        $q = trim($request->get('q', ''));
        if (mb_strlen($q) < 2) {
            return response()->json(['status' => 'error', 'message' => 'कम से कम 2 अक्षर लिखें'], 422);
        }

        $type = $request->get('type', 'all');

        $contents   = [];
        $categories = [];
        $members    = [];

        if (in_array($type, ['all', 'content'])) {
            $contents = Content::active()
                ->where(fn($qb) => $qb->where('title', 'like', "%$q%")->orWhere('description', 'like', "%$q%"))
                ->orderByDesc('created_at')
                ->limit(20)
                ->get()
                ->map(fn($c) => [
                    'type'        => 'content',
                    'id'          => $c->id,
                    'title'       => $c->title,
                    'content_type' => $c->type,
                    'image_url'   => $c->image_url,
                    'author'      => $c->author,
                ]);
        }

        if (in_array($type, ['all', 'category'])) {
            $categories = Category::active()
                ->where('name', 'like', "%$q%")
                ->orderBy('sort_order')
                ->limit(10)
                ->get()
                ->map(fn($c) => [
                    'type'      => 'category',
                    'id'        => $c->id,
                    'title'     => $c->name,
                    'has_child' => $c->children()->active()->exists(),
                ]);
        }

        if (in_array($type, ['all', 'member'])) {
            $members = User::where('status', 'active')
                ->where('profile_complete', true)
                ->where(fn($qb) => $qb->where('name', 'like', "%$q%")->orWhere('username', 'like', "%$q%"))
                ->orderByDesc('id')
                ->limit(20)
                ->get()
                ->map(fn($u) => [
                    'type'          => 'member',
                    'id'            => $u->id,
                    'title'         => $u->name,
                    'username'      => $u->username,
                    'state'         => $u->state,
                    'district'      => $u->district,
                    'profile_image' => $u->profile_image ? url('/api/files/profile/' . $u->id) : null,
                ]);
        }

        return response()->json([
            'status' => 'success',
            'data'   => [
                'contents'   => $contents,
                'categories' => $categories,
                'members'    => $members,
            ],
            'total' => count($contents) + count($categories) + count($members),
        ]);
    }
}
