# Alesto Script v2.0 🚀

Modernizirana verzija Trenches scripta s naprednim UI dizajnom i dodatnim funkcionalnostima.

## ✨ Značajke

### 🎨 Modern UI
- **Gradient efekti** - Lijepi gradijenti na svim elementima
- **Drop shadow** - Realistične sjene
- **Smooth animacije** - Glatke prijelaze i hover efekti
- **Rounded corners** - Moderne zaobljene kutove
- **Color scheme** - Profesionalna tamna tema

### 🎮 Funkcionalnosti
- **Aimbot** - Automatsko ciljanje
- **ESP** - Vidljivost kroz zidove
- **Speed** - Povećana brzina kretanja (60 walk speed)
- **Jump** - Povećana snaga skakanja (120 jump power)
- **Fly** - Letenje
- **NoClip** - Prolazak kroz objekte
- **Infinite Jump** - Beskonačno skakanje
- **Anti Aim** - Anti-aim protekcija

### 🎯 Kontrole
- **Right Shift** - Otvori/zatvori meni
- **M** - Minimiziraj/maksimiziraj meni
- **Right Control** - Uključi/isključi način pomicanja
- **Lijevi klik + pomicanje** - Pomiči meni po ekranu

### 💬 Komande
- `/menu` - Otvori/zatvori meni
- `/minimize` - Minimiziraj/maksimiziraj meni
- `/move <x> <y>` - Premjesti meni na određenu poziciju
- `/help` - Prikaži dostupne komande

## 🚀 Kako pokrenuti

### Opcija 1: Direktno u executor (PREPORUČENO)
```lua
-- Kopiraj SAV kod iz Alesto_Script.lua
-- Zalijepi direktno u executor
-- Pokreni
```

### Opcija 2: Jedna linija koda
```lua
-- Kopiraj ovu liniju u executor:
loadstring(game:HttpGet("YOUR_HOSTED_URL"))()
```

### Opcija 3: Hostaj sam
1. Upload `Alesto_Script.lua` na GitHub/Pastebin
2. Koristi jednu liniju:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repo/main/Alesto_Script.lua"))()
```

## 🎨 UI Značajke

### Boje
- **Primary** - Glavna pozadinska boja
- **Secondary** - Sekundarna pozadinska boja
- **Accent** - Plava akcentna boja za hover efekte
- **Success** - Zelena boja za aktivirane funkcije
- **Warning** - Narančasta boja za upozorenja
- **Error** - Crvena boja za greške

### Animacije
- **Smooth transitions** - Glatki prijelazi između stanja
- **Click effects** - Vizualni feedback na klikove
- **Hover effects** - Interaktivni hover efekti
- **Gradient animations** - Animirani gradijenti

## ⚙️ Konfiguracija

Možete prilagoditi u `Config` tablici:
```lua
local Config = {
    MenuKey = Enum.KeyCode.RightShift,    -- Tipka za otvaranje menija
    MinimizeKey = Enum.KeyCode.M,         -- Tipka za minimiziranje
    DragKey = Enum.KeyCode.RightControl,  -- Tipka za drag mod
    MenuSize = UDim2.new(0, 350, 0, 450), -- Veličina menija
    Colors = {
        Primary = Color3.fromRGB(45, 45, 45),
        Accent = Color3.fromRGB(0, 150, 255),
        -- ... više boja
    }
}
```

## 🔧 Troubleshooting

### Meni se ne pojavljuje:
1. Provjerite je li script pokrenut u Roblox
2. Provjerite konzolu za poruke o greškama
3. Provjerite je li `MainFrame` kreiran

### Kontrole ne rade:
1. Provjerite je li `UserInputService` dostupan
2. Provjerite je li `LocalPlayer` učitan
3. Provjerite konzolu za greške

### Komande ne rade:
1. Provjerite je li `TextChatService` dostupan
2. Provjerite je li chat omogućen
3. Provjerite sintaksu komandi

## 📝 Napomene

- Script koristi TweenService za glatke animacije
- Komande rade kroz chat sistem
- Meni se može pomicati samo kada je u drag modu
- Pozicija se pamti dok se script ne restartira
- Sve funkcije imaju vizualne indikatore stanja
- Moderniziran UI s gradijentima i sjenama

## 🎯 Preporučena verzija

Za najbolje iskustvo, koristite **`Alesto_Script.lua`** jer:
- Ima sve funkcionalnosti
- **Moderne UI komponente**
- **Glatke animacije**
- **Gradient efekti**
- Kompletni sistem komandi
- Lako se prilagođava
- **Nema potrebe za vanjskim hostingom**

## 🔒 Sigurnost

- Script je potpuno siguran za korištenje
- Ne sadrži štetne komponente
- Možete pregledati sav kod
- Otvorenog je koda za prilagođavanje

## 💡 Brzi start

1. Otvori `Alesto_Script.lua`
2. Kopiraj sav kod
3. Zalijepi u executor
4. Pokreni
5. Pritisni **Right Shift** za otvaranje menija

**Uživajte u modernom Alesto Scriptu!** 🎉

## 🆕 Verzija 2.0

### Nove funkcionalnosti:
- **Infinite Jump** - Beskonačno skakanje
- **Anti Aim** - Anti-aim protekcija
- **Modern UI** - Potpuno redizajniran interface
- **Gradient efekti** - Lijepi gradijenti
- **Drop shadows** - Realistične sjene
- **Smooth animations** - Glatke animacije
- **Better colors** - Profesionalna paleta boja 