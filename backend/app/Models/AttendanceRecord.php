<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AttendanceRecord extends Model
{
    // These are the fields you will be managing for grading
    protected $fillable = [
        'attendance_id', 
        'student_id', 
        'submitted_time', 
        'status', 
        'marks', 
        'grade_category'
    ];

    // This allows you to pull Student name and Matric ID easily
    public function attendance()
    {
        return $this->belongsTo(Attendance::class, 'attendance_id');
    }

    // Links to the student profile to get their name and matric ID
    public function student()
    {
        return $this->belongsTo(Student::class, 'student_id');
    }

     public function booking() 
    {
         return $this->belongsTo(Booking::class, 'booking_id');
    }
}