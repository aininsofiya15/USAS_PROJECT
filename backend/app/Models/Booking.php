<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    // Allow mass assignment for these fields
    protected $fillable = [
        'student_id',
        'module_id',
        'attendance',
        'total_marks'
    ];

    // Relationship: A booking belongs to a specific module
    public function module()
    {
        return $this->belongsTo(Module::class, 'module_id');
    }

    public function student()
    {
        return $this->belongsTo(User::class, 'student_id', 'id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}