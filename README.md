# Assa Ticket

> **"Votre voyage à travers le Tchad commence ici."**
> Your journey across Chad starts here.

A full-stack Flutter mobile application that digitalises intercity bus ticket booking in Chad — covering the complete journey from trip search to digital ticket, with an integrated administrator panel for transport operators.

---

## Links

| Resource | URL |
|---|---|
| GitHub Repository | https://github.com/Dounia337/assa_ticket.git |
| Figma Design | https://www.figma.com/design/leOkNoyVtznOo1LW2yOsnJ/Assa-ticket?node-id=0-1&t=aPzCQ3B3mg4h8LUT-1 |
| Backend API | `http://169.239.251.102:280/~deubaybe.dounia/api` |

---

## Overview

Bus travel is the primary means of intercity transport in Chad, yet the entire booking process is manual — passengers must physically visit terminals, pricing is opaque, and no digital record exists. Assa Ticket solves this by providing:

- A **traveller-facing** app for searching trips, booking seats, paying via mobile money, and receiving a digital ticket with QR code
- An **administrator panel** for managing routes, buses, trips, bookings, promotions, and payment accounts — all within the same application

---

## Screenshots

> Add screenshots here after running the app

| Onboarding | Home | Seat Selection | Booking Confirmation |
|---|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* | *(screenshot)* |

| Search Results | Payment | Admin Dashboard | Notifications |
|---|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* | *(screenshot)* |

---

## Features

### For Travellers
- Phone number registration with OTP verification
- Guest mode (browse without registering)
- Search trips by origin city, destination city, date, and passenger count
- Visual seat map with real-time availability (Available / Occupied / Blocked)
- Passenger details entry per seat
- Luggage declaration with automatic weight-based surcharge calculation
- Payment via **Moov Money**, **Airtel Money**, or cash at the station
- Payment screenshot upload for manual confirmation
- Digital ticket with unique number (`AS-XXXXX`) and QR code
- Full booking history and status tracking
- GPS-based nearby trip detection using the Haversine formula
- In-app notification centre
- Canvas-based route map visualisation
- French UI for Chadian users

### For Administrators
- Live statistics dashboard (total bookings, revenue, users, active trips)
- Full CRUD for routes, buses, and trips
- Confirm or reject bookings (with reason)
- Seat inventory management
- Promotions management with automatic broadcast notifications
- Payment account management (Moov Money & Airtel Money account details)
- Support contact information management
- Complete admin action audit log

---

## Architecture

```
lib/
├── core/
│   ├── api/              # Remote HTTP service (ApiService — 66 endpoints)
│   ├── constants/        # App-wide constants, routes, city coordinates
│   ├── database/         # Local SQLite service (DatabaseHelper — 14 tables)
│   ├── models/           # 16 data models
│   └── services/         # LocationService, NotificationService
├── features/
│   ├── auth/             # Login, OTP, registration screens + AuthProvider
│   ├── booking/          # Full booking flow screens + BookingProvider
│   ├── admin/            # Admin dashboard screens + AdminProvider
│   ├── home/             # Home screen + splash screen
│   ├── tickets/          # Ticket list and detail screens
│   ├── search/           # Search results screen
│   ├── map/              # Route map visualisation
│   ├── notifications/    # Notification centre screen
│   └── support/          # Support contact screen
└── shared/
    ├── theme/            # Material 3 theme (colours, typography, gradients)
    └── widgets/          # Reusable UI components
```

### Data Flow

```
UI (Screens)
    ↕
State (Provider — ChangeNotifier)
    ↕
ApiService (HTTP → PHP REST API)   ←→   DatabaseHelper (SQLite — offline fallback)
```

### State Management

Three top-level `ChangeNotifier` providers registered via `MultiProvider`:

| Provider | Responsibility |
|---|---|
| `AuthProvider` | Authentication state, user session, role, guest mode |
| `BookingProvider` | Search → seat → passenger → luggage → payment → ticket flow |
| `AdminProvider` | All admin data: routes, buses, trips, bookings, stats, promotions |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 (Dart) |
| State Management | Provider 6.1.1 |
| Navigation | go_router 13.0.0 |
| Local Database | sqflite 2.3.0 (SQLite) |
| Remote API | PHP REST API — 66 endpoints across 10 files |
| Notifications | flutter_local_notifications 17.2.1 |
| Location | geolocator 11.0.0 |
| QR Code | qr_flutter 4.1.0 |
| PDF | pdf 3.10.8 + printing 5.12.0 |
| Fonts | Manrope (headings) · Plus Jakarta Sans (body) |
| Design System | Material 3 |

