{{-- @extends('layouts.app')

@section('content')
<div class="container">
    <h3>Registration Successful</h3>
    <p>Thank you, <strong>{{ $user->name }}</strong> (NIK: <strong>{{ $user->nik }}</strong>).</p>
    <p>Your registration as Educational Staff has been received.</p>

    <div class="alert alert-info mt-3">
        Please wait for admin approval. You will be notified once your registration is reviewed.
    </div>

    <a href="{{ route('educational-staff-registration.create') }}" class="btn btn-primary mt-3">
        Register Another
    </a>
</div>
@endsection --}}


@extends('layouts.app')

@section('content')
<div class="container">
    <h3>Registration Successful</h3>
    <p>Thank you, <strong>{{ $user->name }}</strong> (NIK: <strong>{{ $user->nik }}</strong>).</p>
    <p>Your registration as Educational Staff has been received.</p>

    <a href="https://example.com/pembayaran/{{ $user->id }}" class="btn btn-success" target="_blank">
        Click to Pay (Dummy Link)
    </a>


    <p class="mt-3 text-muted">*This is just a simulation link. No actual payment will be processed.</p>
</div>
@endsection
