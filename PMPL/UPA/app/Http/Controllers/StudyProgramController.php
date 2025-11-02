<?php

namespace App\Http\Controllers;

use App\Models\StudyProgram;
use Illuminate\Http\Request;

class StudyProgramController extends Controller
{
    public function index()
    {
       $programs = StudyProgram::all();

        return view('study_programs.index', compact('programs'));
    }

    public function create()
    {
        return view('study_programs.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|max:100',
            'code' => 'nullable|max:20',
        ]);

        StudyProgram::create($request->only('name', 'code'));

        return redirect()->route('study-programs.index')->with('success', 'Study Program created successfully.');
    }

    public function show(StudyProgram $studyProgram)
    {
        return view('study_programs.show', compact('studyProgram'));
    }

    public function edit(StudyProgram $studyProgram)
    {
        return view('study_programs.edit', compact('studyProgram'));
    }

    public function update(Request $request, StudyProgram $studyProgram)
    {
        $request->validate([
            'name' => 'required|max:100',
            'code' => 'nullable|max:20',
        ]);

        $studyProgram->update($request->only('name', 'code'));

        return redirect()->route('study-programs.index')->with('success', 'Study Program updated successfully.');
    }

    public function destroy(StudyProgram $studyProgram)
    {
        $studyProgram->delete();
        return redirect()->route('study-programs.index')->with('success', 'Study Program deleted successfully.');
    }
}
