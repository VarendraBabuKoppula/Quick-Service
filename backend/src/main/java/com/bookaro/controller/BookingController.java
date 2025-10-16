package com.bookaro.controller;

import com.bookaro.dto.ApiResponse;
import com.bookaro.dto.BookingDto;
import com.bookaro.dto.CreateBookingRequest;
import com.bookaro.dto.UpdateBookingStatusRequest;
import com.bookaro.model.Booking;
import com.bookaro.model.Booking.BookingStatus;
import com.bookaro.model.Service;
import com.bookaro.model.User;
import com.bookaro.repository.BookingRepository;
import com.bookaro.repository.ServiceRepository;
import com.bookaro.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingRepository bookingRepository;
    private final ServiceRepository serviceRepository;
    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<ApiResponse<BookingDto>> createBooking(
            @Valid @RequestBody CreateBookingRequest request,
            Authentication authentication) {
        
        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Service service = serviceRepository.findById(request.getServiceId())
                .orElseThrow(() -> new RuntimeException("Service not found"));

        // Create booking with total amount from service price
        Booking booking = Booking.builder()
                .user(user)
                .service(service)
                .bookingDate(request.getBookingDate())
                .bookingTime(request.getBookingTime())
                .notes(request.getNotes())
                .totalAmount(service.getPrice())
                .status(BookingStatus.PENDING)
                .build();

        booking = bookingRepository.save(booking);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Booking created successfully", convertToDto(booking)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<BookingDto>>> getUserBookings(
            @RequestParam(required = false) BookingStatus status,
            Authentication authentication) {
        
        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Booking> bookings;
        if (status != null) {
            bookings = bookingRepository.findByUserAndStatus(user, status);
        } else {
            bookings = bookingRepository.findByUserOrderByBookingDateDesc(user);
        }

        List<BookingDto> bookingDtos = bookings.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success("Bookings retrieved successfully", bookingDtos));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<BookingDto>> getBookingById(
            @PathVariable Long id,
            Authentication authentication) {
        
        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Booking booking = bookingRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        // Check if user owns this booking or is the service provider
        if (!booking.getUser().getId().equals(user.getId()) && 
            !booking.getService().getVendor().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Access denied"));
        }

        return ResponseEntity.ok(ApiResponse.success("Booking retrieved successfully", convertToDto(booking)));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<ApiResponse<BookingDto>> updateBookingStatus(
            @PathVariable Long id,
            @Valid @RequestBody UpdateBookingStatusRequest request,
            Authentication authentication) {
        
        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Booking booking = bookingRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        // Check authorization
        boolean isCustomer = booking.getUser().getId().equals(user.getId());
        boolean isVendor = booking.getService().getVendor().getId().equals(user.getId());

        if (!isCustomer && !isVendor) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Access denied"));
        }

        // Validate status transitions
        BookingStatus newStatus = request.getStatus();
        BookingStatus currentStatus = booking.getStatus();

        if (isCustomer && newStatus == BookingStatus.CANCELLED && currentStatus == BookingStatus.PENDING) {
            booking.setStatus(newStatus);
        } else if (isVendor && (newStatus == BookingStatus.CONFIRMED || newStatus == BookingStatus.COMPLETED)) {
            booking.setStatus(newStatus);
        } else {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Invalid status transition"));
        }

        booking = bookingRepository.save(booking);

        return ResponseEntity.ok(ApiResponse.success("Booking status updated successfully", convertToDto(booking)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> cancelBooking(
            @PathVariable Long id,
            Authentication authentication) {
        
        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Booking booking = bookingRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        // Only customer can cancel and only if pending
        if (!booking.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Access denied"));
        }

        if (booking.getStatus() != BookingStatus.PENDING) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Only pending bookings can be cancelled"));
        }

        booking.setStatus(BookingStatus.CANCELLED);
        bookingRepository.save(booking);

        return ResponseEntity.ok(ApiResponse.success("Booking cancelled successfully", null));
    }

    @GetMapping("/vendor")
    public ResponseEntity<ApiResponse<List<BookingDto>>> getVendorBookings(
            @RequestParam(required = false) BookingStatus status,
            Authentication authentication) {
        
        String email = authentication.getName();
        User vendor = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Booking> bookings;
        if (status != null) {
            bookings = bookingRepository.findByServiceVendorAndStatus(vendor, status);
        } else {
            bookings = bookingRepository.findByServiceVendorOrderByBookingDateDesc(vendor);
        }

        List<BookingDto> bookingDtos = bookings.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success("Vendor bookings retrieved successfully", bookingDtos));
    }

    private BookingDto convertToDto(Booking booking) {
        BookingDto dto = new BookingDto();
        dto.setId(booking.getId());
        dto.setUserId(booking.getUser().getId());
        dto.setUserName(booking.getUser().getFullName());
        dto.setUserEmail(booking.getUser().getEmail());
        dto.setServiceId(booking.getService().getId());
        dto.setServiceName(booking.getService().getServiceName());
        dto.setVendorName(booking.getService().getVendor().getBusinessName());
        dto.setBookingDate(booking.getBookingDate());
        dto.setBookingTime(booking.getBookingTime());
        dto.setStatus(booking.getStatus().toString());
        dto.setTotalAmount(booking.getTotalAmount());
        dto.setNotes(booking.getNotes());
        dto.setCreatedAt(booking.getCreatedAt());
        dto.setUpdatedAt(booking.getUpdatedAt());
        return dto;
    }
}
