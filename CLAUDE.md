# Chip8EmulatorPackage

Core CHIP-8 emulator library consumed by all platform frontends.

## Build & Test

```bash
swift build
swift test
```

89 tests in `OpExecutorTests` covering CPU opcodes.

## Architecture

- **Chip8Engine** drives the emulation loop. Native platforms use `Timer`; web uses external `tick()` calls.
- **Chip8EngineDelegate** protocol: consumers implement `render(screen:)` and `beep()`.
- **Chip8InputCode** enum: the 16 CHIP-8 keys. Consumers map platform input to these.
- **RomLoader** loads ROMs into 4K RAM with font data. `loadRam(from: [Byte])` is the cross-platform entry point.
- **OpExecutor** executes CHIP-8 opcodes against `ChipState`.

## Key Files

| File | Purpose |
|------|---------|
| `Sources/Chip8Emulator/Chip8Engine.swift` | Main engine with `start()`, `stop()`, `tick()`, delegate callbacks |
| `Sources/Chip8Emulator/OpExecutor.swift` | CPU instruction execution |
| `Sources/Chip8Emulator/ChipState.swift` | CPU registers, RAM, stack, timers, key state |
| `Sources/Chip8Emulator/RomLoader.swift` | ROM loading (platform-conditional + pure `[Byte]` variant) |
| `Tests/Chip8EmulatorTests/OpExecutorTests.swift` | All CPU opcode tests |

## Cross-Platform Notes

Platform-specific code is guarded with `#if canImport(...)`:
- `AVFoundation`: BeepPlayer
- `CoreGraphics`: PathFactory
- `AppKit || UIKit`: Bundle_Emulator, RomLoader (asset-based loading)
- `ObjectiveC`: Timer-based run loop in Chip8Engine

## Consumer Projects

Changes here affect all downstream projects. After merging:
1. Tag a new version (e.g. `0.0.15`)
2. Update version pin in each consumer's `project.pbxproj` (or `Package.swift`)
3. Build-test each consumer before pushing

| Project | Repo | Platform |
|---------|------|----------|
| chip-8-macos | `ryanggrey/chip-8-macos` | macOS |
| chip-8-tvOS | `ryanggrey/chip-8-tvOS` | tvOS |
| chip-8-watchOS | `ryanggrey/chip-8-watchOS` | watchOS |
| CHIP8AR | `ryanggrey/CHIP8AR` | iOS (AR) |
| chip-8-web | `ryanggrey/chip-8-web` | Web (WASM) |

## Workflow

- Branch protection on `main`: PR required, `build` CI check required, enforce admins
- CI: `.github/workflows/swift.yml` — runs `swift test` on macOS
- Always test downstream compatibility before merging breaking changes

### PR flow

1. Commit to a feature branch
2. Push and create PR
3. Set PR to auto-merge (`gh pr merge --auto --squash`)
4. CI must pass before merge completes
