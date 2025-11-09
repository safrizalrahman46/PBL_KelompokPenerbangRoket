import React from 'react';
import './HeroSection.css';

// Import gambar mockup
import MockupMenu from '../images/mockup3.png';   // tampilan menu
import MockupOrder from '../images/mockup2.png';  // tampilan order
import MockupLogo from '../images/mockup1.png';   // logo

const HeroSection = () => {
  return (
    <section className="hero">
      <div className="hero-content">

        {/* Kiri: Teks */}
        <div className="hero-text">
          <h1 className="hero-title">The Complete F&B POS, Right in Your Hand.</h1>
          <p className="hero-subtitle">
            Manage every order, track table status, and update your menu instantly.
            Get <strong>real-time data sync</strong> via robust API—no more data errors.
          </p>
          <button className="hero-btn">Try Demo</button>
        </div>

        {/* Kanan: Mockup Section */}
        <div className="hero-visual">
          <div className="mockup-top">
            <img src={MockupMenu} alt="POS Menu Mockup" className="hero-img float delay1" />
            <img src={MockupOrder} alt="POS Order Mockup" className="hero-img float delay2" />
          </div>
          <div className="mockup-bottom">
            <img src={MockupLogo} alt="App Logo Mockup" className="hero-img float delay3" />
          </div>
        </div>

      </div>
    </section>
  );
};

export default HeroSection;
