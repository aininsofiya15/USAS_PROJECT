<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'lecturer_id',
        'subject_code',
        'section_name',
        'class_type',
        'class_date',
        'class_time',
        'latitude',
        'longitude',
        'generated_code',
    ];
}