@extends('layouts.app')

@section('content')
<div class="container">
    <h3>Registration Successful</h3>
    <p>Thank you, Student ID: <strong>{{ $registration->nim }}</strong>.</p>
    <p>Please proceed to the payment through the following link:</p>

    <a href="https://example.com/pembayaran/{{ $registration->id }}" class="btn btn-success" target="_blank">
        Click to Pay (Dummy Link)
    </a>

    <p class="mt-3 text-muted">*This is just a simulation link. No actual payment will be processed.</p>
</div>
@endsection
