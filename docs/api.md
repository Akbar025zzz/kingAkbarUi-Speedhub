# API Reference

## Library

| Method | Deskripsi |
| --- | --- |
| `CreateWindow(config)` | Buat window utama |
| `SetTheme(table)` | Ganti tema (runtime) |
| `SetFont(table)` | Ganti font |
| `SetNotification(config)` | Tampilkan notifikasi |
| `Notify(config)` | Alias `SetNotification` |
| `Dialog(config)` | Confirm dialog |
| `SetSound(bool)` | ON/OFF sound effects |
| `EnableSave(fileName)` | Aktifkan save built-in |
| `DisableSave()` | Matikan save |
| `SetToggleKey(key)` | Ganti hotkey toggle UI |
| `GetConfig()` | Ambil CONFIG internal |
| `Destroy()` | Hapus semua UI |

## CreateWindow(config)

| Field | Type | Default | Deskripsi |
| --- | --- | --- | --- |
| `Title` | string | `""` | Judul window |
| `Description` | string | `""` | Sub-judul |
| `TabWidth` | number | `100` | Lebar panel tab |
| `SizeUi` | UDim2 | `420x280` | Ukuran window |
| `Search` | bool | `false` | Kolom search di daftar tab |
| `Profile` | bool | `false` | Avatar + welcome di footer |
| `Logo` | string | `""` | Icon di sebelah judul |
| `HideName` | bool | `true` | Sensor nama user (abc***) |
| `ToggleKey` | KeyCode | `RightShift` | Hotkey show/hide UI |

## Window

| Method | Deskripsi |
| --- | --- |
| `CreateTab({ Name, Icon })` | Buat tab baru |
| `Show()` / `Hide()` / `Toggle()` | Kontrol visibility |
| `Destroy()` | Hapus window |

## Item Components

Semua komponen mendukung format array (`{ "Title", "Content", ... }`) atau named (`{ Title = "..." }`). Method umum: `SetTitle(text)`, `SetContent(text)`, `SetVisible(bool)`, `Destroy()`.

| Method | Field | Extra Methods |
| --- | --- | --- |
| `AddButton` | `Title, Content, Icon, Callback, Tooltip` | `Set(config)` |
| `AddToggle` | `Title, Content, Default, Callback, Tooltip, SaveKey` | `Set(bool, fire?)`, `.Value` |
| `AddSlider` | `Title, Content, Increment, Min, Max, Default, Callback, Tooltip, SaveKey` | `Set(number, fire?)`, `.Value` |
| `AddInput` | `Title, Content, Default, Placeholder, Callback, Tooltip, SaveKey` | `Set(text, fire?)` |
| `AddDropdown` | `Title, Content, Multi, Options, Default, Callback, Search, Tooltip, SaveKey` | `Set(v)`, `Refresh(list, sel)`, `AddOption(name)`, `Clear()` |
| `AddKeybind` 🆕 | `Title, Content, Default, Callback, Tooltip, SaveKey` | `Set(key)`, `Get()` |
| `AddColorPicker` 🆕 | `Title, Content, Default, Callback, Presets, Tooltip, SaveKey` | `Set(color)`, `Get()` |
| `AddPanel` | `Title, Content, Tooltip` | sub: `AddButton`, `AddToggle` |
| `AddParagraph` | `Title, Content, Tooltip` | `Set(config)` |
| `AddSeperator` | `Title, Tooltip` | `Set(config)` |
| `AddLine` | — | `Destroy()` |

- **`SaveKey`**: jika diisi, nilai item otomatis dimuat saat script jalan dan tersimpan saat berubah (butuh `EnableSave()` atau wrapper).
- **`fire`**: `Set(value, false)` mengubah visual tanpa memanggil callback.

## SetNotification(config)

| Field | Type | Default |
| --- | --- | --- |
| `Title` | string | `""` |
| `Description` | string | `""` |
| `Content` | string | `""` |
| `Time` | number | `0.5` |
| `Delay` | number | `5` |
| `Progress` 🆕 | bool | `true` |

Maks 5 notif bersamaan, sisanya otomatis antri.

## Dialog(config)

```lua
Library:Dialog({
  Title   = "Konfirmasi",
  Content = "Yakin lanjut?",
  Buttons = {
    { "Ya", function() end, true },   -- true = tombol primary
    { "Batal", function() end },
  },
})
```
