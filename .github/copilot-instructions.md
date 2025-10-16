# Bookaro Development Instructions

## Project Overview
Bookaro is a three-tier service marketplace platform (Spring Boot + React + PostgreSQL) connecting customers with service providers. Currently in Phase 1 (User Module) - production-ready for customer-facing features.

## CRITICAL: Professional Code Standards

**NEVER include anything that makes code look AI-generated:**
- No emojis anywhere in code, comments, documentation, or UI
- No overly enthusiastic language or exclamation marks in professional contexts
- No "helpful" comments that sound like AI assistance
- Write code exactly as a professional human developer would
- Use standard industry terminology and conventions
- All comments should be technical and necessary, not decorative

## Development Philosophy & Principles

### Core Methodology
- **Agile Development**: Iterative development with clear deliverables, testing, and ongoing refinement
- **Production-Ready Focus**: Build with maintainability, scalability, and professional production standards
- **Phased Approach**: Three core modules developed iteratively - User (Customer), Vendor (Service Provider), Admin

### Technology Stack Restrictions (CRITICAL)
**Backend - Java-centric technologies ONLY:**
- Spring Boot 3.5.0 with REST APIs
- Spring Security for authentication/authorization
- Hibernate/JPA for ORM
- PostgreSQL 15.13 for database (MySQL acceptable alternative)

**Frontend - Java-compatible solutions:**
- React 18+ integrated via REST APIs (current implementation)
- Angular or Thymeleaf (server-side rendering) are acceptable alternatives

**Avoid:**
- Non-Java backend frameworks or tech stacks outside Java ecosystem

### Code Quality Standards
- **Best Practices**: Clean, modular code with proper documentation
- **Security**: Implement secure role-based access control (RBAC) for Admin, User, Vendor roles
- **Error Handling**: Comprehensive exception handling with meaningful messages
- **Code Comments**: Document complex logic and business rules
- **Maintainability**: Write standardized code fit for professional agile teams
- **Professional Appearance**: Code must look human-written, not AI-generated

### Copyright & Legal Compliance (CRITICAL)
- **NO Copyrighted Content**: Never use copyrighted images, fonts, icons, or UI components
- **Open-Source Only**: Use only open-source or freely licensed design elements
- **License Verification**: Verify licenses before using any external resource
- **Attribution**: Properly attribute open-source components where required

