@extends('layouts.app')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <h4 class="fw-bold">Dashboard</h4>
</div>

<div class="row g-4 mb-4">
    @php
        $cards = [
            ['title' => 'Total TOEIC Registrations', 'amount' => $totalRegistrations, 'icon' => 'bi-person-lines-fill', 'color' => 'primary'],
            ['title' => 'Paid Status', 'amount' => $paidRegistrations, 'icon' => 'bi-cash-stack', 'color' => 'success'],
            ['title' => 'Certificates Uploaded', 'amount' => $certUploaded, 'icon' => 'bi-file-earmark-check', 'color' => 'info']
        ];
    @endphp
    @foreach ($cards as $card)
    <div class="col-md-4">
        <div class="card shadow-sm border-0 p-3 position-relative rounded-4">
            <div class="d-flex justify-content-between">
                <div>
                    <h6 class="text-muted mb-1">{{ $card['title'] }}</h6>
                    <h4 class="mb-1">{{ $card['amount'] }}</h4>
                </div>
                <div class="bg-light rounded-circle d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                    <i class="bi {{ $card['icon'] }} text-{{ $card['color'] }}"></i>
                </div>
            </div>
        </div>
    </div>
    @endforeach
</div>

<div class="card shadow-sm border-0 p-3 mb-4 rounded-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="fw-semibold mb-0">Monthly TOEIC Registrations</h5>
    </div>
    <canvas id="overviewChart" height="120"></canvas>
</div>

<div class="card shadow-sm border-0 p-3 rounded-4">
    <h5 class="fw-semibold mb-3">TOEIC Registration List</h5>
    <div class="table-responsive">
        <table class="table table-bordered align-middle">
            <thead class="table-light">
                <tr>
                    <th>No</th>
                    <th>Student ID</th>
                    <th>Status</th>
                    <th>Registration Date</th>
                    <th>Score</th>
                    <th>Certificate</th>
                </tr>
            </thead>
            <tbody>
                @foreach($registrations as $i => $reg)
                <tr>
                    <td>{{ $i+1 }}</td>
                    <td>{{ $reg->nim }}</td>
                    <td>
                        <span class="badge bg-{{ $reg->status == 'paid' ? 'success' : 'secondary' }}">
                            {{ strtoupper($reg->status) }}
                        </span>
                    </td>
                    <td>{{ \Carbon\Carbon::parse($reg->registration_date)->format('d/m/Y') }}</td>
                    <td>{{ $reg->score ?? '-' }}</td>
                    <td>
                        @if($reg->certificate_path)
                            <a href="{{ asset('storage/' . $reg->certificate_path) }}" target="_blank" class="btn btn-sm btn-outline-primary">View</a>
                        @else
                            <span class="text-muted">Not available</span>
                        @endif
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endsection

@section('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    const ctx = document.getElementById('overviewChart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
            datasets: [{
                label: 'Registrations',
                data: @json($monthlyCounts),
                borderColor: '#0d6efd',
                backgroundColor: 'rgba(13,110,253,0.1)',
                tension: 0.4,
                fill: true,
                pointRadius: 4,
                pointHoverRadius: 6
            }]
        },
        options: {
            plugins: { legend: { display: false }},
            scales: { y: { beginAtZero: true }}
        }
    });
</script>
@endsection
