package com.bookaro;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class BookaroApplication {

    public static void main(String[] args) {
        SpringApplication.run(BookaroApplication.class, args);
    }
}

