@extends('layouts.app')

@section('content')
<h4>Educational Staff Detail</h4>
<ul class="list-group">
    <li class="list-group-item"><strong>Username:</strong> {{ $staff->username }}</li>
    <li class="list-group-item"><strong>Name:</strong> {{ $staff->name }}</li>
    <li class="list-group-item"><strong>Email:</strong> {{ $staff->email }}</li>
    <li class="list-group-item"><strong>NIM:</strong> {{ $staff->nim }}</li>
    <li class="list-group-item"><strong>NIK:</strong> {{ $staff->nik }}</li>
    <li class="list-group-item"><strong>Phone:</strong> {{ $staff->phone }}</li>
    <li class="list-group-item"><strong>Origin Address:</strong> {{ $staff->origin_address }}</li>
    <li class="list-group-item"><strong>Current Address:</strong> {{ $staff->current_address }}</li>
    <li class="list-group-item"><strong>Study Program:</strong> {{ optional($staff->studyProgram)->name }}</li>
    <li class="list-group-item"><strong>Major:</strong> {{ optional($staff->major)->name }}</li>
    <li class="list-group-item"><strong>Campus:</strong> {{ $staff->campus }}</li>
</ul>
<a href="{{ route('educational-staff.index') }}" class="btn btn-secondary mt-3">Back</a>
@endsection
