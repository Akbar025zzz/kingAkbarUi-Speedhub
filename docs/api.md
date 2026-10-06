# API Reference (v1.6)

Semua config menerima format **array** (urutan di tabel) atau **named** (nama field).

## Library

| Method | Deskripsi |
| --- | --- |
| `CreateWindow(config)` | Buat window, return `Window` |
| `SetTheme(table)` | Ganti warna tema (panggil **sebelum** `CreateWindow`) |
| `SetFont(table)` | Ganti font (`Bold`, `Regular`) |
| `SetNotification(config)` / `Notify(config)` | Tampilkan notifikasi |
| `GetConfig()` | Ambil tabel konfigurasi internal |
| `Destroy()` | Hapus semua UI |

## CreateWindow(config)

| # | Field | Default | Deskripsi |
| --- | --- | --- | --- |
| 1 | `Title` | `""` | Judul |
| 2 | `Description` | `""` | Sub-judul |
| 3 | `TabWidth` | `112` | Lebar panel tab |
| 4 | `SizeUi` | otomatis | `UDim2` ukuran window; kosong = menyesuaikan layar |
| 5 | `Search` | `false` | Kolom search di daftar tab |
| 6 | `Profile` | `false` | Avatar + "Welcome, nama" di bawah daftar tab |
| 7 | `Logo` | `""` | Ikon di sebelah judul |
| 8 | `HideName` | `true` | Sensor nama user (abc***) |
| 9 | `ToggleKey` | `RightShift` | Hotkey tampil/sembunyi |

## Window

| Method | Deskripsi |
| --- | --- |
| `CreateTab({ Name, Icon })` | Buat tab, return `Tab` |
| `AddBadge(text)` | Badge di topbar; return objek dengan `SetText(t)`, `Destroy()` |
| `SetToggleKey(KeyCode)` | Ganti hotkey |
| `Show()` / `Hide()` / `Toggle()` | Visibilitas |
| `Destroy()` | Hapus window |

## Tab

| Method | Deskripsi |
| --- | --- |
| `AddSection(judul, terbukaDefault)` | Section collapsible, return `Section` |
| `AddTabBox(config)` | Kotak multi-halaman, lihat [tabbox.md](tabbox.md) |

## Komponen (Section dan Page TabBox)

Method umum semua komponen: `SetTitle(text)`, `SetContent(text)`, `SetVisible(bool)`, `Destroy()`.

| Method | Urutan field | Method tambahan |
| --- | --- | --- |
| `AddParagraph` | `Title, Content` | `Set(config)` |
| `AddSeperator` | `Title` | `Set(config)` |
| `AddLine` | — | `Destroy()` |
| `AddButton` | `Title, Content, Icon, Callback` | `Set(config)` |
| `AddToggle` | `Title, Content, Default, Callback` | `Set(value)`, `.Value` |
| `AddSlider` | `Title, Content, Increment, Min, Max, Default, Callback` | `Set(value, fire?)` |
| `AddInput` | `Title, Content, Default, Callback` | `Set(value)` |
| `AddDropdown` | `Title, Content, Multi, Options, Default, Callback` | `Set(value, noCallback?)`, `Clear()`, `AddOption(name)`, `Refresh(list, selected)` |
| `AddKeybind` | `Title, Content, Default, Callback, Changed` | `Set(key, noCallback?)` |
| `AddColorPicker` | `Title, Content, Default, Callback` | `Set(color, noCallback?)` |
| `AddPanel` | `Title, Content` | `AddButton(cfg)`, `AddToggle(cfg)` |

Catatan:
- Keybind: `Callback` dipanggil saat hotkey **ditekan**, `Changed` saat key **diganti**.
- Dropdown `Default` berupa tabel (`{ "A" }`); callback menerima tabel pilihan.
- Callback komponen lama masih **satu slot**. `OnChanged` dengan registry baru ada di TabBox.

## SetNotification(config)

| # | Field | Default |
| --- | --- | --- |
| 1 | `Title` | `""` |
| 2 | `Description` | `""` |
| 3 | `Content` | `""` |
| 5 | `Time` | `0.5` (lama animasi) |
| 6 | `Delay` | `5` (lama tampil) |
