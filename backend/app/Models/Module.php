<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Module extends Model
{
    // These are the fields for the module record
    use HasFactory;

    protected $fillable = [
        'activity_name',
        'date_time',
        'capacity',
        'venue',
        'lecturer_name',
        'description',
        'whatsapp_link',
        'pic_contact',
        'status',
        'current_registration',
    ];

    public function attendanceRecords() {
        // Define the relationship to the attendance records for this module
        return $this->hasMany(AttendanceRecord::class);
    }

}