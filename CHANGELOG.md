# Changelog

## v1.6

- ➕ **TabBox**: `Tab:AddTabBox({ Tabs = {...}, Default = "...", Swipe = false })`
  - API standar: `SetValue`, `GetValue`, `SetVisible`, `Destroy`, `OnChanged` (registry callback)
  - Page punya semua komponen Section (`AddToggle`, `AddSlider`, dst.)
  - Opsi `Swipe` untuk pindah halaman dengan geser di HP
- 🔧 Internal: blok item diekstrak ke `BuildItems(container)` supaya dipakai Section dan TabBox. API lama tidak berubah.

Riwayat sebelum v1.6 belum didokumentasikan.
