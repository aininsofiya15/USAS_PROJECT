<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lab extends Model
{
    protected $primaryKey = 'lab_id';

    protected $fillable = [

        'section_id',
        'lab_name',
        'capacity',
        'enrolled',

    ];
    public function labs()
    {
        return $this->hasMany(Lab::class, 'section_id', 'section_id');
    }
}
