<script setup>
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'
import axios from 'axios'


// Ambil CSRF token dari meta tag
const token = document.head.querySelector('meta[name="csrf-token"]');

if (token) {
    axios.defaults.headers.common['X-CSRF-TOKEN'] = token.content;
} else {
    console.error('CSRF token not found: https://laravel.com/docs/csrf#csrf-x-csrf-token');
}

const props = defineProps({
    studyPrograms: Array,
    majors: Array
})

const currentStep = ref(1)
const totalSteps = 2

const form = ref({
    // Step 1 fields
    username: '',
    email: '',
    password: '',
    password_confirmation: '',

    // Step 2 fields
    name: '',
    nim: '',
    nik: '',
    phone: '',
    origin_address: '',
    current_address: '',
    study_program_id: '',
    major_id: '',
    campus: 'Main',
})

const nextStep = () => {
    // Validate step 1 fields before proceeding
    if (!form.value.username || !form.value.email || !form.value.password || !form.value.password_confirmation) {
        alert('Please fill all required fields')
        return
    }

    if (form.value.password !== form.value.password_confirmation) {
        alert('Passwords do not match')
        return
    }

    currentStep.value++
}

const prevStep = () => {
    currentStep.value--
}

const submit = () => {
    router.post('/signup', {
        ...form.value,
        role_name: 'student',
        role_description: 'Regular student user',
        has_registered_free_toeic: false
    }, {
        onSuccess: () => {
            router.visit('/dashboard')
        },
        onError: (errors) => {
            alert('There were errors with your submission. Please check the form.')
        }
    })
}
</script>

<template>
    <div class="min-h-screen grid grid-cols-1 md:grid-cols-2 bg-white">
        <!-- Left Image Section -->
        <div class="flex items-center justify-center bg-[#1E4CFF] p-6">
            <img src="/public/images/login.png" alt="Signup Visual" class="rounded-xl max-h-[90%] object-contain" />
        </div>

        <!-- Right Form Section -->
        <div class="flex flex-col justify-center px-8 py-12">
            <div class="max-w-md w-full mx-auto">
                <h2 class="text-blue-700 font-bold text-lg">LOGOS</h2>
                <h1 class="text-xl font-semibold mt-2">Sign Up For Free Tho!</h1>

                <!-- Step indicator -->
                <div class="flex items-center justify-between mb-6">
                    <div v-for="step in totalSteps" :key="step" class="flex flex-col items-center">
                        <div :class="[
                            'w-8 h-8 rounded-full flex items-center justify-center',
                            currentStep >= step ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-600'
                        ]">
                            {{ step }}
                        </div>
                        <span class="text-xs mt-1" :class="currentStep >= step ? 'text-blue-600' : 'text-gray-400'">
                            {{ step === 1 ? 'Account' : 'Profile' }}
                        </span>
                    </div>
                </div>

                <!-- Form -->
                <form @submit.prevent="submit" class="mt-6 space-y-4">
                    <!-- Step 1: Account Information -->
                    <div v-if="currentStep === 1" class="space-y-4">
                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Username</label>
                            <input v-model="form.username" type="text" placeholder="Enter your username"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required />
                        </div>
                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Email</label>
                            <input v-model="form.email" type="email" placeholder="Enter your email"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required />
                        </div>
                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Password</label>
                            <input v-model="form.password" type="password" placeholder="Enter your password"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required />
                        </div>
                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Retype Password</label>
                            <input v-model="form.password_confirmation" type="password"
                                placeholder="Retype your password"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required />
                        </div>
                    </div>

                    <!-- Step 2: Personal Information -->
                    <div v-if="currentStep === 2" class="space-y-4">
                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Full Name</label>
                            <input v-model="form.name" type="text" placeholder="Enter your full name"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required />
                        </div>

                        <div>
                            <label class="block text-gray-400 text-sm mb-1">NIM</label>
                            <input v-model="form.nim" type="text" placeholder="Enter your NIM"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required />
                        </div>

                        <div>
                            <label class="block text-gray-400 text-sm mb-1">NIK</label>
                            <input v-model="form.nik" type="text" placeholder="Enter your NIK"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required />
                        </div>

                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Phone Number</label>
                            <input v-model="form.phone" type="tel" placeholder="Enter your phone number"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required />
                        </div>

                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Origin Address</label>
                            <textarea v-model="form.origin_address" placeholder="Enter your origin address"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required></textarea>
                        </div>

                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Current Address</label>
                            <textarea v-model="form.current_address" placeholder="Enter your current address"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required></textarea>
                        </div>

                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Study Program</label>
                            <select v-model="form.study_program_id"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required>
                                <option value="" disabled selected>Select Study Program</option>
                                <option v-for="program in studyPrograms" :key="program.id" :value="program.id">
                                    {{ program.name }}
                                </option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Major</label>
                            <select v-model="form.major_id"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required>
                                <option value="" disabled selected>Select Major</option>
                                <option v-for="major in majors" :key="major.id" :value="major.id">
                                    {{ major.name }}
                                </option>
                            </select>
                        </div>

                        <!-- <div>
              <label class="block text-gray-400 text-sm mb-1">Study Program</label>
              <select v-model="form.study_program_id" class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required>
                <option value="" disabled selected>Select Study Program</option>
                <option v-for="program in studyPrograms" :key="program.id" :value="program.id">
                  {{ program.name }}
                </option>
              </select>
            </div>

            <div>
              <label class="block text-gray-400 text-sm mb-1">Major</label>
              <select v-model="form.major_id" class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required>
                <option value="" disabled selected>Select Major</option>
                <option v-for="major in majors" :key="major.id" :value="major.id">
                  {{ major.name }}
                </option>
              </select>
            </div> -->

                        <div>
                            <label class="block text-gray-400 text-sm mb-1">Campus</label>
                            <select v-model="form.campus"
                                class="w-full px-4 py-3 bg-gray-100 rounded-md focus:outline-none" required>
                                <option value="Main">Main</option>
                                <option value="PSDKU Kediri">PSDKU Kediri</option>
                                <option value="PSDKU Lumajang">PSDKU Lumajang</option>
                                <option value="PSDKU Pamekasan">PSDKU Pamekasan</option>
                            </select>
                        </div>
                    </div>

                    <!-- Navigation Buttons -->
                    <div class="flex gap-4 pt-4">
                        <button v-if="currentStep > 1" @click="prevStep" type="button"
                            class="flex-1 border border-[#1E4CFF] text-[#1E4CFF] bg-white py-3 rounded-md font-semibold shadow hover:shadow-md transition">
                            Back
                        </button>

                        <button v-if="currentStep < totalSteps" @click="nextStep" type="button"
                            class="flex-1 bg-[#1E4CFF] text-white py-3 rounded-md font-semibold hover:bg-blue-800 transition">
                            Next
                        </button>

                        <button v-if="currentStep === totalSteps" type="submit"
                            class="flex-1 bg-[#1E4CFF] text-white py-3 rounded-md font-semibold hover:bg-blue-800 transition">
                            Sign Up
                        </button>
                    </div>
                </form>

                <div class="text-center mt-4">
                    <span class="text-sm text-gray-600">Already have an account? </span>
                    <a href="/login" class="text-sm text-blue-600 hover:underline">Log in</a>
                </div>
            </div>
        </div>
    </div>
</template>
