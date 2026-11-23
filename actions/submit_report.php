<?php
require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $idUser     = (int) $_POST['id_user'];
    $idKategori = (int) $_POST['id_kategori'];
    $idTerlapor = (int) $_POST['id_terlapor'];
    $idStatus   = 1; // Default: Menunggu Verifikasi
    $judul      = $_POST['judul_laporan'];
    $kronologi  = $_POST['kronologi'];
    $kerugian   = (float) $_POST['nominal_kerugian'];

    try {
        // 1. Panggil Stored Procedure Milestone 3
        $stmt = $pdo->prepare("CALL sp_tambah_laporan(?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$idUser, $idKategori, $idTerlapor, $idStatus, $judul, $kronologi, $kerugian]);
        $stmt->closeCursor();

        // Ambil ID laporan terakhir yang baru masuk
        $lastId = $pdo->query("SELECT MAX(id_laporan) AS max_id FROM laporan")->fetch()['max_id'];

        // 2. Catat riwayat status awal
        $stmtRiwayat = $pdo->prepare("INSERT INTO riwayat_status (id_laporan, id_user, id_status, catatan) VALUES (?, ?, 1, 'Laporan berhasil dikirim oleh pelapor.')");
        $stmtRiwayat->execute([$lastId, $idUser]);

        // 3. Jika ada file bukti diunggah, simpan ke folder uploads/ & tabel bukti_laporan
        if (!empty($_FILES['bukti_file']['name']) && $_FILES['bukti_file']['error'] === UPLOAD_ERR_OK) {
            $namaAsli = basename($_FILES['bukti_file']['name']);
            $namaBaru = time() . '_' . preg_replace('/[^a-zA-Z0-9._-]/', '_', $namaAsli);
            $lokasi   = 'uploads/' . $namaBaru;

            if (move_uploaded_file($_FILES['bukti_file']['tmp_name'], '../' . $lokasi)) {
                $stmtBukti = $pdo->prepare("INSERT INTO bukti_laporan (id_laporan, nama_file, lokasi_file) VALUES (?, ?, ?)");
                $stmtBukti->execute([$lastId, $namaAsli, $lokasi]);
            }
        }

        header("Location: ../index.php?success=" . urlencode("Laporan berhasil disimpan & tingkat risiko terlapor otomatis diperbarui oleh Trigger!"));
        exit;
    } catch (PDOException $e) {
        header("Location: ../report.php?error=" . urlencode($e->getMessage()));
        exit;
    }
}