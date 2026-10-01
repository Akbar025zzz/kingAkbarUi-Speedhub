# ⚡ King Akbar UI — SpeedHub & UIWrapper

> Framework User Interface Luau modular untuk Roblox scripting yang menggabungkan **Core GUI Engine** (`kingAkbarui-speedHub`) dengan **Config & State Manager Wrapper** (`UIWrapper.lua`). Dirancang khusus untuk mempermudah pembuatan script hub modern, responsif di Mobile & PC, serta mendukung penyimpanan konfigurasi otomatis (*Auto-Save Config*).

---

## 📑 Daftar Isi

- [Arsitektur Modul](#-arsitektur-modul)
- [Pemasangan & Quick Start](#-pemasangan--quick-start)
- [Dokumentasi Modul 1: UIWrapper.lua](#-dokumentasi-modul-1-uiwrapperlua)
  - [Inisialisasi Tabel (`SetTable` & `GetTable`)](#inisialisasi-tabel-settable--gettable)
  - [Toggle Helper](#toggle-helper)
  - [Button Helper](#button-helper)
  - [Slider Helper](#slider-helper)
  - [Dropdown Helper](#dropdown-helper)
  - [Textbox / Input Helper](#textbox--input-helper)
  - [Paragraph Helper](#paragraph-helper)
- [Dokumentasi Modul 2: Core Library (kingAkbarui-speedHub)](#-dokumentasi-modul-2-core-library-kingakbarui-speedhub)
  - [Window Manager (`CreateWindow`)](#window-manager-createwindow)
  - [Notifikasi Pop-up (`SetNotification`)](#notifikasi-pop-up-setnotification)
  - [Tab & Section Navigation](#tab--section-navigation)
- [Contoh Penerapan Penuh (Production Boilerplate)](#-contoh-penerapan-penuh-production-boilerplate)
- [Aset & Ikon Bawaan](#-aset--ikon-bawaan)
- [Kompatibilitas Executor](#-kompatibilitas-executor)

---

## 🏗️ Arsitektur Modul

Repository ini memisahkan logika UI menjadi dua modul mandiri agar kode rapi dan mudah di-maintain:

```text
kingAkbarUi-Speedhub/
├── kingAkbarui-speedHub  --> Core Engine: Render GUI, Tween, Anti-AFK, Draggable Mobile Toggle
└── UIWrapper.lua         --> State & Config: Type-checker, nil-safety, sinkronisasi tabel config
```

1. **`kingAkbarui-speedHub` (Core Engine):** Mengatur instansiasi ScreenGui, Tween animasi, interaksi drag touch/mouse, layout scrolling otomatis, dan Anti-AFK engine.
2. **`UIWrapper.lua` (State/Config Layer):** Berfungsi sebagai jembatan deklaratif. Pengembang tidak perlu menulis validasi tipe data berulang kali atau manual menyimpan value toggle/slider ke tabel config; wrapper ini mengelolanya secara otomatis.

---

## 🚀 Pemasangan & Quick Start

Muat kedua modul sekaligus ke dalam script menggunakan `game:HttpGet`:

```lua
-- 1. Load Core Library GUI
local Speed_Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/kingAkbarui-speedHub](https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/kingAkbarui-speedHub)"))()

-- 2. Load Config & Element Wrapper
local Helper = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/UIWrapper.lua](https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/UIWrapper.lua)"))()
```

---

## 📦 Dokumentasi Modul 1: UIWrapper.lua

`UIWrapper` bertugas membungkus pemanggilan elemen UI ke section dengan validasi tipe data otomatis dan sinkronisasi config.

### Inisialisasi Tabel (`SetTable` & `GetTable`)
Hubungkan tabel konfigurasi script kamu ke wrapper sebelum membuat elemen UI:

```lua
local ConfigTable = {
    ["Auto Attack"] = true,
    ["WalkSpeed"] = 25,
    ["Selected Island"] = {"Starter Island"}
}

-- Daftarkan tabel ke wrapper
Helper:SetTable(ConfigTable)

-- Mengambil referensi tabel aktif
local activeConfig = Helper:GetTable()
```

---

### Toggle Helper
Membuat switch on/off. Jika parameter default diisi `"Save"`, wrapper akan mengambil nilai awal langsung dari `ConfigTable[Name]`.

```lua
Helper:Toggle(Section, Name, Content, Default, Callback, CustomKey)
```
- **`Section`** *(Instance)*: Objek section induk.
- **`Name`** *(string)*: Judul toggle.
- **`Content`** *(string)*: Deskripsi fitur.
- **`Default`** *(boolean / "Save")*: Gunakan `"Save"` untuk membaca dari tabel config, atau berikan nilai boolean default (`true`/`false`).
- **`Callback`** *(function)*: Fungsi yang dipicu saat toggle berubah `function(boolean)`.
- **`CustomKey`** *(string, opsional)*: Key pengganti jika nama judul mengandung karakter format/emoji.

```lua
Helper:Toggle(MainSection, "Auto Farm", "Menyerang target otomatis", "Save", function(state)
    print("Auto Farm status:", state)
end)
```

---

### Button Helper
Membuat tombol eksekusi interaktif berikon.

```lua
Helper:Button(Section, Name, Content, Callback, Icon)
```
- **`Icon`** *(string, opsional)*: Asset ID gambar (Default: `"rbxassetid://16932740082"`).

```lua
Helper:Button(MainSection, "Teleport Spawn", "Kembali ke safe zone", function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
end)
```

---

### Slider Helper
Membuat slider pengatur angka dengan dukungan pembacaan config.

```lua
Helper:Slider(Section, Name, Content, Min, Max, Increment, Default, Callback, CustomKey)
```

```lua
Helper:Slider(MainSection, "WalkSpeed", "Atur kecepatan lari", 16, 150, 1, "Save", function(val)
    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = val end
end)
```

---

### Dropdown Helper
Membuat menu pilihan single/multi select dengan fitur pencarian teks.

```lua
Helper:Dropdown(Section, Name, Content, Multi, Options, Default, Callback, CustomKey)
```

```lua
Helper:Dropdown(MainSection, "Pilih Target", "Daftar musuh di area", false, {"Slime", "Goblin", "Dragon"}, "Save", function(selected)
    print("Target terpilih:", selected[1])
end)
```

---

### Textbox / Input Helper
Membuat input form satu baris dengan sinkronisasi otomatis saat focus hilang (*Enter*).

```lua
Helper:Textbox(Section, Name, Content, Default, Callback, CustomKey)
```

```lua
Helper:Textbox(MainSection, "Cari Pemain", "Ketik nama pemain", "Save", function(text)
    print("Nama diinput:", text)
end)
```

---

### Paragraph Helper
Menampilkan kotak deskripsi informasi.

```lua
Helper:Paragraph(MainSection, "Status Sistem", "Koneksi stabil | Ping: 40ms")
```

---

## 🎨 Dokumentasi Modul 2: Core Library (kingAkbarui-speedHub)

### Window Manager (`CreateWindow`)
Membuat frame utama script hub:

```lua
local Window = Speed_Library:CreateWindow({
    Title = "KING AKBAR",                -- Nama script hub utama
    Description = "SPEED HUB",           -- Label teks aksen merah
    TabWidth = 125,                      -- Lebar panel navigasi kiri (px)
    SizeUi = UDim2.fromOffset(560, 320)  -- Ukuran keseluruhan jendela
})
```

---

### Notifikasi Pop-up (`SetNotification`)
Menampilkan toast message di sudut kanan bawah layar:

```lua
Speed_Library:SetNotification({
    Title = "King Akbar",
    Description = "System",
    Content = "Modul berhasil dimuat secara optimal!",
    Time = 0.4,                          -- Durasi animasi transisi
    Delay = 3.5                          -- Waktu tampil sebelum tertutup (detik)
})
```

---

### Tab & Section Navigation
```lua
-- Membuat Tab Kiri
local TabMain = Window:CreateTab({
    Name = "Farming",
    Icon = "rbxassetid://7734010488"
})

-- Membuat Accordion Section Lipat
-- Parameter 2: true = terbuka default, false = terlipat default
local SectionCombat = TabMain:AddSection("Pengaturan Tempur", true)
local SectionLoot   = TabMain:AddSection("Filter Drop Barang", false)
```

---

## 💡 Contoh Penerapan Penuh (Production Boilerplate)

Script utuh siap pakai yang menggabungkan **`kingAkbarui-speedHub`** dan **`UIWrapper.lua`** lengkap dengan persistensi file JSON (*Save/Load Config* ke executor):

```lua
-- Inisialisasi Library
local Speed_Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/kingAkbarui-speedHub](https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/kingAkbarui-speedHub)"))()
local Helper = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/UIWrapper.lua](https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/UIWrapper.lua)"))()

-- Inisialisasi Penyimpanan Config Lokal
local ConfigPath = "KingAkbarHub_Config.json"
local MyConfig = {
    ["Auto Farm"] = false,
    ["Speed Multiplier"] = 16,
    ["Target Area"] = {"Starter Area"},
    ["Player Target"] = ""
}

-- Load Config dari Disk jika ada
if isfile and readfile and isfile(ConfigPath) then
    pcall(function()
        local decoded = game:GetService("HttpService"):JSONDecode(readfile(ConfigPath))
        for k, v in pairs(decoded) do
            MyConfig[k] = v
        end
    end)
end

-- Hubungkan tabel ke Helper
Helper:SetTable(MyConfig)

-- Buat Window Utama
local Window = Speed_Library:CreateWindow({
    Title = "KING AKBAR",
    Description = "SPEED HUB",
    TabWidth = 125,
    SizeUi = UDim2.fromOffset(560, 320)
})

Speed_Library:SetNotification({
    Title = "Hub",
    Description = "Ready",
    Content = "Semua modul berhasil diinisialisasi!",
    Delay = 3
})

-- Tab 1: Farming
local TabFarm = Window:CreateTab({ Name = "Farm", Icon = "rbxassetid://7734010488" })
local SecFarm = TabFarm:AddSection("Automasi Utama", true)

Helper:Toggle(SecFarm, "Auto Farm", "Menyerang musuh otomatis", "Save", function(state)
    _G.AutoFarm = state
    print("Auto farm aktif:", state)
end)

Helper:Slider(SecFarm, "Speed Multiplier", "Kecepatan berjalan karakter", 16, 120, 2, "Save", function(val)
    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

Helper:Dropdown(SecFarm, "Target Area", "Pilih zona berburu", false, {"Starter Area", "Desert Zone", "Ice Cavern"}, "Save", function(selected)
    print("Area terpilih:", selected[1])
end)

-- Tab 2: Pengaturan & Simpan Config
local TabSettings = Window:CreateTab({ Name = "Settings", Icon = "rbxassetid://7733964719" })
local SecConfig = TabSettings:AddSection("Manajemen Konfigurasi", true)

Helper:Button(SecConfig, "Save Configuration", "Simpan settingan ke penyimpanan executor", function()
    if writefile then
        local encoded = game:GetService("HttpService"):JSONEncode(Helper:GetTable())
        writefile(ConfigPath, encoded)
        Speed_Library:SetNotification({
            Title = "Config",
            Description = "Saved",
            Content = "Data berhasil disimpan ke " .. ConfigPath,
            Delay = 3
        })
    end
end)

Helper:Paragraph(SecConfig, "Informasi Script", "Dibuat menggunakan King Akbar SpeedHub UI Engine.")
```

---

## 🖼️ Aset & Ikon Bawaan

| Deskripsi | Asset ID |
| :--- | :--- |
| **Mobile Draggable Toggle** | `rbxassetid://136890595976124` |
| **Ripple Click Effect** | `rbxassetid://106471194043211` |
| **Accordion Arrow** | `rbxassetid://125609963478878` |
| **Default Action Icon** | `rbxassetid://16932740082` |
| **Dropdown Indicator** | `rbxassetid://90200523188815` |

---

## 📱 Kompatibilitas Executor

Framework ini sepenuhnya mendukung eksekusi di:
- **Mobile (Android/iOS):** Delta, Fluxus Mobile, Vega X, Hydrogen, Codex, Arceus X Neo.
- **PC (Windows/macOS):** Solara, Wave, MacSploit, Synapse Z, serta environment Roblox Studio.
