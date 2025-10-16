package com.bookaro.util;

import com.bookaro.model.Service;
import com.bookaro.model.Vendor;
import com.bookaro.repository.ServiceRepository;
import com.bookaro.repository.VendorRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.math.BigDecimal;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@Order(2)
@RequiredArgsConstructor
public class CSVDataLoader implements CommandLineRunner {

    private final VendorRepository vendorRepository;
    private final ServiceRepository serviceRepository;

    @Override
    public void run(String... args) throws Exception {
        // Check if CSV services are already loaded (skip if > 20 services exist)
        if (serviceRepository.count() > 20) {
            log.info("Services already loaded. Skipping CSV import. Total services: {}", serviceRepository.count());
            return;
        }

        loadVendorsFromCSV("d:\\Springboard\\mumbai_vendors_150.csv");
    }

    private void loadVendorsFromCSV(String filePath) {
        int vendorCount = 0;
        int serviceCount = 0;

        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            boolean isHeader = true;

            while ((line = br.readLine()) != null) {
                if (isHeader) {
                    isHeader = false;
                    continue;
                }

                String[] data = line.split(",");
                if (data.length < 9) continue;

                String vendorCode = data[0].trim();
                String businessName = data[1].trim();
                String primaryCategory = data[2].trim();
                String subService = data[3].trim();
                String location = data[4].trim();
                String phone = data[5].trim();
                String ratings = data[6].trim();
                String priceRange = data[7].trim();
                String availability = data[8].trim();

                // Create or get vendor
                Vendor vendor = vendorRepository.findByVendorCode(vendorCode).orElse(null);

                if (vendor == null) {
                    vendor = Vendor.builder()
                            .vendorCode(vendorCode)
                            .businessName(businessName)
                            .primaryCategory(primaryCategory)
                            .phone(phone)
                            .location(location)
                            .city("Mumbai")
                            .state("Maharashtra")
                            .postalCode("400001")
                            .availability(availability)
                            .averageRating(new BigDecimal(ratings))
                            .totalReviews((int) (Math.random() * 50) + 5)
                            .yearsOfExperience((int) (Math.random() * 10) + 1)
                            .isActive(true)
                            .isVerified(true)
                            .email(vendorCode.toLowerCase() + "@bookaro.com")
                            .description(businessName + " - Professional " + primaryCategory + " services in " + location)
                            .build();
                    vendor = vendorRepository.save(vendor);
                    vendorCount++;
                    log.debug("Created vendor: {} - {}", vendorCode, businessName);
                }

                // Parse price range (e.g., "821-4525")
                String[] prices = priceRange.split("-");
                BigDecimal price = new BigDecimal(prices[0]);

                // Create service
                Service service = Service.builder()
                        .serviceName(subService)
                        .description(subService + " service provided by " + businessName + " in " + location)
                        .category(primaryCategory)
                        .price(price)
                        .durationMinutes(120) // Default 2 hours
                        .address(location)
                        .city("Mumbai")
                        .state("Maharashtra")
                        .postalCode("400001")
                        .vendor(vendor)
                        .isAvailable(true)
                        .averageRating(vendor.getAverageRating())
                        .totalReviews(vendor.getTotalReviews())
                        .build();

                serviceRepository.save(service);
                serviceCount++;
            }

            log.info("==============================================");
            log.info("CSV DATA LOADED SUCCESSFULLY");
            log.info("==============================================");
            log.info("Vendors created: {}", vendorCount);
            log.info("Services created: {}", serviceCount);
            log.info("==============================================");

        } catch (IOException e) {
            log.error("Error loading CSV file: {}", e.getMessage());
        }
    }
}
