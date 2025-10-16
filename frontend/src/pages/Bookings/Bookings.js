import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { bookingAPI } from '../../services/api';
import './Bookings.css';

const Bookings = () => {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');

  useEffect(() => {
    fetchBookings();
  }, [statusFilter]);

  const fetchBookings = async () => {
    setLoading(true);
    setError('');
    try {
      const response = await bookingAPI.getUserBookings(
        statusFilter === 'ALL' ? null : statusFilter
      );
      setBookings(response.data.data || []);
      setLoading(false);
    } catch (err) {
      setError('Failed to load bookings');
      setLoading(false);
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      PENDING: '#f59e0b',
      CONFIRMED: '#3b82f6',
      COMPLETED: '#10b981',
      CANCELLED: '#ef4444'
    };
    return colors[status] || '#6b7280';
  };

  const getStatusLabel = (status) => {
    const labels = {
      PENDING: 'Pending',
      CONFIRMED: 'Confirmed',
      COMPLETED: 'Completed',
      CANCELLED: 'Cancelled'
    };
    return labels[status] || status;
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner"></div>
        <p>Loading bookings...</p>
      </div>
    );
  }

  return (
    <div className="bookings-page">
      <div className="container">
        <div className="bookings-header fade-in">
          <h1>My Bookings</h1>
          <p>Manage and track all your service bookings</p>
        </div>

        <div className="bookings-filter fade-in">
          <button
            className={`filter-btn ${statusFilter === 'ALL' ? 'active' : ''}`}
            onClick={() => setStatusFilter('ALL')}
          >
            All
          </button>
          <button
            className={`filter-btn ${statusFilter === 'PENDING' ? 'active' : ''}`}
            onClick={() => setStatusFilter('PENDING')}
          >
            Pending
          </button>
          <button
            className={`filter-btn ${statusFilter === 'CONFIRMED' ? 'active' : ''}`}
            onClick={() => setStatusFilter('CONFIRMED')}
          >
            Confirmed
          </button>
          <button
            className={`filter-btn ${statusFilter === 'COMPLETED' ? 'active' : ''}`}
            onClick={() => setStatusFilter('COMPLETED')}
          >
            Completed
          </button>
          <button
            className={`filter-btn ${statusFilter === 'CANCELLED' ? 'active' : ''}`}
            onClick={() => setStatusFilter('CANCELLED')}
          >
            Cancelled
          </button>
        </div>

        {error && <div className="error-message">{error}</div>}

        {bookings.length > 0 ? (
          <div className="bookings-grid">
            {bookings.map((booking) => (
              <Link
                key={booking.id}
                to={`/bookings/${booking.id}`}
                className="booking-card"
              >
                <div className="booking-header">
                  <h3>{booking.serviceName}</h3>
                  <span
                    className="booking-status"
                    style={{ backgroundColor: getStatusColor(booking.status) }}
                  >
                    {getStatusLabel(booking.status)}
                  </span>
                </div>

                <div className="booking-details">
                  <div className="booking-detail-row">
                    <span className="detail-label">Booking ID:</span>
                    <span className="detail-value">#{booking.id}</span>
                  </div>
                  <div className="booking-detail-row">
                    <span className="detail-label">Date:</span>
                    <span className="detail-value">
                      {new Date(booking.bookingDate).toLocaleDateString()}
                    </span>
                  </div>
                  <div className="booking-detail-row">
                    <span className="detail-label">Time:</span>
                    <span className="detail-value">{booking.bookingTime}</span>
                  </div>
                  <div className="booking-detail-row">
                    <span className="detail-label">Service Provider:</span>
                    <span className="detail-value">{booking.vendorName}</span>
                  </div>
                </div>

                {booking.notes && (
                  <div className="booking-notes">
                    <strong>Notes:</strong> {booking.notes}
                  </div>
                )}

                <div className="booking-footer">
                  <span className="booking-date-created">
                    Booked on {new Date(booking.createdAt).toLocaleDateString()}
                  </span>
                  <span className="view-details">View Details →</span>
                </div>
              </Link>
            ))}
          </div>
        ) : (
          <div className="no-bookings">
            <h2>No Bookings Found</h2>
            <p>
              {statusFilter === 'ALL'
                ? 'You have not made any bookings yet'
                : `You have no ${statusFilter.toLowerCase()} bookings`}
            </p>
            <Link to="/services" className="btn btn-primary">
              Browse Services
            </Link>
          </div>
        )}
      </div>
    </div>
  );
};

export default Bookings;
