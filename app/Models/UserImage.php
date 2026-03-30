<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserImage extends Model
{
    protected $fillable = ['user_id', 'image_path', 'sort_order'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function getImageUrlAttribute(): string
    {
        return asset('uploads/user-images/' . $this->image_path);
    }
}
