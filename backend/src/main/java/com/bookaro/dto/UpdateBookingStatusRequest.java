package com.bookaro.dto;

import com.bookaro.model.Booking.BookingStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UpdateBookingStatusRequest {
    
    @NotNull(message = "Status is required")
    private BookingStatus status;
}
