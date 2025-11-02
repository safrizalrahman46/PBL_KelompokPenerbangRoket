@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Detail TOEIC PDF</h2>
    <p><strong>ID:</strong> {{ $toeicScore->id }}</p>
    <p><strong>Diunggah Pada:</strong> {{ $toeicScore->created_at->format('d-m-Y H:i') }}</p>
    <p><strong>PDF:</strong></p>
    <iframe src="{{ asset('storage/' . $toeicScore->pdf) }}" width="100%" height="600px"></iframe>
</div>
@endsection
