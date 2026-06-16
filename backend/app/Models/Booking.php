<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    // These are the fields for the booking record
    protected $fillable = [
        'student_id',
        'module_id',
        'attendance',
        'total_marks'
    ];

    // Relationship: A booking belongs to a specific module
    public function module()
    {   
        // Define the relationship to the module record
        return $this->belongsTo(Module::class, 'module_id');
    }

    // Relationship: A booking belongs to a specific student
    public function student()
    {
        // Define the relationship to the user record (student)
        return $this->belongsTo(User::class, 'student_id', 'id');
    }

    // Relationship: A booking has one attendance record
    public function user()
    {
        // Define the relationship to the user record (student)
        return $this->belongsTo(User::class, 'student_id');
    }
}