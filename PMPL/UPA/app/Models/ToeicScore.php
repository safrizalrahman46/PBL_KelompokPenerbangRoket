<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ToeicScore extends Model
{
    protected $table = 'toeic_scores';

       protected $fillable = ['pdf'];
}

