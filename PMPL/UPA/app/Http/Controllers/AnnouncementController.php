<?php
namespace App\Http\Controllers;

use App\Models\Announcement;
use Illuminate\Http\Request;

class AnnouncementController extends Controller
{
    public function index()
    {
        $announcements = Announcement::latest()->get();
        return view('announcement.index', compact('announcements'));
    }

    public function create()
    {
        return view('announcement.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|max:100',
            'content' => 'required',
            'type' => 'required|in:test_schedule,test_result,certificate,general',
            'target_audience' => 'required|in:student,admin,all',
            'event_date' => 'nullable|date',
            'pickup_certificate' => 'nullable|date',
        ]);

        Announcement::create($request->all());

        return redirect()->route('announcement.index')->with('success', 'Announcement created successfully.');
    }

    public function edit($id)
    {
        $announcement = Announcement::findOrFail($id);
        return view('announcement.edit', compact('announcement'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'title' => 'required|max:100',
            'content' => 'required',
            'type' => 'required|in:test_schedule,test_result,certificate,general',
            'target_audience' => 'required|in:student,admin,all',
            'event_date' => 'nullable|date',
            'pickup_certificate' => 'nullable|date',
        ]);

        $announcement = Announcement::findOrFail($id);
        $announcement->update($request->all());

        return redirect()->route('announcement.index')->with('success', 'Announcement updated successfully.');
    }

    public function destroy($id)
    {
        Announcement::findOrFail($id)->delete();
        return back()->with('success', 'Announcement deleted.');
    }
}
