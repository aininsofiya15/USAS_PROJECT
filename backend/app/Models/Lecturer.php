<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lecturer extends Model
{
    protected $fillable = [
        'lecturer_id',
        'faculty',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'lecturer_id');
    }
}