# Bookaro - Service Marketplace Platform

A professional, production-ready web application for connecting customers with service providers. Built with Java Spring Boot and React.

## Project Overview

Bookaro is a three-tier service marketplace platform featuring:
- User Module (Customer Side) - Phase 1
- Vendor Module (Service Provider Side) - Phase 2
- Admin Module (Platform Management) - Phase 3

## Technology Stack

### Backend
- Java 21 (LTS)
- Spring Boot 3.5.0
- Spring Security with JWT
- Hibernate/JPA
- PostgreSQL
- Maven

### Frontend
- React 18+
- React Router DOM
- Axios
- CSS3

## Getting Started

### Prerequisites
- Java 21 or higher (LTS)
- Node.js 14 or higher
- PostgreSQL 12 or higher
- Maven 3.9 or higher

### Backend Setup

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

Backend server runs on: http://localhost:8080

### Frontend Setup

```bash
cd frontend
npm install
npm start
```

Frontend application runs on: http://localhost:3000

## Project Structure

```
Springboard/
├── backend/               # Spring Boot REST API
├── frontend/              # React application
├── documentation/         # Technical documentation
└── PRD_BOOKARO_COMPLETE.md
```

## Features (Phase 1)

- User registration and authentication
- JWT-based security
- Profile management
- Service search and discovery
- Booking system
- Review and rating system

## Documentation

Detailed documentation available in the `documentation/` folder:
- API_DOCUMENTATION.md
- ARCHITECTURE.md
- DATABASE_SCHEMA.md
- BACKEND_SETUP.md
- FRONTEND_SETUP.md
- PROJECT_SETUP.md

## Color Theme

- Deep Navy Blue: #1a2332
- Bright Royal Blue: #2563eb
- White: #ffffff
- Light Gray: #e5e7eb

## License

This project uses only open-source technologies and libraries.

## Development Status

Phase 1 (User Module) - In Progress

