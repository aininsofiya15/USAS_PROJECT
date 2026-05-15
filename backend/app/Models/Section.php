<?php

namespace App\Models;


use Illuminate\Database\Eloquent\Model;
use App\Models\Registration;
use App\Models\Lab;



class Section extends Model
{
    protected $primaryKey = 'section_id';

    protected $fillable = [

        'lecturer_id',
        'subject_id',
        'section_no',
        'capacity',
    ];

    /// LECTURER
    public function lecturer()
    {
        return $this->belongsTo(
            User::class,
            'lecturer_id'
        );
    }

    /// SUBJECT
    public function subject()
    {
        return $this->belongsTo(
            Subject::class,
            'subject_id',
            'subject_id'
        );
    }

    /// ATTENDANCE
    public function attendances()
    {
        return $this->hasMany(
            Attendance::class,
            'section_id',
            'section_id'
        );
    }

    /// REGISTRATIONS
    public function registrations()
    {
        return $this->hasMany(
            Registration::class,
            'section_id',
            'section_id'
        );
    }

    public function labs()
{
    return $this->hasMany(
        Lab::class,
        'section_id',
        'section_id'
    );
}
}