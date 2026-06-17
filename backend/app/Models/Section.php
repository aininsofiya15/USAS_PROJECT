<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Registration;
use App\Models\Lab;

class Section extends Model
{
    // Primary key for sections table
    protected $primaryKey = 'section_id';

    // Fields allowed for mass assignment
    protected $fillable = [

        'lecturer_id',
        'subject_id',
        'section_no',
    ];

    // Relationship: Section belongs to a lecturer
    public function lecturer()
    {
        return $this->belongsTo(
            User::class,
            'lecturer_id'
        );
    }

    // Relationship: Section belongs to a subject
    public function subject()
    {
        return $this->belongsTo(
            Subject::class,
            'subject_id',
            'subject_id'
        );
    }

    // Relationship: Section has many attendance records
    public function attendances()
    {
        return $this->hasMany(
            Attendance::class,
            'section_id',
            'section_id'
        );
    }

    // Relationship: Section has many registrations
    public function registrations()
    {
        return $this->hasMany(
            Registration::class,
            'section_id',
            'section_id'
        );
    }

    // Relationship: Section has many labs
    public function labs()
    {
        return $this->hasMany(
            Lab::class,
            'section_id',
            'section_id'
        );
    }
}