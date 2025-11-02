@extends('layouts.app')

@section('content')
<div class="container">
    <h3>Study Program Details</h3>
    <ul class="list-group">
        <li class="list-group-item"><strong>ID:</strong> {{ $studyProgram->id }}</li>
        <li class="list-group-item"><strong>Name:</strong> {{ $studyProgram->name }}</li>
        <li class="list-group-item"><strong>Code:</strong> {{ $studyProgram->code }}</li>
        <li class="list-group-item"><strong>Created At:</strong> {{ $studyProgram->created_at }}</li>
        <li class="list-group-item"><strong>Updated At:</strong> {{ $studyProgram->updated_at }}</li>
    </ul>
    <a href="{{ route('study-programs.index') }}" class="btn btn-secondary mt-3">Back</a>
</div>
@endsection
