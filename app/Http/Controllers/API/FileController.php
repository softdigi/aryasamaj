<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserImage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FileController extends Controller
{
    /**
     * GET /api/files/profile/{userId}
     * Serve a user's profile image (auth required).
     */
    public function profileImage(Request $request, int $userId)
    {
        $user = User::findOrFail($userId);

        if (!$user->profile_image) {
            abort(404);
        }

        $path = 'profiles/' . $user->profile_image;

        if (!Storage::disk('private_uploads')->exists($path)) {
            abort(404);
        }

        return Storage::disk('private_uploads')->response($path);
    }

    /**
     * GET /api/files/user-image/{id}
     * Serve a user gallery image (auth required).
     */
    public function userImage(Request $request, int $id)
    {
        $image = UserImage::findOrFail($id);

        $path = 'user-images/' . $image->image_path;

        if (!Storage::disk('private_uploads')->exists($path)) {
            abort(404);
        }

        return Storage::disk('private_uploads')->response($path);
    }
}
