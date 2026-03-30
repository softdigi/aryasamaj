<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MemberCategory extends Model
{
    protected $fillable = ['name', 'slug', 'group', 'sort_order', 'status'];

    public function users()
    {
        return $this->belongsToMany(User::class, 'user_member_categories');
    }

    public function scopeActive($q)
    {
        return $q->where('status', 'active');
    }

    public function scopeRoles($q)
    {
        return $q->where('group', 'role');
    }

    public function scopeOrgs($q)
    {
        return $q->where('group', 'org');
    }
}
