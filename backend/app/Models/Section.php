<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Section extends Model
{
    use HasFactory;

    protected $fillable = [
        'semester_code',
        'section_name',
        'subject_code', // <-- Updated
        'lecturer_id',
    ];

    // --- Relationships ---
    public function subject()
    {
        // belongsTo(Model, foreign_key, owner_key)
        return $this->belongsTo(Subject::class, 'subject_code', 'subject_code');
    }

    public function lecturer()
    {
        return $this->belongsTo(Lecturer::class, 'lecturer_id', 'lecturer_id');
    }
}