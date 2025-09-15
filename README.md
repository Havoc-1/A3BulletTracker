# Bullet Tracing For Spotter 
Recursive bullet tracing for spotters when sniping

Built for Arma 3 and requires ACE and CBA_A3

## Description
With Arma's engine limitation in view distance and particle rendering at extended ranges and making it increasingly difficult to spot for snipers to determine impact. BTFS aims to address this by converting the BIS_fnc_traceBullets function as seen in the Virtual Arsenal  to be multiplayer compatible. In order to maintain balance and immersion while still being functional, **a spotter can only spot for 1 shooter**.







## Features

- **Bullet Tracking Trace Upon Impact**: Traced bullet trajectory upon bullet impact.
- **Impact Point Marking**: 3D Icon with indication of where bullets impact with distance
- **Spotter-Shooter Pairing**: System allows players to pair up as spotter and shooter
- **Customizable Visualization**:
  - Adjustable trace colors
  - Configurable text and icon sizes
  - Light level dependent visibility
  - NVG compatibility options
- **Vehicle Integration**: Support for custom binoculars / turrets (spotting scopes)
- **Performance Optimized**: Efficient tracking system with configurable maximum tracking distance and update intervals
- **CBA Settings Integration**: Full customization through CBA settings menu

## Dependencies
Required addons:
- CBA (Community Base Addons)
- ACE3 (Advanced Combat Environment 3)
## User Setup
1. Approach another player
2. Use the ACE interaction menu on them (default: Windows key)
3. Select "Become Spotter" to pair with that player
4. Use a compatible spotting device (see below)

## Mission Maker setup
## Compatible Equipment
- Default: ACE Spotting Scope
- Default Binoculars: ACE Vector, ACE Vector Day
- Additional binoculars and "turrets" can be added through CBA settings

### Settings
`Configure Addons` → `XK Bullet Tracing for Spotters`

Available settings include:
- Vehicle and item classnames
- Trace color customization
- Minimum light threshold
- Text and icon sizes
- NVG compatibility options
- Debug mode


## Script Version
A standalone version which allows you to use the mod WITHOUT the server or players subscribing to it.

## Support
For issues, questions, or suggestions:
- Open an issue on GitHub
- Visit our Steam Workshop page [link]

## Authors
- [@Paperboathat](https://github.com/Paperboathat)
- [@Havoc-1](https://github.com/Havoc-1)

## Acknowledgements
- prisoner._. fromArma 3 Script & Goodies to building the mod in HEMTT
- ACE3 Team - Framework
- CBA Team - Settings framework
## License
This project is licensed under the Arma Public License Share Alike (APL-SA) - see the [Bohemia Interactive Community License page](https://www.bohemia.net/community/licenses/arma-public-license-share-alike) for details.
