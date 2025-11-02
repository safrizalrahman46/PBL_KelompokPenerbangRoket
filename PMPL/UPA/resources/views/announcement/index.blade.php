@extends('layouts.app')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4>Announcements</h4>
    <a href="{{ route('announcement.create') }}" class="btn btn-success">+ Add Announcement</a>
</div>

@if(session('success'))
    <div class="alert alert-success">{{ session('success') }}</div>
@endif

<div class="row">
    @forelse ($announcements as $a)
    <div class="col-md-6 col-lg-4 mb-4">
    <div class="card h-100 shadow-sm">
        <!-- Gambar default di bagian atas -->
        {{--  <img src="{{ asset('images/polinema.png') }}" class="card-img-top" alt="Default Image">  --}}
        <img src="{{ asset('images/polinema.png') }}" class="card-img-top" alt="Default Image" style="height: 180px; object-fit: cover;">


        <div class="card-body d-flex flex-column">
            <h5 class="card-title">{{ $a->title }}</h5>
            <div class="mb-2">
                <span class="badge bg-primary">{{ ucfirst(str_replace('_', ' ', $a->type)) }}</span>
                <span class="badge bg-secondary">{{ ucfirst($a->target_audience) }}</span>
            </div>
            <p class="card-text flex-grow-1">{{ Str::limit(strip_tags($a->content), 100) }}</p>
            <ul class="list-unstyled small mb-2">
                @if ($a->event_date)
                    <li><strong>Event:</strong> {{ $a->event_date->format('Y-m-d') }}</li>
                @endif
                @if ($a->pickup_certificate)
                    <li><strong>Pickup Cert.:</strong> {{ $a->pickup_certificate->format('Y-m-d') }}</li>
                @endif
            </ul>
            <div class="mt-auto d-flex justify-content-between">
                <a href="{{ route('announcement.edit', $a->id) }}" class="btn btn-sm btn-outline-primary">Edit</a>
                <form action="{{ route('announcement.destroy', $a->id) }}" method="POST" onsubmit="return confirm('Delete this?')">
                    @csrf @method('DELETE')
                    <button type="submit" class="btn btn-sm btn-outline-danger">Delete</button>
                </form>
            </div>
        </div>
    </div>
</div>

    @empty
        <div class="col-12">
            <div class="alert alert-info">No announcements found.</div>
        </div>
    @endforelse
</div>
@endsection
