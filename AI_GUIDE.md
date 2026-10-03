# 🤖 King Akbar UI — Panduan untuk AI

File ini dibuat supaya **AI (Claude, ChatGPT, Gemini, dll.) bisa menulis script hub yang benar** memakai King Akbar UI, tanpa menebak-nebak API.

## Cara pakai (untuk user)

1. Salin **seluruh isi file ini** ke AI.
2. Lanjutkan dengan permintaanmu, misalnya:

> Pakai panduan di atas. Buatkan script hub untuk game **[nama game]** dengan fitur: auto collect coin, auto sell, WalkSpeed slider, dan pilihan lokasi teleport (dropdown). Ikuti TEMPLATE persis dan isi logikanya.

3. Salin hasilnya ke executor.

> Kalau hasil AI error, kirim **pesan error dari console (F9)** ke AI beserta script-nya, lalu minta diperbaiki.

---

## ATURAN UNTUK AI (WAJIB DIIKUTI)

1. **Selalu pakai struktur TEMPLATE di bawah.** Jangan membuat struktur sendiri.
2. **Jangan mengarang method.** Pakai hanya method yang ada di "Referensi API". Jika ragu, jangan dipakai.
3. **Hierarki wajib:** `Library → Window → Tab → Section → Komponen`.
   - `Window:CreateTab({ "Nama" })`
   - `Tab:AddSection("Judul", true)` (`true` = terbuka)
   - Komponen (`AddToggle`, `AddButton`, dst.) **hanya ada di Section**, bukan di Tab atau Window.
4. **Semua parameter pakai format bernama** (`{ Title = "...", Callback = function() end }`), bukan array.
5. **Fitur "auto" wajib memakai helper `Loop()`** dari template: loop berhenti saat toggle dimatikan, tidak dobel, dan terlindungi `pcall`. Jangan menulis `while true do` tanpa flag.
6. **Simpan status di tabel `State`**, bukan variabel global.
7. **Callback Dropdown selalu dinormalisasi:** `local v = (type(x) == "table") and x[1] or x`.
8. **Callback Keybind** menerima `Enum.KeyCode` (pakai `key.Name` untuk namanya).
9. **Tema & font diatur SEBELUM `CreateWindow`.**
10. **Jangan memakai** `Library.new`, `Window:AddTab`, `Tab:AddToggle`, `Section:AddLabel`, `Library:Init`, atau method lain yang tidak tercantum di bawah.
11. Tambahkan `SaveKey = "nama_unik"` pada komponen yang pilihannya perlu disimpan.
12. Tulis komentar bahasa Indonesia singkat di tiap fitur, dan beri tanda `-- TODO:` hanya jika logika memang tidak bisa dibuat.

---

## REFERENSI API

### Memuat library
```lua
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/"
local Library = loadstring(game:HttpGet(BASE .. "init.lua"))()
local Themes  = loadstring(game:HttpGet(BASE .. "themes.lua"))()
```

### Library
| Method | Fungsi |
|---|---|
| `Library:CreateWindow(config)` | Buat window |
| `Library:SetNotification({ Title, Description, Content, Delay })` | Notifikasi |
| `Library:Dialog({ Title, Content, Buttons = { { "Ya", fn, true }, { "Batal", fn } } })` | Dialog konfirmasi |
| `Library:SetTheme(table)` / `Themes.Apply(Library, "Nama")` | Ganti tema |
| `Library:EnableSave("File.json")` | Aktifkan penyimpanan (untuk `SaveKey`) |
| `Library:GetConfig()` | Pengaturan internal (`Window`, `Assets`, `Behavior`) |
| `Library:Destroy()` | Hapus UI |

### CreateWindow
`Title`, `Description`, `Search` (bool), `Profile` (bool), `HideName` (bool), `Logo` (rbxassetid), `ToggleKey` (Enum.KeyCode).
Ukuran window otomatis menyesuaikan layar.

### Window
`CreateTab({ "Nama" })`, `Show()`, `Hide()`, `Toggle()`, `Destroy()`

### Komponen (dipanggil dari Section)
| Method | Field utama | Method tambahan |
|---|---|---|
| `AddButton` | `Title, Content, Callback` | — |
| `AddToggle` | `Title, Content, Default, Callback, SaveKey` | `Set(bool)`, `.Value` |
| `AddSlider` | `Title, Content, Min, Max, Increment, Default, Callback, SaveKey` | `Set(number)`, `.Value` |
| `AddInput` | `Title, Content, Default, Callback, SaveKey` | `Set(text)` |
| `AddDropdown` | `Title, Content, Multi, Options, Default, Callback, SaveKey` | `Set(v)`, `Refresh(list, selected)`, `AddOption(name)`, `Clear()` |
| `AddKeybind` | `Title, Content, Default (Enum.KeyCode), Callback, SaveKey` | `Set(key)` |
| `AddColorPicker` | `Title, Content, Default (Color3), Callback, SaveKey` | `Set(color)` |
| `AddParagraph` | `Title, Content` | `Set({ Title, Content })` |
| `AddSeperator` | `Title` | — |
| `AddLine` | — | — |
| `AddPanel` | `Title, Content` | sub: `AddButton`, `AddToggle` |

