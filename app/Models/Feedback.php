<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Feedback extends Model
{
    protected $fillable = ['user_id', 'type', 'value', 'is_read'];

    protected function casts(): array
    {
        return ['is_read' => 'boolean'];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
