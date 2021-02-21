import class Foundation.Bundle

extension Foundation.Bundle {
    public static var emulator: Bundle {
        return Bundle.module
    }
}
