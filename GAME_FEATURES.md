# Princess Adventure 2D - Game Features Summary

## 🎮 **Core Game Overview**

A 2D platformer game built with Love2D featuring a princess character navigating through levels, fighting skeleton enemies, collecting coins, and reaching goal flags.

---

## 🏗️ **Architecture & File Structure**

### **Main Files:**

- `main.lua` - Main game loop, state management, input handling
- `config.lua` - Game constants, settings, colors, physics values
- `player.lua` - Princess character logic, movement, animations
- `enemy.lua` - Skeleton enemy AI, health system, animations
- `sprites.lua` - Sprite loading, animation system, scaling
- `camera.lua` - Camera system with zoom and limited vertical following
- `collision.lua` - Collision detection utilities and physics
- `level.lua` - Level management, progression, platform layouts
- `coin.lua` - Collectible coin system
- `bullet.lua` - Shooting system and projectile physics
- `mobile.lua` - Touch controls for mobile platforms

### **Asset Structure:**

```
game-folder/
├── princess/           # Princess sprites (1-5.png to 1-8.png, 1-13.png to 1-16.png)
├── skeleton/          # Skeleton enemy sprites (1.png to 4.png)
└── music/             # Background music files
```

---

## 👸 **Player Character (Princess)**

### **Movement & Physics:**

- **WASD/Arrow Keys** for movement
- **Space/W/Up** for jumping
- **Gravity system** (1500 units/sec²)
- **Ground and platform collision** detection
- **Speed:** 200 units/sec, **Jump Power:** 600 units

### **Sprite System:**

- **4-frame walking animations** for left/right movement
- **Original size:** 99×239 pixels, **scaled to:** 24×32 pixels
- **Direction-aware animations** with proper sprite flipping
- **Idle state** shows first frame of last direction moved

### **Combat Abilities:**

- **Shooting (X key):** Yellow bullets, 0.3s cooldown, 300 units/sec speed
- **Stun (Z key):** 50-pixel range AoE stun, 3s cooldown, 2s stun duration
- **Enemy defeat:** Jump on enemies or shoot them

---

## 💀 **Enemy System (Skeletons)**

### **AI & Behavior:**

- **Patrol movement** with automatic direction reversal at boundaries
- **Platform-aware** - can walk on platforms and ground
- **4-frame walking animation** (60×140 pixels scaled to 24×32)
- **Speed range:** 25-55 units/sec (varies by enemy)

### **Health System:**

- **Variable health:** 1-4 HP depending on level/enemy type
- **Health bars** displayed above enemy heads when damaged
- **Visual feedback:** Red background, green health bar, black border
- **Damage sources:** Bullets (1 damage), jump attacks (instant kill)

### **Stun Mechanics:**

- **Blue tint** when stunned
- **Movement disabled** during stun
- **2-second duration** from princess stun ability
- **Visual feedback** with color change

---

## 🏆 **Level System**

### **4 Progressive Levels:**

1. **World 1-1:** Tutorial with basic platforms and 2 enemies
2. **World 1-2:** More platforms, 4 enemies with varying health
3. **World 1-3:** Challenging jumps, precise platforming
4. **World 1-4:** Enemy gauntlet with multiple threats

### **Level Elements:**

- **Platforms:** Various sizes and heights for jumping challenges
- **Goal flags:** Green pole with yellow flag, level completion trigger
- **Dynamic level width:** 1100-1800 pixels depending on level
- **Enemy placement:** Strategic positioning for difficulty progression

### **Progression System:**

- **Automatic advancement** after 3 seconds or Space key
- **Level complete overlay** with instructions
- **Score bonus:** 1000 points per level completion
- **Princess position reset** between levels

---

## 💰 **Collectibles & Scoring**

### **Coins:**

- **Yellow circular sprites** (12×12 pixels)
- **Strategic placement** on platforms and around enemies
- **200 points** per coin collected
- **Disappear when collected**

### **Scoring System:**

- **Enemy defeat:** 100 points (jump) + 50 points (bullet hit)
- **Coin collection:** 200 points each
- **Level completion:** 1000 points bonus
- **Real-time score display** in UI

