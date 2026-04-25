-- 1. users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255),
    phone_number VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255),
    role VARCHAR(20) DEFAULT 'USER',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. routes
CREATE TABLE routes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    origin_city VARCHAR(100),
    destination_city VARCHAR(100),
    base_price DECIMAL(10,2),
    is_active TINYINT(1) DEFAULT 1,
    is_popular TINYINT(1) DEFAULT 0
) ENGINE=InnoDB;

-- 3. buses
CREATE TABLE buses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(50),
    capacity INT,
    status VARCHAR(50),
    condition_status VARCHAR(50)
) ENGINE=InnoDB;

-- 4. trips (depends on routes and buses)
CREATE TABLE trips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT,
    bus_id INT,
    departure_date DATE,
    departure_time VARCHAR(10),
    available_seats INT,
    status VARCHAR(50),
    FOREIGN KEY (route_id) REFERENCES routes(id),
    FOREIGN KEY (bus_id) REFERENCES buses(id)
) ENGINE=InnoDB;

-- 5. seats (depends on trips)
CREATE TABLE seats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT,
    seat_number INT,
    status VARCHAR(20) DEFAULT 'AVAILABLE',
    occupied_by VARCHAR(255),
    occupied_at DATETIME,
    FOREIGN KEY (trip_id) REFERENCES trips(id)
) ENGINE=InnoDB;

-- 6. bookings (depends on users and trips)
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    trip_id INT,
    total_passengers INT,
    total_price DECIMAL(10,2),
    status VARCHAR(50),
    payment_status VARCHAR(50),
    ticket_number VARCHAR(50),
    payment_screenshot TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (trip_id) REFERENCES trips(id)
) ENGINE=InnoDB;

-- 7. passengers (depends on bookings)
CREATE TABLE passengers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    full_name VARCHAR(255),
    seat_number INT,
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
) ENGINE=InnoDB;

-- 8. luggage (depends on bookings)
CREATE TABLE luggage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    number_of_items INT,
    total_weight DECIMAL(10,2),
    extra_fee DECIMAL(10,2),
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
) ENGINE=InnoDB;

-- 9. payments (depends on bookings)
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    method VARCHAR(50),
    amount DECIMAL(10,2),
    status VARCHAR(50),
    transaction_reference VARCHAR(100),
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
) ENGINE=InnoDB;

-- 10. admin_logs
CREATE TABLE admin_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 11. promotions
CREATE TABLE promotions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    valid_until DATE,
    is_active TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

-- 12. contact_info
CREATE TABLE contact_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key_name VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL
) ENGINE=InnoDB;

-- 13. app_notifications
CREATE TABLE app_notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 14. payment_accounts
CREATE TABLE payment_accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    account_name VARCHAR(255),
    account_number VARCHAR(100) NOT NULL,
    is_active TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

--