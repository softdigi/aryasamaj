<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    protected $fillable = ['name', 'parent_id', 'type', 'icon', 'sort_order', 'status'];

    protected function casts(): array
    {
        return ['sort_order' => 'integer'];
    }

    // Parent category
    public function parent()
    {
        return $this->belongsTo(Category::class, 'parent_id');
    }

    // Direct children
    public function children()
    {
        return $this->hasMany(Category::class, 'parent_id');
    }

    // Recursive all children (for tree view)
    public function childrenRecursive()
    {
        return $this->children()->with('childrenRecursive');
    }

    // Contents in this category
    public function contents()
    {
        return $this->hasMany(Content::class);
    }

    // Scope: only active
    public function scopeActive($q)
    {
        return $q->where('status', 'active');
    }

    // Check if has children
    public function hasChildren(): bool
    {
        return $this->children()->exists();
    }
}
