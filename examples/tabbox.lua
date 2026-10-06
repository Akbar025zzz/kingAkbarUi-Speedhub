# TabBox

Satu kotak berisi beberapa halaman (Page). Hierarki: Window → Tab → **TabBox → Page** → Komponen.

```lua
local Box  = Tab:AddTabBox({ Tabs = { "Farm", "Combat" }, Default = "Farm", Swipe = true })
local Farm = Box:GetTab("Farm")
Farm:AddToggle({ "Auto Farm", "", false, function(v) end })

local Extra = Box:AddTab("Extra")      -- tambah halaman belakangan
```

## Config

| Field | Default | Deskripsi |
| --- | --- | --- |
| `Tabs` | `{}` | Daftar nama halaman (boleh juga `AddTabBox({ "A", "B" })`) |
| `Default` | halaman pertama | Nama atau nomor halaman awal |
| `Swipe` | `false` | Geser kiri/kanan (touch) untuk pindah halaman |

## TabBox

| Method | Deskripsi |
| --- | --- |
| `AddTab(nama)` | Tambah halaman, return `Page` |
| `GetTab(nama \| nomor)` | Ambil `Page` |
| `SetValue(nama \| nomor, fire?)` | Pindah halaman; `fire = false` tidak memanggil `OnChanged` |
| `GetValue()` / `GetIndex()` | Nama / nomor halaman aktif |
| `OnChanged(fn)` | `fn(nama, nomor)`; return `{ Disconnect }`; bisa didaftarkan berkali-kali |
| `SetVisible(bool)` | Tampil/sembunyi seluruh kotak |
| `Destroy()` | Hapus kotak dan semua koneksinya |

## Page

Punya semua komponen dari [api.md](api.md) (`AddToggle`, `AddSlider`, ...) ditambah:

| Method | Deskripsi |
| --- | --- |
| `Select()` | Pindah ke halaman ini |
| `SetTitle(text)` | Ganti nama halaman |
| `SetVisible(bool)` | Sembunyikan/tampilkan tombol halaman |
| `Destroy()` | Hapus halaman |
