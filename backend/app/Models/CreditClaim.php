<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CreditClaim extends Model
{
    // Specify the table name 
    protected $table = 'credit_claims';
    
    // These are the fields for the credit claim application
    protected $fillable = [
        'student_id',
        'subject_id',
        'status',
    ];

    // Link to the student profile to get their name and matric ID
    public function student(): BelongsTo
    {
        // Define the relationship to the user record (student)
        return $this->belongsTo(User::class, 'student_id', 'id');
    }

    // Link to the subject to get the subject name and code
    public function subject(): BelongsTo
    {
        // Define the relationship to the subject record
        return $this->belongsTo(Subject::class, 'subject_id', 'subject_id');
    }
}