import React from 'react';
import Navbar from './assets/components/Navbar';
import './App.css'; // Pastikan ada file CSS global jika diperlukan
import HeroSection from './assets/components/HeroSection'; 

function App() {
  return (
    <div className="App">
      <Navbar />
            <HeroSection />

      {/* Konten aplikasi Anda lainnya di sini */}
      <main style={{ padding: '20px', textAlign: 'center' }}>
        <h1>Selamat Datang di Web React Saya!</h1>
        <p>Navbar telah dibuat sesuai permintaan.</p>
      </main>
    </div>
  );
}

export default App;