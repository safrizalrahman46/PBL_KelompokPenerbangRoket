@extends('layouts.app')

@section('content')
<div class="container">
    <h3>Edit Study Program</h3>
    <form action="{{ route('study-programs.update', $studyProgram->id) }}" method="POST">
        @csrf @method('PUT')
        <div class="mb-3">
            <label>Name</label>
            <input type="text" name="name" class="form-control" required value="{{ $studyProgram->name }}">
        </div>
        <div class="mb-3">
            <label>Code</label>
            <input type="text" name="code" class="form-control" value="{{ $studyProgram->code }}">
        </div>
        <button class="btn btn-warning">Update</button>
        <a href="{{ route('study-programs.index') }}" class="btn btn-secondary">Back</a>
    </form>
</div>
@endsection
