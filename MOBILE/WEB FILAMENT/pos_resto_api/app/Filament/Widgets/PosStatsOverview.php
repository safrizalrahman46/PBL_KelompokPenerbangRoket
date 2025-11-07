<?php

namespace App\Filament\Widgets;

// 1. Ganti 'use' BaseWidget
use EightyNine\FilamentAdvancedWidget\AdvancedStatsOverviewWidget as BaseWidget;
use EightyNine\FilamentAdvancedWidget\AdvancedStatsOverviewWidget\Stat;

// Import model Anda
use App\Models\Menu;
use App\Models\Order;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

// 2. Ganti 'extends' BaseWidget
class PosStatsOverview extends BaseWidget
{
    protected static ?string $pollingInterval = '30s';
    protected static ?int $sort = 1; // Urutan pertama

    protected function getStats(): array
    {
        // Data Pemasukan (hanya 'paid')
        $totalRevenueToday = Order::whereDate('created_at', today())
                                ->where('status', 'paid')
                                ->sum('total_price');

        // Data Pesanan (semua status)
        $ordersToday = Order::whereDate('created_at', today())->count();

        // Data Stok
        $totalMenus = Menu::count();
        $stockOutMenus = Menu::where('stock', 0)->count();
        $stockProgress = $totalMenus > 0 ? (100 - (($stockOutMenus / $totalMenus) * 100)) : 100;

        // Data chart mini (7 hari terakhir)
        $revenueChartData = Order::where('status', 'paid')
            ->whereBetween('created_at', [Carbon::now()->subDays(6), Carbon::now()])
            ->select(DB::raw('DATE(created_at) as date'), DB::raw('SUM(total_price) as total'))
            ->groupBy('date')
            ->orderBy('date', 'asc')
            ->pluck('total')
            ->toArray();

        return [
            // Kartu 1: Pemasukan Hari Ini
            Stat::make('Pemasukan Hari Ini', 'Rp ' . number_format($totalRevenueToday, 0, ',', '.'))
                ->icon('heroicon-o-banknotes')
                ->description('Total dari pesanan lunas')
                ->chart($revenueChartData)
                ->chartColor('primary')
                ->backgroundColor('primary')
                ->iconBackgroundColor('primary'),

            // Kartu 2: Pesanan Hari Ini
            Stat::make('Pesanan Hari Ini', $ordersToday)
                ->icon('heroicon-o-clipboard-document-list')
                ->description('Total pesanan masuk')
                ->backgroundColor('info')
                ->iconBackgroundColor('info'),

            // Kartu 3: Stok Menu
            Stat::make('Stok Menu Tersedia', ($totalMenus - $stockOutMenus) . " / " . $totalMenus)
                ->icon('heroicon-o-archive-box')
                ->description("{$stockOutMenus} menu habis stok")
                ->descriptionColor($stockOutMenus > 0 ? 'danger' : 'gray')
                ->progress((int) $stockProgress) // Progress Bar
                ->progressBarColor($stockProgress > 50 ? 'success' : ($stockProgress > 25 ? 'warning' : 'danger'))
                ->backgroundColor('success')
                ->iconBackgroundColor('success'),
        ];
    }
}
