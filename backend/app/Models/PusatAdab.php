<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PusatAdab extends Model
{
    protected $table = 'pusat_adab';

    protected $fillable = [
        'adab_id',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'adab_id');
    }
}