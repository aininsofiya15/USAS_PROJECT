<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    protected $fillable = [
        'student_id',
        'faculty',
        'course_name',
        'current_semester',
        'year',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}