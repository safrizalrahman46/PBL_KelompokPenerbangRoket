@extends('layouts.app')

@section('content')
<h4>Add Educational Staff</h4>
<form method="POST" action="{{ route('educational-staff.store') }}">
    @csrf
    @include('educational-staff.form')
    <button type="submit" class="btn btn-primary">Save</button>
</form>
@endsection
