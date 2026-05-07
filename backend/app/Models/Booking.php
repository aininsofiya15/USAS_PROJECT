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
}