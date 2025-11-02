<?php
namespace App\Http\Controllers;

use App\Models\Major;
use Illuminate\Http\Request;

class MajorController extends Controller
{
    public function index()
    {
       $majors = Major::orderBy('id', 'desc')->get();

        return view('majors.index', compact('majors'));
    }

    public function create()
    {
        return view('majors.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:100',
            'code' => 'nullable|string|max:20',
        ]);

        Major::create($request->only('name', 'code'));

        return redirect()->route('majors.index')->with('success', 'Major berhasil ditambahkan.');
    }

    public function show($id)
    {
        $major = Major::findOrFail($id);
        return view('majors.show', compact('major'));
    }

    public function edit($id)
    {
        $major = Major::findOrFail($id);
        return view('majors.edit', compact('major'));
    }

    public function update(Request $request, $id)
    {
        $major = Major::findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:100',
            'code' => 'nullable|string|max:20',
        ]);

        $major->update($request->only('name', 'code'));

        return redirect()->route('majors.index')->with('success', 'Major berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $major = Major::findOrFail($id);
        $major->delete();

        return redirect()->route('majors.index')->with('success', 'Major berhasil dihapus.');
    }
}
