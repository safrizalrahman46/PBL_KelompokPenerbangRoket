<?php

namespace App\Filament\Widgets;

use EightyNine\FilamentAdvancedWidget\AdvancedStatsOverviewWidget as BaseWidget;
use EightyNine\FilamentAdvancedWidget\AdvancedStatsOverviewWidget\Stat;
use App\Models\Menu;
use App\Models\Order;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class PosStatsOverview extends BaseWidget
{
    protected static ?string $pollingInterval = '30s';
    protected static ?int $sort = 1;
    protected int | string | array $columnSpan = 'full';

    // Mengatur layout jadi 4 kolom
    protected function getColumns(): int
    {
        return 4;
    }

    protected function getStats(): array
    {
        // --- 1. DATA PEMASUKAN (CHART MERAH/BIRU) ---
        $totalRevenueToday = Order::whereDate('created_at', today())->where('status', 'paid')->sum('total_price');
        $revenueChartData = Order::where('status', 'paid')
            ->whereBetween('created_at', [Carbon::now()->subDays(6), Carbon::now()])
            ->select(DB::raw('DATE(created_at) as date'), DB::raw('SUM(total_price) as total'))
            ->groupBy('date')
            ->orderBy('date', 'asc')
            ->pluck('total')->toArray();

        // --- 2. DATA PESANAN (CHART BIRU MUDA) ---
        $ordersToday = Order::whereDate('created_at', today())->count();
        // Kita buat chart juga untuk pesanan biar seragam
        $ordersChartData = Order::whereBetween('created_at', [Carbon::now()->subDays(6), Carbon::now()])
            ->select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as total'))
            ->groupBy('date')
            ->orderBy('date', 'asc')
            ->pluck('total')->toArray();

        // --- 3. DATA STOK (PROGRESS BAR HIJAU) ---
        $totalMenus = Menu::count();
        $stockOutMenus = Menu::where('stock', 0)->count();
        $stockProgress = $totalMenus > 0 ? (100 - (($stockOutMenus / $totalMenus) * 100)) : 100;

        // --- 4. DATA PELANGGAN (GRAFIK KUNING/ORANYE) ---
        // Angka Utama: Pelanggan unik hari ini
        $customersToday = Order::whereDate('created_at', today())
            ->distinct('customer_name')
            ->count('customer_name');

        // Data Grafik: Tren pelanggan unik 7 hari terakhir
        // Ini kuncinya agar muncul garis grafik!
        $customerChartData = Order::select(DB::raw('DATE(created_at) as date'), DB::raw('count(distinct customer_name) as total'))
            ->whereDate('created_at', '>=', Carbon::now()->subDays(6))
            ->groupBy('date')
            ->orderBy('date', 'asc')
            ->pluck('total')
            ->toArray();

        return [
            // KARTU 1: PEMASUKAN
            Stat::make('Pemasukan Hari Ini', 'Rp ' . number_format($totalRevenueToday, 0, ',', '.'))
                ->icon('heroicon-o-banknotes')
                ->chart($revenueChartData) // <-- Ini yang bikin grafik
                ->chartColor('primary')
                ->backgroundColor('primary')
                ->iconBackgroundColor('primary'),

            // KARTU 2: TOTAL PESANAN
            Stat::make('Pesanan Hari Ini', $ordersToday)
                ->icon('heroicon-o-clipboard-document-list')
                ->chart($ordersChartData) // <-- Saya tambahkan grafik juga disini biar keren
                ->chartColor('info')
                ->backgroundColor('info')
                ->iconBackgroundColor('info'),

            // KARTU 3: STOK (Tetap pakai Progress Bar karena lebih cocok untuk stok)
            Stat::make('Menu Tersedia', ($totalMenus - $stockOutMenus) . " / " . $totalMenus)
                ->icon('heroicon-o-archive-box')
                // ->description("{$stockOutMenus} menu habis")
                ->progress((int) $stockProgress)
                ->progressBarColor($stockProgress > 50 ? 'success' : 'danger')
                ->backgroundColor('success')
                ->iconBackgroundColor('success'),

            // KARTU 4: PELANGGAN (DENGAN GRAFIK!)
            Stat::make('Pelanggan Hari Ini', $customersToday)
                ->icon('heroicon-o-user-group')
                ->description('Tren 7 hari terakhir')
                ->chart($customerChartData) // <--- INI KUNCINYA! Array data dimasukkan ke sini
                ->chartColor('warning') // Warna Kuning/Oranye
                ->backgroundColor('warning')
                ->iconBackgroundColor('warning'),
        ];
    }
}