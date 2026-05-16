<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Registration extends Model
{
    use HasFactory;

    // Explicitly define the table name since it's singular
    protected $table = 'registration';

    // Explicitly define the custom primary key
    protected $primaryKey = 'registration_id';

    // Disable timestamps if you only have 'registered_at' and not 'created_at'/'updated_at'
    public $timestamps = false;

    protected $fillable = [
    'student_id',
    'subject_id',
    'section_id',
    'lab_id',
    'status',
    'registered_at',
];

    /**
     * Get the student that owns the registration.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class, 'student_id', 'student_id');
    }

    /**
     * Get the section associated with the registration.
     */
    public function section(): BelongsTo
    {
        // Adjust 'section_id' if your sections table uses a different PK name
        return $this->belongsTo(Section::class, 'section_id', 'section_id');
    } 

    public function lab(): BelongsTo
{
    return $this->belongsTo(
        Lab::class,
        'lab_id',
        'lab_id'
    );
}
}