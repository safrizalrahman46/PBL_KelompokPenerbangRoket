<?php

namespace App\Http\Controllers;

use App\Models\m_user;
use App\Models\StudyProgram;
use App\Models\Major;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminRegistrationController extends Controller
{
    public function index()
    {
        $students = m_user::with(['studyProgram:id,name', 'major:id,name'])
            ->where('role_name', 'student')
            ->select(
                'id', 'username', 'name', 'email', 'nim', 'study_program_id', 'major_id',
                'campus', 'role_name', 'status', 'rejection_reason'
            )
            ->get();

        return view('admin.student-register.index', compact('students'));
    }

    public function create()
    {
        return view('admin.student-register', [
            'studyPrograms' => StudyProgram::all(),
            'majors' => Major::all(),
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'username' => 'required|string|max:50|unique:user,username',
            'email' => 'required|email|unique:user,email',
            'password' => 'required|string|confirmed|min:6',
            'nim' => 'required|unique:user,nim',
            'name' => 'required|string',
            'nik' => 'required|unique:user,nik',
            'phone' => 'required',
            'origin_address' => 'required|string',
            'current_address' => 'required|string',
            'study_program_id' => 'required|exists:study_programs,id',
            'major_id' => 'required|exists:majors,id',
            'campus' => 'required|in:Main,PSDKU Kediri,PSDKU Lumajang,PSDKU Pamekasan',
        ]);

        m_user::create([
            'username' => $request->username,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role_name' => 'student',
            'role_description' => 'Registered by admin',
            'nim' => $request->nim,
            'name' => $request->name,
            'nik' => $request->nik,
            'phone' => $request->phone,
            'origin_address' => $request->origin_address,
            'current_address' => $request->current_address,
            'study_program_id' => $request->study_program_id,
            'major_id' => $request->major_id,
            'campus' => $request->campus,
            'has_registered_free_toeic' => false,
            'status' => 'pending',
        ]);

        return redirect()->back()->with('success', 'Mahasiswa berhasil didaftarkan.');
    }

    public function approve($id)
    {
        $student = m_user::findOrFail($id);
        $student->update([
            'status' => 'approved',
            'rejection_reason' => null,
        ]);

        return back()->with('success', 'Student approved.');
    }

    public function reject(Request $request, $id)
    {
        $request->validate(['rejection_reason' => 'required|string']);

        $student = m_user::findOrFail($id);
        $student->update([
            'status' => 'rejected',
            'rejection_reason' => $request->rejection_reason,
        ]);

        return back()->with('error', 'Student rejected.');
    }
}
