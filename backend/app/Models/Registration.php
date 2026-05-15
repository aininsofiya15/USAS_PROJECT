<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Registration extends Model
{
    protected $table = 'registration';

    protected $primaryKey =
        'registration_id';

    public $timestamps = false;

    protected $fillable = [

        'student_id',

        'subject_id',

        'section_id',

        'lab_id',

        'status',

        'registered_at',
    ];
}