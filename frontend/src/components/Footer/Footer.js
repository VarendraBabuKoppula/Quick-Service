import React from 'react';
import { Link } from 'react-router-dom';
import './Footer.css';

const Footer = () => {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="footer">
      <div className="footer-container container">
        <div className="footer-section">
          <h3 className="footer-title">QuickService</h3>
          <p className="footer-description">
            Your trusted service marketplace platform. 
            Fast Local Service Discovery and securely.
          </p>
        </div>

        <div className="footer-section">
          <h4 className="footer-heading">Quick Links</h4>
          <ul className="footer-links">
            <li><Link to="/">Home</Link></li>
            <li><Link to="/services">Services</Link></li>
            <li><Link to="/bookings">Bookings</Link></li>
            <li><Link to="/profile">Profile</Link></li>
          </ul>
        </div>

        <div className="footer-section">
          <h4 className="footer-heading">Support</h4>
          <ul className="footer-links">
            <li><a href="#faq">FAQ</a></li>
            <li><a href="#help">Help Center</a></li>
            <li><a href="#contact">Contact Us</a></li>
            <li><a href="#terms">Terms of Service</a></li>
          </ul>
        </div>

        <div className="footer-section">
          <h4 className="footer-heading">Connect</h4>
          <p className="footer-text">
            Email: support@QuickService.com<br />
            Phone: +1 (555) 123-4567
          </p>
        </div>
      </div>

      <div className="footer-bottom">
        <div className="container">
          <p>&copy; {currentYear} QuickService. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
