import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import './App.css';

// Components
import Navbar from './components/Navbar/Navbar';
import Footer from './components/Footer/Footer';
import Home from './pages/Home/Home';
import Login from './pages/Auth/Login';
import Register from './pages/Auth/Register';
import Profile from './pages/Profile/Profile';
import Services from './pages/Services/Services';
import ServiceDetail from './pages/Services/ServiceDetail';
import Bookings from './pages/Bookings/Bookings';
import BookingDetail from './pages/Bookings/BookingDetail';
import Addresses from './pages/Addresses/Addresses';
import Favorites from './pages/Favorites/Favorites';

// Utils
import { AuthProvider } from './context/AuthContext';
import PrivateRoute from './components/PrivateRoute/PrivateRoute';

/**
 * Bookaro Main Application Component
 * Phase 1: User Module (Customer Side)
 */
function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="app">
          <Navbar />
          <main className="main-content">
            <Routes>
              {/* Public Routes */}
              <Route path="/" element={<Home />} />
              <Route path="/login" element={<Login />} />
              <Route path="/register" element={<Register />} />

              {/* Protected Routes */}
              <Route path="/profile" element={
                <PrivateRoute>
                  <Profile />
                </PrivateRoute>
              } />
              <Route path="/addresses" element={
                <PrivateRoute>
                  <Addresses />
                </PrivateRoute>
              } />
              <Route path="/favorites" element={
                <PrivateRoute>
                  <Favorites />
                </PrivateRoute>
              } />
              <Route path="/services" element={
                <PrivateRoute>
                  <Services />
                </PrivateRoute>
              } />
              <Route path="/services/:id" element={
                <PrivateRoute>
                  <ServiceDetail />
                </PrivateRoute>
              } />
              <Route path="/bookings" element={
                <PrivateRoute>
                  <Bookings />
                </PrivateRoute>
              } />
              <Route path="/bookings/:id" element={
                <PrivateRoute>
                  <BookingDetail />
                </PrivateRoute>
              } />

              {/* Fallback */}
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </main>
          <Footer />
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
