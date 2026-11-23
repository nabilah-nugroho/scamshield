-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 23, 2026 at 11:18 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `scamshield`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_laporan_berdasarkan_status` (IN `p_status` VARCHAR(50))   BEGIN
SELECT
l.id_laporan,
l.judul_laporan,
u.nama_lengkap AS nama_pelapor,
s.nama_status,
l.nominal_kerugian
FROM laporan l
JOIN users u ON l.id_user = u.id_user
JOIN status_laporan s ON l.id_status = s.id_status
WHERE s.nama_status = p_status;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tambah_laporan` (IN `p_id_user` INT, IN `p_id_kategori` INT, IN `p_id_terlapor` INT, IN `p_id_status` INT, IN `p_judul` VARCHAR(150), IN `p_kronologi` TEXT, IN `p_kerugian` DECIMAL(15,2))   BEGIN
INSERT INTO laporan (
id_user,
id_kategori,
id_terlapor,
id_status,
judul_laporan,
kronologi,
nominal_kerugian
)
VALUES (
p_id_user,
p_id_kategori,
p_id_terlapor,
p_id_status,
p_judul,
p_kronologi,
p_kerugian
);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tampilkan_laporan` ()   BEGIN
SELECT
l.id_laporan,
l.judul_laporan,
u.nama_lengkap AS nama_pelapor,
k.nama_kategori,
t.nilai_identitas,
s.nama_status,
l.nominal_kerugian
FROM laporan l
JOIN users u ON l.id_user = u.id_user
JOIN kategori_penipuan k ON l.id_kategori = k.id_kategori
JOIN terlapor t ON l.id_terlapor = t.id_terlapor
JOIN status_laporan s ON l.id_status = s.id_status;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_cek_kelayakan_verifikasi` (`p_id_laporan` INT) RETURNS VARCHAR(40) CHARSET utf8mb4 COLLATE utf8mb4_general_ci READS SQL DATA BEGIN
    DECLARE v_id_status INT DEFAULT NULL;
    DECLARE v_jumlah_bukti INT DEFAULT 0;

    SELECT id_status
    INTO v_id_status
    FROM laporan
    WHERE id_laporan = p_id_laporan;

    IF v_id_status IS NULL THEN
        RETURN 'Laporan Tidak Ditemukan';
    ELSEIF v_id_status IN (3, 4) THEN
        RETURN 'Sudah Selesai Diproses';
    END IF;

    SELECT COUNT(id_bukti)
    INTO v_jumlah_bukti
    FROM bukti_laporan
    WHERE id_laporan = p_id_laporan;

    IF v_jumlah_bukti = 0 THEN
        RETURN 'Tidak Layak (Belum Ada Bukti)';
    ELSE
        RETURN 'Siap Diverifikasi';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_hitung_tingkat_risiko` (`p_id_terlapor` INT) RETURNS VARCHAR(10) CHARSET utf8mb4 COLLATE utf8mb4_general_ci READS SQL DATA BEGIN
    DECLARE v_jumlah_laporan INT DEFAULT 0;
    DECLARE v_total_kerugian DECIMAL(15, 2) DEFAULT 0;

    SELECT COUNT(id_laporan), COALESCE(SUM(nominal_kerugian), 0)
    INTO v_jumlah_laporan, v_total_kerugian
    FROM laporan
    WHERE id_terlapor = p_id_terlapor
      AND id_status != 4;

    IF v_jumlah_laporan >= 3 OR v_total_kerugian >= 2500000 THEN
        RETURN 'Tinggi';
    ELSEIF v_jumlah_laporan = 2 OR v_total_kerugian >= 750000 THEN
        RETURN 'Sedang';
    ELSE
        RETURN 'Rendah';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_total_kerugian_terlapor` (`p_nilai_identitas` VARCHAR(255)) RETURNS DECIMAL(15,2) READS SQL DATA BEGIN
    DECLARE v_total_kerugian DECIMAL(15, 2);

    SELECT COALESCE(SUM(l.nominal_kerugian), 0)
    INTO v_total_kerugian
    FROM laporan l
    JOIN terlapor t ON l.id_terlapor = t.id_terlapor
    WHERE t.nilai_identitas = p_nilai_identitas
      AND l.id_status != 4;

    RETURN v_total_kerugian;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `bukti_laporan`
--

