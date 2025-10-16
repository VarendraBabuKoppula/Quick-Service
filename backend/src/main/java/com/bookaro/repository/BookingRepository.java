package com.bookaro.repository;

import com.bookaro.model.Booking;
import com.bookaro.model.Booking.BookingStatus;
import com.bookaro.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Booking Repository - Data access layer for Booking entity
 */
@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {

    Page<Booking> findByUserId(Long userId, Pageable pageable);

    Page<Booking> findByServiceVendorId(Long vendorId, Pageable pageable);

    Page<Booking> findByUserIdAndStatus(Long userId, BookingStatus status, Pageable pageable);
    
    // Custom queries with JOIN FETCH to avoid lazy loading issues
    @Query("SELECT b FROM Booking b " +
           "JOIN FETCH b.user " +
           "JOIN FETCH b.service s " +
           "JOIN FETCH s.vendor " +
           "LEFT JOIN FETCH b.address " +
           "WHERE b.user = :user AND b.status = :status")
    List<Booking> findByUserAndStatus(@Param("user") User user, @Param("status") BookingStatus status);
    
    @Query("SELECT b FROM Booking b " +
           "JOIN FETCH b.user " +
           "JOIN FETCH b.service s " +
           "JOIN FETCH s.vendor " +
           "LEFT JOIN FETCH b.address " +
           "WHERE b.user = :user " +
           "ORDER BY b.bookingDate DESC")
    List<Booking> findByUserOrderByBookingDateDesc(@Param("user") User user);
    
    @Query("SELECT b FROM Booking b " +
           "JOIN FETCH b.user " +
           "JOIN FETCH b.service s " +
           "JOIN FETCH s.vendor " +
           "LEFT JOIN FETCH b.address " +
           "WHERE s.vendor = :vendor AND b.status = :status")
    List<Booking> findByServiceVendorAndStatus(@Param("vendor") User vendor, @Param("status") BookingStatus status);
    
    @Query("SELECT b FROM Booking b " +
           "JOIN FETCH b.user " +
           "JOIN FETCH b.service s " +
           "JOIN FETCH s.vendor " +
           "LEFT JOIN FETCH b.address " +
           "WHERE s.vendor = :vendor " +
           "ORDER BY b.bookingDate DESC")
    List<Booking> findByServiceVendorOrderByBookingDateDesc(@Param("vendor") User vendor);
    
    @Query("SELECT b FROM Booking b " +
           "JOIN FETCH b.user " +
           "JOIN FETCH b.service s " +
           "JOIN FETCH s.vendor " +
           "LEFT JOIN FETCH b.address " +
           "WHERE b.id = :id")
    Optional<Booking> findByIdWithDetails(@Param("id") Long id);
}

