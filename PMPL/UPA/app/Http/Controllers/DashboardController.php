<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        // Data kartu
        $totalRegistrations = DB::table('toeic_registration')->count();
        $paidRegistrations = DB::table('toeic_registration')->where('status', 'paid')->count();
        $certUploaded = DB::table('toeic_registration')->whereNotNull('certificate_path')->count();

        // Data tabel
        $registrations = DB::table('toeic_registration')->get();

        // Data grafik bulanan
        $monthlyData = DB::table('toeic_registration')
            ->selectRaw('MONTH(registration_date) as month, COUNT(*) as total')
            ->groupBy('month')
            ->pluck('total', 'month')
            ->toArray();

        // Buat array 12 bulan
        $monthlyCounts = [];
        for ($i = 1; $i <= 12; $i++) {
            $monthlyCounts[] = $monthlyData[$i] ?? 0;
        }

        return view('dashboard.index', compact(
            'totalRegistrations',
            'paidRegistrations',
            'certUploaded',
            'registrations',
            'monthlyCounts'
        ));
    }
}

