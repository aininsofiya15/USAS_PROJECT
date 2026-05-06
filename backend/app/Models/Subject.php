<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Subject extends Model
{
    protected $primaryKey = 'subject_id';

    protected $fillable = [
        //'faculty_registrar_id',
        'subject_code',
        'subject_name',
        'credit_hours',
        'total_section',
        'total_lab',
        'subject_status',
        //'created_by',
    ];

    // Relationships
    //public function facultyRegistrar()
    //{
    //    return $this->belongsTo(User::class, 'faculty_registrar_id');
    //}

    //public function creator()
    //{
    //    return $this->belongsTo(User::class, 'created_by');
    //}

    public function sections()
    {
        return $this->hasMany(Section::class, 'subject_id', 'subject_id');
    }
}