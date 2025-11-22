<?php

namespace App\Http\Controllers;


class HomeController extends Controller
{
    public function index()
    {
        $pageTitle = 'Eat.o | Solusi POS Restoran Modern'; // Definisikan variabel

        return view('landing', compact('pageTitle'));
        
        // ATAU
        
        return view('landing', [
            'title' => $pageTitle // Pastikan key-nya adalah 'title'
        ]);
    }
}