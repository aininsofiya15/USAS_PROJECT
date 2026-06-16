<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ModuleAttendance extends Model

{

    protected $fillable = ['attendance_id', 'booking_id'];

    // Link back to the parent to get the GPS/Code info
    public function attendance()
    {
        return $this->belongsTo(Attendance::class, 'attendance_id');
    }


    // Link to the booking to know WHICH module this is for (e.g., Kayaking)
    public function booking()
    {
        return $this->belongsTo(Booking::class, 'booking_id');
    }

}