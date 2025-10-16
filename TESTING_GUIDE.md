# Bookaro - End-to-End Testing Guide

## Pre-Testing Setup

### 1. Start Backend Server
```powershell
cd d:\Springboard\backend
mvn spring-boot:run
```

**Expected Output:**
- Server starts on port 8080
- Database tables created: `addresses` and `favorites` (new)
- DataInitializer creates 3 test users + 1 vendor + 3 services
- Server ready message appears

**Verify Database Tables:**
```powershell
$env:PGPASSWORD='root'
psql -U postgres -d bookarodb -c "\dt"
```

Expected tables: users, vendors, services, bookings, reviews, **addresses**, **favorites**

### 2. Start Frontend Server
```powershell
cd d:\Springboard\frontend
npm start
```

**Expected Output:**
- Development server starts on port 3000
- Browser opens automatically to http://localhost:3000
- No console errors in browser

---

## Testing Checklist

### 🔐 Authentication Testing
**Test Credentials:**
- User: `user@bookaro.com` / `password123`
- Vendor: `vendor@bookaro.com` / `password123`
- Admin: `admin@bookaro.com` / `admin123`

#### Test Cases:
- [ ] **TC-AUTH-01**: Login with valid credentials
  - Navigate to /login
  - Enter user@bookaro.com / password123
  - Click Login button
  - **Expected**: Redirect to home page, navbar shows user menu

- [ ] **TC-AUTH-02**: Login with invalid credentials
  - Enter wrong password
  - **Expected**: Error message "Login failed"

- [ ] **TC-AUTH-03**: Logout functionality
  - Click Logout in navbar
  - **Expected**: Redirect to home, navbar shows Login/Register

- [ ] **TC-AUTH-04**: Protected route access
  - Without login, navigate to /addresses
  - **Expected**: Redirect to /login

---

### 🏠 Address Management Testing

#### Test Cases:
- [ ] **TC-ADDR-01**: View empty addresses page
  - Login and navigate to /addresses
  - **Expected**: Empty state or message if no addresses

- [ ] **TC-ADDR-02**: Create HOME address
  - Click "Add New Address" button
  - Fill form:
    - Type: HOME
    - Address Line 1: "123 Main Street"
    - City: "Mumbai"
    - State: "Maharashtra"
    - Postal Code: "400001"
    - Landmark: "Near Central Park"
    - Check "Set as Default"
  - Click Save
  - **Expected**: Address created, displayed in grid with "Default" badge

- [ ] **TC-ADDR-03**: Create OFFICE address
  - Click "Add New Address"
  - Fill form with OFFICE type
  - Do NOT check "Set as Default"
  - Click Save
  - **Expected**: Address created, no default badge

- [ ] **TC-ADDR-04**: Create OTHER address
  - Similar to ADDR-03 with OTHER type
  - **Expected**: Address created successfully

- [ ] **TC-ADDR-05**: Edit existing address
  - Click Edit on any address
  - Change address line 1 to "456 New Street"
  - Click Update
  - **Expected**: Address updated, form closes

- [ ] **TC-ADDR-06**: Set different address as default
  - Click "Set as Default" on OFFICE address
  - **Expected**: 
    - OFFICE address now has "Default" badge
    - Previous default loses "Default" badge
    - Only one default address

- [ ] **TC-ADDR-07**: Delete address
  - Click Delete on any non-default address
  - Confirm in dialog
  - **Expected**: Address removed from list

- [ ] **TC-ADDR-08**: Form validation
  - Click "Add New Address"
  - Leave required fields empty
  - Try to submit
  - **Expected**: Validation messages (fields marked with *)

- [ ] **TC-ADDR-09**: Cancel add/edit
  - Click "Add New Address"
  - Fill some fields
  - Click Cancel
  - **Expected**: Form closes, no address created

---

### ❤️ Favorites Testing

#### Test Cases:
- [ ] **TC-FAV-01**: View empty favorites page
  - Navigate to /favorites
  - **Expected**: Empty state with heart icon, "Browse Services" button

- [ ] **TC-FAV-02**: Add to favorites from Services page
  - Navigate to /services
  - Click heart icon on any service card
  - **Expected**: 
    - Heart fills with red color
    - Border turns red
    - Background changes to light red

- [ ] **TC-FAV-03**: Verify favorite persists
  - Refresh the page
  - **Expected**: Heart icon still red/filled for favorited service

- [ ] **TC-FAV-04**: Add to favorites from ServiceDetail page
  - Click on a service card to view details
  - Click "Save" button (with heart icon)
  - **Expected**: 
    - Button text changes to "Saved"
    - Button styling changes (red border, light red background)

