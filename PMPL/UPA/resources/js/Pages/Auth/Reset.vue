<script setup>
import { ref } from 'vue'

const email = ref('')
</script>

<template>
  <div class="min-h-screen grid grid-cols-1 md:grid-cols-2 bg-black text-white">
    <!-- Left Side with Blue Background -->
    <div class="flex items-center justify-center bg-[#1E4CFF] p-6">
      <img src="/public/images/login.png" alt="Forget Password Visual" class="rounded-xl max-h-[90%] object-contain shadow-xl" />
    </div>

    <!-- Right Side Form -->
    <div class="flex flex-col justify-center px-8 py-12 bg-white text-black">
      <div class="max-w-md w-full mx-auto">
        <h2 class="text-blue-700 font-bold text-lg">LOGOS</h2>
        <h1 class="text-xl font-semibold mt-2">Welcome Back Gan</h1>
        <p class="mt-6 font-bold text-center">Forget Password Here!</p>

        <!-- Form -->
        <form class="mt-4 space-y-4">
          <div>
            <label class="block text-gray-500 text-sm mb-1">Email</label>
            <input
              v-model="email"
              type="email"
              placeholder="Enter your email"
              class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none"
            />
          </div>

          <div class="text-left mt-1">
            <a href="#" class="text-xs text-gray-500 underline decoration-black hover:text-gray-700">Forget Password</a>
          </div>

          <button
            type="submit"
            class="w-full bg-[#1E4CFF] text-white py-3 rounded-md font-semibold hover:bg-blue-800 transition"
          >
            Reset
          </button>
        </form>

        <!-- OR Divider -->
        <div class="flex items-center gap-4 my-6">
          <hr class="flex-grow border-t border-gray-300" />
          <span class="text-sm text-gray-500">Or</span>
          <hr class="flex-grow border-t border-gray-300" />
        </div>

        <!-- Google Sign-in -->
        <button class="w-full flex items-center justify-center gap-3 border rounded-full py-2 shadow-sm hover:shadow-md transition">
          <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="Google" class="w-5 h-5" />
          <span class="text-sm text-gray-700">Sign In With Google</span>
        </button>
      </div>
    </div>
  </div>
</template>
