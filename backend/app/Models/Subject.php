<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Subject extends Model
{
    protected $primaryKey = 'subject_id';

    protected $fillable = [

        'subject_code',
        'subject_name',
        'credit_hours',
        'total_section',
        'total_lab',
        'subject_status',
    ];

    public function sections()
    {
        return $this->hasMany(
            Section::class,
            'subject_id',
            'subject_id'
        );
    }
}