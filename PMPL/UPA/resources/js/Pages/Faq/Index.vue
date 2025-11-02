<script setup>
import { ref } from 'vue'
import { ChevronDown } from 'lucide-vue-next'

const faqs = ref([
  { question: 'What is TOEIC?', answer: 'TOEIC is a test that measures English language proficiency for international communication.', open: false },
  { question: 'How do I register?', answer: 'You can register through the registration page on our website.', open: false },
  { question: 'Is there an age limit?', answer: 'TOEIC can be taken by anyone without any age restriction.', open: false },
  { question: 'How much does the test cost?', answer: 'The test fee varies depending on the location and schedule.', open: false },
  { question: 'How long does it take to get the results?', answer: 'Results are usually available within 5–10 business days.', open: false },
])


function toggle(index) {
  faqs.value[index].open = !faqs.value[index].open
}
</script>

<template>
  <div class="min-h-screen flex flex-col justify-between">
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

    <!-- FAQ Section -->
    <main class="flex-1 py-16 bg-white px-4">
      <div class="max-w-3xl mx-auto text-center mb-12">
        <h1 class="text-2xl md:text-3xl font-bold mb-2">Frequently Asked Questions</h1>
        <p class="text-gray-500 text-sm">
          Stuck on something? We’re here to help with all your questions and answers in one place.
        </p>
      </div>

      <div class="max-w-4xl mx-auto space-y-6">
        <div
          v-for="(faq, index) in faqs"
          :key="index"
          class="border-b pb-4"
        >
          <div class="flex items-start justify-between gap-4 cursor-pointer" @click="toggle(index)">
            <div class="flex gap-4">
              <div class="w-12 h-12 bg-white shadow rounded-xl flex items-center justify-center">
                <img src="/public/images/shield.svg" alt="icon" class="w-6 h-6" />
              </div>
              <div>
                <h3 class="text-lg font-bold text-black">{{ faq.question }}</h3>
              </div>
            </div>
            <button
              class="p-2 transition-transform duration-300"
              :class="{ 'rotate-180': faq.open }"
            >
              <ChevronDown class="w-5 h-5 text-black" />
            </button>
          </div>

          <transition name="accordion">
            <div
              v-show="faq.open"
              class="ml-16 mt-2 text-sm text-gray-600 overflow-hidden"
            >
              <p class="pb-2">{{ faq.answer }}</p>
            </div>
          </transition>
        </div>
      </div>
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
            <p class="text-sm">0851-xxx-xxx</p>
            <p>Username</p>
            <p class="text-sm">toeic@gmail.com</p>
          </div>
        </div>
        <div class="border-t border-white/20 mt-10 pt-6 text-center">
          <p class="text-sm">© 2025 TOEIC.</p>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.accordion-enter-active,
.accordion-leave-active {
  transition: all 0.3s ease;
}
.accordion-enter-from,
.accordion-leave-to {
  max-height: 0;
  opacity: 0;
}
.accordion-enter-to,
.accordion-leave-from {
  max-height: 500px;
  opacity: 1;
}
</style>
