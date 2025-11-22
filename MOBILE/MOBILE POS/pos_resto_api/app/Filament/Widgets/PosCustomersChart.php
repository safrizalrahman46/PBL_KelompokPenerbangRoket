<?php

namespace App\Filament\Widgets;

use EightyNine\FilamentAdvancedWidget\AdvancedChartWidget;
use App\Models\Order;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class PosCustomersChart extends AdvancedChartWidget
{
    // --- KONFIGURASI TAMPILAN ---
    protected static ?string $heading = 'Grafik Kunjungan Pelanggan';
    protected static ?string $icon = 'heroicon-o-user-group';
    
    // Gunakan warna 'warning' (Kuning/Oranye) agar beda dengan grafik penjualan (Biru)
    protected static string $color = 'warning'; 
    protected static ?string $iconColor = 'warning';
    protected static ?string $iconBackgroundColor = 'warning';
    protected static ?string $label = 'Grafik Pelanggan Unik';

    // Taruh di urutan ke-3 (Setelah Grafik Penjualan)
    protected static ?int $sort = 1;

    protected int | string | array $columnSpan = 'full';
    

    public ?string $filter = 'week';

    protected function getFilters(): ?array
    {
        return [
            'today' => 'Hari Ini',
            'week' => 'Minggu Ini',
            'month' => 'Bulan Ini',
            'year' => 'Tahun Ini',
        ];
    }

    // Judul Angka Besar (Total Pelanggan)
    public function getHeading(): string
    {
        $total = $this->getTotalCustomers($this->filter);
        return number_format($total, 0, ',', '.') . ' Orang';
    }

    protected function getData(): array
    {
        $filter = $this->filter;
        $data = [];
        $labels = [];

        // Query Dasar: Ambil order yang sudah dibayar ('completed' atau 'completed')
        $query = Order::where('status', 'completed'); 
        $now = Carbon::now();

        switch ($filter) {
            case 'today':
                // --- HITUNGAN HARI INI (PER JAM) ---
                $customers = $query->whereDate('created_at', $now->today())
                    ->select(
                        DB::raw('count(distinct customer_name) as total'), // Hitung nama unik
                        DB::raw("DATE_FORMAT(created_at, '%H:00') as hour")
                    )
                    ->groupBy('hour')
                    ->orderBy('hour', 'asc')
                    ->get();

                $labels = array_map(fn($h) => str_pad($h, 2, '0', STR_PAD_LEFT).':00', range(0, 23));
                $data = array_fill(0, 24, 0);
                
                foreach ($customers as $row) {
                    $hourIndex = (int) substr($row->hour, 0, 2);
                    $data[$hourIndex] = $row->total;
                }
                break;

            case 'week':
                // --- HITUNGAN MINGGU INI (PER HARI) ---
                $startDate = $now->startOfWeek();
                $customers = $query->whereBetween('created_at', [$startDate, $now->endOfWeek()])
                    ->select(
                        DB::raw('count(distinct customer_name) as total'),
                        DB::raw('DATE(created_at) as date')
                    )
                    ->groupBy('date')
                    ->orderBy('date', 'asc')
                    ->get();

                $labels = array_map(fn($i) => $startDate->copy()->addDays($i)->format('d M'), range(0, 6));
                $data = array_fill(0, 7, 0);

                foreach ($customers as $row) {
                    $dateIndex = Carbon::parse($row->date)->diffInDays($startDate);
                    $data[$dateIndex] = $row->total;
                }
                break;

            case 'month':
                // --- HITUNGAN BULAN INI (PER TANGGAL) ---
                $startDate = $now->startOfMonth();
                $daysInMonth = $startDate->daysInMonth;
                
                $customers = $query->whereYear('created_at', $startDate->year)
                    ->whereMonth('created_at', $startDate->month)
                    ->select(
                        DB::raw('count(distinct customer_name) as total'),
                        DB::raw('DATE(created_at) as date')
                    )
                    ->groupBy('date')
                    ->orderBy('date', 'asc')
                    ->get();

                $labels = array_map(fn($i) => $startDate->copy()->addDays($i)->format('d M'), range(0, $daysInMonth - 1));
                $data = array_fill(0, $daysInMonth, 0);

                foreach ($customers as $row) {
                    $dateIndex = Carbon::parse($row->date)->diffInDays($startDate);
                    $data[$dateIndex] = $row->total;
                }
                break;

            case 'year':
                // --- HITUNGAN TAHUN INI (PER BULAN) ---
                $customers = $query->whereYear('created_at', $now->year)
                    ->select(
                        DB::raw('count(distinct customer_name) as total'),
                        DB::raw("DATE_FORMAT(created_at, '%Y-%m') as month")
                    )
                    ->groupBy('month')
                    ->orderBy('month', 'asc')
                    ->get();

                $labels = array_map(fn($m) => Carbon::create(null, $m)->format('M'), range(1, 12));
                $data = array_fill(0, 12, 0);

                foreach ($customers as $row) {
                    $monthIndex = (int) substr($row->month, 5, 2) - 1;
                    $data[$monthIndex] = $row->total;
                }
                break;
        }

        return [
            'datasets' => [
                [
                    'label' => 'Jumlah Pelanggan',
                    'data' => $data,
                    'backgroundColor' => 'rgba(251, 191, 36, 0.2)', // Warna Kuning Transparan
                    'borderColor' => 'rgb(251, 191, 36)', // Warna Kuning Solid
                    'tension' => 0.3,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }

    // Helper untuk hitung total angka besar di atas grafik
    private function getTotalCustomers(string $filter): int
    {
        // Menggunakan 'distinct' agar nama pelanggan yang sama dihitung 1 kali
        $query = Order::where('status', 'completed');
        $now = Carbon::now();

        switch ($filter) {
            case 'today':
                return $query->whereDate('created_at', $now->today())->distinct('customer_name')->count('customer_name');
            case 'week':
                return $query->whereBetween('created_at', [$now->startOfWeek(), $now->endOfWeek()])->distinct('customer_name')->count('customer_name');
            case 'month':
                return $query->whereMonth('created_at', $now->month)->whereYear('created_at', $now->year)->distinct('customer_name')->count('customer_name');
            case 'year':
                return $query->whereYear('created_at', $now->year)->distinct('customer_name')->count('customer_name');
            default:
                return 0;
        }
    }
}