- [ ] **TC-FAV-05**: View favorites list
  - Navigate to /favorites
  - **Expected**: 
    - Grid of favorited services displayed
    - Each card shows: name, category, description, location, rating, price
    - Heart icon (filled red) visible on each card

- [ ] **TC-FAV-06**: Remove from favorites (Favorites page)
  - On /favorites page, click heart icon on any service
  - **Expected**: 
    - Service removed from favorites list immediately
    - If last favorite, empty state appears

- [ ] **TC-FAV-07**: Remove from favorites (Services page)
  - Navigate to /services
  - Click heart icon on a favorited service (red heart)
  - **Expected**: 
    - Heart becomes outline (unfilled)
    - Service removed from favorites

- [ ] **TC-FAV-08**: Sync between pages
  - Add favorite on Services page
  - Navigate to ServiceDetail page for that service
  - **Expected**: "Saved" button shows favorited state
  - Navigate to /favorites
  - **Expected**: Service appears in favorites list

- [ ] **TC-FAV-09**: Book from favorites
  - On /favorites page, click "Book Now" button
  - **Expected**: Redirect to service detail page

- [ ] **TC-FAV-10**: Favorite without login
  - Logout
  - Navigate to /services
  - Click heart icon
  - **Expected**: Error message or redirect to login

---

### 🔍 Service Search & Filters Testing

#### Test Cases:
- [ ] **TC-SEARCH-01**: View all services
  - Navigate to /services
  - **Expected**: Grid of services displayed (pagination if > 9)

- [ ] **TC-SEARCH-02**: Filter by category
  - Click "Toggle Filters"
  - Select category (e.g., "Plumbing")
  - Click Search
  - **Expected**: Only plumbing services displayed

- [ ] **TC-SEARCH-03**: Filter by city
  - Select city: "Mumbai"
  - Click Search
  - **Expected**: Only Mumbai services displayed

- [ ] **TC-SEARCH-04**: Filter by price range
  - Enter Min Price: 1000
  - Enter Max Price: 2000
  - Click Search
  - **Expected**: Only services priced between ₹1000-₹2000

- [ ] **TC-SEARCH-05**: Filter by minimum rating
  - Select Min Rating: 4
  - Click Search
  - **Expected**: Only services with rating ≥ 4

- [ ] **TC-SEARCH-06**: Combined filters
  - Category: "Cleaning"
  - City: "Mumbai"
  - Min Price: 1000
  - Max Price: 3000
  - Min Rating: 3
  - **Expected**: Services matching all criteria

- [ ] **TC-SEARCH-07**: Sort by price (low to high)
  - Click "Price ↑" sort button
  - **Expected**: Services sorted by price ascending

- [ ] **TC-SEARCH-08**: Sort by rating (high to low)
  - Click "Rating ↓" sort button
  - **Expected**: Services sorted by rating descending

- [ ] **TC-SEARCH-09**: Sort by name
  - Click "Name" sort button
  - Click again to toggle direction
  - **Expected**: Services sorted alphabetically

- [ ] **TC-SEARCH-10**: Pagination
  - If > 9 services, navigate to page 2
  - **Expected**: Next set of services displayed

---

### 📅 Booking Management Testing

#### Test Cases:
- [ ] **TC-BOOK-01**: Create booking from service detail
  - Navigate to any service detail page
  - Click "Book This Service" button
  - Fill form:
    - Date: Tomorrow or later
    - Time: Any valid time
    - Notes: "Test booking"
  - Click "Confirm Booking"
  - **Expected**: 
    - Success message
    - Redirect to /bookings after 2 seconds

- [ ] **TC-BOOK-02**: View bookings list
  - Navigate to /bookings
  - **Expected**: List of all user bookings with status badges

- [ ] **TC-BOOK-03**: View booking details
  - Click on any booking card
  - **Expected**: 
    - Redirect to /bookings/{id}
    - Full booking details displayed
    - Service information shown
    - Status badge visible

- [ ] **TC-BOOK-04**: Cancel booking
  - On booking detail page (PENDING status)
  - Click "Cancel Booking" button
  - Confirm
  - **Expected**: 
    - Status changes to CANCELLED
    - Cancel button disabled

- [ ] **TC-BOOK-05**: Booking validation
  - Try to book with past date
  - **Expected**: Validation error

---

### ⭐ Reviews Testing

#### Test Cases:
- [ ] **TC-REV-01**: View service reviews
  - Navigate to any service detail page
  - Scroll to reviews section
  - **Expected**: Existing reviews displayed (if any)

