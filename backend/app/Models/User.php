<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;


class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    // Role helpers
    public function isStudent(): bool
    {
        return $this->role === 'student';
    }

    public function isLecturer(): bool
    {
        return $this->role === 'lecturer';
    }

    public function isPusatAdab(): bool
    {
        return $this->role === 'pusat_adab';
    }

    // Relationships
    public function student()
    {
        return $this->hasOne(Student::class, 'student_id');
    }

    public function lecturer()
    {
        return $this->hasOne(Lecturer::class, 'lecturer_id');
    }

    public function pusatAdab()
    {
        return $this->hasOne(PusatAdab::class, 'adab_id');
    }

    public function sections()
    {
        return $this->hasMany(Section::class, 'lecturer_id');
    }
}

