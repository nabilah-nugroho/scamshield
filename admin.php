<?php
require_once 'config/database.php';
include 'includes/header.php';

// Ambil daftar laporan beserta hasil pengecekan kelayakan dari STORED FUNCTION
$laporanAdmin = $pdo->query("
    SELECT 
        l.id_laporan,
        l.judul_laporan,
        u.nama_lengkap AS pelapor,
        t.nilai_identitas,
        l.nominal_kerugian,
        s.nama_status,
        fn_cek_kelayakan_verifikasi(l.id_laporan) AS status_kelayakan
    FROM laporan l
    JOIN users u ON l.id_user = u.id_user
    JOIN terlapor t ON l.id_terlapor = t.id_terlapor
    JOIN status_laporan s ON l.id_status = s.id_status
    ORDER BY l.id_laporan DESC
")->fetchAll();

// Ambil daftar Verifier/Admin & Status
$verifierList = $pdo->query("SELECT id_user, nama_lengkap, role FROM users WHERE role IN ('Verifier', 'Admin')")->fetchAll();
$statusList   = $pdo->query("SELECT id_status, nama_status FROM status_laporan WHERE id_status IN (2, 3, 4)")->fetchAll();

// Ambil Jejak Audit (Audit Trail) dari riwayat_status
$auditLogs = $pdo->query("
    SELECT 
        rs.id_riwayat,
        l.judul_laporan,
        s.nama_status,
        u.nama_lengkap AS aktor,
        u.role,
        rs.catatan,
        rs.waktu_perubahan
    FROM riwayat_status rs
    JOIN laporan l ON rs.id_laporan = l.id_laporan
    JOIN users u ON rs.id_user = u.id_user
    JOIN status_laporan s ON rs.id_status = s.id_status
    ORDER BY rs.waktu_perubahan DESC, rs.id_riwayat DESC
    LIMIT 15
")->fetchAll();
?>

<!-- Panel Verifikasi Atomik (Milestone 4) -->
<section class="bg-white rounded-xl shadow-sm border border-stone-200 overflow-hidden">
    <div class="px-6 py-4 border-b border-stone-200">
        <h1 class="font-bold text-lg">Panel Verifikasi Laporan (Transaksi Atomik & Kelayakan)</h1>
        <p class="text-xs text-stone-500 mt-0.5">
            Kelayakan dicek via <code>fn_cek_kelayakan_verifikasi()</code>, pembaruan status dieksekusi via <code>CALL sp_verifikasi_laporan_atomik()</code> (<code>START TRANSACTION / COMMIT / ROLLBACK</code>).
        </p>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-left text-sm">
            <thead class="bg-stone-100 text-stone-600 uppercase text-xs">
                <tr>
                    <th class="px-4 py-3">ID & Judul</th>
                    <th class="px-4 py-3">Terlapor</th>
                    <th class="px-4 py-3">Status Saat Ini</th>
                    <th class="px-4 py-3">Kelayakan (Function)</th>
                    <th class="px-4 py-3">Aksi Verifier (Atomik)</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-stone-200">
                <?php foreach ($laporanAdmin as $row): ?>
                <tr>
                    <td class="px-4 py-3">
                        <span class="font-semibold">#<?= $row['id_laporan'] ?> <?= htmlspecialchars($row['judul_laporan']) ?></span>
                        <span class="block text-xs text-stone-500">Pelapor: <?= htmlspecialchars($row['pelapor']) ?></span>
                    </td>
                    <td class="px-4 py-3 font-mono text-xs"><?= htmlspecialchars($row['nilai_identitas']) ?></td>
                    <td class="px-4 py-3 font-medium"><?= htmlspecialchars($row['nama_status']) ?></td>
                    <td class="px-4 py-3">
                        <span class="px-2.5 py-1 rounded text-xs font-semibold <?= $row['status_kelayakan'] === 'Siap Diverifikasi' ? 'bg-emerald-100 text-emerald-800' : 'bg-stone-200 text-stone-700' ?>">
                            <?= htmlspecialchars($row['status_kelayakan']) ?>
                        </span>
                    </td>
                    <td class="px-4 py-3">
                        <form action="actions/verify_report.php" method="POST" class="flex flex-wrap gap-2 items-center">
                            <input type="hidden" name="id_laporan" value="<?= $row['id_laporan'] ?>">
                            <select name="id_user" class="border border-stone-300 rounded px-2 py-1 text-xs">
                                <?php foreach ($verifierList as $v): ?>
                                    <option value="<?= $v['id_user'] ?>"><?= htmlspecialchars($v['nama_lengkap']) ?></option>
                                <?php endforeach; ?>
                            </select>
                            <select name="id_status" class="border border-stone-300 rounded px-2 py-1 text-xs">
                                <?php foreach ($statusList as $st): ?>
                                    <option value="<?= $st['id_status'] ?>"><?= htmlspecialchars($st['nama_status']) ?></option>
                                <?php endforeach; ?>
                            </select>
                            <input type="text" name="catatan" placeholder="Catatan verifikasi..." required
                                   class="border border-stone-300 rounded px-2 py-1 text-xs w-40">
                            <button type="submit" class="bg-stone-900 hover:bg-stone-700 text-white px-3 py-1 rounded text-xs">
                                Proses
                            </button>
                        </form>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</section>

<!-- Tabel Jejak Audit (Audit Trail) -->
<section class="bg-white rounded-xl shadow-sm border border-stone-200 overflow-hidden">
    <div class="px-6 py-4 border-b border-stone-200">
        <h2 class="font-bold text-lg">Riwayat Perubahan Status (Audit Trail)</h2>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-left text-sm">
            <thead class="bg-stone-100 text-stone-600 uppercase text-xs">
                <tr>
                    <th class="px-6 py-3">Waktu</th>
                    <th class="px-6 py-3">Laporan</th>
                    <th class="px-6 py-3">Status Baru</th>
                    <th class="px-6 py-3">Aktor</th>
                    <th class="px-6 py-3">Catatan</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-stone-200">
                <?php foreach ($auditLogs as $log): ?>
                <tr>
                    <td class="px-6 py-3 text-xs text-stone-500"><?= htmlspecialchars($log['waktu_perubahan']) ?></td>
                    <td class="px-6 py-3 font-medium"><?= htmlspecialchars($log['judul_laporan']) ?></td>
                    <td class="px-6 py-3"><?= htmlspecialchars($log['nama_status']) ?></td>
                    <td class="px-6 py-3"><?= htmlspecialchars($log['aktor']) ?> (<?= htmlspecialchars($log['role']) ?>)</td>
                    <td class="px-6 py-3 text-stone-600"><?= htmlspecialchars($log['catatan']) ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</section>

<?php include 'includes/footer.php'; ?>