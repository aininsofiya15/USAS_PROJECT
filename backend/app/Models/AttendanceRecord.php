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
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function attendance(): BelongsTo
    {
        return $this->belongsTo(Attendance::class);
    }

     public function booking() 
    {
         return $this->belongsTo(Booking::class, 'booking_id');
    }
}