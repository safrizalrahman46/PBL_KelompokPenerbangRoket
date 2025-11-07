<?php

namespace App\Filament\Widgets;

// 1. Ganti 'use'
use EightyNine\FilamentAdvancedWidget\AdvancedChartWidget;

// Import model & helper
use App\Models\Order;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

// 2. Ganti 'extends'
class PosSalesChart extends AdvancedChartWidget
{
    // Styling dari tutorial
    protected static ?string $icon = 'heroicon-o-chart-bar';
    protected static string $color = 'primary';
    protected static ?string $iconColor = 'primary';
    protected static ?string $iconBackgroundColor = 'primary';
    protected static ?string $label = 'Grafik Pemasukan (Lunas)';

    // Tampilkan widget ini di urutan kedua
    protected static ?int $sort = 2;

    // Filter yang bisa dipilih (default-nya 'week')
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

    // Judul dinamis
    public function getHeading(): string // <-- PERBAIKAN: diubah dari 'protected' ke 'public'
    {
        $total = $this->getTotalSales($this->filter);
        return 'Rp ' . number_format($total, 0, ',', '.');
    }

    // Fungsi untuk mengambil data berdasarkan filter
    protected function getData(): array
    {
        $filter = $this->filter;
        $data = [];
        $labels = [];

        // Kita hanya hitung pesanan yang 'paid' (lunas)
        $query = Order::where('status', 'paid');
        $now = Carbon::now();

        switch ($filter) {
            case 'today':
                $sales = $query->whereDate('created_at', $now->today())
                                ->select(
                                    DB::raw('SUM(total_price) as total'),
                                    DB::raw("DATE_FORMAT(created_at, '%H:00') as hour")
                                )
                                ->groupBy('hour')
                                ->orderBy('hour', 'asc')
                                ->get();
                // Buat label 24 jam (00:00 - 23:00)
                $labels = array_map(fn($h) => str_pad($h, 2, '0', STR_PAD_LEFT).':00', range(0, 23));
                $data = array_fill(0, 24, 0);
                foreach ($sales as $sale) {
                    $hourIndex = (int) substr($sale->hour, 0, 2);
                    $data[$hourIndex] = $sale->total;
                }
                break;

            case 'week':
                $startDate = $now->startOfWeek();
                $sales = $query->whereBetween('created_at', [$startDate, $now->endOfWeek()])
                                ->select(
                                    DB::raw('SUM(total_price) as total'),
                                    DB::raw('DATE(created_at) as date')
                                )
                                ->groupBy('date')
                                ->orderBy('date', 'asc')
                                ->get();
                $labels = array_map(fn($i) => $startDate->copy()->addDays($i)->format('d M'), range(0, 6));
                $data = array_fill(0, 7, 0);
                foreach ($sales as $sale) {
                    $dateIndex = Carbon::parse($sale->date)->diffInDays($startDate);
                    $data[$dateIndex] = $sale->total;
                }
                break;

            case 'month':
                $startDate = $now->startOfMonth();
                $daysInMonth = $startDate->daysInMonth;
                $sales = $query->whereYear('created_at', $startDate->year)
                               ->whereMonth('created_at', $startDate->month)
                                ->select(
                                    DB::raw('SUM(total_price) as total'),
                                    DB::raw('DATE(created_at) as date')
                                )
                                ->groupBy('date')
                                ->orderBy('date', 'asc')
                                ->get();

                $labels = array_map(fn($i) => $startDate->copy()->addDays($i)->format('d M'), range(0, $daysInMonth - 1));
                $data = array_fill(0, $daysInMonth, 0);
                foreach ($sales as $sale) {
                    $dateIndex = Carbon::parse($sale->date)->diffInDays($startDate);
                    $data[$dateIndex] = $sale->total;
                }
                break;

            case 'year':
                $sales = $query->whereYear('created_at', $now->year)
                                ->select(
                                    DB::raw('SUM(total_price) as total'),
                                    DB::raw("DATE_FORMAT(created_at, '%Y-%m') as month")
                                )
                                ->groupBy('month')
                                ->orderBy('month', 'asc')
                                ->get();
                $labels = array_map(fn($m) => Carbon::create(null, $m)->format('M'), range(1, 12));
                $data = array_fill(0, 12, 0);
                foreach ($sales as $sale) {
                    $monthIndex = (int) substr($sale->month, 5, 2) - 1;
                    $data[$monthIndex] = $sale->total;
                }
                break;
        }

        return [
            'datasets' => [
                [
                    'label' => 'Pemasukan (Lunas)',
                    'data' => $data,
                    'backgroundColor' => 'rgba(54, 162, 235, 0.2)',
                    'borderColor' => 'rgb(54, 162, 235)',
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

    // Fungsi helper untuk total di heading
    private function getTotalSales(string $filter): float
    {
        $query = Order::where('status', 'paid');
        $now = Carbon::now();

        switch ($filter) {
            case 'today':
                return $query->whereDate('created_at', $now->today())->sum('total_price');
            case 'week':
                return $query->whereBetween('created_at', [$now->startOfWeek(), $now->endOfWeek()])->sum('total_price');
            case 'month':
                return $query->whereMonth('created_at', $now->month)->whereYear('created_at', $now->year)->sum('total_price');
            case 'year':
                return $query->whereYear('created_at', $now->year)->sum('total_price');
            default:
                return 0;
        }
    }
}
