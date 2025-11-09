import React from 'react';
import './HeroSection.css';
// Ganti dengan jalur file gambar mockup aplikasi POS mobile Anda
import AppMockup from '../images/logo.png'; 

const HeroSection = () => {
  const handleDownloadClick = () => {
    // Di sini Anda akan menambahkan logika untuk mengarahkan ke link download
    console.log('Tombol DOWNLOAD NOW ditekan!');
    // Contoh: window.location.href = 'LINK_APLIKASI_ANDA';
  };

  return (
    <section className="hero">
      <div className="hero-content">
        
        {/* Kolom Kiri: Teks & CTA */}
        <div className="hero-text">
          
          {/* HEADLINE UTAMA (Opsi 2: Versi Inggris) */}
          <h1 className="hero-headline">
            The Complete F&B POS, Right in Your Hand.
          </h1>
          
          {/* SUB-HEADLINE UTAMA (Opsi 2: Versi Inggris) */}
          <p className="hero-subheadline">
            Streamline every order, sync data in real-time, and manage your entire restaurant from one powerful dashboard.
          </p>
          
          {/* Tombol CTA Primer */}
          <button className="hero-cta-button" onClick={handleDownloadClick}>
            DOWNLOAD NOW
          </button>
    
        </div>

        {/* Kolom Kanan: Visual Marketing */}
        <div className="hero-visual">
          <img 
            src={AppMockup} 
            alt="Eat.o POS Mobile App Mockup on a Smartphone" 
            className="mockup-image"
          />
        </div>

      </div>
    </section>
  );
};

export default HeroSection;