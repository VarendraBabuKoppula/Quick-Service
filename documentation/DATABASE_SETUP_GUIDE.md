# Database Setup Guide

## Current Setup: H2 In-Memory Database

The application is currently configured to use H2 in-memory database. This means:
- ✅ No installation required
- ✅ Data loads automatically on startup
- ✅ Perfect for development and testing
- ⚠️ Data is lost when application restarts

### How Data Loading Works

1. **DataInitializer** (@Order(1)) runs first:
   - Checks if users exist: `if (userRepository.count() == 0)`
   - Creates 3 test users (user, vendor, admin)
   - Creates 3 sample services
   - **Will NOT reload if data already exists**

2. **CSVDataLoader** (@Order(2)) runs second:
   - Checks if services exist: `if (serviceRepository.count() > 3)`
   - Loads 150 vendors from CSV if needed
   - Creates 150 services from CSV data
   - **Will NOT reload if data already exists**

## Option 1: Keep Using H2 (Current - Recommended for Development)

**Pros:**
- No setup required
- Fast and simple
- Good for development

**Cons:**
- Data resets on every restart
- CSV loads every restart

**Configuration:**
- File: `application.properties` (already configured)
- Database: In-memory
- Console: http://localhost:8081/api/v1/h2-console
  - JDBC URL: jdbc:h2:mem:bookarodb
  - Username: sa
  - Password: (leave empty)

## Option 2: Switch to PostgreSQL (Permanent Storage)

**Pros:**
- ✅ Data persists across restarts
- ✅ CSV loads ONLY ONCE
- ✅ Production-ready
- ✅ Better performance

**Cons:**
- Requires PostgreSQL installation

### PostgreSQL Setup Steps

#### 1. Install PostgreSQL

**Windows (using Chocolatey):**
```powershell
choco install postgresql
```

**Or download from:** https://www.postgresql.org/download/windows/

#### 2. Create Database

```powershell
# Start psql
psql -U postgres

# In psql console:
CREATE DATABASE bookarodb;
\q
```

#### 3. Update Configuration

The PostgreSQL configuration is already created in:
`backend/src/main/resources/application-postgres.properties`

**To use PostgreSQL, run the application with:**
```powershell
cd backend
java -jar target/bookaro-backend-1.0.0.jar --spring.profiles.active=postgres
```

**Or update `application.properties` to:**
```properties
spring.profiles.active=postgres
```

#### 4. Default PostgreSQL Settings

The application expects:
- Database: `bookarodb`
- Username: `postgres`
- Password: `postgres`
- Port: `5432`

**To change these, edit `application-postgres.properties`:**
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/bookarodb
spring.datasource.username=YOUR_USERNAME
spring.datasource.password=YOUR_PASSWORD
```

### How PostgreSQL Prevents Data Reloading

1. **ddl-auto: update** (not create-drop)
   - Tables are created if missing
   - Data is preserved across restarts

2. **DataInitializer Check:**
   ```java
   if (userRepository.count() == 0) {
       // Only creates users if none exist
   }
   ```

3. **CSVDataLoader Check:**
   ```java
   if (serviceRepository.count() > 3) {
       log.info("Services already loaded. Skipping CSV import.");
       return;
   }
   ```

## Current Status

✅ H2 in-memory database is active
✅ Data loads on every restart
✅ Perfect for development and testing
✅ CSV loader checks prevent duplicate loading within same session
✅ 153 services loaded (3 sample + 150 CSV)

## Recommendation

For development: **Keep using H2** (current setup)
- Fast startup
- No installation needed
- Easy debugging with H2 console

For production: **Switch to PostgreSQL**
- Persistent data
- One-time CSV load
- Better performance

## Quick Commands

### Using H2 (Current):
```powershell
cd backend
java -jar target/bookaro-backend-1.0.0.jar
```

### Using PostgreSQL:
```powershell
# First time setup
createdb -U postgres bookarodb

# Run application
cd backend
java -jar target/bookaro-backend-1.0.0.jar --spring.profiles.active=postgres
```

### View Database Console (H2 only):
http://localhost:8081/api/v1/h2-console
- JDBC URL: `jdbc:h2:mem:bookarodb`
- Username: `sa`
- Password: (empty)

## Testing Data Loading

### Verify CSV Data Loaded:
1. Start backend
2. Check console for:
   ```
   ==============================================
   CSV DATA LOADED SUCCESSFULLY
   ==============================================
   Vendors created: 150
   Services created: 150
   ==============================================
   ```

### Test Service Endpoints:
```powershell
# Get all services
curl http://localhost:8081/api/v1/services

# Search by category
curl "http://localhost:8081/api/v1/services?category=Plumbing"

# Search by city
curl "http://localhost:8081/api/v1/services?city=Mumbai"

# Get categories
curl http://localhost:8081/api/v1/services/categories
```

## Troubleshooting

### Issue: CSV loads every restart
**Solution:** This is expected with H2 in-memory. Switch to PostgreSQL for permanent storage.

### Issue: Duplicate data after multiple restarts
**Solution:** DataInitializer and CSVDataLoader already check for existing data. This should not happen.

### Issue: PostgreSQL connection error
**Solution:** 
1. Check PostgreSQL is running: `pg_isready`
2. Verify database exists: `psql -U postgres -l`
3. Check credentials in application-postgres.properties

### Issue: Services not loading in frontend
**Solution:** 
1. Check backend is running on port 8081
2. Check console for errors
3. Test endpoint: `curl http://localhost:8081/api/v1/services`
4. Check frontend is making correct API calls
