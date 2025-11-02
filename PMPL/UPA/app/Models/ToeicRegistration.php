<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ToeicRegistration extends Model
{
    protected $table = 'toeic_registration';

    protected $fillable = [
        'nim', 'status', 'registration_date', 'score', 'certificate_path'
    ];

    public $timestamps = false;
}
