@extends('layouts.app')

@section('content')
<h4>Edit Student</h4>

<form action="{{ route('students.update', $student->id) }}" method="POST" enctype="multipart/form-data">
    @csrf
    @method('PUT')
    @include('students.form', ['student' => $student])
    <button type="submit" class="btn btn-primary">Update</button>
    <a href="{{ route('students.index') }}" class="btn btn-secondary">Back</a>
</form>
@endsection
