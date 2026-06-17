<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Subject extends Model
{
    /**
     * Purpose:
     * Specify the primary key column for the subjects table.
     * Laravel default is 'id', but this table uses 'subject_id'.
     */
    protected $primaryKey = 'subject_id';

    /**
     * Purpose:
     * Define fields that can be mass assigned when creating
     * or updating a subject record.
     */
    protected $fillable = [

        // Subject code (e.g., BCS2314)
        'subject_code',

        // Subject name (e.g., Software Engineering)
        'subject_name',

        // Total credit hours for the subject
        'credit_hours',

        // Total number of sections offered
        'total_section',

        // Total number of labs under the subject
        'total_lab',

        // Subject status (active / inactive)
        'subject_status',
    ];

    /**
     * Purpose:
     * Define one-to-many relationship between Subject and Section.
     *
     * One Subject
     * └── Many Sections
     *
     * Example:
     * Subject: Software Engineering
     * ├── Section 1A
     * ├── Section 1B
     * └── Section 2A
     */
    public function sections()
    {
        return $this->hasMany(

            // Related model
            Section::class,

            // Foreign key in sections table
            'subject_id',

            // Local key in subjects table
            'subject_id'
        );
    }
}