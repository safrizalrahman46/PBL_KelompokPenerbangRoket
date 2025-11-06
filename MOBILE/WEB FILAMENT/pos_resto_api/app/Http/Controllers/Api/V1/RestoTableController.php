<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\RestoTable;

class RestoTableController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // Ambil semua meja, urutkan berdasarkan nama
        $tables = RestoTable::orderBy('name', 'asc')->get();
        return response()->json($tables);
    }

    public function updateStatus(Request $request, RestoTable $restoTable)
    {
        // Validasi input, pastikan statusnya hanya 'available' atau 'occupied'
        $validated = $request->validate([
            'status' => 'required|string|in:available,occupied',
        ]);

        // Update status meja
        $restoTable->status = $validated['status'];
        $restoTable->save();

        // Kembalikan data meja yang sudah di-update
        return response()->json($restoTable);
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
