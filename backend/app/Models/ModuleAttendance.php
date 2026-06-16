<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ModuleAttendance extends Model

{

    // These are the fields for the module attendance record
    protected $fillable = ['attendance_id', 'booking_id'];

    // Link back to the parent to get the GPS/Code info
    public function attendance()
    {
        // Define the relationship to the attendance record
        return $this->belongsTo(Attendance::class, 'attendance_id');
    }


    // Link to the booking to know WHICH module this is for (e.g., Kayaking)
    public function booking()
    {
        // Define the relationship to the booking record
        return $this->belongsTo(Booking::class, 'booking_id');
    }

}