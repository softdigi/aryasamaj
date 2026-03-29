<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Content extends Model
{
    protected $fillable = [
        'title', 'type', 'file', 'image', 'category_id',
        'description', 'author', 'edition_year', 'download_count', 'status',
    ];

    protected function casts(): array
    {
        return ['download_count' => 'integer'];
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    // Full URL accessor for file
    public function getFileUrlAttribute(): ?string
    {
        return $this->file ? asset('uploads/' . $this->file) : null;
    }

    // Full URL accessor for image
    public function getImageUrlAttribute(): ?string
    {
        return $this->image ? asset('uploads/' . $this->image) : null;
    }

    public function scopeActive($q)
    {
        return $q->where('status', 'active');
    }
}
