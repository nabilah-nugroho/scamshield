<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SCAMSHIELD — Pelaporan & Verifikasi Penipuan Digital</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-stone-50 text-stone-800 min-h-screen flex flex-col">
    <nav class="bg-stone-900 text-white shadow-sm">
        <div class="max-w-6xl mx-auto px-6 py-4 flex justify-between items-center">
            <a href="index.php" class="font-bold text-xl tracking-wider text-emerald-400">SCAMSHIELD</a>
            <div class="flex items-center space-x-6 text-sm font-medium">
                <a href="index.php" class="hover:text-emerald-400 transition">Dashboard Publik</a>
                <a href="admin.php" class="hover:text-emerald-400 transition">Panel Verifier & Audit</a>
                <a href="report.php" class="bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-2 rounded-lg transition">
                    + Buat Laporan
                </a>
            </div>
        </div>
    </nav>

    <main class="max-w-6xl w-full mx-auto px-6 py-8 flex-1 space-y-8">
        <?php if (isset($_GET['success'])): ?>
            <div class="bg-emerald-50 border border-emerald-200 text-emerald-800 px-4 py-3 rounded-lg text-sm">
                <?= htmlspecialchars($_GET['success']) ?>
            </div>
        <?php endif; ?>
        <?php if (isset($_GET['error'])): ?>
            <div class="bg-rose-50 border border-rose-200 text-rose-800 px-4 py-3 rounded-lg text-sm">
                <strong>Database Error:</strong> <?= htmlspecialchars($_GET['error']) ?>
            </div>
        <?php endif; ?>