<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OtpLog extends Model
{
    protected $fillable = ['mobile', 'otp', 'expires_at', 'is_used'];

    protected function casts(): array
    {
        return [
            'expires_at' => 'datetime',
            'is_used' => 'boolean',
        ];
    }

    public $timestamps = false;

    protected $dates = ['created_at'];

    const CREATED_AT = 'created_at';
    const UPDATED_AT = null;
}
