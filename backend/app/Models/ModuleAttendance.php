<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ModuleAttendance extends Model
{
    protected $fillable = [
        'booking_id',
    ];

    public function attendance()
    {
        return $this->belongsTo(Attendance::class, 'attendance_id');
    }
}
