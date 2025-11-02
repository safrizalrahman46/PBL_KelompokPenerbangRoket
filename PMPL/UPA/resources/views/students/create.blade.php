@extends('layouts.app')

@section('content')
<h4>Add Student</h4>

<form action="{{ route('students.store') }}" method="POST" enctype="multipart/form-data">
    @csrf
    @include('students.form')
    <button type="submit" class="btn btn-primary">Save</button>
    <a href="{{ route('students.index') }}" class="btn btn-secondary">Back</a>
</form>
@endsection
