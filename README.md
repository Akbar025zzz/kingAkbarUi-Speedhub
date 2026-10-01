# ⚡ King Akbar UI — SpeedHub Framework

> Framework User Interface Luau berperforma tinggi, responsif, dan kaya fitur untuk Roblox script development. Didesain secara khusus untuk kompatibilitas lintas platform (**Mobile & PC**), mendukung tema modern *Dark Industrial Neon*, efek riak interaktif (*ripple effect*), serta sistem manajemen memori dan GUI terisolasi.

---

## 📑 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Arsitektur & Kompatibilitas](#-arsitektur--kompatibilitas)
- [Instalasi Cepat](#-instalasi-cepat)
- [Dokumentasi Lengkap API](#-dokumentasi-lengkap-api)
  - [1. Library Inisialisasi](#1-library-inisialisasi)
  - [2. Sistem Notifikasi (`SetNotification`)](#2-sistem-notifikasi-setnotification)
  - [3. Window Manager (`CreateWindow`)](#3-window-manager-createwindow)
  - [4. Tab Manager (`CreateTab`)](#4-tab-manager-createtab)
  - [5. Accordion Section (`AddSection`)](#5-accordion-section-addsection)
  - [6. Elemen Interaktif](#6-elemen-interaktif)
    - [Button](#-button)
    - [Toggle (dengan Kontrol Programatik)](#-toggle-dengan-kontrol-programatik)
    - [Slider (Drag & Direct Text Input)](#-slider-drag--direct-text-input)
    - [Input / Textbox](#-input--textbox)
    - [Dropdown (Search Bar & Multi-Select)](#-dropdown-search-bar--multi-select)
    - [Paragraph (Auto-Wrap Dynamic Height)](#-paragraph-auto-wrap-dynamic-height)
    - [Separator & Line](#-separator--line)
- [Contoh Script Lengkap (Boilerplate)](#-contoh-script-lengkap-boilerplate)
- [Daftar Aset ID Default](#-daftar-aset-id-default)
- [Troubleshooting & FAQ](#-troubleshooting--faq)

---

## 🚀 Fitur Utama

- 📱 **Mobile Touch Optimization:** Dilengkapi floating toggle button berlogo kustom yang dapat digeser (*draggable*) untuk menyembunyikan/membuka GUI di layar HP tanpa memakan ruang pandang.
- 🛡️ **Built-in Anti-AFK Engine:** Terintegrasi langsung dengan `VirtualUser` dan event `Player.Idled` untuk mencegah *Kick Error Code 268 / 20-minute idle disconnect*.
- 🔒 **Safe CoreGui Parenting:** Mendukung `gethui()`, `cloneref()`, serta fallback `CoreGui` dan `PlayerGui` (Roblox Studio) agar script aman dari deteksi UI client dasar.
- 🔎 **Smart Dropdown with Search:** Panel dropdown independen dengan fitur filtering teks instan dan dukungan multi-select.
- 📐 **Dynamic Layout Engine:** Tinggi elemen teks, deskripsi, dan accordion dihitung secara real-time berdasarkan `TextBounds` dan pembungkus baris otomatis.

---

## 🛠️ Arsitektur & Kompatibilitas

Framework ini telah diuji dan kompatibel dengan berbagai level executor mobile maupun desktop:

| Platform | Executor yang Didukung |
| :--- | :--- |
| **Android / iOS** | Delta, Fluxus Mobile, Vega X, Hydrogen, Codex, Cryptic |
| **Windows / macOS** | Solara, Wave, Synapse Z, MacSploit, Roblox Studio |

---

## 📦 Instalasi Cepat

Muat library secara langsung ke dalam executor menggunakan `loadstring` dan `game:HttpGet`:

```lua
local Speed_Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/kingAkbarui-speedHub](https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/kingAkbarui-speedHub)"))()
```

---

## 📖 Dokumentasi Lengkap API

Library mendukung format konfigurasi berupa **Dictionary Key** (`Title = ...`) maupun **Indexed Array** (`[1] = ...`).

---

### 1. Library Inisialisasi

Ketika library dimuat, fungsi **Anti-AFK** otomatis aktif di background. Properti status framework:

```lua
-- Memeriksa apakah GUI telah ditutup permanen oleh user
print(Speed_Library.Unloaded) -- boolean (true/false)
```

---

### 2. Sistem Notifikasi (`SetNotification`)

Menampilkan notifikasi pop-up animasi di pojok kanan bawah dengan stack otomatis ke atas.

```lua
local Notification = Speed_Library:SetNotification({
    Title = "Sistem",                     -- [1] Judul utama
    Description = "Berhasil",             -- [2] Sub-judul (Aksen Merah)
    Content = "Script berhasil dimuat!",  -- [3] Pesan detail
    Time = 0.5,                           -- [5] Durasi tween animasi (detik)
    Delay = 4                             -- [6] Waktu tampil sebelum auto-close (detik)
})

-- Menutup notifikasi secara manual sebelum delay habis:
-- Notification:Close()
```

---

### 3. Window Manager (`CreateWindow`)

Membuat jendela utama script hub.

```lua
local Window = Speed_Library:CreateWindow({
    Title = "KING AKBAR",                -- [1] Nama utama script
    Description = "SPEED HUB",           -- [2] Tagline / versi (berwarna aksen)
    TabWidth = 120,                      -- [3] Lebar panel navigasi tab kiri (offset px)
    SizeUi = UDim2.fromOffset(550, 315)  -- [4] Dimensi awal jendela utama
})
```

---

### 4. Tab Manager (`CreateTab`)

Membuat kategori tab di panel navigasi sebelah kiri.

```lua
local MainTab = Window:CreateTab({
    Name = "Main Farm",                  -- [1] Nama tab
    Icon = "rbxassetid://7734010488"     -- [2] Icon asset ID Roblox
})

local PlayerTab = Window:CreateTab({
    Name = "Local Player",
    Icon = "rbxassetid://7733964719"
})
```

---

### 5. Accordion Section (`AddSection`)

Membuat grup penampung elemen berbentuk drop-down accordion lipat.

```lua
-- Parameter:
-- 1. Title (string): Judul section
-- 2. OpenSection (boolean): true = terbuka saat dimuat, false = terlipat
local FarmSection = MainTab:AddSection("Auto Farming Options", true)
local TeleportSection = MainTab:AddSection("Teleport Lokasi", false)
```

---

### 6. Elemen Interaktif

Semua elemen di bawah ini dibuat dari objek section yang telah diinisialisasi (`FarmSection`, dll).

#### 🔘 Button
Tombol aksi dengan efek riak (ripple) saat ditekan.
```lua
FarmSection:AddButton({
    Title = "Claim Gift",                -- [1] Judul tombol
    Content = "Klaim hadiah gratis",     -- [2] Keterangan/deskripsi
    Icon = "rbxassetid://16932740082",   -- [3] Icon tombol kanan
    Callback = function()                -- [4] Fungsi saat tombol diklik
        print("Hadiah berhasil di-claim!")
    end
})
```

---

#### 🔀 Toggle (dengan Kontrol Programatik)
Switch on/off dengan animasi indikator warna dinamis.
```lua
local MyToggle = FarmSection:AddToggle({
    Title = "Auto Attack",
    Content = "Serang musuh terdekat otomatis",
    Default = false,                     -- [3] Status default (true / false)
    Callback = function(State)          -- [4] Return boolean status
        print("Toggle aktif:", State)
    end
})

-- Kontrol eksternal/programatik:
MyToggle:Set(true)  -- Mengaktifkan toggle secara instan dan memanggil callback
MyToggle:Set(false) -- Menonaktifkan toggle
print(MyToggle.Value) -- Cek status saat ini
```

---

#### 🎚️ Slider (Drag & Direct Text Input)
Slider pengatur nilai numerik yang dapat digeser atau diketik langsung nilainya pada kotak angka.
```lua
local MySlider = FarmSection:AddSlider({
    Title = "WalkSpeed Multiplier",
    Content = "Sesuaikan kecepatan berjalan",
    Increment = 1,                       -- [3] Nilai pembulatan step
    Min = 16,                            -- [4] Batas minimal
    Max = 200,                           -- [5] Batas maksimal
    Default = 16,                        -- [6] Nilai awal
    Callback = function(Value)          -- [7] Return number value
        local Char = game.Players.LocalPlayer.Character
        if Char and Char:FindFirstChild("Humanoid") then
            Char.Humanoid.WalkSpeed = Value
        end
    end
})

-- Kontrol programatik:
MySlider:Set(50) -- Memindahkan posisi slider ke 50 dan memicu callback
```

---

#### ⌨️ Input / Textbox
Form isian string satu baris.
```lua
local MyInput = FarmSection:AddInput({
    Title = "Teleport Target",
    Content = "Masukkan sebagian nama pemain",
    Default = "",                        -- Nilai teks awal
    Callback = function(Text)           -- Terpanggil saat user menekan Enter / FocusLost
        print("Input diterima:", Text)
    end
})

-- Kontrol programatik:
MyInput:Set("BarXYZ") -- Mengisi nilai input box
```

---

#### 🔽 Dropdown (Search Bar & Multi-Select)
Menu seleksi interaktif dengan search filter built-in.
```lua
-- Single Selection
local IslandDropdown = FarmSection:AddDropdown({
    Title = "Pilih Lokasi",
    Content = "Pilih pulau untuk teleportasi",
    Multi = false,                       -- false = Single Select
    Options = {"Pulau Pemula", "Gurun Pasir", "Gunung Es", "Lautan Api"},
    Default = {"Pulau Pemula"},          -- Harus berupa tabel string
    Callback = function(SelectedTable)  -- Return tabel opsi terpilih
        print("Lokasi terpilih:", SelectedTable[1])
    end
})

-- Multi Selection
local FilterDropdown = FarmSection:AddDropdown({
    Title = "Filter Rarity",
    Content = "Pilih tier item yang ingin disimpan",
    Multi = true,                        -- true = Multi Select
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
    Default = {"Legendary", "Mythic"},
    Callback = function(SelectedTable)
        print("Daftar tier aktif:")
        for _, tier in ipairs(SelectedTable) do
            print("- " .. tier)
        end
    end
})

-- Method Manipulasi Dropdown:
IslandDropdown:AddOption("Pulau Rahasia")             -- Menambah opsi baru
IslandDropdown:Clear()                                -- Menghapus seluruh opsi
IslandDropdown:Refresh({"Kota A", "Kota B"}, {"Kota A"}) -- Reset total opsi & default
IslandDropdown:Set({"Kota B"})                       -- Memilih opsi secara programatik
```

---

#### 📄 Paragraph (Auto-Wrap Dynamic Height)
Penampil teks informasi statis maupun dinamis.
```lua
local InfoParagraph = FarmSection:AddParagraph({
    Title = "Status Server",
    Content = "Memeriksa status koneksi..."
})

-- Memperbarui isi paragraph sewaktu-waktu:
InfoParagraph:Set({
    Title = "Status Server: Stabil",
    Content = "FPS: 60 | Ping: 45ms | Server Uptime: 3 Jam"
})
```

---

#### ➖ Separator & Line
Elemen dekoratif untuk membagi kategori dalam section.
```lua
-- Separator dengan teks judul berlatar gradien:
local Sep = FarmSection:AddSeperator({
    Title = "Pengaturan Lanjutan"
})
Sep:Set({ Title = "Opsi Lainnya" }) -- Mengubah judul separator

-- Garis pembatas tipis bergradien polos:
FarmSection:AddLine()
```

---

## 💡 Contoh Script Lengkap (Boilerplate)

Contoh nyata menyusun hub fungsional dari awal sampai akhir:

```lua
local Speed_Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/kingAkbarui-speedHub](https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/kingAkbarui-speedHub)"))()

-- 1. Buat Window
local Window = Speed_Library:CreateWindow({
    Title = "KING AKBAR",
    Description = "SPEED HUB V2",
    TabWidth = 125,
    SizeUi = UDim2.fromOffset(560, 320)
})

-- 2. Tampilkan Notifikasi Pembuka
Speed_Library:SetNotification({
    Title = "King Akbar UI",
    Description = "Loaded",
    Content = "Selamat datang, framework berhasil diinisialisasi!",
    Delay = 3
})

-- 3. Inisialisasi Tab
local TabMain = Window:CreateTab({ Name = "Main", Icon = "rbxassetid://7734010488" })
local TabPlayer = Window:CreateTab({ Name = "Player", Icon = "rbxassetid://7733964719" })

-- 4. Inisialisasi Section
local SecFarm = TabMain:AddSection("Farming Otomatis", true)
local SecMove = TabPlayer:AddSection("Karakter & Movement", true)

-- 5. Tambah Komponen
SecFarm:AddToggle({
    Title = "Auto Farm Level",
    Content = "Mencari monster terdekat dan menyerang otomatis",
    Default = false,
    Callback = function(state)
        _G.AutoFarm = state
        print("Farming:", state)
    end
})

SecFarm:AddDropdown({
    Title = "Target Monster",
    Content = "Pilih jenis monster sasaran",
    Multi = false,
    Options = {"Slime [Lv. 1]", "Goblin [Lv. 15]", "Orc [Lv. 50]"},
    Default = {"Slime [Lv. 1]"},
    Callback = function(val)
        print("Sasaran:", val[1])
    end
})

SecFarm:AddLine()

SecFarm:AddButton({
    Title = "Reset Position",
    Content = "Kembali ke titik awal respawn",
    Icon = "rbxassetid://16932740082",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char then char:BreakJoints() end
    end
})

SecMove:AddSlider({
    Title = "WalkSpeed",
    Content = "Atur kecepatan lari",
    Min = 16,
    Max = 120,
    Increment = 1,
    Default = 16,
    Callback = function(val)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
})

SecMove:AddSlider({
    Title = "JumpPower",
    Content = "Atur tinggi lompatan",
    Min = 50,
    Max = 250,
    Increment = 5,
    Default = 50,
    Callback = function(val)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then 
            hum.UseJumpPower = true
            hum.JumpPower = val 
        end
    end
})
```

---

## 🎨 Daftar Aset ID Default

Aset Roblox built-in yang digunakan oleh library:

| Fungsi | Asset ID | URL Preview |
| :--- | :--- | :--- |
| **Mobile Open/Close Button** | `rbxassetid://136890595976124` | Ikon toggle floating |
| **Ripple Click Effect** | `rbxassetid://106471194043211` | Lingkaran blur gradien |
| **Accordion Arrow Indicator**| `rbxassetid://125609963478878` | Panah segitiga rotasi |
| **Default Button Icon** | `rbxassetid://7734010488` | Ikon cursor / click |
| **Dropdown Indicator** | `rbxassetid://90200523188815` | Ikon menu layer |

---

## ❓ Troubleshooting & FAQ

#### 1. Mengapa UI tidak muncul saat di-execute?
Pastikan executor mendukung pemuatan konten RAW dari GitHub. Jika menggunakan koneksi internet tertentu di Indonesia yang memblokir domain `raw.githubusercontent.com`, gunakan DNS alternatif (1.1.1.1 atau 8.8.8.8).

#### 2. Bagaimana cara membuka menu kembali setelah di-minimize di perangkat Android?
Saat tombol tanda minus (`-`) di pojok kanan atas ditekan, jendela utama akan tersembunyi dan digantikan oleh tombol mengambang merah di sudut kiri layar. Sentuh tombol tersebut untuk menampilkan jendela utama kembali.

#### 3. Apakah Anti-AFK bisa memicu disconnect dari sistem game?
Tidak. Anti-AFK bekerja dengan meniru event klik mouse kanan melalui `VirtualUser:Button2Down` dan `VirtualUser:Button2Up` ke engine kamera game, sehingga Roblox menganggap pemain tetap aktif secara natural tanpa mengubah memori status game.

---

## 📜 Lisensi & Kontribusi

Proyek ini dirancang secara terbuka untuk komunitas scripter Roblox Luau. Bebas digunakan, dimodifikasi, dan disematkan ke dalam script hub publik maupun privat.
