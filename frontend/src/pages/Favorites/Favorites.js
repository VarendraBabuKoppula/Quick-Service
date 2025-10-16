import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { favoriteAPI } from '../../services/api';
import './Favorites.css';

const Favorites = () => {
  const [favorites, setFavorites] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchFavorites();
  }, []);

  const fetchFavorites = async () => {
    try {
      setLoading(true);
      const response = await favoriteAPI.getFavorites();
      setFavorites(response.data.data || []);
      setLoading(false);
    } catch (err) {
      setError('Failed to load favorites');
      setLoading(false);
    }
  };

  const handleRemoveFavorite = async (serviceId) => {
    try {
      await favoriteAPI.removeFromFavorites(serviceId);
      setFavorites(favorites.filter(service => service.id !== serviceId));
    } catch (err) {
      setError('Failed to remove from favorites');
    }
  };

  if (loading) {
    return <div className="loading">Loading favorites...</div>;
  }

  return (
    <div className="favorites-page">
      <div className="container">
        <div className="favorites-header">
          <h1>My Favorites</h1>
          <p>Quick access to your favorite services</p>
        </div>

        {error && <div className="error-message">{error}</div>}

        {favorites.length === 0 ? (
          <div className="no-favorites">
            <div className="empty-state">
              <svg className="heart-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
              </svg>
              <h2>No favorites yet</h2>
              <p>Start adding services to your favorites for quick access</p>
              <Link to="/services" className="btn btn-primary">
                Browse Services
              </Link>
            </div>
          </div>
        ) : (
          <div className="favorites-grid">
            {favorites.map((service) => (
              <div key={service.id} className="favorite-card">
                <div className="favorite-header">
                  <Link to={`/services/${service.id}`} className="service-link">
                    <h3>{service.serviceName}</h3>
                  </Link>
                  <button
                    className="remove-favorite-btn"
                    onClick={() => handleRemoveFavorite(service.id)}
                    title="Remove from favorites"
                  >
                    <svg viewBox="0 0 24 24" fill="currentColor">
                      <path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                    </svg>
                  </button>
                </div>

                <div className="service-category">
                  {service.category}
                </div>

                <p className="service-description">
                  {service.description && service.description.length > 120
                    ? `${service.description.substring(0, 120)}...`
                    : service.description}
                </p>

                <div className="service-details">
                  <div className="service-location">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    {service.city}, {service.state}
                  </div>

                  {service.averageRating > 0 && (
                    <div className="service-rating">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="gold" stroke="gold">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                      </svg>
                      {service.averageRating.toFixed(1)} ({service.totalReviews})
                    </div>
                  )}
                </div>

                <div className="favorite-footer">
                  <div className="service-price">
                    Rs. {service.price?.toLocaleString()}
                  </div>
                  <Link
                    to={`/services/${service.id}`}
                    className="btn btn-primary btn-sm"
                  >
                    Book Now
                  </Link>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Favorites;
