<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subject extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'subject_code',
        'subject_name',
    ];

    // --- Relationships ---

    // A subject can have many Sections (e.g., Section 01, Section 02)
    public function sections()
    {
        return $this->hasMany(Section::class);
    }
}