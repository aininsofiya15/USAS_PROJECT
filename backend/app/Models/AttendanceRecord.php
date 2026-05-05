<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class AttendanceRecord extends Model
{
    use HasFactory;

    protected $primaryKey = 'attendanceRecord_id';

    protected $fillable = [
        'attendance_id',
        'student_id',
        'submitted_time',
        'status',
        'marks',
        'grade_category',
    ];
}