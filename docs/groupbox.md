# GroupBox

Kotak berjudul untuk mengelompokkan komponen. Hierarki: Window → Tab → **GroupBox** → Komponen.

```lua
local Box = Tab:AddGroupBox({ Title = "Farming", Collapsible = true, Open = true })
Box:AddToggle({ "Auto Farm", "", false, function(v) end })
Box:AddSlider({ "Delay", "", 1, 0, 10, 1, function(v) end })
```

Bisa juga `Tab:AddGroupBox("Judul")` untuk kotak sederhana.

## GroupBox vs Section

| | `AddSection` | `AddGroupBox` |
| --- | --- | --- |
| Buka/tutup | Selalu bisa | Opsional (`Collapsible`) |
| Animasi buka/tutup | Ya | Hanya rotasi panah |
| Scroll sendiri | Tidak | Opsional (`MaxHeight`) |
| `OnChanged` (registry) | Tidak | Ya |
| Method standar `SetValue/GetValue` | Tidak | Ya |

`AddSection` tidak berubah dan tetap bisa dipakai.

## Config

| # | Field | Default | Deskripsi |
| --- | --- | --- | --- |
| 1 | `Title` | `""` | Judul |
| 2 | `Collapsible` | `false` | Judul bisa diklik untuk buka/tutup |
| 3 | `Open` | `true` | Keadaan awal |
| 4 | `MaxHeight` | tidak ada | Tinggi maksimum isi (minimal 60). Lewat batas ini isi bisa digulir |

Catatan `MaxHeight`: halaman Tab sudah bisa discroll, jadi scroll di dalam scroll bisa membingungkan di HP. Pakai hanya untuk daftar yang panjang.

## Method

| Method | Deskripsi |
| --- | --- |
| `SetValue(open, fire?)` | Buka/tutup; `fire = false` tidak memanggil `OnChanged` |
| `GetValue()` | `true` jika terbuka |
| `Toggle()` | Balik keadaan |
| `SetTitle(text)` | Ganti judul |
| `OnChanged(fn)` | `fn(terbuka)`; return `{ Disconnect }`; bisa didaftarkan berkali-kali |
| `SetVisible(bool)` | Tampil/sembunyi seluruh kotak |
| `Destroy()` | Hapus kotak dan koneksinya |

Plus semua komponen dari [api.md](api.md) (`AddToggle`, `AddSlider`, ...).
