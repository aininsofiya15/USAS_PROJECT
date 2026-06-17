<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lab extends Model
{
    // Primary key for labs table
    protected $primaryKey = 'lab_id';

    // Fields allowed for mass assignment
    protected $fillable = [

        'section_id',
        'lab_name',
        'capacity',
        'enrolled',
        'schedule_day',
        'schedule_time',
    ];

    // Relationship: Lab belongs to a section
    public function section()
    {
        return $this->belongsTo(
            Section::class,
            'section_id',
            'section_id'
        );
    }

    // Relationship: Lab has many registrations
    public function registrations()
    {
        return $this->hasMany(
            Registration::class,
            'lab_id',
            'lab_id'
        );
    }
}