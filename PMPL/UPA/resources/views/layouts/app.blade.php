<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        body { background-color: #f2f2f2; }
        .sidebar { min-height: 100vh; background-color: white; }
        .content-wrapper { padding: 20px; }
    </style>
</head>
<body>

<div class="d-flex">
    @include('layouts.sidebar')

    <div class="flex-grow-1">
        @include('layouts.header')

        <div class="content-wrapper">
            @yield('content')
        </div>

        @include('layouts.footer')
    </div>
</div>

</body>
@stack('scripts')

</html>
