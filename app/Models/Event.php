<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    protected $fillable = ['title', 'description', 'event_date', 'location', 'image', 'status'];

    protected function casts(): array
    {
        return ['event_date' => 'datetime'];
    }

    public function getImageUrlAttribute(): ?string
    {
        return $this->image ? asset('uploads/events/' . $this->image) : null;
    }

    public function scopePublished($q)
    {
        return $q->whereIn('status', ['upcoming', 'past']);
    }
}
