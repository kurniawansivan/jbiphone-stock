# JBIphone Bali Stock

A comprehensive mobile inventory and sales management system designed specifically for phone retailers. Built with Flutter for cross-platform functionality.

## Overview

JBIphone Bali Stock is a complete stock management solution for phone retailers, allowing efficient tracking of phone inventory, service management, sales records, and financial reporting. The application streamlines the entire business process from purchase to sale, including service and repair tracking.

## Features

### Inventory Management
- Track all phones in stock with detailed information
- Add new phones with model, IMEI, purchase price, and other details
- View comprehensive inventory statistics
- Filter and search functionality for quick access

### Service Management
- Track phones currently in service/repair
- Record service costs and details
- Update service status
- Return phones to inventory after service completion

### Sales Processing
- Record sales transactions with buyer information
- Calculate profits automatically
- Track sales history and performance
- Record pricing details including base price, service costs, and selling price

### Financial Reporting
- Generate PDF sales reports for specific time periods:
  - Daily reports
  - Monthly reports
  - Yearly reports
- Export and share reports directly from the app
- Complete financial overview with profit calculations

### Dashboard & Analytics
- Real-time overview of business performance
- Track daily, monthly, and yearly sales statistics
- Monitor inventory investment
- View profit trends and insights

## Technical Details

### Architecture
- Built using Flutter for cross-platform compatibility
- Provider pattern for state management
- SQLite database for local data storage
- PDF generation for reports

### Dependencies
- `sqflite`: SQL database for Flutter
- `provider`: State management
- `intl`: Internationalization and formatting
- `path_provider`: File system access
- `pdf`: PDF document generation
- `printing`: PDF viewing and printing
- `open_file`: Native file opening
- `share_plus`: Sharing functionality

## Getting Started

### Prerequisites
- Flutter SDK (2.19.2 or higher)
- Android Studio or VS Code with Flutter extensions
- Android SDK for Android deployment
- Xcode for iOS deployment (Mac only)

### Installation
1. Clone the repository
   ```
   git clone [repository-url]
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Run the application
   ```
   flutter run
   ```

### Building for Production
Build an APK for Android:
```
flutter build apk
```

The output APK will be named "JBIphone Bali Stock-release-v1.0.apk" and can be found in `build/app/outputs/flutter-apk/`.

## Project Structure
- `lib/database`: Database configuration and helpers
- `lib/models`: Data models
- `lib/providers`: State management
- `lib/screens`: UI screens
- `lib/utils`: Utility functions
- `lib/widgets`: Reusable UI components

## License

© 2025 JBIphone Bali. All rights reserved.
