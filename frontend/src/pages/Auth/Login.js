import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import './Auth.css';

const Login = () => {
  const [formData, setFormData] = useState({
    email: 'user@bookaro.com',
    password: 'password123',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const { login } = useAuth();
  const navigate = useNavigate();

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    const result = await login(formData.email, formData.password);

    if (result.success) {
      navigate('/services');
    } else {
      setError(result.message);
    }
    setLoading(false);
  };

  const handleQuickLogin = async (email, password) => {
    setLoading(true);
    setError('');
    setFormData({ email, password });

    const result = await login(email, password);

    if (result.success) {
      navigate('/services');
    } else {
      setError(result.message);
    }
    setLoading(false);
  };

  return (
    <div className="auth-page">
      <div className="auth-container fade-in">
        <div className="auth-card">
          <h1 className="auth-title">Welcome Back</h1>
          <p className="auth-subtitle">Sign in to continue to Bookaro</p>

          {error && <div className="alert alert-error">{error}</div>}

          <form onSubmit={handleSubmit} className="auth-form">
            <div className="form-group">
              <label htmlFor="email">Email Address</label>
              <input
                type="email"
                id="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                placeholder="you@example.com"
                required
              />
            </div>

            <div className="form-group">
              <label htmlFor="password">Password</label>
              <input
                type="password"
                id="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                placeholder="Enter your password"
                required
              />
            </div>

            <button type="submit" className="btn btn-auth-primary" disabled={loading}>
              {loading ? 'Signing in...' : 'Sign In'}
            </button>
          </form>

          <div style={{ marginTop: '20px', padding: '15px', background: '#f0f4f8', borderRadius: '8px' }}>
            <p style={{ fontSize: '14px', marginBottom: '10px', color: '#1e3a8a', fontWeight: '600' }}>Quick Login (Test Accounts):</p>
            <div style={{ display: 'flex', gap: '10px', flexDirection: 'column' }}>
              <button
                onClick={() => handleQuickLogin('user@bookaro.com', 'password123')}
                disabled={loading}
                style={{
                  padding: '8px 12px',
                  background: '#2563eb',
                  color: 'white',
                  border: 'none',
                  borderRadius: '6px',
                  cursor: 'pointer',
                  fontSize: '13px'
                }}
              >
                Login as User
              </button>
              <button
                onClick={() => handleQuickLogin('vendor@bookaro.com', 'password123')}
                disabled={loading}
                style={{
                  padding: '8px 12px',
                  background: '#2563eb',
                  color: 'white',
                  border: 'none',
                  borderRadius: '6px',
                  cursor: 'pointer',
                  fontSize: '13px'
                }}
              >
                Login as Vendor
              </button>
              <button
                onClick={() => handleQuickLogin('admin@bookaro.com', 'admin123')}
                disabled={loading}
                style={{
                  padding: '8px 12px',
                  background: '#2563eb',
                  color: 'white',
                  border: 'none',
                  borderRadius: '6px',
                  cursor: 'pointer',
                  fontSize: '13px'
                }}
              >
                Login as Admin
              </button>
            </div>
          </div>

          <p className="auth-footer">
            Don't have an account?{' '}
            <Link to="/register" className="auth-link">
              Sign up now
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
