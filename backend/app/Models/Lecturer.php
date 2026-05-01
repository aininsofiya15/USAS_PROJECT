<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Lecturer extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'lecturer_id',
        'full_name',
    ];

    // --- Relationships ---

    // A lecturer belongs to one User account
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // A lecturer can teach many Sections
    public function sections()
    {
        return $this->hasMany(Section::class);
    }
}