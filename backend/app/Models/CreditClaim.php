<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CreditClaim extends Model
{
    protected $fillable = ['student_id', 'subject_id', 'status', 'remarks'];

    // Relationship to User/Student
    public function student() {
        return $this->belongsTo(User::class, 'student_id');
    }

    // Relationship to the Subject (Koko)
    public function subject() {
        return $this->belongsTo(Subject::class, 'subject_id');
    }
}