<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Http\Controllers\Controller;
// use Illuminate\Http\Request;
use App\Models\m_user;
use App\Models\StudyProgram;
use App\Models\Major;

class EducationalStaffController extends Controller
{
    public function index()
    {
        $staffs = m_user::with(['studyProgram', 'major'])
            ->where('role_name', 'educational_staff')
            ->get();

        return view('educational-staff.index', compact('staffs'));
    }

    public function create()
    {
        $programs = StudyProgram::all();
        $majors = Major::all();
        return view('educational-staff.create', compact('programs', 'majors'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'username' => 'required|unique:user',
            'email' => 'required|email|unique:user',
            'nim' => 'required',
            'name' => 'required',
            'nik' => 'required',
            'phone' => 'required',
            'origin_address' => 'required',
            'current_address' => 'required',
            'study_program_id' => 'required',
            'major_id' => 'required',
            'campus' => 'required|in:Main,PSDKU Kediri,PSDKU Lumajang,PSDKU Pamekasan',
        ]);

        m_user::create([
            'username' => $request->username,
            'password' => bcrypt('default123'),
            'email' => $request->email,
            'role_name' => 'educational_staff',
            'role_description' => 'Educational Staff',
            'nim' => $request->nim,
            'name' => $request->name,
            'nik' => $request->nik,
            'phone' => $request->phone,
            'origin_address' => $request->origin_address,
            'current_address' => $request->current_address,
            'study_program_id' => $request->study_program_id,
            'major_id' => $request->major_id,
            'campus' => $request->campus,
        ]);

        return redirect()->route('educational-staff.index')->with('success', 'Educational Staff created.');
    }

    public function show($id)
    {
        $staff = m_user::with(['studyProgram', 'major'])
            ->where('role_name', 'educational_staff')
            ->findOrFail($id);
        return view('educational-staff.show', compact('staff'));
    }

    public function edit($id)
    {
        $staff = m_user::findOrFail($id);
        $programs = StudyProgram::all();
        $majors = Major::all();
        return view('educational-staff.edit', compact('staff', 'programs', 'majors'));
    }

    public function update(Request $request, $id)
    {
        $staff = m_user::findOrFail($id);
        $request->validate([
            'email' => 'required|email|unique:user,email,' . $id,
            'name' => 'required',
            'phone' => 'required',
            'origin_address' => 'required',
            'current_address' => 'required',
        ]);

        $staff->update($request->only([
            'email', 'name', 'phone', 'origin_address', 'current_address',
            'study_program_id', 'major_id', 'campus'
        ]));

        return redirect()->route('educational-staff.index')->with('success', 'Educational Staff updated.');
    }

    public function destroy($id)
    {
        $staff = m_user::findOrFail($id);
        $staff->delete();

        return redirect()->route('educational-staff.index')->with('success', 'Educational Staff deleted.');
    }
}

