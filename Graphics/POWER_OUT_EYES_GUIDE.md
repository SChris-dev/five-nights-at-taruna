# Power Out Eyes Guide

## The Issue
The eyes weren't appearing during power out because no texture was assigned to the eye sprite.

## The Fix
✅ Added `eye_texture` export variable
✅ Script now warns if no texture is assigned
✅ Created a fallback (two yellow circles) if texture is missing

## What You Need to Do

### Option 1: Create Custom Eye Texture (Recommended)

1. **Create the texture** (128x64 pixels recommended):
   - Two glowing eyes (circles or more detailed)
   - Yellow/orange color works best for FNAF feel
   - Transparent background (PNG format)
   - Make them glow/ominous looking

2. **Save it** as `freddy_eyes.png` in `Graphics/` folder

3. **Assign in Godot**:
   - Open `Scenes/Nights/nights.tscn`
   - Select the `PowerOutSequence` node
   - In Inspector, find "Visual Settings" → "Eye Texture"
   - Drag your `freddy_eyes.png` file to the "Eye Texture" field

### Option 2: Use Fallback (Already Works)

If you don't assign a texture, the script will automatically create simple yellow circles as eyes.
- This works immediately but looks basic
- Good for testing, but custom texture looks better

## Customization Options

In the PowerOutSequence node Inspector, you can adjust:

- **Eye Texture**: Your custom eye image
- **Eye Glow Color**: Color tint (default: yellow/orange)
- **Eye Position**: Position relative to office sprite (default: 1500, 600)
  - Office is 3000x1500 pixels
  - (1500, 600) is center-left area (left door)
  - (1200, 600) is more to the left
  - (1800, 600) is more to the right
- **Eye Scale**: Size multiplier (default: 1.0, try 3.0 for bigger)
- **Show Eyes**: Toggle eyes on/off
- **Attach Eyes To Office**: If true, eyes move with office scrolling (default: true)

## Recommended Eye Design

For authentic FNAF look:
- **Size**: 128x64 pixels (or larger, powers of 2 work best)
- **Style**: Two circular eyes with glow effect
- **Color**: Bright yellow or orange with darker center
- **Spacing**: Eyes should be apart (like staring at you)
- **Background**: Transparent (PNG with alpha)
- **Effect**: Add slight blur or glow in image editor

## Example Specifications

**Simple Version:**
- Two circles, 20-30 pixels diameter each
- Bright yellow (#FFDD00)
- Slight glow/blur around edges
- Black or transparent background

**Detailed Version:**
- Eyes with pupils
- Reflections/highlights
- Subtle animation frames (optional)
- More menacing appearance

## Technical Notes

- The sprite is automatically scaled using `eye_scale` export
- Default scale is 1.0, but scene has it set to 3.0
- Eyes appear at z_index 101 (above darkness overlay)
- Color can be tinted via `eye_glow_color`
- **Eyes are attached to the Office sprite** so they move with scrolling/panorama
- Position is relative to the office (3000x1500), not the screen
- The office sprite scrolls left/right, and eyes move with it

## Eye Positioning Guide

The office sprite is 3000x1500 pixels. Common positions:

- **Left door area**: (1200, 600) - Eyes at left doorway
- **Center**: (1500, 750) - Middle of office
- **Right door area**: (1800, 600) - Eyes at right doorway

Adjust Y value to move eyes up/down:
- Higher Y = lower on screen
- Lower Y = higher on screen

## Testing

1. Run the game
2. Let the power run out
3. Eyes should appear in the darkness
4. Check console for: `[PowerOutSequence] Eye texture assigned: [path]`
   - Or: `[PowerOutSequence] Fallback eyes created` if using fallback

## Current Status

✅ Fallback eyes work automatically
📝 Custom texture needs to be created and assigned
🎨 Recommended: Create custom eye texture for better visual

## Quick Start (5 Minutes)

1. Open any image editor (GIMP, Photoshop, Paint.NET)
2. Create 128x64 canvas with transparent background
3. Draw two yellow/orange circles
4. Add glow/blur effect
5. Export as PNG
6. Drag into Godot's `Graphics/` folder
7. Assign to PowerOutSequence → Eye Texture
8. Done!
