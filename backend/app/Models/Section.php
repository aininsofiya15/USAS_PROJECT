<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Section extends Model
{
    use HasFactory;

    protected $primaryKey = 'section_id';

    protected $fillable = [
        'subject_id',
        'lecturer_id',
        'semester_code',
        'section_name',
        'subject_code',
    ];
}