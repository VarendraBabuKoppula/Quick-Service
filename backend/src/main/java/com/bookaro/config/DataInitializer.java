package com.bookaro.config;

import com.bookaro.model.Service;
import com.bookaro.model.User;
import com.bookaro.model.Vendor;
import com.bookaro.repository.ServiceRepository;
import com.bookaro.repository.UserRepository;
import com.bookaro.repository.VendorRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;

@Configuration
public class DataInitializer {
    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    @Bean
    @Order(1)
    CommandLineRunner initDatabase(UserRepository userRepository, 
                                   ServiceRepository serviceRepository, 
                                   VendorRepository vendorRepository,
                                   PasswordEncoder passwordEncoder) {
        return args -> {
            if (userRepository.count() == 0) {
                User testUser = new User();
                testUser.setEmail("user@bookaro.com");
                testUser.setPassword(passwordEncoder.encode("password123"));
                testUser.setFullName("Test User");
                testUser.setPhone("1234567890");
                testUser.setAddress("123 Test Street");
                testUser.setCity("Test City");
                testUser.setState("Test State");
                testUser.setZipCode("12345");
                testUser.setRole(User.UserRole.USER);
                testUser.setIsActive(true);

                userRepository.save(testUser);

                User testVendor = new User();
                testVendor.setEmail("vendor@bookaro.com");
                testVendor.setPassword(passwordEncoder.encode("password123"));
                testVendor.setFullName("Test Vendor");
                testVendor.setPhone("0987654321");
                testVendor.setAddress("456 Vendor Avenue");
                testVendor.setCity("Vendor City");
                testVendor.setState("Vendor State");
                testVendor.setZipCode("54321");
                testVendor.setRole(User.UserRole.VENDOR);
                testVendor.setIsActive(true);

                userRepository.save(testVendor);

                User testAdmin = new User();
                testAdmin.setEmail("admin@bookaro.com");
                testAdmin.setPassword(passwordEncoder.encode("admin123"));
                testAdmin.setFullName("Admin User");
                testAdmin.setPhone("1112223333");
                testAdmin.setAddress("789 Admin Road");
                testAdmin.setCity("Admin City");
                testAdmin.setState("Admin State");
                testAdmin.setZipCode("99999");
                testAdmin.setRole(User.UserRole.ADMIN);
                testAdmin.setIsActive(true);

                userRepository.save(testAdmin);

                // Create test vendor entity for services
                Vendor testVendorEntity = Vendor.builder()
                        .vendorCode("TEST001")
                        .businessName("Test Services Co.")
                        .primaryCategory("Home Services")
                        .phone("0987654321")
                        .email("vendor@bookaro.com")
                        .location("Mumbai Central")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400001")
                        .availability("Mon-Sat 9AM-6PM")
                        .yearsOfExperience(5)
                        .averageRating(new BigDecimal("4.5"))
                        .totalReviews(50)
                        .isActive(true)
                        .isVerified(true)
                        .description("Professional home service provider offering plumbing, cleaning, and electrical services")
                        .build();
                
                vendorRepository.save(testVendorEntity);

                logger.info("======================================");
                logger.info("DATABASE INITIALIZED WITH TEST USERS");
                logger.info("======================================");
                logger.info("USER: user@bookaro.com / password123");
                logger.info("VENDOR: vendor@bookaro.com / password123");
                logger.info("ADMIN: admin@bookaro.com / admin123");
                logger.info("======================================");

                // Add sample services (Prices in Indian Rupees)
                Service service1 = Service.builder()
                        .serviceName("Professional Plumbing Repair")
                        .description("Expert plumbing repair services for all your needs")
                        .category("Plumbing")
                        .price(new BigDecimal("1500.00"))
                        .durationMinutes(120)
                        .address("123 Main Street, Andheri")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400001")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.50"))
                        .totalReviews(10)
                        .build();

                Service service2 = Service.builder()
                        .serviceName("Home Cleaning Service")
                        .description("Professional home cleaning with eco-friendly products")
                        .category("Cleaning")
                        .price(new BigDecimal("2500.00"))
                        .durationMinutes(180)
                        .address("456 Oak Avenue, Bandra")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400050")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.80"))
                        .totalReviews(25)
                        .build();

                Service service3 = Service.builder()
                        .serviceName("Electrical Wiring and Installation")
                        .description("Licensed electrician for all electrical work")
                        .category("Electrical")
                        .price(new BigDecimal("2000.00"))
                        .durationMinutes(90)
                        .address("789 Electric Blvd, Powai")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400076")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.70"))
                        .totalReviews(15)
                        .build();

                Service service4 = Service.builder()
                        .serviceName("Professional Painting Service")
                        .description("Interior and exterior painting with quality finish and eco-friendly paints")
                        .category("Painting")
                        .price(new BigDecimal("3500.00"))
                        .durationMinutes(300)
                        .address("12 Artist Lane, Juhu")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400049")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.60"))
                        .totalReviews(18)
                        .build();

                Service service5 = Service.builder()
                        .serviceName("AC Repair and Maintenance")
                        .description("Expert AC servicing, repair, and installation for all brands")
                        .category("Appliance Repair")
                        .price(new BigDecimal("1800.00"))
                        .durationMinutes(120)
                        .address("45 Cool Street, Goregaon")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400063")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.75"))
                        .totalReviews(22)
                        .build();

                Service service6 = Service.builder()
                        .serviceName("Pest Control Services")
                        .description("Safe and effective pest control for residential and commercial properties")
                        .category("Pest Control")
                        .price(new BigDecimal("2200.00"))
                        .durationMinutes(150)
                        .address("78 Green Valley, Thane")
                        .city("Thane")
                        .state("Maharashtra")
                        .postalCode("400601")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.55"))
                        .totalReviews(12)
                        .build();

                Service service7 = Service.builder()
                        .serviceName("Carpentry and Furniture Repair")
                        .description("Custom furniture making and professional repair services")
                        .category("Carpentry")
                        .price(new BigDecimal("2800.00"))
                        .durationMinutes(240)
                        .address("23 Wood Street, Malad")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400064")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.85"))
                        .totalReviews(30)
                        .build();

                Service service8 = Service.builder()
                        .serviceName("Home Tutoring - Mathematics")
                        .description("Experienced math tutor for grades 8-12, board exam preparation")
                        .category("Education")
                        .price(new BigDecimal("1200.00"))
                        .durationMinutes(60)
                        .address("56 Scholar Road, Vile Parle")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400056")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.90"))
                        .totalReviews(35)
                        .build();

                Service service9 = Service.builder()
                        .serviceName("Laptop and Computer Repair")
                        .description("Hardware and software troubleshooting, virus removal, data recovery")
                        .category("IT Services")
                        .price(new BigDecimal("1500.00"))
                        .durationMinutes(90)
                        .address("34 Tech Park, Andheri East")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400059")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.65"))
                        .totalReviews(20)
                        .build();

                Service service10 = Service.builder()
                        .serviceName("Salon Services at Home - Women")
                        .description("Professional salon services including haircut, styling, facial, and makeup")
                        .category("Beauty")
                        .price(new BigDecimal("2500.00"))
                        .durationMinutes(120)
                        .address("67 Beauty Lane, Bandra West")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400050")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.80"))
                        .totalReviews(28)
                        .build();

                Service service11 = Service.builder()
                        .serviceName("Gardening and Landscaping")
                        .description("Garden maintenance, lawn care, and landscape design services")
                        .category("Gardening")
                        .price(new BigDecimal("1800.00"))
                        .durationMinutes(180)
                        .address("89 Garden View, Borivali")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400066")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.40"))
                        .totalReviews(14)
                        .build();

                Service service12 = Service.builder()
                        .serviceName("Car Washing and Detailing")
                        .description("Complete car wash, interior cleaning, and professional detailing")
                        .category("Car Services")
                        .price(new BigDecimal("1000.00"))
                        .durationMinutes(90)
                        .address("12 Auto Hub, Kandivali")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400067")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.50"))
                        .totalReviews(16)
                        .build();

                Service service13 = Service.builder()
                        .serviceName("Yoga and Fitness Training")
                        .description("Personal yoga and fitness training sessions at your home")
                        .category("Fitness")
                        .price(new BigDecimal("1500.00"))
                        .durationMinutes(60)
                        .address("45 Wellness Street, Dadar")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400028")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.95"))
                        .totalReviews(40)
                        .build();

                Service service14 = Service.builder()
                        .serviceName("Photography Services")
                        .description("Professional photography for events, portraits, and product shoots")
                        .category("Photography")
                        .price(new BigDecimal("5000.00"))
                        .durationMinutes(180)
                        .address("23 Capture Point, Worli")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400018")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.70"))
                        .totalReviews(25)
                        .build();

                Service service15 = Service.builder()
                        .serviceName("Laundry and Dry Cleaning")
                        .description("Pickup and delivery laundry service with same-day option")
                        .category("Laundry")
                        .price(new BigDecimal("800.00"))
                        .durationMinutes(1440)
                        .address("56 Fresh Lane, Chembur")
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400071")
                        .vendor(testVendorEntity)
                        .isAvailable(true)
                        .averageRating(new BigDecimal("4.35"))
                        .totalReviews(19)
                        .build();

                serviceRepository.save(service1);
                serviceRepository.save(service2);
                serviceRepository.save(service3);
                serviceRepository.save(service4);
                serviceRepository.save(service5);
                serviceRepository.save(service6);
                serviceRepository.save(service7);
                serviceRepository.save(service8);
                serviceRepository.save(service9);
                serviceRepository.save(service10);
                serviceRepository.save(service11);
                serviceRepository.save(service12);
                serviceRepository.save(service13);
                serviceRepository.save(service14);
                serviceRepository.save(service15);

                logger.info("======================================");
                logger.info("15 SAMPLE SERVICES ADDED");
                logger.info("======================================");
            } else {
                logger.info("Database already contains {} users. Skipping initialization.", userRepository.count());
            }
        };
    }
}
