# Fix Button Texture Guide

## Required Size: 128x64 pixels

## Button Types

### 1. RPL Disruptor Button (Camera Fix)
- **Purpose**: Fix the camera disruption caused by RPL
- **Text suggestion**: "FIX CAMERA", "RESET CAM", or an icon
- **Location**: Appears in Room 6 (RPL Room) when cameras are disrupted

### 2. TKJ Drainer Button (Power Drain Fix)
- **Purpose**: Stop the extra power drain from TKJ
- **Text suggestion**: "STOP DRAIN", "FIX POWER", or an icon
- **Location**: Appears in Room 7 (TKJ Room) when power is draining

## Texture Files Needed (per button)

1. **Normal state** (required):
   - `rpl_fix_button.png` (128x64)
   - `tkj_fix_button.png` (128x64)

2. **Hover state** (optional):
   - `rpl_fix_button_hover.png` (128x64)
   - `tkj_fix_button_hover.png` (128x64)

3. **Pressed state** (optional):
   - `rpl_fix_button_pressed.png` (128x64)
   - `tkj_fix_button_pressed.png` (128x64)

## How to Apply Textures

Once you create the textures:

1. Place them in `Graphics/HUD/` folder
2. Import them in Godot (should happen automatically)
3. Open the scene `Scenes/Nights/nights.tscn`
4. Select the `RPLFixButton` node
5. In the Inspector, find the exported variables:
   - Drag your texture to "Button Texture"
   - Optionally add hover and pressed textures
6. Repeat for `TKJFixButton`

## Design Tips

- Use high contrast colors (white/red/yellow text on dark background)
- Make it look like it belongs on a security camera feed
- Consider adding scanlines or static effects for a retro feel
- Keep text readable at small size
- Match the FNAF aesthetic

## Current Setup

✅ Both buttons now sized at 128x64
✅ Buttons randomize position each time they appear
✅ Texture support added to script
✅ Text will auto-hide when texture is applied
