<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    use HasFactory;

    protected $primaryKey = 'student_id';

    protected $fillable = [
        'user_id',
        'faculty',
        'course_name',
        'current_semester',
        'year',
    ];

    /**
     * A student belongs to one User account.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'id');
    }

    /**
     * A student has many Attendance Records.
     * (Added based on your ERD)
     */
    public function attendanceRecords()
    {
        return $this->hasMany(AttendanceRecord::class, 'student_id', 'student_id');
    }
}