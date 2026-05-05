<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Attendance extends Model
{
    use HasFactory;

    protected $primaryKey = 'attendance_id';

    protected $fillable = [
        'section_id',
        //'booking_id',
        'attendance_code',
        'geo_lat',
        'geo_long',
        'geo_radius',
        'time_validity',
    ];
}