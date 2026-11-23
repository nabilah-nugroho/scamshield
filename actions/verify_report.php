<?php
require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $idLaporan = (int) $_POST['id_laporan'];
    $idUser    = (int) $_POST['id_user'];
    $idStatus  = (int) $_POST['id_status'];
    $catatan   = trim($_POST['catatan']);

    try {
        $stmt = $pdo->prepare("CALL sp_verifikasi_laporan_atomik(?, ?, ?, ?)");
        $stmt->execute([$idLaporan, $idUser, $idStatus, $catatan]);
        $stmt->closeCursor();

        header("Location: ../admin.php?success=" . urlencode("Transaksi verifikasi berhasil di-COMMIT & jejak audit tercatat!"));
        exit;
    } catch (PDOException $e) {
        header("Location: ../admin.php?error=" . urlencode("Transaksi di-ROLLBACK: " . $e->getMessage()));
        exit;
    }
}