- [ ] **TC-REV-02**: Write review (with completed booking)
  - If you have a COMPLETED booking:
    - On service detail page, find "Write a Review" section
    - Select rating (1-5 stars)
    - Enter comment: "Great service!"
    - Click Submit Review
    - **Expected**: Review added to list

- [ ] **TC-REV-03**: Review without completed booking
  - Try to review a service you haven't used
  - **Expected**: Message "Complete a booking first" or similar

---

### 👤 Profile Management Testing

#### Test Cases:
- [ ] **TC-PROF-01**: View profile
  - Navigate to /profile
  - **Expected**: User details displayed (email, name, phone)

- [ ] **TC-PROF-02**: Update profile
  - Change first name to "Updated Name"
  - Click Update Profile
  - **Expected**: Success message, profile updated

---

### 📱 Responsive Design Testing

#### Test Cases (Resize browser or use DevTools):
- [ ] **TC-RESP-01**: Mobile view (< 768px)
  - Check all pages
  - **Expected**: 
    - Navbar collapses to hamburger menu (if implemented)
    - Grids change to single column
    - Buttons stack vertically
    - Text remains readable

- [ ] **TC-RESP-02**: Tablet view (768px - 1024px)
  - **Expected**: 
    - Grids show 2 columns
    - Layout adapts smoothly

- [ ] **TC-RESP-03**: Desktop view (> 1024px)
  - **Expected**: 
    - Full grid layouts (3 columns for services)
    - All features accessible

---

### 🎨 Theme Consistency Testing

#### Visual Checks:
- [ ] **TC-THEME-01**: Color consistency
  - Navigate through all pages
  - **Expected**: 
    - Headers: Navy Blue (#1a2332)
    - CTAs: Royal Blue (#2563eb)
    - Success: Green (#10b981)
    - Danger: Red (#ef4444)
    - Backgrounds: White/Light Gray

- [ ] **TC-THEME-02**: Button styles
  - Check all buttons across pages
  - **Expected**: Consistent hover effects, colors, sizes

- [ ] **TC-THEME-03**: Card designs
  - **Expected**: Uniform shadows, borders, spacing

---

## Bug Reporting Template

If you find any issues, document them as follows:

```
**Bug ID**: BUG-001
**Severity**: Critical | High | Medium | Low
**Page**: /addresses
**Test Case**: TC-ADDR-02
**Steps to Reproduce**:
1. Navigate to /addresses
2. Click "Add New Address"
3. Fill all fields
4. Click Save

**Expected Result**: Address created and displayed

**Actual Result**: Error message appears

**Console Errors**: [Paste any browser console errors]

**Screenshots**: [Attach if relevant]
```

---

## Performance Testing

### Load Time Checks:
- [ ] Home page loads < 2 seconds
- [ ] Services page loads < 3 seconds (with filters)
- [ ] No console errors on any page
- [ ] No network request failures (check Network tab)

### Database Queries:
- [ ] Check backend logs for slow queries
- [ ] Verify pagination reduces data load

---

## Security Testing

- [ ] **SEC-01**: JWT token stored in localStorage
- [ ] **SEC-02**: Protected routes redirect to login
- [ ] **SEC-03**: Can't access other users' data
- [ ] **SEC-04**: Passwords not visible in network requests

---

## Final Checklist

Before marking testing complete:
- [ ] All critical test cases passed
- [ ] No blocker bugs found
- [ ] Performance acceptable
- [ ] Mobile responsive
- [ ] No console errors
- [ ] Backend logs clean (no exceptions)
- [ ] All features documented work correctly

---

## Known Limitations (Expected Behavior)

1. **CSV Data Loader**: Disabled, only test data from DataInitializer
2. **Phase 2/3 Features**: Vendor dashboard, Admin panel not implemented
3. **Payment**: Not integrated (planned for future)
4. **Notifications**: Not real-time (planned for future)
5. **Location**: No map integration yet (planned for future)

---

## Success Criteria

✅ **Phase 1 Complete** when:
- All 9 user features working:
  1. User registration/login ✅
  2. Profile management ✅
  3. Service browsing/search ✅
  4. Service details ✅
  5. Booking creation ✅
  6. Booking management ✅
  7. Reviews & ratings ✅
  8. **Address management** ✅ (NEW)
  9. **Favorites/Wishlist** ✅ (NEW)

- All test cases pass (at least 90% coverage)
- No critical or high severity bugs
- Application runs without crashes
- Performance acceptable (page loads < 3 seconds)

---

## Next Steps After Testing

1. Fix any bugs found
2. Update documentation with test results
3. Create production deployment plan
4. Begin Phase 2 planning (Vendor Module)

---

**Happy Testing! 🚀**
