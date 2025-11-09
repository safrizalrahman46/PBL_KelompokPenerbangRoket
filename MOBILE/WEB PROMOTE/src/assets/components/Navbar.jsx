import React from 'react';
import './Navbar.css';
import Logo from '../images/logo.png'; // Pastikan jalur file logo Anda benar

const Navbar = () => {
  return (
    <nav className="navbar">
      {/* 1. KONTENER PEMBUNGKUS BARU untuk mengatur lebar maksimal di tengah */}
      <div className="navbar-content"> 
        
        {/* Kiri: Logo Eat.o */}
        <div className="navbar-logo">
          <img src={Logo} alt="Logo Eat.o" className="logo-image" />
          <span className="logo-text-label">Eat.o</span> 
        </div>

        {/* Tengah: Menu Navigasi Sederhana */}
        <ul className="navbar-links">
          <li><a href="#home">Home</a></li>
          <li><a href="#tentang">Tentang</a></li> 
          {/* Mengganti 'Hubungi Kami' dengan 'Kontak' sesuai kode Anda */}
          <li><a href="#kontak">Kontak</a></li> 
        </ul>

        {/* Kanan: Tombol Aksi (CTA) */}
        <div className="navbar-actions">
          {/* Tombol Search (🔍) DIHAPUS, karena tidak ada di menu sederhana Anda */}
          <button className="cta-button">
            DOWNLOAD NOW
          </button>
        </div>
      
      </div> {/* Penutup navbar-content */}
    </nav>
  );
};

export default Navbar;