<script setup>
import { ref } from 'vue'
</script>

<template>
  <div class="min-h-screen grid grid-cols-1 md:grid-cols-2 bg-white">
    <!-- Left Side Image -->
    <div class="flex items-center justify-center bg-[#1E4CFF] p-6">
      <img src="/public/images/login.png" alt="Login Visual" class="rounded-xl max-h-[90%] object-contain" />
    </div>

    <!-- Right Side Form -->
    <div class="flex flex-col justify-center px-8 py-12">
      <div class="max-w-md w-full mx-auto">
        <h2 class="text-blue-700 font-bold text-lg">LOGOS</h2>
        <h1 class="text-xl font-semibold mt-2">Welcome Back Gan</h1>
        <p class="mt-6 font-bold text-center">Sign In Here!</p>


        <!-- Form -->
        <form class="mt-4 space-y-4">
          <div>
            <label class="block text-gray-400 text-sm mb-1">Email</label>
            <input type="email" placeholder="Enter your email"
              class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" />
          </div>
          <div>
            <label class="block text-gray-400 text-sm mb-1">Password</label>
            <input type="password" placeholder="Enter your password"
              class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" />
          </div>

          <div class="text-right">
            <a href="#" class="text-sm text-gray-600 underline decoration-black hover:text-gray-800">Forget Password</a>
          </div>

          <button type="submit" class="w-full bg-[#1E4CFF] text-white py-3 rounded-md font-semibold hover:bg-blue-800 transition">
            Sign In
          </button>
        </form>


      </div>
    </div>
  </div>
</template>
