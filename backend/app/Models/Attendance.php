<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use app\Models\ModuleAttendance;

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

    public function moduleAttendance() 
    {
        return $this->hasOne(ModuleAttendance::class, 'attendance_id');
    }

    public function records() 
    {
        return $this->hasMany(AttendanceRecord::class, 'attendance_id');
    }   
}