<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CreditClaim extends Model
{
    // 1. Explicitly define the table name matching your migration
    protected $table = 'credit_claims';

    // 2. Specify fillable fields to protect against Mass Assignment vulnerabilities
    protected $fillable = [
        'student_id',
        'subject_id',
        'status',
    ];

    // ── 🔄 RELATIONSHIPS (Makes querying data incredibly simple) ──

    /**
     * Get the student profile that owns this credit claim application.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id', 'id');
    }

    /**
     * Get the subject metadata details (UQA2002) linked to this claim.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class, 'subject_id', 'subject_id');
    }
}