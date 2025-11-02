<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Storage;

class EducationalStaffRegistrationController extends Controller
{

    public function index()
    {
        $staffs = User::where('role_name', 'educational_staff')->latest()->get();
        return view('educational_staff_registration.index', compact('staffs'));
    }

    public function show($id)
    {
        $staff = User::where('role_name', 'educational_staff')->findOrFail($id);
        return view('educational_staff_registration.show', compact('staff'));
    }

    public function edit($id)
    {
        $staff = User::where('role_name', 'educational_staff')->findOrFail($id);
        return view('educational_staff_registration.edit', compact('staff'));
    }

    public function update(Request $request, $id)
    {
        $staff = User::where('role_name', 'educational_staff')->findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:100',
            'nik' => 'required|string|max:20|unique:user,nik,' . $staff->id,
            'phone' => 'required|string|max:15',
            'origin_address' => 'required|string',
            'current_address' => 'required|string',
            'photo_path' => 'nullable|image|max:2048',
            'id_card_path' => 'nullable|mimes:pdf,jpg,jpeg,png|max:2048',
        ]);

        // Handle file uploads
        if ($request->hasFile('photo_path')) {
            if ($staff->photo_path) {
                Storage::disk('public')->delete($staff->photo_path);
            }
            $staff->photo_path = $request->file('photo_path')->store('photos', 'public');
        }

        if ($request->hasFile('id_card_path')) {
            if ($staff->id_card_path) {
                Storage::disk('public')->delete($staff->id_card_path);
            }
            $staff->id_card_path = $request->file('id_card_path')->store('id_cards', 'public');
        }

        // Update fields
        $staff->update([
            'name' => $request->name,
            'nik' => $request->nik,
            'phone' => $request->phone,
            'origin_address' => $request->origin_address,
            'current_address' => $request->current_address,
        ]);

        return redirect()->route('educational-staff-registration.index')->with('success', 'Staff updated successfully.');
    }

    public function destroy($id)
    {
        $staff = User::where('role_name', 'educational_staff')->findOrFail($id);

        // Delete associated files
        if ($staff->photo_path) {
            Storage::disk('public')->delete($staff->photo_path);
        }
        if ($staff->id_card_path) {
            Storage::disk('public')->delete($staff->id_card_path);
        }

        $staff->delete();

        return redirect()->route('educational-staff-registration.index')->with('success', 'Staff deleted successfully.');
    }

    public function create()
    {
        return view('educational_staff_registration.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:100',
            'nik' => 'required|string|max:20|unique:user,nik',
            'phone' => 'required|string|max:15',
            'origin_address' => 'required|string',
            'current_address' => 'required|string',
            'photo_path' => 'nullable|image|max:2048',
            'id_card_path' => 'nullable|mimes:pdf,jpg,jpeg,png|max:2048',
        ]);

        $photoPath = $request->file('photo_path') ? $request->file('photo_path')->store('photos', 'public') : null;
        $idCardPath = $request->file('id_card_path') ? $request->file('id_card_path')->store('id_cards', 'public') : null;

        $user = User::create([
            'username' => $request->nik,
            'password' => bcrypt('password'), // default dummy password
            'email' => $request->nik . '@example.com', // dummy email
            'role_name' => 'educational_staff',
            'nim' => '-', // not applicable
            'name' => $request->name,
            'nik' => $request->nik,
            'phone' => $request->phone,
            'origin_address' => $request->origin_address,
            'current_address' => $request->current_address,
            'photo_path' => $photoPath,
            'id_card_path' => $idCardPath,
            'status' => 'pending',
        ]);

        return redirect()->route('educational-staff-registration.success', $user->id);
    }

    public function success($id)
    {
        $user = User::findOrFail($id);
        return view('educational_staff_registration.success', compact('user'));
    }
}