### UI/UX Requirements
- **Creative Freedom**: Exercise creativity for modern, responsive user experiences
- **Current Theme**: Deep Navy Blue (#1a2332), Bright Royal Blue (#2563eb), White (#ffffff), Light Gray (#e5e7eb)
- **Professional Design**: Clean, business-appropriate design without decorative elements

## Critical Architecture Decisions

### Vendor-Service Separation (IMPORTANT)
- **Vendors** and **Services** are SEPARATE entities with distinct tables
- One vendor can provide multiple services (Vendor 1:N Service relationship)
- Service.vendor_id references Vendor.id (NOT User.id)
- CSV data loading is DISABLED via commented @Component in CSVDataLoader.java
- Test data only: 1 vendor (TEST001) with 3 services

### Database Schema Management (PRODUCTION CRITICAL)
```properties
spring.jpa.hibernate.ddl-auto=validate  # NEVER change to create-drop/update
```
- **validate**: Production-safe mode - only validates schema, makes NO changes
- Data persists permanently in PostgreSQL (bookarodb)
- Schema changes require manual migrations (never auto-applied)
- Database: PostgreSQL 15.13 on localhost:5432, user: postgres, password: root

### Authentication & Role-Based Access Control (RBAC)
- **JWT Authentication**: 24-hour token expiration with BCrypt password encryption
- **Token Flow**: Stored in localStorage (frontend), validated via JwtAuthenticationFilter (backend)
- **Three Roles**: USER, VENDOR, ADMIN (enum in User.UserRole)
  
**Endpoint Security Pattern:**
```java
// Public endpoints (no authentication required)
.requestMatchers("/auth/**", "/services/**").permitAll()

// Protected endpoints (JWT required, role-based access)
.anyRequest().authenticated()
```

**Role Permissions (Current Implementation):**
- USER: Profile management, service browsing, booking creation, reviews
- VENDOR: (Phase 2) Service management, booking acceptance, revenue tracking
- ADMIN: (Phase 3) User/vendor approval, platform analytics

**Security Best Practices Applied:**
- Passwords hashed with BCrypt (never stored in plaintext)
- JWT tokens include user ID, email, role
- Auto-logout on 401 (unauthorized) responses
- CORS configured for specific origins only

## Development Workflows

### Backend Build & Run
```bash
# Development (port 8080, auto-restart)
cd backend
mvn spring-boot:run

# Production JAR (port 8081)
cd backend
mvn clean package -DskipTests
java -jar target/bookaro-backend-1.0.0.jar
```

**Context path**: `/api/v1` (e.g., `http://localhost:8081/api/v1/services`)

### Frontend Setup
```bash
cd frontend
npm install
npm start  # Runs on port 3000
```

### Database Verification
```bash
$env:PGPASSWORD='root'
psql -U postgres -d bookarodb -c "SELECT COUNT(*) FROM vendors; SELECT COUNT(*) FROM services;"
```

## Project-Specific Patterns

### Standard API Response Format
All endpoints return:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```
Use ApiResponse.success() and ApiResponse.error() static factory methods.

### DTO Naming Convention
- Request DTOs: *Request.java (e.g., LoginRequest, BookingRequest)
- Response DTOs: *Response.java or *Dto.java (e.g., AuthResponse, ServiceDto)
- Always map entities to DTOs in controllers - never expose entities directly

### Security Configuration Pattern
```java
// Public endpoints (no auth)
.requestMatchers("/auth/**", "/services/**").permitAll()

// Protected endpoints (JWT required)
.anyRequest().authenticated()
```

### Service Layer Transaction Management
Use @Transactional on service methods that modify data:
```java
@Transactional
public BookingDto createBooking(BookingRequest request) { ... }
```

## Common Integration Points

### Frontend → Backend API
```javascript
// API base: http://localhost:8081/api/v1
// JWT automatically added via axios interceptor in api.js
import { serviceAPI, bookingAPI, reviewAPI } from '../services/api';

// All API calls return response.data.data (nested structure)
const services = await serviceAPI.searchServices(category, city, page, size);
```

### Backend Validation Pattern
```java
// Use javax.validation annotations
@NotBlank(message = "Email is required")
@Email(message = "Invalid email format")
private String email;

// Controllers use @Valid
public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request)
```

### Error Handling Convention
- Global exception handler: GlobalExceptionHandler.java
- Custom exceptions in exception/ package
- Always return ApiResponse with meaningful error messages

## Data Initialization

### Test Data (DataInitializer.java)
- 3 users: user@bookaro.com, vendor@bookaro.com, admin@bookaro.com (all password: password123 or admin123)
- 1 vendor: TEST001 - "Test Services Co."
- 3 services: Plumbing (Rs.1500), Cleaning (Rs.2500), Electrical (Rs.2000)

### CSVDataLoader (DISABLED)
- Commented @Component annotation to prevent auto-loading
- Previously loaded 150 Mumbai vendors - now disabled for production
- Only enable if explicitly requested to reload CSV data

## Key Files & Their Purpose

| File | Purpose | Critical Notes |
|------|---------|----------------|
| SecurityConfig.java | JWT + CORS setup | Frontend origin: http://localhost:3000 |
| DataInitializer.java | Creates 3 test users + 1 vendor + 3 services | @Order(1) - runs first |
| CSVDataLoader.java | (DISABLED) Loads vendors from CSV | @Component commented out |
| application.properties | Database + server config | ddl-auto=validate (never change) |
| api.js (frontend) | Axios instance with JWT interceptor | Auto-redirects to /login on 401 |
| AuthContext.js (frontend) | Global auth state management | Stores token + user in localStorage |

## Phase Status & Boundaries

### Phase 1 - User Module (PRODUCTION READY)
**Delivered Features (Iteratively Tested & Verified):**
- User registration/login with JWT authentication
- Profile management (view/update personal information)
- Service browsing/search (by category, location, with pagination)
- Service details with vendor information
- Booking creation with date/time selection
- Booking status tracking (PENDING, CONFIRMED, COMPLETED, CANCELLED)
- Review & rating system (1-5 stars with comments)
- All 9 user features verified working in production configuration

**Test Credentials:**
- User: user@bookaro.com / password123
- Vendor: vendor@bookaro.com / password123
- Admin: admin@bookaro.com / admin123

### Phase 2 - Vendor Module (NOT STARTED)
**DO NOT implement vendor features unless explicitly requested:**
- Vendor dashboard and analytics
- Service management (create, update, delete services)
- Booking acceptance/rejection workflow
- Revenue tracking and reporting
- Customer communication tools

### Phase 3 - Admin Module (NOT STARTED)
**DO NOT implement admin features unless explicitly requested:**
- User and vendor approval workflows
- Platform-wide analytics and reporting
- Content moderation tools
- System configuration management

**Agile Principle**: Each phase follows complete cycles:
1. Requirements analysis
2. Implementation
3. Testing
4. Refinement
5. Production deployment

Only proceed to next phase when current phase is fully tested and production-ready.

## Testing & Verification

### Manual Testing Script
See test_user_module.ps1 for PowerShell script testing all 9 user features.

### Production Readiness
See documentation/PRODUCTION_READINESS_CHECKLIST.md for deployment checklist.

**Security TODOs** (not critical for development):
- Change database password from 'root'
- Update JWT secret from default key
- Configure production CORS domain
- Enable HTTPS/SSL

## When Making Changes

### Code Quality Checklist
1. **Follow Java Best Practices**:
   - Use meaningful variable/method names
   - Keep methods focused (single responsibility)
   - Add JavaDoc for public APIs
   - Use Lombok annotations to reduce boilerplate
   - Follow Spring Boot conventions

2. **Security Considerations**:
   - Never expose entities directly (always use DTOs)
   - Validate all user inputs with @Valid annotations
   - Hash passwords with BCrypt (never plaintext)
   - Check role permissions before sensitive operations
   - Update SecurityConfig for new endpoint access rules

3. **Database Changes**:
   - Schema modifications: Temporarily change ddl-auto=update, test, manual migration, revert to validate
   - Never change ddl-auto to create-drop (data loss)
   - Check documentation/DATABASE_SCHEMA.md before adding tables/columns
   - Use indexes for frequently queried columns

4. **API Development**:
   - All endpoints return ApiResponse<T> wrapper
   - Update SecurityConfig permitAll/authenticated rules for new endpoints
   - Create separate DTOs (never expose entities)
   - Add @Transactional to service methods that modify data
   - Document new endpoints in documentation/API_DOCUMENTATION.md

5. **Frontend Integration**:
   - Update corresponding service in api.js for new backend endpoints
   - Handle loading states and error messages
   - Validate forms before API calls
   - Store sensitive data (tokens) securely in localStorage

6. **Testing & Verification**:
   - Test all CRUD operations manually
   - Verify role-based access control
   - Check database persistence (data survives restart)
   - Ensure error messages are user-friendly
   - Update test_user_module.ps1 for new features

### Common Patterns to Follow

**Controller Pattern:**
```java
@RestController
@RequestMapping("/api/v1/resource")
@RequiredArgsConstructor
public class ResourceController {
    private final ResourceService service;
    
    @PostMapping
    public ResponseEntity<ApiResponse<ResourceDto>> create(@Valid @RequestBody ResourceRequest request) {
        ResourceDto result = service.create(request);
        return ResponseEntity.ok(ApiResponse.success("Resource created", result));
    }
}
```

**Service Pattern:**
```java
@Service
@RequiredArgsConstructor
@Transactional
public class ResourceService {
    private final ResourceRepository repository;
    
    public ResourceDto create(ResourceRequest request) {
        // Business logic here
        Resource entity = repository.save(resource);
        return mapToDto(entity);
    }
}
```

**Exception Handling:**
```java
// Custom exceptions in exception/ package
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}

// Global handler catches and returns ApiResponse
@ExceptionHandler(ResourceNotFoundException.class)
public ResponseEntity<ApiResponse<Void>> handleNotFound(ResourceNotFoundException ex) {
    return ResponseEntity.status(404)
        .body(ApiResponse.error(ex.getMessage(), null));
}
```

## Documentation References
- Architecture: documentation/ARCHITECTURE.md
- API Endpoints: documentation/API_DOCUMENTATION.md
- Database Schema: documentation/DATABASE_SCHEMA.md
- Production Checklist: documentation/PRODUCTION_READINESS_CHECKLIST.md
