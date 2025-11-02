<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tailwindcss@^2/dist/tailwind.min.css">
</head>
<body class="bg-blue-50">
    <div class="min-h-screen flex items-center justify-center px-4">
        <div class="bg-white shadow-md rounded-md p-8 w-full max-w-md">
            <h2 class="text-2xl font-semibold text-blue-700 mb-4">Reset Password</h2>

            @if (session('status'))
                <div class="bg-green-100 text-green-800 px-4 py-2 rounded text-sm mb-4">
                    {{ session('status') }}
                </div>
            @endif

            <form method="POST" action="{{ route('password.update') }}" class="space-y-4">
                @csrf

                <input type="hidden" name="token" value="{{ $token }}">

                <div>
                    <label class="block text-sm text-gray-600">Email</label>
                    <input name="email" type="email" value="{{ old('email') }}"
                        class="w-full px-4 py-2 bg-gray-100 rounded-md focus:outline-none" required>
                    @error('email')
                        <p class="text-red-500 text-sm">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm text-gray-600">New Password</label>
                    <input name="password" type="password"
                        class="w-full px-4 py-2 bg-gray-100 rounded-md focus:outline-none" required>
                    @error('password')
                        <p class="text-red-500 text-sm">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-sm text-gray-600">Confirm Password</label>
                    <input name="password_confirmation" type="password"
                        class="w-full px-4 py-2 bg-gray-100 rounded-md focus:outline-none" required>
                </div>

                <button type="submit"
                    class="w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700 transition">
                    Reset Password
                </button>
            </form>
        </div>
    </div>
</body>
</html>
