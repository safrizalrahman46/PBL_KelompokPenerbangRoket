@extends('layouts.app')

@section('content')
<div class="container">
    <h3 class="mb-4">Edit Educational Staff</h3>

    <form action="{{ route('educational-staff-registration.update', $staff->id) }}" method="POST" enctype="multipart/form-data">
        @csrf
        @method('PUT')

        <div class="mb-3">
            <label for="name" class="form-label">Name *</label>
            <input type="text" name="name" value="{{ old('name', $staff->name) }}" class="form-control" required>
        </div>

        <div class="mb-3">
            <label for="nik" class="form-label">NIK *</label>
            <input type="text" name="nik" value="{{ old('nik', $staff->nik) }}" class="form-control" required>
        </div>

        <div class="mb-3">
            <label for="phone" class="form-label">Phone *</label>
            <input type="text" name="phone" value="{{ old('phone', $staff->phone) }}" class="form-control" required>
        </div>

        <div class="mb-3">
            <label for="origin_address" class="form-label">Origin Address *</label>
            <textarea name="origin_address" class="form-control" required>{{ old('origin_address', $staff->origin_address) }}</textarea>
        </div>

        <div class="mb-3">
            <label for="current_address" class="form-label">Current Address *</label>
            <textarea name="current_address" class="form-control" required>{{ old('current_address', $staff->current_address) }}</textarea>
        </div>

        <div class="mb-3">
            <label for="photo_path" class="form-label">Photo</label><br>
            @if ($staff->photo_path)
                <img src="{{ asset('storage/' . $staff->photo_path) }}" width="100" class="img-thumbnail mb-2"><br>
            @endif
            <input type="file" name="photo_path" class="form-control">
        </div>

        <div class="mb-3">
            <label for="id_card_path" class="form-label">ID Card (PDF/JPG/PNG)</label><br>
            @if ($staff->id_card_path)
                <a href="{{ asset('storage/' . $staff->id_card_path) }}" target="_blank">Current ID Card</a><br>
            @endif
            <input type="file" name="id_card_path" class="form-control">
        </div>

        <button type="submit" class="btn btn-primary">Update</button>
        <a href="{{ route('educational-staff-registration.index') }}" class="btn btn-light">Cancel</a>
    </form>
</div>
@endsection
