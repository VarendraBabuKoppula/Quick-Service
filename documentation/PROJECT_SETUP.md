# Project Setup Documentation

## Service Marketplace Platform - Phase 1: User Module

### Project Structure
```
Springboard/
├── backend/          # Spring Boot REST API
├── frontend/         # React Application
├── documentation/    # All project documentation
└── PRD_User_Module.md
```

### Technology Stack

#### Backend
- Java 21 (LTS)
- Spring Boot 3.5.0
- Spring Security (JWT Authentication)
- Spring Data JPA (Hibernate)
- MySQL/PostgreSQL
- Maven

#### Frontend
- React 18+
- React Router
- Axios (HTTP client)
- Material-UI or custom components (following color theme)
- CSS/SCSS for styling

### Color Theme
- Deep Navy Blue: `#1a2332`
- Bright Royal Blue: `#2563eb`
- White: `#ffffff`
- Light Gray: `#f3f4f6`

### Phase 1 Features
1. User Registration & Login with validation
2. Profile Management (name, contact, location)
3. Search for nearby services by type and location
4. View detailed service provider information
5. Book services with date/time selection
6. Track booking status in real-time
7. Rate and review services after completion

### Setup Instructions

#### Backend Setup
1. Navigate to `backend/` directory
2. Configure database in `application.properties`
3. Run `mvn clean install`
4. Start application: `mvn spring-boot:run`

#### Frontend Setup
1. Navigate to `frontend/` directory
2. Install dependencies: `npm install`
3. Start development server: `npm start`

### API Documentation
API documentation will be available at `/swagger-ui.html` when backend is running.

### Database Schema
See `DATABASE_SCHEMA.md` for detailed entity relationship diagrams and table structures.

