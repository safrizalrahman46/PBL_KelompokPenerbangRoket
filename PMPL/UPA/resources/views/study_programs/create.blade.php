@extends('layouts.app')

@section('content')
<div class="container">
    <h3>Create Study Program</h3>
    <form action="{{ route('study-programs.store') }}" method="POST">
        @csrf
        <div class="mb-3">
            <label>Name</label>
            <input type="text" name="name" class="form-control" required value="{{ old('name') }}">
        </div>
        <div class="mb-3">
            <label>Code</label>
            <input type="text" name="code" class="form-control" value="{{ old('code') }}">
        </div>
        <button class="btn btn-success">Save</button>
        <a href="{{ route('study-programs.index') }}" class="btn btn-secondary">Back</a>
    </form>
</div>
@endsection