CREATE TABLE `bukti_laporan` (
  `id_bukti` int(11) NOT NULL,
  `id_laporan` int(11) NOT NULL,
  `nama_file` varchar(255) NOT NULL,
  `lokasi_file` varchar(255) NOT NULL,
  `tanggal_upload` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bukti_laporan`
--

INSERT INTO `bukti_laporan` (`id_bukti`, `id_laporan`, `nama_file`, `lokasi_file`, `tanggal_upload`) VALUES
(1, 1, 'bukti_chat_andi.jpg', 'uploads/bukti_chat_andi.jpg', '2026-11-11 08:38:04'),
(2, 1, 'link_phishing.png', 'uploads/link_phishing.png', '2026-11-11 08:38:04'),
(3, 2, 'bukti_transfer.jpg', 'uploads/bukti_transfer.jpg', '2026-11-11 08:38:04'),
(4, 3, 'percakapan_penjual.png', 'uploads/percakapan_penjual.png', '2026-11-11 08:38:04'),
(5, 4, 'pesan_hadiah.pdf', 'uploads/pesan_hadiah.pdf', '2026-11-11 08:38:04'),
(6, 5, 'rekaman_telepon.mp3', 'uploads/rekaman_telepon.mp3', '2026-11-11 08:38:04');

-- --------------------------------------------------------

--
-- Table structure for table `kategori_penipuan`
--

CREATE TABLE `kategori_penipuan` (
  `id_kategori` int(11) NOT NULL,
  `nama_kategori` varchar(100) NOT NULL,
  `deskripsi` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kategori_penipuan`
--

INSERT INTO `kategori_penipuan` (`id_kategori`, `nama_kategori`, `deskripsi`) VALUES
(1, 'Phishing', 'Penipuan melalui tautan atau situs palsu'),
(2, 'Penipuan Investasi', 'Penipuan berkedok investasi'),
(3, 'Penipuan Online Shop', 'Penipuan transaksi jual beli online'),
(4, 'Penipuan Hadiah', 'Penipuan berkedok hadiah atau undian'),
(5, 'Social Engineering', 'Penipuan melalui manipulasi psikologis');

-- --------------------------------------------------------

--
-- Table structure for table `laporan`
--

CREATE TABLE `laporan` (
  `id_laporan` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_kategori` int(11) NOT NULL,
  `id_terlapor` int(11) NOT NULL,
  `id_status` int(11) NOT NULL,
  `judul_laporan` varchar(150) NOT NULL,
  `kronologi` text NOT NULL,
  `nominal_kerugian` decimal(15,2) DEFAULT 0.00,
  `tanggal_laporan` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `laporan`
--

INSERT INTO `laporan` (`id_laporan`, `id_user`, `id_kategori`, `id_terlapor`, `id_status`, `judul_laporan`, `kronologi`, `nominal_kerugian`, `tanggal_laporan`) VALUES
(1, 1, 1, 1, 4, 'Penipuan Link Phishing', 'Korban menerima tautan palsu yang meminta informasi akun perbankan.', 2500000.00, '2026-11-11 08:37:03'),
(2, 2, 2, 2, 2, 'Penipuan Investasi Bodong', 'Korban dijanjikan keuntungan investasi tinggi tetapi dana tidak dikembalikan.', 5000000.00, '2026-11-11 08:37:03'),
(3, 3, 3, 3, 3, 'Penipuan Toko Online', 'Korban melakukan pembayaran barang tetapi barang tidak pernah dikirim.', 750000.00, '2026-11-11 08:37:03'),
(4, 1, 4, 4, 4, 'Penipuan Hadiah Undian', 'Korban diminta membayar biaya administrasi untuk mendapatkan hadiah palsu.', 1000000.00, '2026-11-11 08:37:03'),
(5, 2, 5, 5, 1, 'Penipuan Social Engineering', 'Korban menerima telepon dari pihak yang mengaku sebagai petugas bank.', 1500000.00, '2026-11-11 08:37:03'),
(6, 1, 1, 1, 1, 'Penipuan Melalui WhatsApp', 'Korban menerima pesan WhatsApp berisi tautan palsu.', 2000000.00, '2026-11-18 05:28:38'),
(9, 1, 1, 1, 1, 'Penipuan Spasi Berlebih', 'Kronologi penipuan.', 500000.00, '2026-11-18 06:52:56'),
(10, 2, 2, 5, 1, 'Penipuan Nomor Telepon Baru', 'Korban diminta transfer dana.', 2000000.00, '2026-11-18 06:53:14');

--
-- Triggers `laporan`
--
DELIMITER $$
CREATE TRIGGER `trg_after_insert_laporan` AFTER INSERT ON `laporan` FOR EACH ROW BEGIN
UPDATE terlapor
SET tingkat_risiko = fn_hitung_tingkat_risiko(NEW.id_terlapor)
WHERE id_terlapor = NEW.id_terlapor;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_after_update_laporan` AFTER UPDATE ON `laporan` FOR EACH ROW BEGIN
IF OLD.id_status != NEW.id_status OR OLD.nominal_kerugian != NEW.nominal_kerugian THEN
UPDATE terlapor
SET tingkat_risiko = fn_hitung_tingkat_risiko(NEW.id_terlapor)
WHERE id_terlapor = NEW.id_terlapor;
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_before_insert_laporan` BEFORE INSERT ON `laporan` FOR EACH ROW BEGIN
IF NEW.nominal_kerugian < 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Gagal menyimpan laporan: Nominal kerugian tidak boleh bernilai negatif.';
END IF;
SET NEW.judul_laporan = TRIM(NEW.judul_laporan);
IF NEW.id_status IS NULL OR NEW.id_status = 0 THEN
SET NEW.id_status = 1;
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_before_update_laporan` BEFORE UPDATE ON `laporan` FOR EACH ROW BEGIN
DECLARE v_status_kelayakan VARCHAR(40);
IF OLD.id_status != NEW.id_status AND NEW.id_status = 3 THEN
SET v_status_kelayakan = fn_cek_kelayakan_verifikasi(OLD.id_laporan);
IF v_status_kelayakan != 'Siap Diverifikasi' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Laporan tidak dapat diverifikasi: Lampiran bukti belum tersedia atau status sudah final.';
END IF;
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `riwayat_status`
--

CREATE TABLE `riwayat_status` (
  `id_riwayat` int(11) NOT NULL,
  `id_laporan` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_status` int(11) NOT NULL,
  `catatan` text DEFAULT NULL,
  `waktu_perubahan` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `riwayat_status`
--

INSERT INTO `riwayat_status` (`id_riwayat`, `id_laporan`, `id_user`, `id_status`, `catatan`, `waktu_perubahan`) VALUES
(1, 1, 1, 1, 'Laporan berhasil dikirim oleh pelapor.', '2026-11-11 08:38:38'),
(2, 2, 2, 1, 'Laporan berhasil dikirim oleh pelapor.', '2026-11-11 08:38:38'),
(3, 2, 4, 2, 'Verifier mulai memeriksa bukti investasi.', '2026-11-11 08:38:38'),
(4, 3, 3, 1, 'Laporan berhasil dikirim oleh pelapor.', '2026-11-11 08:38:38'),
(5, 3, 4, 3, 'Bukti transaksi telah diperiksa dan laporan terverifikasi.', '2026-11-11 08:38:38'),
(6, 4, 1, 1, 'Laporan berhasil dikirim oleh pelapor.', '2026-11-11 08:38:38'),
(7, 4, 4, 4, 'Bukti yang diberikan tidak memenuhi kriteria verifikasi.', '2026-11-11 08:38:38'),
(8, 5, 2, 1, 'Laporan berhasil dikirim oleh pelapor.', '2026-11-11 08:38:38');

-- --------------------------------------------------------

--
-- Table structure for table `status_laporan`
--

CREATE TABLE `status_laporan` (
  `id_status` int(11) NOT NULL,
  `nama_status` varchar(50) NOT NULL,
  `deskripsi` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `status_laporan`
--

INSERT INTO `status_laporan` (`id_status`, `nama_status`, `deskripsi`) VALUES
(1, 'Menunggu Verifikasi', 'Laporan menunggu pemeriksaan'),
(2, 'Dalam Pemeriksaan', 'Laporan sedang diperiksa oleh verifier'),
(3, 'Terverifikasi', 'Laporan telah melalui proses verifikasi'),
(4, 'Ditolak', 'Laporan tidak memenuhi kriteria verifikasi');

-- --------------------------------------------------------

--
-- Table structure for table `terlapor`
--

CREATE TABLE `terlapor` (
  `id_terlapor` int(11) NOT NULL,
  `jenis_identitas` enum('Nomor Rekening','Nomor Telepon','Media Sosial','URL Website') NOT NULL,
  `nilai_identitas` varchar(255) NOT NULL,
  `tingkat_risiko` enum('Rendah','Sedang','Tinggi') DEFAULT 'Rendah'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `terlapor`
--

INSERT INTO `terlapor` (`id_terlapor`, `jenis_identitas`, `nilai_identitas`, `tingkat_risiko`) VALUES
(1, 'Nomor Telepon', '081234567890', 'Tinggi'),
(2, 'Nomor Rekening', '123456789012', 'Tinggi'),
(3, 'Media Sosial', '@toko_online_palsu', 'Sedang'),
(4, 'URL Website', 'www.hadiah-palsu.com', 'Tinggi'),
(5, 'Nomor Telepon', '085678901234', 'Tinggi');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id_user` int(11) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('Pelapor','Verifier','Admin') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id_user`, `nama_lengkap`, `email`, `password`, `role`, `created_at`) VALUES
(1, 'Andi Pratama', 'andi@gmail.com', 'hash_andi', 'Pelapor', '2026-11-11 08:32:04'),
(2, 'Budi Santoso', 'budi@gmail.com', 'hash_budi', 'Pelapor', '2026-11-11 08:32:04'),
(3, 'Citra Amelia', 'citra@gmail.com', 'hash_citra', 'Pelapor', '2026-11-11 08:32:04'),
(4, 'Dina Maharani', 'dina@gmail.com', 'hash_dina', 'Verifier', '2026-11-11 08:32:04'),
(5, 'Eko Saputra', 'eko@gmail.com', 'hash_eko', 'Admin', '2026-11-11 08:32:04');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bukti_laporan`
--
ALTER TABLE `bukti_laporan`
  ADD PRIMARY KEY (`id_bukti`),
  ADD KEY `id_laporan` (`id_laporan`);

--
-- Indexes for table `kategori_penipuan`
--
ALTER TABLE `kategori_penipuan`
  ADD PRIMARY KEY (`id_kategori`);

--
-- Indexes for table `laporan`
--
ALTER TABLE `laporan`
  ADD PRIMARY KEY (`id_laporan`),
  ADD KEY `idx_laporan_user` (`id_user`),
  ADD KEY `idx_laporan_kategori` (`id_kategori`),
  ADD KEY `idx_laporan_terlapor` (`id_terlapor`),
  ADD KEY `idx_laporan_status` (`id_status`);

--
-- Indexes for table `riwayat_status`
--
ALTER TABLE `riwayat_status`
  ADD PRIMARY KEY (`id_riwayat`),
  ADD KEY `id_laporan` (`id_laporan`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `id_status` (`id_status`);

--
-- Indexes for table `status_laporan`
--
ALTER TABLE `status_laporan`
  ADD PRIMARY KEY (`id_status`),
  ADD KEY `idx_status_nama` (`nama_status`);

--
-- Indexes for table `terlapor`
--
ALTER TABLE `terlapor`
  ADD PRIMARY KEY (`id_terlapor`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bukti_laporan`
--
ALTER TABLE `bukti_laporan`
  MODIFY `id_bukti` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `kategori_penipuan`
--
ALTER TABLE `kategori_penipuan`
  MODIFY `id_kategori` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `laporan`
--
ALTER TABLE `laporan`
  MODIFY `id_laporan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `riwayat_status`
--
ALTER TABLE `riwayat_status`
  MODIFY `id_riwayat` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `status_laporan`
--
ALTER TABLE `status_laporan`
  MODIFY `id_status` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `terlapor`
--
ALTER TABLE `terlapor`
  MODIFY `id_terlapor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bukti_laporan`
--
ALTER TABLE `bukti_laporan`
  ADD CONSTRAINT `bukti_laporan_ibfk_1` FOREIGN KEY (`id_laporan`) REFERENCES `laporan` (`id_laporan`);

--
-- Constraints for table `laporan`
--
ALTER TABLE `laporan`
  ADD CONSTRAINT `laporan_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`),
  ADD CONSTRAINT `laporan_ibfk_2` FOREIGN KEY (`id_kategori`) REFERENCES `kategori_penipuan` (`id_kategori`),
  ADD CONSTRAINT `laporan_ibfk_3` FOREIGN KEY (`id_terlapor`) REFERENCES `terlapor` (`id_terlapor`),
  ADD CONSTRAINT `laporan_ibfk_4` FOREIGN KEY (`id_status`) REFERENCES `status_laporan` (`id_status`);

--
-- Constraints for table `riwayat_status`
--
ALTER TABLE `riwayat_status`
  ADD CONSTRAINT `riwayat_status_ibfk_1` FOREIGN KEY (`id_laporan`) REFERENCES `laporan` (`id_laporan`),
  ADD CONSTRAINT `riwayat_status_ibfk_2` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`),
  ADD CONSTRAINT `riwayat_status_ibfk_3` FOREIGN KEY (`id_status`) REFERENCES `status_laporan` (`id_status`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

CREATE OR REPLACE VIEW view_laporan_penipuan AS
SELECT
    l.id_laporan,
    l.judul_laporan,
    u.nama_lengkap AS pelapor,
    u.email,
    k.nama_kategori AS kategori_penipuan,
    t.jenis_identitas,
    t.nilai_identitas AS identitas_terlapor,
    t.tingkat_risiko,
    s.nama_status AS status_laporan,
    l.kronologi,
    l.nominal_kerugian,
    l.tanggal_laporan
FROM laporan l
JOIN users u ON l.id_user = u.id_user
JOIN kategori_penipuan k ON l.id_kategori = k.id_kategori
JOIN terlapor t ON l.id_terlapor = t.id_terlapor
JOIN status_laporan s ON l.id_status = s.id_status;
