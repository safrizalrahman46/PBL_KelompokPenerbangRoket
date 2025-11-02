@extends('layouts.app')

@section('content')
<div class="container">
    <h3>TOEIC Re-Registration (Paid)</h3>
    <form action="{{ route('toeic-registration.store') }}" method="POST">
        @csrf
        <div class="mb-3">
            <label for="nim" class="form-label">NIM ID (NIM)</label>
            <input type="text" class="form-control" id="nim" name="nim" required>
        </div>
        <button type="submit" class="btn btn-success">Register & Get Payment Link</button>
    </form>
</div>
@endsection
