# 🚀 Bookaro Quick Start Guide

## Start the Application

### 1. Start Backend (Terminal 1)
```powershell
cd d:\Springboard\backend
mvn spring-boot:run
```
**Wait for**: "Started BookaroApplication" message

### 2. Start Frontend (Terminal 2)
```powershell
cd d:\Springboard\frontend
npm start
```
**Opens**: http://localhost:3000 automatically

---

## Quick Test Flow

### Login
1. Go to http://localhost:3000/login
2. Email: `user@bookaro.com`
3. Password: `password123`
4. Click Login

### Test New Features

#### ❤️ **Favorites**
1. Navigate to **Services** (navbar)
2. Click the **heart icon** on any service card
3. Navigate to **Favorites** (navbar)
4. See your saved service
5. Click heart icon to remove

#### 🏠 **Addresses**
1. Navigate to **Addresses** (navbar)
2. Click **"Add New Address"**
3. Fill the form:
   - Type: HOME
   - Address Line 1: "123 Main St"
   - City: "Mumbai"
   - State: "Maharashtra"
   - Postal Code: "400001"
   - Check "Set as Default"
4. Click **Save**
5. See your address in the grid

---

## Key URLs

| Feature | URL |
|---------|-----|
| Home | http://localhost:3000 |
| Services | http://localhost:3000/services |
| Favorites | http://localhost:3000/favorites |
| Addresses | http://localhost:3000/addresses |
| My Bookings | http://localhost:3000/bookings |
| Profile | http://localhost:3000/profile |

---

## Test Credentials

| Role | Email | Password |
|------|-------|----------|
| User | user@bookaro.com | password123 |
| Vendor | vendor@bookaro.com | password123 |
| Admin | admin@bookaro.com | admin123 |

---

## Verify Database

```powershell
$env:PGPASSWORD='root'
psql -U postgres -d bookarodb

# Inside psql:
\dt                          # List all tables
SELECT COUNT(*) FROM addresses;
SELECT COUNT(*) FROM favorites;
SELECT COUNT(*) FROM services;
```

---

## Common Issues

### Backend won't start
- Check if port 8080 is already in use
- Verify PostgreSQL is running
- Check database credentials in `application.properties`

### Frontend won't start
- Check if port 3000 is already in use
- Run `npm install` if dependencies missing
- Clear browser cache

### "Table doesn't exist" error
- Restart backend to create new tables
- Check `spring.jpa.hibernate.ddl-auto=validate` in `application.properties`

---

## What to Test

### ✅ Must Test
- [ ] Login/Logout
- [ ] Create address (all 3 types: HOME, OFFICE, OTHER)
- [ ] Set default address
- [ ] Add service to favorites (from Services page)
- [ ] Add service to favorites (from ServiceDetail page)
- [ ] View favorites list
- [ ] Remove from favorites
- [ ] Browse services with filters
- [ ] Create booking
- [ ] View booking details

### 📱 Also Test
- [ ] Mobile view (resize browser to < 768px)
- [ ] Heart icons sync across pages
- [ ] Navigation links work
- [ ] Logout clears favorites/addresses state

---

## Full Documentation

| Document | Purpose |
|----------|---------|
| `TESTING_GUIDE.md` | Complete test cases (49 total) |
| `IMPLEMENTATION_SUMMARY.md` | Feature overview & statistics |
| `CODE_QUALITY_CHECKLIST.md` | Quality verification |
| `PHASE_1_COMPLETION_REPORT.md` | Executive summary |

---

## Quick Commands

```powershell
# Rebuild backend
cd backend
mvn clean package -DskipTests

# Check backend is running
Invoke-WebRequest -Uri "http://localhost:8080/api/v1/services" -Method GET

# Check frontend is running
Invoke-WebRequest -Uri "http://localhost:3000" -Method GET

# View database tables
psql -U postgres -d bookarodb -c "\dt"

# Count records
psql -U postgres -d bookarodb -c "SELECT COUNT(*) FROM services;"
```

---

## Success Indicators

✅ Backend logs show: "Started BookaroApplication"  
✅ Frontend shows: "Compiled successfully!"  
✅ No console errors in browser  
✅ Can login with test credentials  
✅ Can create address  
✅ Can favorite a service  
✅ Heart icons turn red when clicked  

---

## 🎯 Ready to Test!

**All features implemented and ready for testing.**

Follow **TESTING_GUIDE.md** for comprehensive test coverage.

**Enjoy testing! 🚀**
