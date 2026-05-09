<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClassAttendance extends Model
{
    protected $fillable = [
        'section_id',
        'class_type',
        'date',
        'time',
    ];

    public function section()
    {
        return $this->belongsTo(Section::class, 'section_id', 'section_id');
    }
}
