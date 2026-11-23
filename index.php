<?php
require_once 'config/database.php';
include 'includes/header.php';

// 1. Cek Identitas Terlapor menggunakan STORED FUNCTION dari Milestone 3
$hasilCek = null;
if (!empty($_GET['identitas'])) {
    $identitas = trim($_GET['identitas']);
    $stmt = $pdo->prepare("
        SELECT 
            t.jenis_identitas,
            t.nilai_identitas,
            fn_total_kerugian_terlapor(t.nilai_identitas) AS total_kerugian,
            fn_hitung_tingkat_risiko(t.id_terlapor) AS rekomendasi_risiko,
            t.tingkat_risiko AS status_risiko_db
        FROM terlapor t
        WHERE t.nilai_identitas LIKE ?
        LIMIT 1
    ");
    $stmt->execute(["%$identitas%"]);
    $hasilCek = $stmt->fetch();
}

// 2. Ambil daftar laporan dari VIEW (Milestone 2)
$laporanList = $pdo->query("SELECT * FROM view_laporan_penipuan ORDER BY tanggal_laporan DESC")->fetchAll();
?>

<!-- Fitur Pencarian / Cek Risiko Identitas -->
<section class="bg-white p-6 rounded-xl shadow-sm border border-stone-200">
    <h1 class="text-xl font-bold mb-1">Cek Rekam Jejak Identitas Terlapor</h1>
    <p class="text-sm text-stone-500 mb-4">Periksa nomor rekening, nomor telepon, akun media sosial, atau URL mencurigakan[cite: 21].</p>
    
    <form method="GET" class="flex gap-3">
        <input type="text" name="identitas" value="<?= htmlspecialchars($_GET['identitas'] ?? '') ?>"
               placeholder="Contoh: 081234567890 atau 123456789012..." required
               class="flex-1 border border-stone-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500">
        <button type="submit" class="bg-stone-900 hover:bg-stone-800 text-white px-6 py-2.5 rounded-lg text-sm font-medium">
            Periksa
        </button>
    </form>

    <?php if (isset($_GET['identitas'])): ?>
        <?php if ($hasilCek): ?>
            <div class="mt-4 p-4 rounded-lg bg-stone-100 border border-stone-200 flex flex-wrap justify-between items-center gap-4">
                <div>
                    <span class="text-xs uppercase font-semibold text-stone-500"><?= htmlspecialchars($hasilCek['jenis_identitas']) ?></span>
                    <p class="font-bold text-lg"><?= htmlspecialchars($hasilCek['nilai_identitas']) ?></p>
                    <p class="text-sm text-stone-600">Total Akumulasi Kerugian: <strong>Rp <?= number_format($hasilCek['total_kerugian'], 0, ',', '.') ?></strong></p>
                </div>
                <div class="text-right">
                    <span class="text-xs text-stone-500 block mb-1">Tingkat Risiko (Stored Function)</span>
                    <span class="px-3 py-1.5 rounded-full text-xs font-bold bg-rose-100 text-rose-800">
                        Risiko <?= htmlspecialchars($hasilCek['rekomendasi_risiko']) ?>
                    </span>
                </div>
            </div>
        <?php else: ?>
            <div class="mt-4 p-4 rounded-lg bg-emerald-50 text-emerald-800 text-sm">
                Identitas <strong><?= htmlspecialchars($_GET['identitas']) ?></strong> belum pernah dilaporkan dalam database SCAMSHIELD.
            </div>
        <?php endif; ?>
    <?php endif; ?>
</section>

<!-- Tabel Daftar Laporan dari VIEW -->
<section class="bg-white rounded-xl shadow-sm border border-stone-200 overflow-hidden">
    <div class="px-6 py-4 border-b border-stone-200 flex justify-between items-center">
        <h2 class="font-bold text-lg">Daftar Laporan Penipuan (via <code>view_laporan_penipuan</code>)</h2>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-left text-sm">
            <thead class="bg-stone-100 text-stone-600 uppercase text-xs">
                <tr>
                    <th class="px-6 py-3">Judul Laporan</th>
                    <th class="px-6 py-3">Kategori</th>
                    <th class="px-6 py-3">Identitas Terlapor</th>
                    <th class="px-6 py-3">Risiko</th>
                    <th class="px-6 py-3">Kerugian</th>
                    <th class="px-6 py-3">Status</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-stone-200">
                <?php foreach ($laporanList as $row): ?>
                <tr class="hover:bg-stone-50">
                    <td class="px-6 py-4 font-medium"><?= htmlspecialchars($row['judul_laporan']) ?></td>
                    <td class="px-6 py-4"><?= htmlspecialchars($row['kategori_penipuan']) ?></td>
                    <td class="px-6 py-4 font-mono text-xs"><?= htmlspecialchars($row['identitas_terlapor']) ?></td>
                    <td class="px-6 py-4">
                        <span class="px-2.5 py-1 rounded text-xs font-semibold bg-amber-100 text-amber-800">
                            <?= htmlspecialchars($row['tingkat_risiko']) ?>
                        </span>
                    </td>
                    <td class="px-6 py-4">Rp <?= number_format($row['nominal_kerugian'], 0, ',', '.') ?></td>
                    <td class="px-6 py-4 font-medium"><?= htmlspecialchars($row['status_laporan']) ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</section>

<?php include 'includes/footer.php'; ?>