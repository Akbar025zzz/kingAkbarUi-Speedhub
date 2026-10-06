# Changelog

## v1.7

- ➕ **GroupBox**: `Tab:AddGroupBox({ Title, Collapsible = false, Open = true, MaxHeight = nil })`
  - API standar: `SetValue(open)`, `GetValue`, `SetVisible`, `Destroy`, `OnChanged`, plus `Toggle`, `SetTitle`
  - Punya semua komponen Section (`AddToggle`, `AddSlider`, dst.)
  - `MaxHeight` mengaktifkan scroll sendiri (opsional; tanpa itu tidak ada scroll bersarang)
- 🔧 Internal: helper bersama `BindOwned`, `AddChanged`, `FireChanged` untuk komponen baru. `TabBox` dipindah ke helper ini, perilaku sama.
- `Section` dan `AddSection` tidak berubah.

## v1.6

- ➕ **TabBox**: `Tab:AddTabBox({ Tabs = {...}, Default = "...", Swipe = false })`
  - API standar: `SetValue`, `GetValue`, `SetVisible`, `Destroy`, `OnChanged` (registry callback)
  - Page punya semua komponen Section (`AddToggle`, `AddSlider`, dst.)
  - Opsi `Swipe` untuk pindah halaman dengan geser di HP
- 🔧 Internal: blok item diekstrak ke `BuildItems(container)` supaya dipakai Section dan TabBox. API lama tidak berubah.

Riwayat sebelum v1.6 belum didokumentasikan.
