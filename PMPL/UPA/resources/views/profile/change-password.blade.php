@extends('layouts.app')

@section('content')
<div class="card p-4">
    <h4>Change Password</h4>
    <form action="{{ route('profile.update-password') }}" method="POST">
        @csrf
        @method('PUT')

        <div class="mb-3">
            <label for="current_password" class="form-label">Current Password</label>
            <input type="password" name="current_password" class="form-control" required>
        </div>

        <div class="mb-3">
            <label for="new_password" class="form-label">New Password</label>
            <input type="password" name="new_password" class="form-control" required>
        </div>

        <div class="mb-3">
            <label for="new_password_confirmation" class="form-label">Confirm New Password</label>
            <input type="password" name="new_password_confirmation" class="form-control" required>
        </div>

        <button type="submit" class="btn btn-success">Update Password</button>
        <a href="{{ route('profile.show') }}" class="btn btn-secondary">Cancel</a>
    </form>
</div>
@endsection
