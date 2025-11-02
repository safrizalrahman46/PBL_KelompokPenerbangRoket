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

    0%,
    100% {
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
        /* Geser setengah dari total lebar (hanya set pertama) */
    }
}

.animate-scroll {
    display: flex;
    animation: scroll-left 30s linear infinite;
    width: max-content;
}

/* Untuk menghindari jeda saat hover */
.animate-scroll:hover {
    animation-play-state: paused;
}

.transition {
    transition: all 0.3s ease-in-out;
}

.blob-shape {
    clip-path: path('M0,100 Q50,0 100,100 T200,100');
}

@keyframes scroll {
    0% {
        transform: translateX(0);
    }

    100% {
        transform: translateX(-66.66%);
    }

    /* Geser 1/3 dari lebar total */
}

.animate-scroll {
    animation: scroll 90s linear infinite;
}
</style>

<template>

    <Head title="Home" />

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


    <!-- Hero Section -->
    <section class="bg-white min-h-screen flex items-center">
        <div class="container mx-auto grid md:grid-cols-2 gap-12 items-center px-4">
            <!-- Left Text Content -->
            <div class="space-y-6">
                <h1 class="text-5xl font-bold leading-tight text-blue-900">
                    Rise Your <span class="text-blue-600">{{ displayedText }}</span> And Unlock<br />
                    Global Opportunities with Proven<br />
                    Business English-language <span class="text-blue-600">Proficiency</span>.
                </h1>

                <p class="text-gray-600">
                    Through Technology and Collaboration, We Deliver a Seamless Experience.
                </p>
                <!-- <Button class="bg-blue-700 hover:bg-blue-800 text-white text-2xl px-30 py-6 rounded-xl">
          Register
        </Button> -->
                <a href="/signup"
                    class="bg-blue-700 hover:bg-blue-800 text-white text-xl px-8 py-3 rounded-xl inline-block text-center">
                    Register
                </a>


            </div>

            <!-- Right Image Content -->
            <div class="relative flex justify-center">
                <img src="/public/images/tataletak1.png" alt="Tataletak"
                    class="rounded-3xl shadow-lg max-w-full h-auto" />

                <!-- Bubble 1 -->
                <div
                    class="absolute top-4 right-0 bg-white rounded-2xl shadow-md p-4 flex items-center gap-2 animate-bubble">
                    <svg class="text-blue-600 w-6 h-6" fill="none" stroke="currentColor" stroke-width="2"
                        viewBox="0 0 24 24">
                        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20M4 4h16v13H6.5A2.5 2.5 0 0 1 4 14.5V4z" />
                    </svg>
                    <p class="text-sm font-semibold text-gray-700">
                        Improve Your Future Journey
                    </p>
                </div>

                <!-- Bubble 2 -->
                <div
                    class="absolute bottom-0 left-0 bg-white rounded-2xl shadow-md p-4 flex items-center gap-2 animate-bubble">
                    <svg class="text-blue-600 w-6 h-6" fill="none" stroke="currentColor" stroke-width="2"
                        viewBox="0 0 24 24">
                        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20M4 4h16v13H6.5A2.5 2.5 0 0 1 4 14.5V4z" />
                    </svg>
                    <p class="text-sm font-semibold text-gray-700">
                        Help You To Rise Your Successful<br />Around The World
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- What is PolinemaTOEIC Section -->
    <section class="container mx-auto px-4 py-16 grid md:grid-cols-2 gap-12 items-center">
        <!-- Left image with small bubble button -->
        <!-- Left image with small bubble button -->
        <div class="relative flex justify-center items-center w-full max-w-md mx-auto">
            <img src="/public/images/tataletak2.png" alt="What is PolinemaTOEIC" class="rounded-3xl shadow-lg w-full" />

            <!-- Tanda tanya (?) diletakkan lebih presisi -->
            <div class="absolute top-10 left-[43%] text-blue-600 text-8xl font-bold animate-float">?</div>
            <div class="absolute top-24 left-[78%] text-blue-600 text-7xl font-bold animate-float">?</div>
            <div class="absolute top-36 left-[58%] text-blue-600 text-6xl font-bold animate-float">?</div>



            <!-- Tombol About di tengah bawah -->
            <!-- <div a href="/about"
        class="absolute bottom-4 right-6 bg-blue-700 text-white rounded-full shadow-md px-6 py-2 flex items-center gap-2 hover:bg-blue-800 cursor-pointer">
        <span class="font-semibold">About</span>
        <ArrowRight class="w-4 h-4" />
      </div> -->
            <a href="/about"
                class="absolute bottom-4 right-6 bg-blue-700 text-white rounded-full shadow-md px-6 py-2 flex items-center gap-2 hover:bg-blue-800 cursor-pointer">
                <span class="font-semibold">About</span>
                <ArrowRight class="w-4 h-4" />
            </a>



        </div>




        <!-- Right text -->
        <div class="space-y-6">
            <h2 class="text-5xl font-bold text-black">
                What Is <br />
                <span class="text-black font-bold">Polinema<span class="text-blue-600">TOEIC</span> ?</span>
            </h2>

            <p class="text-gray-700 text-lg leading-relaxed">
                TOEIC exam easier with Polinema Integrated System – quick register, Instant Pay, Real-Time results!
            </p>

            <hr class="my-6 border-black" />

            <div class="flex items-center space-x-4">
                <div class="flex items-center justify-center bg-black text-white w-10 h-10 rounded-full">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8m-18 8h18a2 2 0 002-2V8a2 2 0 00-2-2H3a2 2 0 00-2 2v6a2 2 0 002 2z" />
                    </svg>
                </div>

                <p class="text-gray-700 font-semibold">
                    Start your journey to Global success with TOEIC - all in one easy and reliable Platform.
                </p>
            </div>



        </div>

        <!--
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 mt-8">
        <div class="flex items-center space-x-4">
          <Download class="text-blue-600" size="32" />
          <p class="text-gray-700 font-semibold">Simple Apps</p>
        </div>
        <div class="flex items-center space-x-4">
          <ArrowRight class="text-blue-600" size="32" />
          <p class="text-gray-700 font-semibold">Fastest Registration</p>
        </div>
        <div class="flex items-center space-x-4">
          <MessageCircle class="text-blue-600" size="32" />
          <p class="text-gray-700 font-semibold">Realtime Score</p>
        </div>
      </div> -->
        <!-- </div> -->
    </section>


    <!-- Features Section -->
    <section class="container mx-auto px-4 py-16">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
            <!-- Simple Apps -->
            <div class="flex flex-col items-center space-y-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-12 h-12 text-[#266CFF]" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M4 16v2a2 2 0 002 2h12a2 2 0 002-2v-2M7 10l5 5m0 0l5-5m-5 5V4" />
                </svg>
                <p class="text-blue-900 font-bold text-xl">Simple Apps</p>
                <p class="text-gray-600 text-sm">User friendly application for easy exam management.</p>
            </div>

            <!-- Fastest Registration -->
            <div class="flex flex-col items-center space-y-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-12 h-12 text-[#266CFF]" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M17 8l4 4m0 0l-4 4m4-4H3" />
                </svg>
                <p class="text-blue-900 font-bold text-xl">Fastest Registration</p>
                <p class="text-gray-600 text-sm">Quick registration process to get you started faster.</p>
            </div>

            <!-- Realtime Score -->
            <div class="flex flex-col items-center space-y-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-12 h-12 text-[#266CFF]" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M7 8h10M7 12h4m1 8a9 9 0 110-18 9 9 0 010 18z" />
                </svg>
                <p class="text-blue-900 font-bold text-xl">Realtime Score</p>
                <p class="text-gray-600 text-sm">Get your test results immediately after completing the test.</p>
            </div>
        </div>
    </section>



    <!-- FAQ Section -->
    <section
        class="flex flex-col md:flex-row items-center justify-between bg-[#0629F6] rounded-3xl mx-8 my-16 overflow-hidden relative">

        <!-- KIRI - Text -->
        <div class="flex-1 p-8 md:p-16 text-white space-y-6 z-10">
            <h2 class="text-5xl font-bold">FAQ</h2>
            <p class="text-xl leading-relaxed max-w-md">
                Flexible and planned TOEIC exam schedule – and customize by campus
            </p>
            <!-- <button
                class="bg-white text-[#0024F6] text-lg font-semibold py-3 px-10 rounded-xl hover:bg-gray-100 transition">
                FAQ
            </button> -->

            <a href="/faq"
                class="bg-white text-[#0024F6] text-lg font-semibold py-3 px-10 rounded-xl hover:bg-gray-100 transition inline-block">
                FAQ
            </a>

        </div>

        <!-- KANAN - FAQ Cards -->
        <div class="flex-1 hidden md:block relative h-[550px] p-8 overflow-visible">

            <!-- Card 1 -->
            <div
                class="absolute top-0 left-10 rotate-[-8deg] bg-white rounded-3xl shadow-xl shadow-blue-200 w-[750px] p-6">
                <div class="flex items-center gap-4 mb-4">
                    <div class="w-8 h-8 rounded-full bg-[#265DF2]"></div>
                    <span class="font-bold text-lg">ILHAM</span>
                </div>
                <p class="text-gray-900 text-lg">Is this a reliable website?</p>
            </div>

            <!-- Card 2 -->
            <div
                class="absolute top-28 left-14 rotate-[-3deg] bg-white rounded-3xl shadow-xl shadow-blue-200 w-[750px] p-6">
                <div class="flex items-center gap-4 mb-4">
                    <div class="w-8 h-8 rounded-full bg-[#2F4F99]"></div>
                    <span class="font-bold text-lg">SAFRIZAL</span>
                </div>
                <p class="text-gray-900 text-lg">How to register?, is it trusted yet?</p>
            </div>

            <!-- Card 3 -->
            <div
                class="absolute top-[260px] left-10 rotate-[1deg] bg-white rounded-3xl shadow-xl shadow-blue-200 w-[750px] p-6">
                <div class="flex items-center gap-4 mb-4">
                    <div class="w-8 h-8 rounded-full bg-[#AAAAAA]"></div>
                    <span class="font-bold text-lg">ILHAM</span>
                </div>
                <p class="text-gray-900 text-lg">When is the test scheduled?</p>
            </div>

            <!-- Card 4 -->
            <div
                class="absolute top-[380px] left-14 rotate-[5deg] bg-white rounded-3xl shadow-xl shadow-blue-200 w-[750px] p-6">
                <div class="flex items-center gap-4 mb-4">
                    <div class="w-8 h-8 rounded-full bg-[#2D1B59]"></div>
                    <span class="font-bold text-lg">Ardhio Fatra</span>
                </div>
                <p class="text-gray-900 text-lg">Will the schedule collide with lectures?</p>
            </div>

        </div>

    </section>


    <!-- Testimonials Section -->
    <section class="bg-[#f5f5f5] px-4 py-12 overflow-hidden">
        <div class="relative w-full">
            <div class="animate-scroll flex gap-6 whitespace-nowrap hover:[animation-play-state:paused]">
                <!-- Original Cards -->
                <div class="flex gap-6">
                    <!-- CARD 1 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar1.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Fitri Cahyaniati</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>

                    </div>

                    <!-- CARD 2 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar2.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Sabrina</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <!-- <span class="text-yellow-400 text-sm">½</span> -->

                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 3 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar3.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Cindy</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 4 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar4.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Hanin</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 5 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar5.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Kirana</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 6 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar6.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Nada</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 7 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar7.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Azkiya</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>
                </div>

                <!-- Duplicate Cards (for seamless looping) -->
                <div class="flex gap-6">
                    <!-- CARD 1 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar1.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Fitri Cahyaniati</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 2 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar2.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Sabrina</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 3 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar3.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Cindy</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 4 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar4.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Hanin</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 5 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar5.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Kirana</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 6 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar6.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Nada</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 7 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar7.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Azkiya</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>
                </div>

                <div class="flex gap-6">
                    <!-- CARD 1 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar1.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Fitri Cahyaniati</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 2 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar2.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Sabrina</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 3 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar3.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Cindy</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 4 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar4.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Hanin</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 5 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar5.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Kirana</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 6 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar6.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Nada</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 7 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar7.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Azkiya</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>
                </div>

                <div class="flex gap-6">
                    <!-- CARD 1 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar1.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Fitri Cahyaniati</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 2 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar2.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Sabrina</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 3 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar3.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Cindy</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 4 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar4.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Hanin</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 5 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar5.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Kirana</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 6 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar6.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Nada</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>

                    <!-- CARD 7 -->
                    <div class="flex w-[320px] rounded-[20px] shadow-lg bg-white overflow-hidden">
                        <div class="relative w-[120px] flex-shrink-0">
                            <img src="/public/images/avatar7.png" class="w-full h-full object-cover rounded-[20px]" />
                            <div class="absolute bottom-2 left-2 text-white z-10">
                                <p class="text-sm font-bold drop-shadow">Azkiya</p>
                                <p class="text-xs drop-shadow">College Student</p>
                            </div>
                        </div>
                        <div class="px-4 py-4">
                            <div class="flex items-center mb-1">
                                <!-- Bintang Rating -->
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                                <span class="text-yellow-400 text-sm">★</span>
                            </div>
                            <p class="text-sm text-black leading-snug">"incredibly And helpful."</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>




    <!-- Register Tutorial Section - Versi Desain Sesuai -->




    <!-- Real Time Score Section -->
    <section class="max-w-7xl mx-auto px-4 py-16">
        <div
            class="bg-[#0023E5] text-white rounded-2xl p-8 flex flex-col md:flex-row justify-between items-center gap-6">

            <!-- Grid Skor - lebih rapat -->
            <div class="grid grid-cols-2 gap-4">
                <!-- Baris 1 -->
                <div
                    class="bg-white text-[#0023E5] text-xl font-bold rounded-xl w-28 h-20 flex items-center justify-center">
                    763</div>
                <div
                    class="bg-white text-[#0023E5] text-xl font-bold rounded-xl w-28 h-20 flex items-center justify-center">
                    750</div>

                <!-- Baris 2 -->
                <div
                    class="bg-white text-[#0023E5] text-xl font-bold rounded-xl w-28 h-20 flex items-center justify-center">
                    668</div>
                <div
                    class="bg-white text-[#0023E5] text-xl font-bold rounded-xl w-28 h-20 flex items-center justify-center">
                    667</div>

                <!-- Baris 3 -->
                <div
                    class="bg-white text-[#0023E5] text-xl font-bold rounded-xl w-28 h-20 flex items-center justify-center">
                    755</div>
                <div
                    class="bg-white text-[#0023E5] text-xl font-bold rounded-xl w-28 h-20 flex items-center justify-center">
                    680</div>
            </div>

            <!-- Teks dan Tombol - lebih rapat -->
            <div class="text-center md:text-left">
                <h2 class="text-2xl font-bold leading-tight mb-2">
                    Real Time<br />
                    The highest Score in<br />
                    this month
                </h2>
                <p class="text-base mb-3">Look Your Result in here</p>
                <a href="/login"
                    class="bg-white text-[#0023E5] font-semibold px-5 py-2 rounded-lg text-base hover:bg-gray-100 transition inline-block text-center">
                    Look
                </a>

            </div>

        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-[#0023E5] text-white py-12 px-4">
        <div class="max-w-7xl mx-auto">
            <div class="flex flex-col md:flex-row justify-between gap-8">
                <!-- Contact Info with Icons -->
                <div class="space-y-2">
                    <div class="flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                        </svg>
                        <span>Tosic@course.com</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                        </svg>
                        <span>+1 (201) 897-12413</span>
                    </div>
                </div>

                <!-- Three Column Links -->
                <div class="grid grid-cols-3 gap-8 flex-1 max-w-2xl">
                    <!-- Company Column -->
                    <div>
                        <h4 class="font-bold mb-3">Company</h4>
                        <ul class="space-y-2 text-sm">
                            <li>Blog</li>
                            <li>Careers</li>
                            <li>Pricing</li>
                        </ul>
                    </div>

                    <!-- Resources Column -->
                    <div>
                        <h4 class="font-bold mb-3">Resources</h4>
                        <ul class="space-y-2 text-sm">
                            <li>Documentation</li>
                            <li>Papers</li>
                            <li>Press Conferences</li>
                        </ul>
                    </div>

                    <!-- Legal Column -->
                    <div>
                        <h4 class="font-bold mb-3">Legal</h4>
                        <ul class="space-y-2 text-sm">
                            <li>Terms of Service</li>
                            <li>Privacy Policy</li>
                            <li>Cookies Policy</li>
                        </ul>
                    </div>
                </div>

                <!-- User Info with Icons -->
                <div class="space-y-2">
                    <div class="flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                        </svg>
                        <span>Phone</span>
                    </div>
                    <p class="text-sm ml-7">0313_sec.sec.sec</p>

                    <div class="flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                        <span>Username</span>
                    </div>
                    <p class="text-sm ml-7">Tosi@gmail.com</p>
                </div>
            </div>

            <!-- Copyright -->
            <div class="border-t border-white/20 mt-10 pt-6 text-center">
                <p class="text-sm">© 2025 TOEIC.</p>
            </div>
        </div>
    </footer>
</template>
