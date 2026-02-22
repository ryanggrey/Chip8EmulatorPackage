# Chip 8 Emulator Swift Package

A Chip-8 emulator Swift package. For use in macOS, iOS, watchOS and tvOS projects.

This package implements the core functionality of a Chip-8 emulator in Swift. It contains no platform UI elements and this is left to a consumer projects to implement.

## Design
The emulator package contains a `Chip8Engine` which drives the Chip-8 run loop. 

### Start the engine
`chip8Engine.start()`

### Stop the engine
`chip8Engine.stop()`

### Feed inputs into the engine
[chip-8 keys](https://en.wikipedia.org/wiki/CHIP-8#Input) (`Chip8InputCode`)
- `chip8Engine.handleKeyDown(key: key)`
- `chip8Engine.handleKeyUp(key: key)`

### Receive callbacks from the engine
The callbacks are handled through the delegate pattern. Set the delegate of the engine:

```
override func viewDidLoad() {
  super.viewDidLoad()
  chip8Engine.delegate = self
}
```

#### Rendering
The engine will call the delegate `render` method when the engine determines that a render of the pixels is necessary. 

This will only be called when the pixels have changed. The engine assumes that pixels have been rendered on a call to the delegate and will not re-call with the same pixels.

Implement the rendering method:

```
extension YourViewController: Chip8EngineDelegate {
  func render(screen: Chip8Screen) {
    // ...
  }
}
```

#### Beeping
The engine will call the delegate `beep` method when the engine determines that a sound effect needs to be played.

Implement the beep method using the provided `BeepPlayer` (or through a custom implementation):

```
extension YourViewController: Chip8EngineDelegate {
  func beep() {
    beepPlayer.play()
    // haptics etc.
  }
}
```

## Consumer Projects
- [chip-8-macOS](https://github.com/ryanggrey/chip-8-macos)
- [chip-8-watchOS](https://github.com/ryanggrey/chip-8-watchOS)
- [chip-8-tvOS](https://github.com/ryanggrey/chip-8-tvOS)
- [CHIP8AR](https://github.com/ryanggrey/CHIP8AR) (iOS, AR)
- [chip-8-web](https://github.com/ryanggrey/chip-8-web) (Web, SwiftWasm)

## Assets
### ROMs
The ROMs bundled into this project are from https://github.com/dmatlack/chip8

### Sounds
`beep.wav` file in Assets is from [Mixkit](https://mixkit.co), originally titled `mixkit-player-jumping-in-a-video-game-2043.wav`. See here for Mixkit [license](https://mixkit.co/license/#sfxFree).

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
