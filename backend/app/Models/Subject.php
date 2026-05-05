<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subject extends Model
{
    use HasFactory;

    protected $primaryKey = 'subject_id';

    protected $fillable = [
        'subject_code',
        'subject_name',
        'credit_hours',
        'total_section',
        'total_lab',
        'subject_status',
        'created_by',
    ];

    // --- Relationships ---

    // A subject can have many Sections (e.g., Section 01, Section 02)
    public function sections()
    {
        return $this->hasMany(Section::class);
    }
}