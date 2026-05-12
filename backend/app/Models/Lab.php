<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lab extends Model
{
    protected $primaryKey = 'lab_id';

    protected $fillable = [

        'section_id',
        'lab_name',
        'capacity',
        'enrolled',
        'schedule_day',
        'schedule_time',
    ];

    public function section()
    {
        return $this->belongsTo(
            Section::class,
            'section_id',
            'section_id'
        );
    }
}