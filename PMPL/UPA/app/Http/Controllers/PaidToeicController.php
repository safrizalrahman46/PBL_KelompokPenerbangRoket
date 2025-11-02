<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;


class PaidToeicController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
         return view('PaidRegister');
    }

    /**
     * Show the form for creating a new resource.
     */
    // public function create()
    // {
    //     //
    // }

    // /**
    //  * Store a newly created resource in storage.
    //  */
    // public function store(Request $request)
    // {
    //     //
    // }

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
      public function create()
    {
        return view('PaidRegister');
    }

    public function store(Request $request)
    {
        $request->validate([
            'nim' => 'required|string|max:20',
            'name' => 'required|string|max:100',
            'nik' => 'required|string|max:20',
            'phone' => 'required|string|max:15',
            'origin_address' => 'required|string',
            'current_address' => 'required|string',
            'study_program' => 'required|string|max:50',
            'department' => 'required|string|max:50',
            'campus' => 'required|string',
            'photo' => 'nullable|image|max:2048',
            'id_card' => 'required|file|mimes:jpg,jpeg,png,pdf|max:2048',
            'student_card' => 'required|file|mimes:jpg,jpeg,png,pdf|max:2048',
            'payment_proof' => 'required|file|mimes:jpg,jpeg,png,pdf|max:2048',
        ]);

        // Simpan file
        $photoPath = $request->hasFile('photo') ? $request->file('photo')->store('photos') : null;
        $idCardPath = $request->file('id_card')->store('id_cards');
        $studentCardPath = $request->file('student_card')->store('student_cards');
        $paymentProofPath = $request->file('payment_proof')->store('payment_proofs');

        // Simpan data
        DB::table('paid_toeic')->insert([
            'nim' => $request->nim,
            'name' => $request->name,
            'nik' => $request->nik,
            'phone' => $request->phone,
            'origin_address' => $request->origin_address,
            'current_address' => $request->current_address,
            'study_program' => $request->study_program,
            'department' => $request->department,
            'campus' => $request->campus,
            'photo_path' => $photoPath,
            'id_card_path' => $idCardPath,
            'student_card_path' => $studentCardPath,
            'payment_proof_path' => $paymentProofPath,
            'created_at' => now(),
        ]);

        return redirect()->route('paid-toeic.form')->with('success', 'Your registration was successfully submitted!');
    }
}
