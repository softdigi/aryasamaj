<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Donation extends Model
{
    protected $fillable = [
        'type', 'account_name', 'account_number',
        'ifsc_code', 'upi_id', 'image', 'description', 'status',
    ];

    public function getImageUrlAttribute(): ?string
    {
        return $this->image ? asset('uploads/donations/' . $this->image) : null;
    }
}
