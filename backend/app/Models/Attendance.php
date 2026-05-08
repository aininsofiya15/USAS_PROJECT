<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    protected $table = 'attendances';

    protected $fillable = [
        'section_id',
        'attendance_code',
        'geo_lat',
        'geo_long',
        'geo_radius',
        'date',
        'time',
    ];

    public function section()
    {
        return $this->belongsTo(Section::class, 'section_id', 'section_id');
    }

    public function attendanceRecords()
    {
        return $this->hasMany(AttendanceRecord::class, 'attendance_id');
    }
}