import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { serviceAPI, bookingAPI, reviewAPI, favoriteAPI } from '../../services/api';
import { useAuth } from '../../context/AuthContext';
import { useToast } from '../../components/Toast/Toast';
import './ServiceDetail.css';

const ServiceDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const toast = useToast();
  const [service, setService] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showBookingForm, setShowBookingForm] = useState(false);
  const [isFavorite, setIsFavorite] = useState(false);
  const [bookingData, setBookingData] = useState({
    bookingDate: '',
    bookingTime: '',
    notes: ''
  });
  const [bookingError, setBookingError] = useState('');
  const [bookingSuccess, setBookingSuccess] = useState('');

  useEffect(() => {
    fetchServiceDetails();
    fetchReviews();
    checkFavoriteStatus();
  }, [id]);

  const checkFavoriteStatus = async () => {
    if (!user) return;
    try {
      const response = await favoriteAPI.checkFavorite(id);
      setIsFavorite(response.data.data);
    } catch (err) {
      // Not favorite or not logged in
    }
  };

  const handleToggleFavorite = async () => {
    if (!user) {
      toast.warning('Please login to save favorites');
      navigate('/login');
      return;
    }
    
    try {
      if (isFavorite) {
        await favoriteAPI.removeFromFavorites(id);
        setIsFavorite(false);
        toast.success('Removed from favorites');
      } else {
        await favoriteAPI.addToFavorites(id);
        setIsFavorite(true);
        toast.success('Added to favorites');
      }
    } catch (err) {
      toast.error('Failed to update favorites');
      setError('Failed to update favorites');
    }
  };

  const fetchServiceDetails = async () => {
    try {
      const response = await serviceAPI.getServiceById(id);
      setService(response.data.data);
      setLoading(false);
    } catch (err) {
      setError('Failed to load service details');
      setLoading(false);
    }
  };

  const fetchReviews = async () => {
    try {
      const response = await reviewAPI.getServiceReviews(id);
      setReviews(response.data.data || []);
    } catch (err) {
      console.error('Failed to load reviews:', err);
    }
  };

  const handleBookingChange = (e) => {
    setBookingData({
      ...bookingData,
      [e.target.name]: e.target.value
    });
  };

  const handleBookingSubmit = async (e) => {
    e.preventDefault();
    setBookingError('');
    setBookingSuccess('');

    if (!user) {
      navigate('/login');
      return;
    }

    try {
      const response = await bookingAPI.createBooking({
        serviceId: parseInt(id),
        bookingDate: bookingData.bookingDate,
        bookingTime: bookingData.bookingTime,
        notes: bookingData.notes
      });
      
      setBookingSuccess('Booking created successfully');
      setShowBookingForm(false);
      setBookingData({ bookingDate: '', bookingTime: '', notes: '' });
      
      setTimeout(() => {
        navigate('/bookings');
      }, 2000);
    } catch (err) {
      setBookingError(err.response?.data?.message || 'Failed to create booking');
    }
  };

  const getTomorrowDate = () => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return tomorrow.toISOString().split('T')[0];
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner"></div>
        <p>Loading service details...</p>
      </div>
    );
  }

  if (error || !service) {
    return (
      <div className="error-container">
        <h2>Service Not Found</h2>
        <p>{error || 'The service you are looking for does not exist.'}</p>
        <button className="btn btn-primary" onClick={() => navigate('/services')}>
          Back to Services
        </button>
      </div>
    );
  }

  return (
    <div className="service-detail-page">
      <div className="container">
        <button className="btn btn-outline back-button" onClick={() => navigate('/services')}>
          Back to Services
        </button>

        <div className="service-detail-container fade-in">
          <div className="service-header-section">
            <div className="service-title-section">
              <h1>{service.serviceName}</h1>
              <span className="service-category-badge">{service.category}</span>
            </div>
            <div className="service-actions-section">
              <button 
                className={`favorite-btn ${isFavorite ? 'favorited' : ''}`}
                onClick={handleToggleFavorite}
                title={isFavorite ? 'Remove from favorites' : 'Add to favorites'}
              >
                <svg 
                  xmlns="http://www.w3.org/2000/svg" 
                  width="24" 
                  height="24" 
                  viewBox="0 0 24 24" 
                  fill={isFavorite ? '#ef4444' : 'none'}
                  stroke="currentColor" 
                  strokeWidth="2" 
                  strokeLinecap="round" 
                  strokeLinejoin="round"
                >
                  <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                </svg>
                {isFavorite ? 'Saved' : 'Save'}
              </button>
              <div className="service-price-section">
                <div className="price-label">Starting at</div>
                <div className="price-value">₹{service.price}</div>
                <div className="duration-label">Duration: {service.durationMinutes} mins</div>
              </div>
            </div>
          </div>

          <div className="service-rating-section">
            <div className="rating-display">
              <span className="rating-stars">{service.averageRating || 0} stars</span>
              <span className="rating-count">({service.totalReviews || 0} reviews)</span>
            </div>
            <div className="availability-badge">
              {service.isAvailable ? 'Available' : 'Not Available'}
            </div>
          </div>

          <div className="service-content-grid">
            <div className="service-main-content">
              <section className="service-section">
                <h3>About This Service</h3>
                <p className="service-description">{service.description}</p>
              </section>

              <section className="service-section">
                <h3>Service Location</h3>
                <div className="location-info">
                  <p><strong>Address:</strong> {service.address}</p>
                  <p><strong>City:</strong> {service.city}, {service.state}</p>
                  <p><strong>Postal Code:</strong> {service.postalCode}</p>
                </div>
              </section>

              {reviews.length > 0 && (
                <section className="service-section">
                  <h3>Customer Reviews ({reviews.length})</h3>
                  <div className="reviews-list">
                    {reviews.map((review) => (
                      <div key={review.id} className="review-card">
                        <div className="review-header">
                          <div className="review-user">{review.userName}</div>
                          <div className="review-rating">{review.rating} stars</div>
                        </div>
                        <p className="review-comment">{review.comment}</p>
                        <div className="review-date">
                          {new Date(review.createdAt).toLocaleDateString()}
                        </div>
                      </div>
                    ))}
                  </div>
                </section>
              )}
            </div>

            <div className="service-sidebar">
              <div className="vendor-card">
                <h3>Service Provider</h3>
                <div className="vendor-info">
                  <p><strong>Name:</strong> {service.vendor?.firstName} {service.vendor?.lastName}</p>
                  <p><strong>Business:</strong> {service.vendor?.businessName}</p>
                  <p><strong>Experience:</strong> {service.vendor?.yearsOfExperience} years</p>
                  <p><strong>Contact:</strong> {service.vendor?.phone}</p>
                  <div className="vendor-rating">
                    <span>{service.vendor?.averageRating || 0} stars</span>
                    <span>({service.vendor?.totalReviews || 0} reviews)</span>
                  </div>
                </div>
              </div>

              {service.isAvailable && (
                <div className="booking-card">
                  {!showBookingForm ? (
                    <button 
                      className="btn btn-primary btn-block"
                      onClick={() => setShowBookingForm(true)}
                    >
                      Book This Service
                    </button>
                  ) : (
                    <div className="booking-form-container">
                      <h3>Book Service</h3>
                      {bookingError && <div className="error-message">{bookingError}</div>}
                      {bookingSuccess && <div className="success-message">{bookingSuccess}</div>}
                      
                      <form onSubmit={handleBookingSubmit}>
                        <div className="form-group">
                          <label htmlFor="bookingDate">Booking Date</label>
                          <input
                            type="date"
                            id="bookingDate"
                            name="bookingDate"
                            value={bookingData.bookingDate}
                            onChange={handleBookingChange}
                            min={getTomorrowDate()}
                            required
                          />
                        </div>

                        <div className="form-group">
                          <label htmlFor="bookingTime">Booking Time</label>
                          <input
                            type="time"
                            id="bookingTime"
                            name="bookingTime"
                            value={bookingData.bookingTime}
                            onChange={handleBookingChange}
                            required
                          />
                        </div>

                        <div className="form-group">
                          <label htmlFor="notes">Additional Notes (Optional)</label>
                          <textarea
                            id="notes"
                            name="notes"
                            value={bookingData.notes}
                            onChange={handleBookingChange}
                            rows="3"
                            placeholder="Any special requirements or instructions"
                          />
                        </div>

                        <div className="form-actions">
                          <button type="submit" className="btn btn-primary btn-block">
                            Confirm Booking
                          </button>
                          <button 
                            type="button" 
                            className="btn btn-outline btn-block"
                            onClick={() => setShowBookingForm(false)}
                          >
                            Cancel
                          </button>
                        </div>
                      </form>
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ServiceDetail;
