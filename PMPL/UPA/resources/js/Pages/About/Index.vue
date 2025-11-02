<script setup>
import { Head } from '@inertiajs/vue3'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { ArrowRight, Download, MessageCircle } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'

// Typing-deleting animation setup
const journeyText = '#Journey'
const displayedText = ref('')
let index = 0
let isDeleting = false

onMounted(() => {
  const typingInterval = setInterval(() => {
    if (!isDeleting) {
      if (index < journeyText.length) {
        displayedText.value += journeyText[index]
        index++
      } else {
        isDeleting = true
        setTimeout(() => { }, 1000)
      }
    } else {
      if (index > 0) {
        displayedText.value = journeyText.substring(0, index - 1)
        index--
      } else {
        isDeleting = false
      }
    }
  }, 150)
})
</script>

<style scoped>
@keyframes bubbleMovement {
  0% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
  100% {
    transform: translateY(0);
  }
}

.animate-bubble {
  animation: bubbleMovement 2s infinite ease-in-out;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

.animate-float {
  animation: float 3s ease-in-out infinite;
}

@keyframes scroll-left {
  0% {
    transform: translateX(0);
  }
  100% {
    transform: translateX(-50%);
  }
}

.animate-scroll {
  display: flex;
  animation: scroll-left 30s linear infinite;
  width: max-content;
}

.animate-scroll:hover {
  animation-play-state: paused;
}

.transition {
  transition: all 0.3s ease-in-out;
}

.blob-shape {
  clip-path: path('M0,100 Q50,0 100,100 T200,100');
}
</style>

<template>
    <div>
      <!-- Header -->
     <header class="bg-white shadow-sm">
  <div class="container mx-auto flex items-center justify-between py-4 px-4">
    <div class="text-2xl font-bold text-blue-900">
      <a href="/">UPA</a>
    </div>

    <nav class="hidden md:flex gap-8 text-blue-900 font-semibold">
      <a href="/" class="hover:text-blue-600">Home</a>
      <a href="/about" class="hover:text-blue-600">About</a>
      <a href="/faq" class="hover:text-blue-600">FAQ</a>
    </nav>

    <div class="flex gap-2">
      <a href="/signup">
        <button class="text-blue-900 border border-blue-900 px-4 py-2 rounded hover:bg-blue-50">
          Sign Up
        </button>
      </a>
      <a href="/login">
        <button class="bg-blue-700 hover:bg-blue-800 text-white px-4 py-2 rounded">
          Login
        </button>
      </a>
    </div>
  </div>
</header>

      <main>
        <Head title="Home" />

        <!-- Hero Section -->
        <section class="text-center py-12">
          <h1 class="text-2xl md:text-3xl font-bold leading-tight text-black">
            Rise Your <span class="text-blue-600 font-bold">#Journey</span> And Unlock<br />
            Global opportunities with proven<br />
            <span class="text-black font-bold">Business English-language Proficiency.</span>
          </h1>
          <p class="mt-4 text-sm text-gray-500">
            Rise Your <span class="text-blue-600">#Journey</span> And Unlock Global opportunities with proven
            Business English-language Proficiency.
          </p>
          <div class="mt-6">
            <img
              src="/public/images/hero-library.png"
              alt="Students in library"
              class="w-full h-auto object-cover ml-0 mr-auto block"
            />
          </div>
        </section>

        <!-- Statement Section -->
        <section class="py-12">
          <div class="max-w-5xl mx-auto px-6 text-left">
            <h2 class="text-xl md:text-2xl font-bold text-black leading-snug">
              Rise Your <span class="text-blue-600">#Journey</span> And Unlock Global<br />
              opportunities with proven<br />
              Business English-language Proficiency.
            </h2>
          </div>
        </section>

        <!-- Three Columns Section -->
        <section class="py-16 bg-white max-w-6xl mx-auto px-6 text-center">
          <div class="grid md:grid-cols-3 gap-12">
            <div>
              <h3 class="text-3xl font-bold text-black mb-6">01</h3>
              <p class="text-lg text-black font-semibold leading-relaxed">
                Rise Your <span class="text-blue-600">#Journey</span> And Unlock<br />
                Global opportunities with proven<br />
                Business English-language<br />
                Proficiency.
              </p>
            </div>
            <div>
              <h3 class="text-3xl font-bold text-black mb-6">02</h3>
              <p class="text-lg text-black font-semibold leading-relaxed">
                Rise Your <span class="text-blue-600">#Journey</span> And Unlock<br />
                Global opportunities with proven<br />
                Business English-language<br />
                Proficiency.
              </p>
            </div>
            <div>
              <h3 class="text-3xl font-bold text-black mb-6">03</h3>
              <p class="text-lg text-black font-semibold leading-relaxed">
                Rise Your <span class="text-blue-600">#Journey</span> And Unlock<br />
                Global opportunities with proven<br />
                Business English-language<br />
                Proficiency.
              </p>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-6 items-stretch mt-12">
            <div class="overflow-hidden rounded-xl shadow-md">
              <img src="/public/images/img-01.png" class="w-full h-full object-cover" />
            </div>
            <div class="overflow-hidden rounded-xl shadow-md">
              <img src="/public/images/img-02.png" class="w-full h-full object-cover" />
            </div>
            <div class="overflow-hidden rounded-xl shadow-md">
              <img src="/public/images/img-03.png" class="w-full h-full object-cover" />
            </div>
          </div>
        </section>

        <!-- Text and Image Section -->
        <section class="py-16 bg-white max-w-6xl mx-auto px-6">
          <div class="flex flex-col md:flex-row items-center md:items-start justify-center gap-8">
            <div class="md:w-1/2 text-gray-800 leading-relaxed text-base">
              <p class="text-justify">
                isisesajnjsnakn isisesajnjsnaknisisesajnjsnaknisisesaj
                njsnaknisisesajnjsnaknisisesajnjsnakni sisesajnjsnaknisisesajnjsnaknisisesajn
                jsnaknisisesajnjsnaknisisesajnjsnaknis esajnjsnaknisisesajnjsnaknisisesajnjsn
                aknisisesajnjsnaknisisesajnjsnaknisisesaj nsaknisisesajnjsnaknisisesajnjsnaknisi
                sisesajnjsnaknisisesajnjsnaknisisesajns aknisisesajnjsnakn
              </p>
            </div>
            <div class="md:w-1/2">
              <img src="/public/images/img-04.png" />
            </div>
          </div>
        </section>

        <!-- Bottom Image -->
        <section>
          <img src="/public/images/empty-classroom.png" alt="Empty classroom" class="w-full object-cover h-64 md:h-auto block" />
        </section>
      </main>

      <!-- Footer -->
      <footer class="bg-[#0023E5] text-white py-12 px-4">
        <div class="max-w-7xl mx-auto">
          <div class="flex flex-col md:flex-row justify-between gap-8">
            <div class="space-y-2">
              <p>Toeic@course.com</p>
              <p>+1 (201) 897-12413</p>
            </div>

            <div class="grid grid-cols-3 gap-8 flex-1 max-w-2xl">
              <div>
                <h4 class="font-bold mb-3">Company</h4>
                <ul class="space-y-2 text-sm">
                  <li>Blog</li>
                  <li>Careers</li>
                  <li>Pricing</li>
                </ul>
              </div>
              <div>
                <h4 class="font-bold mb-3">Resources</h4>
                <ul class="space-y-2 text-sm">
                  <li>Documentation</li>
                  <li>Papers</li>
                  <li>Press Conferences</li>
                </ul>
              </div>
              <div>
                <h4 class="font-bold mb-3">Legal</h4>
                <ul class="space-y-2 text-sm">
                  <li>Terms of Service</li>
                  <li>Privacy Policy</li>
                  <li>Cookies Policy</li>
                </ul>
              </div>
            </div>

            <div class="space-y-2">
              <p>Phone</p>
              <p class="text-sm">0851-xxxx-xxxxx</p>
              <p>Username</p>
              <p class="text-sm">Tueinggrad4.com</p>
            </div>
          </div>
          <div class="border-t border-white/20 mt-10 pt-6 text-center">
            <p class="text-sm">© 2025 TOEIC.</p>
          </div>
        </div>
      </footer>
    </div>
  </template>

