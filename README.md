# Spotter Bullet Tracker

A lightweight bullet vapor trail mod for Arma 3. Spotters can see bullet condensation trails through binoculars, rangefinders, and spotting scopes.

Major overhaul and rewrite written by Viv. 
Inspired by [A3BulletTracker](https://github.com/Havoc-1/A3BulletTracker) by Xeph and Keystone.

## Requirements

- [CBA_A3](https://steamcommunity.com/sharedfiles/filedetails/?id=450814997)
- [ACE3](https://steamcommunity.com/sharedfiles/filedetails/?id=463939057)

## Features

- Live bullet vapor wake that drifts with wind.
- 3D impact marker with real-time target distance reading upon bullet impact.
- Works out of the box with binoculars, rangefinders, laser designators, and tripod spotting scopes (including ACE).
- Simple 1-to-1 sniper and spotter pairing via ACE interaction.
- Ambient light check so vapor trails do not glow in pitch black night unless you are on NVGs or thermals.
- Zero dedicated server performance hit. All code runs client-side between the shooter and spotter, and only renders when ADS through optics.
- Configurable active trace limit to keep performance smooth during rapid fire.

## Usage

1. Walk up to a friendly player, open ACE Interact (Windows key), and select "Become Spotter".
2. Look down your binoculars or spotting scope. When your shooter fires, you will see their bullet vapor trails and impact distance marker.
3. To unpair, open ACE Self-Interact (Ctrl + Windows key) and select "Stop Spotting".
4. Adjust trail color, opacity, lifetime, active trace limits, impact marker settings, and light thresholds in CBA Addon Options (`Esc -> Options -> Addon Options -> Spotter Bullet Tracker`).

## Documentation

For technical architecture, network protocol, and codebase maintenance, see [MAINTENANCE.md](MAINTENANCE.md).

## License

MIT
