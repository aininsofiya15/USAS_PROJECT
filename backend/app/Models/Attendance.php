<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    protected $table = 'attendances';

    protected $fillable = [
        'attendance_code',
        'geo_lat',
        'geo_long',
        'geo_radius',
        'date',
        'time',
    ];


    public function attendanceRecords()
    {
        return $this->hasMany(AttendanceRecord::class, 'attendance_id');
    }
}