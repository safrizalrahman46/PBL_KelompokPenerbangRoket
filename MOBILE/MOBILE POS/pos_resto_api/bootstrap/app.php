<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
// use \Illuminate\Http\Middleware\HandleCors::class;
use Illuminate\Http\Middleware\HandleCors; // <-- 1. TAMBAHKAN INI

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        //
        $middleware->prepend(HandleCors::class);

    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
