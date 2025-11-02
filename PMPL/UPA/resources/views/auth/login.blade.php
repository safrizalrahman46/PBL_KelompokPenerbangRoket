<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Login</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tailwindcss@^2/dist/tailwind.min.css">
</head>

<body class="bg-blue-50">

    <div class="min-h-screen grid grid-cols-1 md:grid-cols-2 bg-white">
        <!-- Left Image Section -->
        <div class="flex items-center justify-center bg-[#1E4CFF] p-8">
            <div class="bg-white rounded-xl p-4">
                <img src="{{ asset('images/login.png') }}" alt="Login Visual"
                    class="rounded-xl max-h-[90vh] object-contain">
            </div>
        </div>

        <!-- Right Form Section -->
        <div class="flex flex-col justify-center px-8 py-12">
            <div class="max-w-md w-full mx-auto">
                <h2 class="text-blue-700 font-bold text-lg">LOGOS</h2>
                <h1 class="text-xl font-semibold mt-2">Welcome Back!</h1>

                {{--  <form action="{{ route('login') }}" method="POST" class="mt-6 space-y-4">
                      --}}
                      <form action="{{ route('login.post') }}" method="POST" class="mt-6 space-y-4">

                    @csrf

                    <div>
                        <label class="block text-gray-400 text-sm mb-1">Email</label>
                        <input name="email" type="email" value="{{ old('email') }}"
                            class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required>
                        @error('email')
                            <p class="text-red-500 text-sm">{{ $message }}</p>
                        @enderror
                    </div>

                    <div>
                        <label class="block text-gray-400 text-sm mb-1">Password</label>
                        <input name="password" type="password"
                            class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required>
                        @error('password')
                            <p class="text-red-500 text-sm">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="text-right">
                        <a href="{{ route('password.request') }}"
                            class="text-sm text-blue-600 hover:underline">Forgot Password?</a>
                    </div>

                    <div class="pt-4">
                        <button type="submit" class="w-full bg-gray-300 text-black py-3 rounded-md">
                            Login
                        </button>
                    </div>

                    {{--  <div class="flex items-center justify-center my-4">
                        <div class="border-t w-1/4"></div>
                        <span class="px-2 text-sm text-gray-400">Or</span>
                        <div class="border-t w-1/4"></div>
                    </div>

                    <button type="button"
                        class="w-full flex items-center justify-center border border-gray-300 py-3 rounded-md hover:bg-gray-100">
                        <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg"
                            alt="Google Icon" class="w-5 h-5 mr-2">
                        <span class="text-sm">Sign In with Google</span>
                    </button>
                </form>  --}}

                <div class="text-center mt-4">
                    <span class="text-sm text-gray-400">Don’t have an account?</span>
                    <a href="{{ route('signup.index') }}" class="text-sm text-blue-600 hover:underline">Sign up</a>
                </div>
            </div>
        </div>
    </div>

</body>

</html>
