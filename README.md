<div align="center">
  <img src="assets/logo.png" alt="SCAMSHIELD Logo" width="160" />
  <h1>SCAMSHIELD</h1>
  <p><strong>Community-Driven Digital Fraud Reporting & Verification System</strong></p>

  <p>
    <img src="https://img.shields.io/badge/PHP-8.2+-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP 8.2+" />
    <img src="https://img.shields.io/badge/MariaDB-10.4+-003545?style=for-the-badge&logo=mariadb&logoColor=white" alt="MariaDB" />
    <img src="https://img.shields.io/badge/Tailwind_CSS-3.4-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white" alt="Tailwind CSS" />
    <img src="https://img.shields.io/badge/PDO-Prepared_Statements-4F5D95?style=for-the-badge" alt="PDO" />
  </p>
</div>

---

**SCAMSHIELD** is a web-based fraud reporting platform and relational database dashboard designed to centralize, verify, and track digital scam reports (bank accounts, phone numbers, social media handles, and phishing URLs).

Built for the **Advanced Databases (*Basis Data Lanjut*)** course at **UPN "Veteran" Jakarta**, this project demonstrates transactional database operations directly executed through a lightweight web interface—showcasing **3NF Normalization, Views, Stored Functions, Stored Procedures, Triggers, Indexing, ACID Transactions, Role-Based Access Control (RBAC), and Event Schedulers**.

## 👥 Team Members (Kelompok 5 — S1 Sains Data)

| Name | NIM | Role / Focus |
| :--- | :--- | :--- |
| **Nabilah Nur Aisyah Nugroho** | 2510514020 | Full-Stack Web Integration, Triggers & Event Scheduler |
| **Benaya Alexander Manuel** | 2510514007 | Database Schema, Indexing & Deadlock Simulation |
| **Khayla Oksyasyuni** | 2510514018 | Stored Procedures & Atomic Transactions |
| **Abimanyu Daffa Saputra** | 2510514032 | Stored Functions & RBAC Security (`GRANT`/`REVOKE`) |

*Lecturer: Nindy Irzavika, S.Si., M.T.*

## 🛠️ Tech Stack

* **Database Engine:** MariaDB / MySQL (InnoDB Engine)
* **Backend:** PHP 8+ (Native with PDO Prepared Statements)
* **Frontend:** HTML5, Tailwind CSS (CDN)
* **Development Environment:** XAMPP / PHP Built-in Server

## 🗄️ Database Architecture & Advanced Features

The database schema is normalized to **Third Normal Form (3NF)** across 7 core tables (`users`, `kategori_penipuan`, `terlapor`, `status_laporan`, `laporan`, `bukti_laporan`, and `riwayat_status`) and implements the following advanced routines:

1. **Database Views (`scamshield_master.sql`)**
   * `view_laporan_penipuan`: Consolidates multi-table joins across reports, reporters, categories, reported entities, and verification statuses for dynamic filtering on the public dashboard.

2. **Stored Functions (`scamshield_master.sql`)**
   * `fn_total_kerugian_terlapor(nilai_identitas)`: Calculates cumulative financial losses for a reported entity while excluding rejected reports.
   * `fn_hitung_tingkat_risiko(id_terlapor)`: Automatically classifies risk levels (`Rendah`, `Sedang`, `Tinggi`) based on active report counts and total financial loss.
   * `fn_cek_kelayakan_verifikasi(id_laporan)`: Validates whether a report is eligible for verification (must have supporting evidence and an active pending status).

3. **Stored Procedures & Triggers (`scamshield_master.sql`)**
   * `sp_tampilkan_laporan()`, `sp_laporan_berdasarkan_status()`, and `sp_tambah_laporan(...)`: Encapsulates structured CRUD operations.
   * `trg_before_insert_laporan` & `trg_before_update_laporan`: Blocks negative financial loss inputs and prevents unverified approval without evidence using `SIGNAL SQLSTATE '45000'`.
   * `trg_after_insert_laporan` & `trg_after_update_laporan`: Automatically recalculates and updates `tingkat_risiko` in the `terlapor` table in real time.

4. **Transactions, Security & Automation (`database/milestone4/`)**
   * **ACID Transactions (`01_sp_verifikasi_atomik.sql`):** Wraps status updates and audit log insertions inside an explicit `START TRANSACTION` / `COMMIT` / `ROLLBACK` block.
   * **RBAC (`02_grants_roles.sql`):** Separate database users (`scam_admin`, `scam_verifier`, `scam_pelapor`) enforcing least-privilege access via `GRANT` and `REVOKE`.
   * **Event Scheduler (`03_event_scheduler.sql`):** Daily summary aggregation (`evt_rekap_harian_scamshield` at 23:59) and automated archiving of resolved reports older than 30 days (`evt_arsip_laporan_lama`).
   * **Deadlock Simulation (`04_demo_deadlock.sql`):** Reproducible two-session locking scenario and consistent lock-ordering resolution.

## 📁 Project Structure

```text
scamshield/
├── actions/                            # Form handlers executing PDO CALL statements
│   ├── submit_report.php               # Calls sp_tambah_laporan & handles evidence upload
│   └── verify_report.php               # Calls sp_verifikasi_laporan_atomik
├── assets/
│   └── logo.png                        # Project logo displayed in README & UI
├── config/
│   └── database.php                    # PDO database connection configuration
├── database/
│   ├── scamshield_master.sql           # Complete Milestone 1–3 SQL dump (Tables, Seed, View, SP, Function, Trigger)
│   └── milestone4/                     # Modular Milestone 4 scripts for parallel team development
│       ├── 01_sp_verifikasi_atomik.sql # Atomic verification stored procedure
│       ├── 02_grants_roles.sql         # RBAC user privileges (GRANT & REVOKE)
│       ├── 03_event_scheduler.sql      # Daily recap & 30-day archiving events
│       └── 04_demo_deadlock.sql        # Two-session deadlock demo & resolution
├── includes/                           # Reusable UI components (navbar & footer)
│   ├── header.php
│   └── footer.php
├── uploads/                            # Directory for uploaded fraud evidence files
├── admin.php                           # Verifier & Admin dashboard + audit trail viewer
├── index.php                           # Public dashboard & entity risk lookup
├── report.php                          # Fraud report submission form
└── README.md
```

## 🚀 Getting Started (Local Setup)

### 1. Prerequisites
* **XAMPP** (with MariaDB/MySQL and PHP 8.0+)
* **Git**

### 2. Clone the Repository
```bash
git clone https://github.com/your-username/scamshield.git
cd scamshield
```

### 3. Import the Database
1. Start the **MySQL/MariaDB** service in XAMPP Control Panel.
2. Create a database named `scamshield` and import `database/scamshield_master.sql` via phpMyAdmin or PowerShell:
   ```powershell
   C:\xampp\mysql\bin\mysql.exe -u root -e "CREATE DATABASE IF NOT EXISTS scamshield;"
   Get-Content database/scamshield_master.sql | C:\xampp\mysql\bin\mysql.exe -u root scamshield
   ```
3. Run the Milestone 4 scripts (`01_sp_verifikasi_atomik.sql`, `02_grants_roles.sql`, and `03_event_scheduler.sql`) from `database/milestone4/`.

### 4. Run the Web Application
Start the PHP built-in development server from the project root directory:
```bash
php -S localhost:8000
```
Open your browser and navigate to **`http://localhost:8000`**.