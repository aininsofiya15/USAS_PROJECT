<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AttendanceRecord extends Model
{
    // These are the fields for the attendance record
    protected $fillable = [
        'attendance_id', 
        'student_id', 
        'submitted_time', 
        'status', 
        'marks', 
        'grade_category'
    ];

    // Link back to the parent attendance to get the GPS/Code info
    public function attendance()
    {
        // Define the relationship to the attendance record
        return $this->belongsTo(Attendance::class, 'attendance_id');
    }

    // Links to the student profile to get their name and matric ID
    public function student()
    {
        // Define the relationship to the student record
        return $this->belongsTo(Student::class, 'student_id');
    }

    // Link to the booking to know WHICH module this is for
     public function booking() 
    {
        // Define the relationship to the booking record
         return $this->belongsTo(Booking::class, 'booking_id');
    }
}