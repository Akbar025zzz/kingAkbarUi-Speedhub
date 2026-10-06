# Migrasi dari v1.4 ke v2.0

| v1.4 | v2.0 | Aksi |
| --- | --- | --- |
| `SetTheme` sebelum `CreateWindow` wajib | Runtime, kapan saja | ✅ Opsional, script lama tetap jalan |
| Toggle callback terpanggil saat init | Tidak lagi | ⚠️ Cek script yang bergantung pada ini |
| Wrapper multi-dropdown "Save" | 🐛 Bug fix: sekarang benar tersimpan | Update `wrapper.lua` |
| Wrapper dropdown `Default = "A"` | 🐛 Bug fix: tidak dipaksa jadi table | Update `wrapper.lua` |
| Icon Button wrapper hardcoded | Dihapus | Tambah `Icon = "rbxassetid://16932740082"` manual |
| `Library:SetTheme(Themes.X)` | Tetap jalan | Rekomendasi: `Themes.Apply(Library, "X")` |
