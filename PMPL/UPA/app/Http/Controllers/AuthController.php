<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\Auth;


use Illuminate\Http\Request;

class AuthController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
          return view('auth.login', [
        ]);
    }

   public function postlogin(Request $request)
{
    if ($request->ajax() || $request->wantsJson()) {
        // $credentials = $request->only('username', 'password');
        $credentials = $request->only('email', 'password');

        if (Auth::attempt($credentials)) {
            return response()->json([
                'status' => true,
                'message' => 'Login Berhasil',
                'redirect' => url('/dashboard') // ⬅️ Redirect ke dashboard
            ]);
        }

        return response()->json([
            'status' => false,
            'message' => 'Login Gagal'
        ]);
    }

    // fallback kalau bukan AJAX
    if (Auth::attempt($request->only('email', 'password'))) {
        return redirect('/dashboard'); // ⬅️ Redirect langsung kalau bukan AJAX
    }

    return redirect('login')->withErrors([
        'email' => 'Login gagal',
    ]);
}



    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
