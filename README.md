# Chip 8 Emulator Swift Package

A Chip-8 emulator Swift package. For use in macOS, iOS, watchOS and tvOS projects.

This package implements the core functionality of a Chip-8 emulator in Swift. It contains no platform UI elements and this is left to a consumer projects to implement.

## Design
The emulator package is designed to be driven by the consuming platform application. This means it is left to the consumer project to:
1. Decide how and when to call the `chip8.cycle()` method. 
2. Decide how to render the `pixels` to the platform's display.
3. Detect user inputs and map them to [chip-8 keys](https://en.wikipedia.org/wiki/CHIP-8#Input) (`Chip8KeyCode`), including key down and up events.

Not a lot of thought has went into this design which has so far been influenced purely by reducing duplication between the [chip-8-macOS](https://github.com/ryanggrey/chip-8-macos) and [chip-8-watchOS](https://github.com/ryanggrey/chip-8-watchOS) projects.

## Consumer Projects
- [chip-8-macOS](https://github.com/ryanggrey/chip-8-macos)
- [chip-8-watchOS](https://github.com/ryanggrey/chip-8-watchOS)

## References
I made heavy use of the following resources when working on this project:
- Checking runtime correctness:
  - https://colineberhardt.github.io/wasm-rust-chip8/web/
  - http://johnearnest.github.io/Octo/
- Specs:
  - https://en.wikipedia.org/wiki/CHIP-8
  - http://devernay.free.fr/hacks/chip8/C8TECH10.HTM
- Checking code/logic correctness:
  - http://emulator101.com
  - https://github.com/davecom/ChipLate
