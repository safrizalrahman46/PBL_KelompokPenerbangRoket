@extends('layouts.app')

@section('content')
<h4>Edit Educational Staff</h4>
<form method="POST" action="{{ route('educational-staff.update', $staff->id) }}">
    @csrf
    @method('PUT')
    @include('educational-staff.form')
    <button type="submit" class="btn btn-primary">Update</button>
</form>
@endsection
