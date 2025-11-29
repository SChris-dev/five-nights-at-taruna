# 🌙 Five Nights at Taruna

<p align="center">
  <strong>A complete Five Nights at Freddy's inspired horror game built with Godot 4</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Godot-4.x-blue?logo=godot-engine" alt="Godot 4">
  <img src="https://img.shields.io/badge/Status-Complete-green" alt="Status">
  <img src="https://img.shields.io/badge/Genre-Horror%20Survival-red" alt="Genre">
</p>

---

## 📖 About

**Five Nights at Taruna** is a horror survival game inspired by Five Nights at Freddy's. You play as a security guard working the night shift at Taruna, monitoring security cameras and managing power while defending against supernatural threats and anomalies.

Survive from 12 AM to 6 AM by tracking hostile entities through cameras, managing doors and lights, and fixing system disruptions before they lead to your demise.

---

## ✨ Features

### 🎮 Gameplay Mechanics
- **📹 13-Camera Security System** - Monitor multiple rooms with realistic camera controls
- **🚪 Interactive Door System** - Control left and right doors with power management
- **💡 Light System** - Check hallways for threats using security lights
- **⚡ Power Management** - Strategic resource management under time pressure
- **🔧 Anomaly Fix System** - Interactive mechanics to resolve system disruptions
- **📱 Tablet Interface** - Intuitive camera switching and monitoring

### 🤖 AI & Entities
- **6 Unique Threats** with distinct behavior patterns:
  - **(INST) Traffic Light Bot** - Persistent hallway stalker
  - **(TKJ) Patrol Bot** - Door-watching roamer
  - **(TKR) Samurai Fighter Bot** - Aggressive sprinter
  - **(TPM/LAS) Junk Bot** - Power-draining roamer
  - **(RPL) P.I.P.P.Y** - Camera system saboteur
  - **(TKJ) Power Bot** - Power drainer
- Advanced pathfinding through 13 interconnected rooms
- Dynamic difficulty scaling across 6 nights + Custom Night

### 🎨 Visual & Audio
- Custom office with equirectangular perspective shader
- Smooth camera scrolling system
- CRT wave shader effects for authentic security camera feel
- Full audio system with ambience, jumpscares, and SFX
- Jumpscare animations with configurable settings
- Phone call system with night-specific voicelines

### 🎯 Game Modes
- **Story Mode** - 6 progressively difficult nights
- **Custom Night** - Customize AI difficulty levels (0-20)
- **Night Selection** - Replay completed nights
- Full save/load system

---

## 🚀 Getting Started

### Prerequisites
- [Godot Engine 4.x](https://godotengine.org/download)

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/SChris-dev/five-nights-at-taruna.git
   ```
2. Open the project in Godot 4
3. Run the main scene: `Scenes/Menu/main_menu.tscn`

### Playing the Game
1. Launch from main menu
2. Select **New Game** or **Continue**
3. Choose your night from the Night Selection screen
4. Survive from 12 AM to 6 AM
5. Complete all 6 nights to unlock Custom Night

---

## 🎮 Controls

| Action | Control |
|--------|---------|
| **Open/Close Camera** | Left Mouse Button on tablet |
| **Switch Cameras** | Click camera buttons |
| **Toggle Doors** | Click door buttons |
| **Toggle Lights** | Click light buttons |
| **Pan Office View** | Move mouse to screen edges |
| **Fix Anomalies** | Click fix buttons when prompted |

---

## 📚 How to Play

### Basic Gameplay
- **Monitor Cameras** - Use the tablet to track anomaly movements across 13 rooms
- **Manage Power** - Keep an eye on your power usage - running out means game over
- **Close Doors** - Block threats at your office doorways when they get close
- **Use Lights** - Check hallways before opening doors to see if it's safe
- **Fix Anomalies** - Click fix buttons when systems malfunction
- **Survive Until 6 AM** - Make it through the night without getting caught!

---

## 🏗️ Project Structure

```
five-nights-at-taruna/
├── Scenes/
│   ├── Menu/           # Main menu, night select, game over
│   └── Nights/         # Main gameplay scene
├── Scripts/
│   ├── Global/         # Global state and data
│   ├── Menu/           # Menu systems
│   └── Nights/
│       ├── AI/         # Character AI behaviors
│       ├── Camera/     # Camera system
│       └── Office/     # Office mechanics
├── Graphics/
│   ├── CamRooms/       # Camera feed sprites
│   ├── Office/         # Office backgrounds
│   ├── Jumpscares/     # Jumpscare animations
│   └── Menu/           # Menu assets
├── SFX/
│   ├── Ambience/       # Background sounds
│   ├── Jumpscares/     # Jumpscare audio
│   └── Office/         # Door, light, and power sounds
└── Shaders/            # Visual effects
```

---

## 🛠️ Technology Stack

- **Engine:** Godot 4.x (GDScript)
- **Shaders:** Custom GLSL shaders for CRT and perspective effects
- **Audio:** Godot's AudioStreamPlayer system with custom AudioManager
- **State Management:** Global singleton pattern
- **Save System:** Godot's ConfigFile format

---

## 🎯 Game Mechanics

### Power System
- Starts at 100% each night
- Drains faster with doors closed and cameras open
- Running out of power triggers game over sequence
- Strategic management is key to survival

### AI Behavior
- Each entity has unique movement patterns
- AI level determines movement frequency (0-20 scale)
- Some entities interact with doors, cameras, or power
- Difficulty increases each night automatically

### Win Condition
- Survive until 6 AM (timer based)
- Successfully manage all threats
- Unlock next night upon completion

---

## 🤝 Contributing

This project is complete but open to improvements! Feel free to:
- Report bugs via Issues
- Submit pull requests for enhancements
- Add new features or AI behaviors
- Improve documentation

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

### Development
- Built with [Godot Engine](https://godotengine.org/)
- Based on the Cupcakes Framework by Oplexitie

### Inspiration
- Five Nights at Freddy's by Scott Cawthon
- Various FNAF fan games and communities

---

## 📞 Contact & Support

- **Discord:** [Join our server](https://discord.gg/CHgH8KJyqE)
- **Issues:** [GitHub Issues](https://github.com/SChris-dev/five-nights-at-taruna/issues)

---

<p align="center">
  <strong>⭐ If you enjoyed this project, please consider giving it a star! ⭐</strong>
</p>

<p align="center">
  Made with 💜 using Godot Engine
</p>
