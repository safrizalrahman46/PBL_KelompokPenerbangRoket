@extends('layouts.app')

@section('content')
<div class="container">
    <h3 class="mb-4">Educational Staff Detail</h3>

    <div class="card">
        <div class="card-body">
            <p><strong>Name:</strong> {{ $staff->name }}</p>
            <p><strong>NIK:</strong> {{ $staff->nik }}</p>
            <p><strong>Phone:</strong> {{ $staff->phone }}</p>
            <p><strong>Origin Address:</strong> {{ $staff->origin_address }}</p>
            <p><strong>Current Address:</strong> {{ $staff->current_address }}</p>

            @if ($staff->photo_path)
                <p><strong>Photo:</strong><br>
                    <img src="{{ asset('storage/' . $staff->photo_path) }}" width="150" class="img-thumbnail">
                </p>
            @endif

            @if ($staff->id_card_path)
                <p><strong>ID Card:</strong><br>
                    <a href="{{ asset('storage/' . $staff->id_card_path) }}" target="_blank" class="btn btn-sm btn-secondary">View ID Card</a>
                </p>
            @endif

            <a href="{{ route('educational-staff-registration.index') }}" class="btn btn-light mt-3">Back</a>
        </div>
    </div>
</div>
@endsection
