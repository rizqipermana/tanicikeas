# TaniCikeas 🌾

Aplikasi keuangan sederhana untuk petani. Catat pemasukan dan pengeluaran, lihat laporan laba.

## Setup

### 1. Install Flutter
https://docs.flutter.dev/get-started/install/windows

### 2. Setup Supabase
1. Buat project di https://supabase.com
2. Buka SQL Editor, jalankan:

```sql
create table tbl_user (
  id uuid primary key default gen_random_uuid(),
  full_name text,
  phone_number text,
  created_at timestamp default now()
);

create table tbl_transaction (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  transaction_type text,
  category text,
  amount numeric,
  note text,
  transaction_date date,
  created_at timestamp default now()
);
```

3. Buka Settings → API → salin Project URL dan anon key

### 3. Isi Supabase credentials
Buka `lib/main.dart`, ganti:
```dart
const String supabaseUrl = 'MASUKKAN_SUPABASE_URL_KAMU';
const String supabaseAnonKey = 'MASUKKAN_SUPABASE_ANON_KEY_KAMU';
```

### 4. Jalankan aplikasi
```bash
flutter pub get
flutter run
```

### 5. Build APK
```bash
flutter build apk --release
```
File APK ada di: `build/app/outputs/flutter-apk/app-release.apk`

## Struktur Project
```
lib/
├── main.dart
├── models/transaction.dart
├── services/supabase_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── add_transaction_screen.dart
│   ├── history_screen.dart
│   └── report_screen.dart
└── widgets/
    ├── summary_card.dart
    └── transaction_tile.dart
```
