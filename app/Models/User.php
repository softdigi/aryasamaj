<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'mobile',
        'email',
        'password',
        'is_admin',
        'status',
        'profile_image',
        'username',
        'gender',
        'dob',
        'country',
        'state',
        'district',
        'tehsil',
        'village',
        'post_office',
        'pincode',
        'about',
        'org_type',
        'org_name',
        'profile_complete',
        'is_verified',
        'profile_views',
        'fcm_token',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'is_admin' => 'boolean',
            'profile_complete' => 'boolean',
            'is_verified' => 'boolean',
            'dob' => 'date',
        ];
    }

    public function feedback()
    {
        return $this->hasMany(Feedback::class);
    }

    public function memberCategories()
    {
        return $this->belongsToMany(MemberCategory::class, 'user_member_categories');
    }

    public function images()
    {
        return $this->hasMany(UserImage::class)->orderBy('sort_order');
    }

    /**
     * Eager-load the single first image per user using a subquery join.
     * Produces 2 queries total (one for users, one for first images) instead of N+1.
     */
    public function scopeWithFirstImage($query)
    {
        $firstImageSub = \DB::table('user_images')
            ->select('user_id', \DB::raw('MIN(id) as first_image_id'))
            ->groupBy('user_id');

        $query->leftJoinSub($firstImageSub, 'fi', 'fi.user_id', '=', 'users.id')
              ->leftJoin('user_images as ui_first', 'ui_first.id', '=', 'fi.first_image_id')
              ->addSelect('users.*', 'ui_first.id as _fi_id');
    }

    /**
     * Returns the first-image URL resolved via the subquery join columns,
     * or falls back to the loaded images collection.
     */
    public function getFirstImageUrlAttribute(): ?string
    {
        if (isset($this->attributes['_fi_id']) && $this->attributes['_fi_id']) {
            return url('/api/files/user-image/' . $this->attributes['_fi_id']);
        }
        $first = $this->images->first();
        return $first ? $first->image_url : null;
    }
}

