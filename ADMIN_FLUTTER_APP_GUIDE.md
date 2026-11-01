# 🖥️ SHARE2GO Admin Portal — Flutter Web & Mobile Client (`sharingwalaadmin`)

## 📌 Architecture Overview

The `sharingwalaadmin` Flutter application is an enterprise-grade, **Web & Mobile responsive** dashboard designed following the clean architectural patterns of the user app (`share2go`):

```
sharingwalaadmin/lib/
├── core/
│   ├── api_config/
│   │   └── admin_endpoints.dart         # Admin API routes (http://localhost:5000/api/v1/admin)
│   ├── theme/
│   │   ├── app_colors.dart              # Share2Go Yellow (#F9CF09), Slate (#0F172A), Accents
│   │   ├── app_text_styles.dart         # GoogleFonts Inter typography
│   │   └── app_theme.dart               # Material 3 Responsive Theme
│   └── remote_data_source/
│       └── admin_remote_data_source.dart# Dio-backed network data source
├── services/
│   ├── api_client.dart                  # Dio instance with Bearer Auth & logging interceptors
│   └── admin_auth_service.dart          # Token & session persistence via SharedPreferences
├── models/
│   └── admin_models.dart                # Strongly-typed models for all administrative domains
├── bloc/                                # Cubit, State, Repo per domain
│   ├── auth/                            # Admin authentication & session checks
│   ├── dashboard/                       # KPI statistics & radar metrics
│   ├── users/                           # Commuter & driver directory management
│   ├── drivers/                         # Driver license review & verification
│   ├── vehicles/                        # Vehicle RC cards & insurance compliance
│   ├── rides/                           # Live rides & emergency cancellation
│   ├── reports/                         # Trust & safety ticket resolution & user penalties
│   ├── communities/                     # Corporate & campus networks
│   ├── pricing/                         # Non-commercial fuel cost per km caps
│   ├── banners/                         # Promotional hero banner manager
│   └── staff/                           # Sub-admins RBAC & activity audit log trail
├── presentation/                        # Responsive Screens & Shell
│   ├── auth/admin_login_screen.dart     # Glassmorphic admin login
│   ├── shell/admin_shell.dart           # Adaptive layout: Desktop Sidebar vs Mobile Drawer
│   ├── shell/admin_sidebar.dart         # Deep Navy navigation with active indicator
│   ├── shell/admin_header.dart          # Sticky header with breadcrumbs & profile
│   ├── dashboard/dashboard_screen.dart  # Metric stat cards & operational hub
│   ├── users/users_screen.dart          # Directory with search, role filters & status modals
│   ├── drivers/drivers_screen.dart      # Verification tab bar & license approval
│   ├── vehicles/vehicles_screen.dart    # RC plate badges, Car/Bike filters & verify actions
│   ├── rides/rides_screen.dart          # Route waypoints, seats & force cancellation dialog
│   ├── reports/reports_screen.dart      # Incident investigation & penalty enforcement
│   ├── communities/communities_screen.dart # Corporate hubs grid & creation dialog
│   ├── pricing/pricing_screen.dart      # Base rate and max contribution per km editor
│   ├── banners/banners_screen.dart      # Hero cards preview & publisher
│   └── staff/staff_screen.dart          # Staff accounts & real-time audit log stream
├── widgets/                             # Modular UI Building Blocks
│   ├── responsive_layout.dart           # Mobile (<768px), Tablet, Desktop (>=1100px)
│   ├── stat_card.dart                   # Glassmorphic KPI cards with trend indicators
│   ├── status_badge.dart                # Semantic color-coded badges
│   ├── confirmation_dialog.dart         # Reason prompt dialog for critical actions
│   └── empty_state.dart                 # Polished empty & error state fallback
├── app_routes/
│   └── admin_router.dart                # GoRouter with authentication redirect guard
├── state_injector.dart                  # MultiBlocProvider & MultiRepositoryProvider
└── main.dart                            # Entrypoint
```

---

## 🎨 Theme & Brand Palette

- **Primary Accent**: `#F9CF09` (Share2Go Signature Gold/Yellow)
- **Secondary Accent**: `#FFD600` / `#F9D426`
- **Dashboard Surface**: `#F8FAFC` (Light Slate Canvas)
- **Navigation Sidebar**: `#0B132B` (Executive Deep Navy)
- **Card Background**: `#FFFFFF` with `#E2E8F0` micro-borders
- **Status Badges**:
  - `APPROVED` / `ACTIVE`: Emerald Green (`#10B981`)
  - `PENDING` / `UNDER_REVIEW`: Warm Amber (`#F59E0B`)
  - `REJECTED` / `BLOCKED`: Rose Red (`#EF4444`)
  - `IN_PROGRESS` / `CAR`: Indigo Blue (`#2563EB`)
  - `BIKE`: Violet Purple (`#9333EA`)

---

## 📱 Responsive Adaptation

| Screen Size | Navigation Mode | Content Layout |
| :--- | :--- | :--- |
| **Desktop (>= 1100px)** | Permanent Fixed Sidebar (260px) | Multi-column Grid (3-4 columns), full DataTable |
| **Tablet (768px - 1099px)** | Collapsible Sidebar / Drawer | 2-column Grid, scrollable DataTable |
| **Mobile (< 768px)** | Hamburger Menu Drawer | 1-column Vertical Cards, touch-friendly action sheets |

---

## 🚀 How to Run the Admin App

### 1. Run as Web Application (Chrome)
```bash
cd C:\Users\SIRI\StudioProjects\sharingwalaadmin
flutter run -d chrome
```

### 2. Run on Android Emulator / Physical Device
```bash
cd C:\Users\SIRI\StudioProjects\sharingwalaadmin
flutter run -d android
```

### 3. Run on Windows Desktop
```bash
cd C:\Users\SIRI\StudioProjects\sharingwalaadmin
flutter run -d windows
```

### 4. Build Production Web Release
```bash
flutter build web --release
```
The optimized web bundle will be in `build/web`.

