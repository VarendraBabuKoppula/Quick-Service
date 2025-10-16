import React, { useState, useEffect } from 'react';
import { addressAPI } from '../../services/api';
import { useToast } from '../../components/Toast/Toast';
import './Addresses.css';

const Addresses = () => {
  const toast = useToast();
  const [addresses, setAddresses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [editingAddress, setEditingAddress] = useState(null);
  const [formData, setFormData] = useState({
    addressType: 'HOME',
    addressLine1: '',
    addressLine2: '',
    city: '',
    state: '',
    postalCode: '',
    landmark: '',
    isDefault: false,
  });

  useEffect(() => {
    fetchAddresses();
  }, []);

  const fetchAddresses = async () => {
    try {
      setLoading(true);
      const response = await addressAPI.getUserAddresses();
      setAddresses(response.data.data || []);
      setLoading(false);
    } catch (err) {
      setError('Failed to load addresses');
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({
      ...formData,
      [name]: type === 'checkbox' ? checked : value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editingAddress) {
        await addressAPI.updateAddress(editingAddress.id, formData);
        toast.success('Address updated successfully');
      } else {
        await addressAPI.createAddress(formData);
        toast.success('Address added successfully');
      }
      setShowForm(false);
      setEditingAddress(null);
      resetForm();
      fetchAddresses();
    } catch (err) {
      const errorMsg = err.response?.data?.message || 'Failed to save address';
      setError(errorMsg);
      toast.error(errorMsg);
    }
  };

  const handleEdit = (address) => {
    setEditingAddress(address);
    setFormData({
      addressType: address.addressType,
      addressLine1: address.addressLine1,
      addressLine2: address.addressLine2 || '',
      city: address.city,
      state: address.state,
      postalCode: address.postalCode,
      landmark: address.landmark || '',
      isDefault: address.isDefault,
    });
    setShowForm(true);
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this address?')) {
      try {
        await addressAPI.deleteAddress(id);
        toast.success('Address deleted successfully');
        fetchAddresses();
      } catch (err) {
        const errorMsg = 'Failed to delete address';
        setError(errorMsg);
        toast.error(errorMsg);
      }
    }
  };

  const handleSetDefault = async (id) => {
    try {
      await addressAPI.setDefaultAddress(id);
      toast.success('Default address updated');
      fetchAddresses();
    } catch (err) {
      const errorMsg = 'Failed to set default address';
      setError(errorMsg);
      toast.error(errorMsg);
    }
  };

  const resetForm = () => {
    setFormData({
      addressType: 'HOME',
      addressLine1: '',
      addressLine2: '',
      city: '',
      state: '',
      postalCode: '',
      landmark: '',
      isDefault: false,
    });
  };

  const handleCancel = () => {
    setShowForm(false);
    setEditingAddress(null);
    resetForm();
  };

  if (loading) {
    return <div className="loading">Loading addresses...</div>;
  }

  return (
    <div className="addresses-page">
      <div className="container">
        <div className="addresses-header">
          <h1>My Addresses</h1>
          <button
            className="btn btn-primary"
            onClick={() => setShowForm(true)}
          >
            Add New Address
          </button>
        </div>

        {error && <div className="error-message">{error}</div>}

        {showForm && (
          <div className="address-form-card">
            <h2>{editingAddress ? 'Edit Address' : 'Add New Address'}</h2>
            <form onSubmit={handleSubmit}>
              <div className="form-row">
                <div className="form-group">
                  <label>Address Type *</label>
                  <select
                    name="addressType"
                    value={formData.addressType}
                    onChange={handleInputChange}
                    required
                  >
                    <option value="HOME">Home</option>
                    <option value="OFFICE">Office</option>
                    <option value="OTHER">Other</option>
                  </select>
                </div>
              </div>

              <div className="form-group">
                <label>Address Line 1 *</label>
                <input
                  type="text"
                  name="addressLine1"
                  value={formData.addressLine1}
                  onChange={handleInputChange}
                  placeholder="House/Flat No., Building Name"
                  required
                />
              </div>

              <div className="form-group">
                <label>Address Line 2</label>
                <input
                  type="text"
                  name="addressLine2"
                  value={formData.addressLine2}
                  onChange={handleInputChange}
                  placeholder="Street, Area"
                />
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>City *</label>
                  <input
                    type="text"
                    name="city"
                    value={formData.city}
                    onChange={handleInputChange}
                    required
                  />
                </div>

                <div className="form-group">
                  <label>State *</label>
                  <input
                    type="text"
                    name="state"
                    value={formData.state}
                    onChange={handleInputChange}
                    required
                  />
                </div>

                <div className="form-group">
                  <label>Postal Code *</label>
                  <input
                    type="text"
                    name="postalCode"
                    value={formData.postalCode}
                    onChange={handleInputChange}
                    required
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Landmark</label>
                <input
                  type="text"
                  name="landmark"
                  value={formData.landmark}
                  onChange={handleInputChange}
                  placeholder="Nearby landmark (optional)"
                />
              </div>

              <div className="form-group checkbox-group">
                <label>
                  <input
                    type="checkbox"
                    name="isDefault"
                    checked={formData.isDefault}
                    onChange={handleInputChange}
                  />
                  Set as default address
                </label>
              </div>

              <div className="form-actions">
                <button type="submit" className="btn btn-primary">
                  {editingAddress ? 'Update Address' : 'Save Address'}
                </button>
                <button
                  type="button"
                  className="btn btn-outline"
                  onClick={handleCancel}
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        )}

        <div className="addresses-list">
          {addresses.length === 0 ? (
            <div className="no-addresses">
              <p>No Delivery Addresses Saved</p>
              <p>
                Save your frequently used addresses to make bookings faster and easier.
                Add your home, office, or other locations now!
              </p>
              <button
                className="btn btn-primary"
                onClick={() => setShowForm(true)}
              >
                Add Your First Address
              </button>
            </div>
          ) : (
            addresses.map((address) => (
              <div key={address.id} className="address-card">
                <div className="address-header">
                  <div className="address-type-badge">
                    {address.addressType}
                  </div>
                  {address.isDefault && (
                    <span className="default-badge">Default</span>
                  )}
                </div>

                <div className="address-details">
                  <p className="address-line">
                    {address.addressLine1}
                    {address.addressLine2 && `, ${address.addressLine2}`}
                  </p>
                  <p className="address-line">
                    {address.city}, {address.state} - {address.postalCode}
                  </p>
                  {address.landmark && (
                    <p className="address-landmark">
                      Landmark: {address.landmark}
                    </p>
                  )}
                </div>

                <div className="address-actions">
                  {!address.isDefault && (
                    <button
                      className="btn btn-sm btn-outline"
                      onClick={() => handleSetDefault(address.id)}
                    >
                      Set as Default
                    </button>
                  )}
                  <button
                    className="btn btn-sm btn-outline"
                    onClick={() => handleEdit(address)}
                  >
                    Edit
                  </button>
                  <button
                    className="btn btn-sm btn-danger"
                    onClick={() => handleDelete(address.id)}
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default Addresses;
