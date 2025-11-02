<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Lupa Password</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tailwindcss@^2/dist/tailwind.min.css">
</head>

<body class="bg-blue-50">

    <div class="min-h-screen grid grid-cols-1 md:grid-cols-2 bg-white">
        <!-- Left Image Section -->
        <div class="flex items-center justify-center bg-[#1E4CFF] p-8">
            <div class="bg-white rounded-xl p-4">
                <img src="{{ asset('images/login.png') }}" alt="Forgot Password Visual"
                    class="rounded-xl max-h-[90vh] object-contain">
            </div>
        </div>

        <!-- Right Form Section -->
        <div class="flex flex-col justify-center px-8 py-12">
            <div class="max-w-md w-full mx-auto">
                <h2 class="text-blue-700 font-bold text-lg">LOGOS</h2>
                <h1 class="text-xl font-semibold mt-2">Forgot Your Password?</h1>
                <p class="text-sm text-gray-500 mt-1 mb-6">
                    Enter your email and we’ll send you a password reset link.
                </p>

                @if (session('status'))
                    <div class="bg-green-100 text-green-800 px-4 py-2 rounded text-sm mb-4">
                        {{ session('status') }}
                    </div>
                @endif

                <form method="POST" action="{{ route('password.email') }}" class="space-y-4">
                    @csrf

                    <div>
                        <label class="block text-gray-400 text-sm mb-1">Email</label>
                        <input name="email" type="email" value="{{ old('email') }}"
                            class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required>
                        @error('email')
                            <p class="text-red-500 text-sm">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="pt-4">
                        <button type="submit"
                            class="w-full bg-blue-600 text-white py-3 rounded-md hover:bg-blue-700 transition">
                            Kirim Link Reset Password
                        </button>
                    </div>
                </form>

                <div class="text-center mt-4">
                    <a href="{{ route('login') }}" class="text-sm text-blue-600 hover:underline">
                        ← Kembali ke Login
                    </a>
                </div>
            </div>
        </div>
    </div>

</body>

</html>