Semua komponen juga punya: `SetTitle(text)`, `SetContent(text)`, `SetVisible(bool)`, `Destroy()`.

### Tema yang tersedia
Dark, Neon, Cyberpunk, BloodRed, Gold, Purple, Ocean, Light, Matrix, Sunset, Violet, dan lainnya (lihat `themes.lua`).

---

## TEMPLATE (ikuti persis)

```lua
-- ═══ PENGATURAN HUB ═══
local HUB = {
  Name = "Nama Hub", Tagline = "|  Komunitas", Game = "Nama Game", Version = "v1.0.0",
  Theme = "Violet", Logo = "rbxassetid://7734010488", ToggleKey = Enum.KeyCode.RightShift,
  SaveFile = "NamaHub.json",
}

-- ═══ LOAD ═══
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/"
local Library = loadstring(game:HttpGet(BASE .. "init.lua"))()
local Themes  = loadstring(game:HttpGet(BASE .. "themes.lua"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ═══ TEMA & SAVE (sebelum CreateWindow) ═══
if type(Themes.Apply) == "function" then Themes.Apply(Library, HUB.Theme)
elseif Themes[HUB.Theme] then Library:SetTheme(Themes[HUB.Theme]) end
Library:GetConfig().Window.BackgroundImage = ""
if type(Library.EnableSave) == "function" then Library:EnableSave(HUB.SaveFile) end

-- ═══ WINDOW ═══
local Window = Library:CreateWindow({
  Title = HUB.Name, Description = HUB.Tagline,
  Search = true, Profile = true, HideName = true,
  Logo = HUB.Logo, ToggleKey = HUB.ToggleKey,
})

-- ═══ HELPER ═══
local State, Loops = {}, {}
local function Loop(Flag, Interval, Fn)          -- fitur "auto": jalan selama State[Flag] == true
  if Loops[Flag] then return end
  Loops[Flag] = true
  task.spawn(function()
    while State[Flag] do
      local ok, err = pcall(Fn)
      if not ok then warn(Flag .. ": " .. tostring(err)) end
      task.wait(Interval)
    end
    Loops[Flag] = nil
  end)
end
local function Notify(Title, Text)
  Library:SetNotification({ Title = Title, Description = "•", Content = Text, Delay = 3 })
end

-- ═══ TAB ═══
local MainTab     = Window:CreateTab({ "Main" })
local SettingsTab = Window:CreateTab({ "Settings" })

-- ═══ FITUR ═══
local Farm = MainTab:AddSection("Farming", true)

Farm:AddToggle({
  Title = "Auto Farm", Content = "Deskripsi singkat", Default = false, SaveKey = "auto_farm",
  Callback = function(on)
    State.AutoFarm = on
    if on then
      Loop("AutoFarm", 0.5, function()
        -- logika fitur di sini
      end)
    end
  end,
})

Farm:AddDropdown({
  Title = "Target", Multi = false, Options = { "A", "B", "C" }, Default = "A", SaveKey = "target",
  Callback = function(x)
    State.Target = (type(x) == "table") and x[1] or x
  end,
})

-- ═══ SETTINGS (wajib ada) ═══
local Misc = SettingsTab:AddSection("Lainnya", true)
Misc:AddButton({
  Title = "Tutup UI", Content = "Hapus UI & hentikan semua fitur",
  Callback = function()
    for k in pairs(State) do State[k] = false end
    Library:Destroy()
  end,
})

Notify(HUB.Name, "Loaded — tekan [" .. HUB.ToggleKey.Name .. "] untuk buka/tutup UI")
```

Template lengkap dengan tab Info, ganti tema, hotkey UI, dan Anti-AFK ada di [`examples/template.lua`](examples/template.lua).

---

## KESALAHAN UMUM (hindari)

| ❌ Salah | ✅ Benar |
|---|---|
| `Tab:AddToggle({...})` | `Tab:AddSection("X", true):AddToggle({...})` |
| `Window:AddTab("Main")` | `Window:CreateTab({ "Main" })` |
| `Library.new("Judul")` | `Library:CreateWindow({ Title = "Judul" })` |
| `while true do ... end` untuk fitur auto | `Loop("Flag", detik, function() ... end)` |
| `Callback = function(v) print(v[1]) end` pada Dropdown tanpa cek tipe | `local n = (type(v) == "table") and v[1] or v` |
| `SetTheme` setelah elemen dibuat (v1.x) | `SetTheme` / `Themes.Apply` sebelum `CreateWindow` |
| Dua item dengan `SaveKey` sama | `SaveKey` unik per item |
| Variabel global `_G.AutoFarm` | `State.AutoFarm` |
