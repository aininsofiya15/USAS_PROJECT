<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Section extends Model
{
    protected $primaryKey = 'section_id';

    protected $fillable = [
        'lecturer_id',
        'subject_id',
        'section_no',
        'lab_group',
        'capacity',
        'enrolled',
        'schedule_time',
        'schedule_day',
    ];

    // Relationships
    public function lecturer()
    {
        return $this->belongsTo(User::class, 'lecturer_id');
    }

    public function subject()
    {
        return $this->belongsTo(Subject::class, 'subject_id', 'subject_id');
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class, 'section_id', 'section_id');
    }
}