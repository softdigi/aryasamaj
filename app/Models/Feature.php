<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Feature extends Model
{
    protected $fillable = ['name', 'name_hindi', 'icon', 'route', 'section', 'sort_order', 'status'];

    protected function casts(): array
    {
        return ['sort_order' => 'integer'];
    }

    public function scopeActive($q)
    {
        return $q->where('status', 'active');
    }

    public function getIconUrlAttribute(): ?string
    {
        return $this->icon ? asset('uploads/images/' . $this->icon) : null;
    }
}
