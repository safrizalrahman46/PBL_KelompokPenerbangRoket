@extends('layouts.app')

@section('content')
<div class="container">
    <h3>TOEIC Registration - Educational Staff</h3>
    <form action="{{ route('educational-staff-registration.store') }}" method="POST" enctype="multipart/form-data">
        @csrf

        <div class="mb-3">
            <label for="name" class="form-label">Full Name</label>
            <input type="text" name="name" class="form-control" required>
        </div>

        <div class="mb-3">
            <label for="nik" class="form-label">NIK</label>
            <input type="text" name="nik" class="form-control" required>
        </div>

        <div class="mb-3">
            <label for="phone" class="form-label">Phone Number</label>
            <input type="text" name="phone" class="form-control" required>
        </div>

        <div class="mb-3">
            <label for="origin_address" class="form-label">Origin Address</label>
            <textarea name="origin_address" class="form-control" required></textarea>
        </div>

        <div class="mb-3">
            <label for="current_address" class="form-label">Current Address</label>
            <textarea name="current_address" class="form-control" required></textarea>
        </div>

        <div class="mb-3">
            <label for="photo_path" class="form-label">Profile Photo (optional)</label>
            <input type="file" name="photo_path" class="form-control">
        </div>

        <div class="mb-3">
            <label for="id_card_path" class="form-label">ID Card (PDF/JPG/PNG)</label>
            <input type="file" name="id_card_path" class="form-control">
        </div>

        <button type="submit" class="btn btn-success">Register</button>
    </form>
</div>
@endsection
