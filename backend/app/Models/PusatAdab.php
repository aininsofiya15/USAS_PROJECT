<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PusatAdab extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'adab_id',
    ];

    // --- Relationships ---

    // A lecturer belongs to one User account
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
