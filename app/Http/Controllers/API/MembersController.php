<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\MemberCategory;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MembersController extends Controller
{
    // GET /api/members
    public function index(Request $request)
    {
        $v = Validator::make($request->all(), [
            'category_id' => 'nullable|integer|exists:member_categories,id',
            'state'       => 'nullable|string|max:100',
            'district'    => 'nullable|string|max:100',
            'search'      => 'nullable|string|max:100',
            'per_page'    => 'nullable|integer|min:1|max:100',
        ]);
        if ($v->fails()) return $this->error($v->errors()->first());

        $query = User::query()
            ->where('status', 'active')
            ->where('profile_complete', true)
            ->with(['memberCategories:id,name,group', 'images' => fn($q) => $q->orderBy('sort_order')->limit(1)]);

        if ($request->filled('category_id')) {
            $query->whereHas('memberCategories', fn($q) => $q->where('member_categories.id', $request->category_id));
        }

        if ($request->filled('state')) {
            $query->where('state', 'like', '%' . $request->state . '%');
        }

        if ($request->filled('district')) {
            $query->where('district', 'like', '%' . $request->district . '%');
        }

        if ($request->filled('search')) {
            $s = $request->search;
            $query->where(fn($q) => $q->where('name', 'like', "%$s%")
                ->orWhere('username', 'like', "%$s%"));
        }

        $perPage = $request->input('per_page', 20);
        $members = $query->orderByDesc('id')->paginate($perPage);

        return response()->json([
            'status' => 'success',
            'data'   => $members->map(fn($u) => $this->formatCard($u)),
            'meta'   => [
                'current_page' => $members->currentPage(),
                'last_page'    => $members->lastPage(),
                'total'        => $members->total(),
            ],
        ]);
    }

    // GET /api/members/{id}
    public function show(Request $request, int $id)
    {
        $user = User::where('id', $id)
            ->where('status', 'active')
            ->where('profile_complete', true)
            ->with(['memberCategories:id,name,group', 'images'])
            ->firstOrFail();

        // Increment profile views
        $user->increment('profile_views');

        return $this->success($this->formatDetail($user));
    }

    // GET /api/member-categories
    public function categories()
    {
        $cats = MemberCategory::active()->orderBy('group')->orderBy('sort_order')->get();
        return $this->success($cats->map(fn($c) => [
            'id'    => $c->id,
            'name'  => $c->name,
            'slug'  => $c->slug,
            'group' => $c->group,
        ]));
    }

    private function formatCard(User $u): array
    {
        $firstImage = $u->images->first();
        return [
            'id'            => $u->id,
            'name'          => $u->name,
            'username'      => $u->username,
            'state'         => $u->state,
            'district'      => $u->district,
            'profile_image' => $u->profile_image ? asset('uploads/profiles/' . $u->profile_image) : null,
            'is_verified'   => $u->is_verified,
            'categories'    => $u->memberCategories->map(fn($c) => ['id' => $c->id, 'name' => $c->name]),
            'org_type'      => $u->org_type,
            'first_image'   => $firstImage ? $firstImage->image_url : null,
        ];
    }

    private function formatDetail(User $u): array
    {
        return [
            'id'            => $u->id,
            'name'          => $u->name,
            'username'      => $u->username,
            'mobile'        => $u->mobile,
            'gender'        => $u->gender,
            'dob'           => $u->dob?->format('Y-m-d'),
            'country'       => $u->country,
            'state'         => $u->state,
            'district'      => $u->district,
            'tehsil'        => $u->tehsil,
            'village'       => $u->village,
            'post_office'   => $u->post_office,
            'pincode'       => $u->pincode,
            'about'         => $u->about,
            'org_type'      => $u->org_type,
            'org_name'      => $u->org_name,
            'profile_image' => $u->profile_image ? asset('uploads/profiles/' . $u->profile_image) : null,
            'is_verified'   => $u->is_verified,
            'profile_views' => $u->profile_views,
            'categories'    => $u->memberCategories->map(fn($c) => ['id' => $c->id, 'name' => $c->name, 'group' => $c->group]),
            'images'        => $u->images->map(fn($i) => ['id' => $i->id, 'url' => $i->image_url]),
        ];
    }

    private function success($data = [], $message = 'Success', $code = 200)
    {
        return response()->json(['status' => 'success', 'message' => $message, 'data' => $data], $code);
    }

    private function error($message = 'Error', $code = 400)
    {
        return response()->json(['status' => 'error', 'message' => $message], $code);
    }
}