---

## 📱 **Mobile Support**

### **Touch Controls:**

- **Virtual D-pad** for left/right movement
- **Jump button** (large, right side)
- **Semi-transparent overlays** for visibility
- **Touch-to-start** and **touch-to-restart** functionality

### **Platform Detection:**

- **Automatic mobile detection** (Android/iOS)
- **Responsive UI** adjustments for mobile screens
- **Smaller default zoom** (1.5x) for mobile devices

---

## 📷 **Camera System**

### **Movement:**

- **Horizontal following** - smooth tracking of princess movement
- **Limited vertical range** - Y: 210-250 pixels only
- **Boundary constraints** - prevents camera from going outside level

### **Zoom Features:**

- **Default zoom:** 2.0x for desktop, 1.5x for mobile
- **Dynamic zoom control:** +/- keys (0.5x to 4.0x range)
- **Real-time zoom adjustment** during gameplay

### **Visual Feedback:**

- **Zoom level display** in UI
- **Camera Y position** shown with range info
- **Page Up/Down** for camera height adjustment

---

## 🎵 **Audio System**

### **Background Music:**

- **Looping background track** ("i am running out of time.mp3")
- **Volume control** and **mute toggle** (M key)
- **Configurable** music enabled/disabled state
- **Stream loading** for efficient memory usage

---

## ⚙️ **Technical Features**

### **Game States:**

- **"menu"** - Main menu with game info and controls
- **"playing"** - Active gameplay state
- **"lostlife"** - Life lost screen (press any key to continue)
- **"truegameover"** - All lives lost, final score, return to menu

### **Lives System:**

- **3 lives** per game session
- **Life loss triggers:** Enemy contact, falling off world
- **Life display** in UI with remaining count
- **Proper state transitions** between life loss and game over

### **Performance:**

- **FPS counter** in top-right corner
- **Efficient sprite scaling** and animation systems
- **Object pooling** for bullets (removed when off-screen)
- **Collision optimization** with early exit conditions

### **Input Handling:**

- **Keyboard support:** Full desktop controls
- **Touch support:** Mobile-optimized interface
- **Key remapping:** Multiple keys for same actions (WASD + arrows)
- **Cooldown systems** prevent input spam

---

## 🚀 **Deployment Options**

### **Desktop:**

- **Love2D executable** for Windows/Mac/Linux
- **Standalone .love file** for distribution

### **Mobile:**

- **Android APK** generation via Love2D Android tools
- **Touch-optimized controls** and UI
- **Platform-specific optimizations**

---

## 🎯 **Game Balance**

### **Difficulty Progression:**

- **Level 1:** 2 enemies (1-2 HP), basic platforming
- **Level 2:** 4 enemies (2-3 HP), more complex jumps
- **Level 3:** 5 enemies (1-4 HP), precision platforming
- **Level 4:** 7 enemies (3-4 HP), enemy gauntlet

### **Combat Balance:**

- **Bullet cooldown:** 0.3 seconds prevents spam
- **Stun cooldown:** 3 seconds encourages strategic use
- **Enemy health scaling** provides progression challenge
- **Multiple defeat methods** (jump vs shoot) for player choice

---

## 📊 **Technical Specifications**

### **Performance Targets:**

- **60 FPS** on modern hardware
- **Responsive controls** with minimal input lag
- **Smooth animations** at 0.15-0.2 seconds per frame
- **Efficient memory usage** with sprite scaling

### **Compatibility:**

- **Love2D 11.0+** framework
- **Windows/Mac/Linux** desktop support
- **Android mobile** support via Love2D Android
- **Scalable resolution** support

---

## 🔧 **Configuration Options**

### **Easily Adjustable:**

- **Game speed** via config.PLAYER.SPEED
- **Jump height** via config.PLAYER.JUMP_POWER
- **Gravity strength** via config.GRAVITY
- **Zoom levels** and camera bounds
- **Color schemes** via config.COLORS
- **Audio settings** (volume, enabled/disabled)

This comprehensive feature set creates a complete, polished 2D platformer experience with modern game development practices and cross-platform compatibility.
