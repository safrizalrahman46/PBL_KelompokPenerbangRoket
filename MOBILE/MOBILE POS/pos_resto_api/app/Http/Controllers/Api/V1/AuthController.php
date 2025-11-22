<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\User;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Hash; // Penting untuk Hash::make()
use Illuminate\Support\Facades\Auth; // Penting untuk Auth::attempt()
use Illuminate\Validation\ValidationException;
// use App\Models\User; // Penting untuk model User
use Laravel\Sanctum\HasApiTokens;

class AuthController extends Controller
{
    // --- METODE REGISTER (Sudah benar) ---
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role' => [
                'required',
                'string',
                Rule::in(['cashier', 'kitchen']),
            ],
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'User registered successfully',
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    // --- METODE LOGIN (Harus ditambahkan kembali) ---
    public function login(Request $request)
    {
        // 1. Validasi
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // 2. Cek Kredensial
        if (!Auth::attempt($request->only('email', 'password'))) {
            throw ValidationException::withMessages([
                'email' => ['Kredensial yang Anda masukkan tidak cocok dengan catatan kami.'],
            ]);
        }

        // 3. Ambil User dan Buat Token
        $user = Auth::user();
        // Method ini memerlukan HasApiTokens
        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    // --- METODE LOGOUT (Harus ditambahkan kembali) ---
    public function logout(Request $request)
    {
        // Hapus token yang digunakan saat ini
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Successfully logged out']);
    }

    // --- METODE USER (Harus ditambahkan kembali) ---
    public function user(Request $request)
    {
        // Mengembalikan detail user yang sedang login
        return response()->json($request->user());
    }
}