---

## Database Schema

14 tables organised into four domains:

| Domain | Tables |
|---|---|
| Users | `users` |
| Transport | `routes` · `buses` · `trips` · `seats` |
| Transactions | `bookings` · `passengers` · `luggage` · `payments` |
| System | `promotions` · `app_notifications` · `admin_logs` · `contact_info` · `payment_accounts` |

---

## API Endpoints

66 distinct actions across 10 PHP files:

| File | Actions |
|---|---|
| `users.php` | getByPhone, getById, insert, update, getAll |
| `routes.php` | getAll, getPopular, getById, insert, update, delete |
| `buses.php` | getAll, getById, insert, update, delete |
| `trips.php` | search, getByOrigin, getAll, getById, insert, update, updateSeats, updateSeatsFromTable, delete |
| `bookings.php` | getUserBookings, getAll, getById, insert, update, updateStatus, updateScreenshot |
| `passengers.php` | insert, getByBooking |
| `luggage.php` | insert, getByBooking |
| `payments.php` | insert, getByBooking, updateStatus, getAll |
| `admin.php` | insertLog, getLogs, getStats |
| `seats.php` | initialize, getForTrip, get, updateStatus, getOccupied, getAvailable |
| `promotions.php` | getActive, getAll, insert, update, delete |
| `contact_info.php` | get, upsert |
| `notifications.php` | insert, getForUser, getUnreadCount, markRead, markAllRead |
| `payment_accounts.php` | getAll, getByType, insert, update, delete |

---

## Luggage Fee Structure

| Category | Weight | Extra Fee |
|---|---|---|
| Léger (Light) | 0 – 15 kg | 0 FCFA |
| Moyen (Medium) | 15 – 30 kg | 1,000 FCFA |
| Lourd (Heavy) | 30+ kg | 2,500 FCFA |
| Max items | — | 3 items |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0 <4.0.0`
- Dart SDK
- Android Studio or VS Code with Flutter extension
- Android emulator or physical device (Android 6.0+)

### Installation

```bash
# Clone the repository
git clone https://github.com/Dounia337/assa_ticket.git

# Navigate into the project
cd assa_ticket

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Demo Credentials

| Role | Phone Number | OTP |
|---|---|---|
| Admin | *(set in AppConstants.adminPhone)* | `123456` |
| User | Any 8-digit number | `123456` |

> The OTP is hardcoded to `123456` for demonstration purposes. In production this would be replaced by a real SMS gateway integration.

---

## Supported Cities

15 major Chadian cities with GPS coordinates for distance calculation and map rendering:

N'Djamena · Moundou · Sarh · Abéché · Kélo · Koumra · Pala · Am Timan · Mongo · Ati · Faya-Largeau · Bongor · Doba · Moussoro · Massakory

---

## Booking Status Flow

```
New Booking → EN_ATTENTE (Pending)
                    │
        ┌───────────┴───────────┐
        │ Admin confirms        │ Admin rejects
        ▼                       ▼
    CONFIRME               REJETÉ
    (Confirmed)            (Rejected)
        │
        │ Trip departs
        ▼
    COMPLÉTÉ
    (Completed)

ANNULÉ (Cancelled) — possible from any state
```

---

## Future Improvements

- **Real SMS OTP** — integrate Africa's Talking SMS gateway
- **Direct mobile money API** — automate payment confirmation via Moov Money & Airtel Money APIs
- **WhatsApp ticket delivery** — send digital tickets via WhatsApp Business API
- **Offline-first sync** — queue bookings when offline, sync on reconnect
- **Real-time seat updates** — WebSocket to prevent double-booking
- **Arabic language support** — for eastern and northern Chad users

---

## Project Stats

| Metric | Count |
|---|---|
| Database tables | 14 |
| Named app routes | 23 |
| State providers | 3 |
| Data models | 16 |
| API endpoints | 66 |
| PHP backend files | 10 |

---

## Developer

**Deubaybe Dounia**
successdouni.a@gmail.com
April 2026

---

## License

This project was developed as an academic submission. All rights reserved.
