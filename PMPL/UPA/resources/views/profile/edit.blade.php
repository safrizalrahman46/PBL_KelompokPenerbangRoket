@extends('layouts.app')

@section('content')
<div class="card p-4">
    <h4>Edit Profile</h4>
    <form action="{{ route('profile.update') }}" method="POST" enctype="multipart/form-data">
        @csrf
        @method('PUT')

        <div class="mb-3">
            <label for="name" class="form-label">Full Name</label>
            <input type="text" name="name" value="{{ old('name', $user->name) }}" class="form-control">
        </div>

        <div class="mb-3">
            <label for="phone" class="form-label">Phone</label>
            <input type="text" name="phone" value="{{ old('phone', $user->phone) }}" class="form-control">
        </div>

        <div class="mb-3">
            <label for="origin_address" class="form-label">Origin Address</label>
            <textarea name="origin_address" class="form-control">{{ old('origin_address', $user->origin_address) }}</textarea>
        </div>

        <div class="mb-3">
            <label for="current_address" class="form-label">Current Address</label>
            <textarea name="current_address" class="form-control">{{ old('current_address', $user->current_address) }}</textarea>
        </div>

        <div class="mb-3">
            <label for="photo" class="form-label">Profile Photo</label>
            <input type="file" name="photo" class="form-control">
            @if ($user->photo_path)
                <img src="{{ asset($user->photo_path) }}" alt="Photo" class="img-thumbnail mt-2" width="100">
            @endif
        </div>

        <button type="submit" class="btn btn-success">Save Changes</button>
        <a href="{{ route('profile.show') }}" class="btn btn-secondary">Cancel</a>
    </form>
</div>
@endsection
