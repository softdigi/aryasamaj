<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\MemberCategory;
use App\Models\User;
use App\Models\UserImage;
use App\Services\ImageResizeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class ProfileController extends Controller
{
    private ImageResizeService $imageService;

    public function __construct(ImageResizeService $imageService)
    {
        $this->imageService = $imageService;
    }
    // POST /api/save-profile  (Step 1 + Step 2)
    public function saveProfile(Request $request)
    {
        $v = Validator::make($request->all(), [
            'name'         => 'required|string|max:100',
            'username'     => 'required|string|max:80|alpha_dash|unique:users,username,' . $request->user()->id,
            'gender'       => 'required|in:male,female,other',
            'dob'          => 'required|date|before:today',
            'country'      => 'required|string|max:80',
            'state'        => 'required|string|max:100',
            'district'     => 'required|string|max:100',
            'tehsil'       => 'nullable|string|max:100',
            'village'      => 'nullable|string|max:150',
            'post_office'  => 'nullable|string|max:100',
            'pincode'      => 'nullable|string|max:10',
            'profile_image' => 'nullable|image|mimes:jpeg,jpg,png,webp|max:2048',
        ]);
        if ($v->fails()) return $this->error($v->errors()->first());

        $user = $request->user();
        $data = $request->only([
            'name', 'username', 'gender', 'dob',
            'country', 'state', 'district', 'tehsil',
            'village', 'post_office', 'pincode',
        ]);

        if ($request->hasFile('profile_image')) {
            $file = $request->file('profile_image');
            $baseName = 'profile_' . $user->id . '_' . time();
            if ($user->profile_image) {
                Storage::disk('private_uploads')->delete('profiles/' . $user->profile_image);
            }
            $filename = $this->imageService->resizeProfile($file, 'private_uploads', 'profiles', $baseName);
            $data['profile_image'] = $filename;
        }

        $user->update($data);

        return $this->success($this->formatUser($user), 'Profile saved');
    }

    // POST /api/save-categories  (Step 3)
    public function saveCategories(Request $request)
    {
        $v = Validator::make($request->all(), [
            'category_ids'   => 'required|array|min:1',
            'category_ids.*' => 'integer|exists:member_categories,id',
            'org_type'       => 'nullable|string|max:100',
            'org_name'       => 'nullable|string|max:150',
        ]);
        if ($v->fails()) return $this->error($v->errors()->first());

        $user = $request->user();
        $user->memberCategories()->sync($request->category_ids);
        $user->update([
            'org_type' => $request->org_type,
            'org_name' => $request->org_name,
        ]);

        return $this->success([], 'Categories saved');
    }

    // POST /api/save-about  (Step 4)
    public function saveAbout(Request $request)
    {
        $v = Validator::make($request->all(), [
            'about' => 'required|string|max:6000',
        ]);
        if ($v->fails()) return $this->error($v->errors()->first());

        $request->user()->update(['about' => $request->about]);

        return $this->success([], 'About saved');
    }

    // POST /api/upload-images  (Step 5)
    public function uploadImages(Request $request)
    {
        $v = Validator::make($request->all(), [
            'images'   => 'required|array|min:1|max:10',
            'images.*' => 'image|mimes:jpeg,jpg,png,webp|max:3072',
        ]);
        if ($v->fails()) return $this->error($v->errors()->first());

        $user = $request->user();
        $saved = [];

        foreach ($request->file('images') as $idx => $file) {
            $baseName = 'user_' . $user->id . '_' . time() . '_' . $idx;
            $result = $this->imageService->resizeGallery($file, 'private_uploads', 'user-images', $baseName);
            $img = UserImage::create([
                'user_id'    => $user->id,
                'image_path' => $result['main'],
                'sort_order' => $user->images()->count() + $idx,
            ]);
            $saved[] = ['id' => $img->id, 'url' => url('/api/files/user-image/' . $img->id)];
        }

        // Mark profile complete after images step
        $user->update(['profile_complete' => true]);

        return $this->success(['images' => $saved], 'Images uploaded');
    }

    // DELETE /api/delete-image/{id}
    public function deleteImage(Request $request, int $id)
    {
        $image = UserImage::where('id', $id)->where('user_id', $request->user()->id)->firstOrFail();
        Storage::disk('private_uploads')->delete('user-images/' . $image->image_path);
        $image->delete();
        return $this->success([], 'Image deleted');
    }

    // GET /api/my-profile
    public function myProfile(Request $request)
    {
        $user = $request->user()->load(['memberCategories', 'images']);
        return $this->success($this->formatUser($user, true));
    }

    // POST /api/user/fcm-token
    public function updateFcmToken(Request $request)
    {
        $v = Validator::make($request->all(), [
            'fcm_token' => 'nullable|string|max:255',
        ]);
        if ($v->fails()) return $this->error($v->errors()->first());

        $request->user()->update(['fcm_token' => $request->fcm_token]);

        return $this->success([], 'FCM token updated');
    }

    private function formatUser(User $user, bool $full = false): array
    {
        $data = [
            'id'               => $user->id,
            'name'             => $user->name,
            'username'         => $user->username,
            'mobile'           => $user->mobile,
            'gender'           => $user->gender,
            'dob'              => $user->dob?->format('Y-m-d'),
            'country'          => $user->country,
            'state'            => $user->state,
            'district'         => $user->district,
            'tehsil'           => $user->tehsil,
            'village'          => $user->village,
            'post_office'      => $user->post_office,
            'pincode'          => $user->pincode,
            'org_type'         => $user->org_type,
            'org_name'         => $user->org_name,
            'profile_image'    => $user->profile_image ? url('/api/files/profile/' . $user->id) : null,
            'is_verified'      => $user->is_verified,
            'profile_complete' => $user->profile_complete,
        ];

        if ($full) {
            $data['about']      = $user->about;
            $data['categories'] = $user->memberCategories->map(fn($c) => ['id' => $c->id, 'name' => $c->name, 'group' => $c->group]);
            $data['images']     = $user->images->map(fn($i) => ['id' => $i->id, 'url' => url('/api/files/user-image/' . $i->id)]);
        }

        return $data;
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
