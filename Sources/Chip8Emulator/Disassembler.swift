//
//  Disassembler.swift
//  CHIP-8
//
//  Created by Ryan Grey on 23/01/2021.
//

import Foundation

public struct Disassembler {
    public func disassemble(codeBuffer: [Byte]) {
        let pcStart = 0x200
        var pc = pcStart
        let lastOpIndex = (codeBuffer.count - 1)
        while pc < lastOpIndex {
            let byte1 = codeBuffer[pc]
            let byte2 = codeBuffer[pc+1]
            let op = Word(bytes: [byte1, byte2])
            disassemble(pc: pc, op: op)
            pc += 2
        }
    }

    // TODO: update to match http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#3.0
    public func disassemble(pc: Int, op: Word) {
        let addressAndCodeStr = getAddressAndCodeStr(pc, op.byte1, op.byte2)
        var mnemonicStr = getMnemonicStr("NOOP")
        var opStr = getOpStr("")

        switch (op.nibble1, op.nibble2, op.nibble3, op.nibble4)
        {
        case (0x00, 0x00, 0x0e, 0x00):
            // 00E0, Display, Clears the screen.
            mnemonicStr = getMnemonicStr("CLS")
            opStr = getOpStr("")
        case (0x00, 0x00, 0x0e, 0x0e):
            // 00EE, Flow, Returns from a subroutine.
            mnemonicStr = getMnemonicStr("RTS")
            opStr = getOpStr("")
        case (0x00, let n1, let n2, let n3):
            // 0NNN, Call, Calls machine code routine (RCA 1802 for COSMAC VIP) at address NNN. Not necessary for most ROMs.
            mnemonicStr = getMnemonicStr("CALL")
            let nibbles = getAddressNibblesStr([n1, n2, n3])
            opStr = getOpStr(nibbles)
        case (0x01, let n1, let n2, let n3):
            // 1NNN, Flow, Jumps to address NNN.
            mnemonicStr = getMnemonicStr("JUMP")
            let nibbles = getAddressNibblesStr([n1, n2, n3])
            opStr = getOpStr(nibbles)
        case (0x02, let n1, let n2, let n3):
            // 2NNN, Flow, Calls subroutine at NNN.
            mnemonicStr = getMnemonicStr("CALL")
            let nibbles = getAddressNibblesStr([n1, n2, n3])
            opStr = getOpStr(nibbles)

        case (0x03, let x, let n1, let n2):
            // 3XNN, Cond, Skips the next instruction if VX equals NN. (Usually the next instruction is a jump to skip a code block)
            mnemonicStr = getMnemonicStr("SKIP.EQ")
            let nibbles = getValueNibblesStr([n1, n2])
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr), \(nibbles)")

        case (0x04, let x, let n1, let n2):
            // 4XNN, Cond, Skips the next instruction if VX doesn't equal NN. (Usually the next instruction is a jump to skip a code block)
            mnemonicStr = getMnemonicStr("SKIP.NE")
            let nibbles = getValueNibblesStr([n1, n2])
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr), \(nibbles)")

        case (0x05, let x, let y, 0x00):
            // 5XY0, Cond, Skips the next instruction if VX equals VY. (Usually the next instruction is a jump to skip a code block)
            mnemonicStr = getMnemonicStr("SKIP.EQ")
            let xStr = getRegisterStr(x)
            let yStr = getRegisterStr(y)
            opStr = getOpStr("V\(xStr), V\(yStr)")

        case (0x06, let x, let n1, let n2):
            // 6XNN, Const, Sets VX to NN.
            mnemonicStr = getMnemonicStr("MVI")
            let nibbles = getValueNibblesStr([n1, n2])
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr), \(nibbles)")

        case (0x07, let x, let n1, let n2):
            // 7XNN, Const, Adds NN to VX. (Carry flag is not changed)
            mnemonicStr = getMnemonicStr("ADD")
            let nibbles = getValueNibblesStr([n1, n2])
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr), \(nibbles)")

        case (0x08, let x, let y, 0x00):
            // 8XY0, Assign, Sets VX to the value of VY.
            mnemonicStr = getMnemonicStr("MOV")
            let xStr = getRegisterStr(x)
            let yStr = getRegisterStr(y)
            opStr = getOpStr("V\(xStr), V\(yStr)")
        case (0x08, let x, let y, 0x01):
            // 8XY1, BitOp, Sets VX to VX or VY. (Bitwise OR operation)
            mnemonicStr = getMnemonicStr("OR")
            let xStr = getRegisterStr(x)
            let yStr = getRegisterStr(y)
            opStr = getOpStr("V\(xStr), V\(yStr)")
        case (0x08, let x, let y, 0x02):
            // 8XY2, BitOp, Sets VX to VX and VY. (Bitwise AND operation)
            mnemonicStr = getMnemonicStr("AND")
            let xStr = getRegisterStr(x)
            let yStr = getRegisterStr(y)
            opStr = getOpStr("V\(xStr), V\(yStr)")
        case (0x08, let x, let y, 0x03):
            // 8XY3, BitOp, Sets VX to VX xor VY.
            mnemonicStr = getMnemonicStr("XOR")
            let xStr = getRegisterStr(x)
            let yStr = getRegisterStr(y)
            opStr = getOpStr("V\(xStr), V\(yStr)")
        case (0x08, let x, let y, 0x04):
            // 8XY4, Math, Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
            mnemonicStr = getMnemonicStr("ADD.")
            let xStr = getRegisterStr(x)
            let yStr = getRegisterStr(y)
            opStr = getOpStr("V\(xStr), V\(yStr)")
        case (0x08, let x, let y, 0x05):
            // 8XY5, Math, VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
            mnemonicStr = getMnemonicStr("SUB.")
            let xStr = getRegisterStr(x)
            let yStr = getRegisterStr(y)
            opStr = getOpStr("V\(xStr), V\(yStr)")
        case (0x08, let x, _, 0x06):
            // 8XY6, BitOp, Stores the least significant bit of VX in VF and then shifts VX to the right by 1.
            mnemonicStr = getMnemonicStr("SHR.")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr)")
        case (0x08, let x, let y, 0x07):
            // 8XY7, Math, Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
            mnemonicStr = getMnemonicStr("SUBB.")
            let xStr = getRegisterStr(x)
            let yStr = getRegisterStr(y)
            opStr = getOpStr("V\(xStr), V\(yStr)")
        case (0x08, let x, _, 0x0e):
            // 8XYE, BitOp, Stores the most significant bit of VX in VF and then shifts VX to the left by 1.
            mnemonicStr = getMnemonicStr("SHL.")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr)")

        case (0x09, let x, let y, 0x00):
            // 9XY0, Cond, Skips the next instruction if VX doesn't equal VY. (Usually the next instruction is a jump to skip a code block)
            mnemonicStr = getMnemonicStr("SKIP.NE")
            let xStr = getRegisterStr(x)
            let yStr = getRegisterStr(y)
            opStr = getOpStr("V\(xStr), V\(yStr)")

        case (0x0a, let n1, let n2, let n3):
            // ANNN, MEM, Sets I to the address NNN.
            mnemonicStr = getMnemonicStr("MVI")
            let nibbles = getValueNibblesStr([n1, n2, n3])
            opStr = getOpStr("I, \(nibbles)")

        case (0x0b, let n1, let n2, let n3):
            // BNNN, Flow, Jumps to the address NNN plus V0.
            mnemonicStr = getMnemonicStr("JUMP")
            let nibbles = getAddressNibblesStr([n1, n2, n3])
            opStr = getOpStr("\(nibbles)(V0)")

        case (0x0c, let x, let n1, let n2):
            // CXNN, Rand, Sets VX to the result of a bitwise AND operation on a random number (Typically: 0 to 255) and NN.
            mnemonicStr = getMnemonicStr("RAND")
            let nibbles = getValueNibblesStr([n1, n2])
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr), \(nibbles)")

        case (0x0d, let x, let y, let n):
            // DXYN, Disp, Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N+1 pixels. Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesn’t change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn’t happen
            mnemonicStr = getMnemonicStr("SPRITE")
            let nibbles = getValueNibblesStr([n])
            let xStr = getRegisterStr(x)
            let yStr = getRegisterStr(y)
            opStr = getOpStr("V\(xStr), V\(yStr), \(nibbles)")

        case (0x0e, let x, 0x09, 0x0e):
            // EX9E, KeyOp, Skips the next instruction if the key stored in VX is pressed. (Usually the next instruction is a jump to skip a code block)
            mnemonicStr = getMnemonicStr("SKIP.KEY")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr)")
        case (0x0e, let x, 0x0a, 0x01):
            // EXA1, KeyOp, Skips the next instruction if the key stored in VX isn't pressed. (Usually the next instruction is a jump to skip a code block)
            mnemonicStr = getMnemonicStr("SKIP.NOKEY")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr)")

        case (0x0f, let x, 0x00, 0x07):
            // FX07, Timer, Sets VX to the value of the delay timer.
            mnemonicStr = getMnemonicStr("MOV")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr), DELAY")
        case (0x0f, let x, 0x00, 0x0a):
            // FX0A, KeyOp, A key press is awaited, and then stored in VX. (Blocking Operation. All instruction halted until next key event)
            mnemonicStr = getMnemonicStr("WAITKEY")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V\(xStr)")
        case (0x0f, let x, 0x01, 0x05):
            // FX15, Timer, Sets the delay timer to VX.
            mnemonicStr = getMnemonicStr("MOV")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("DELAY, V\(xStr)")
        case (0x0f, let x, 0x01, 0x08):
            // FX18, Sound, Sets the sound timer to VX.
            mnemonicStr = getMnemonicStr("MOV")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("SOUND, V\(xStr)")
        case (0x0f, let x, 0x01, 0x0e):
            // FX1E, MEM, Adds VX to I. VF is not affected.
            mnemonicStr = getMnemonicStr("ADD")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("I, V\(xStr)")
        case (0x0f, let x, 0x02, 0x09):
            // FX29, MEM, Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
            mnemonicStr = getMnemonicStr("SPRITECHAR")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("I, V\(xStr)")
        case (0x0f, let x, 0x03, 0x03):
            // FX33, BCD, Stores the binary-coded decimal representation of VX, with the most significant of three digits at the address in I, the middle digit at I plus 1, and the least significant digit at I plus 2. (In other words, take the decimal representation of VX, place the hundreds digit in memory at location in I, the tens digit at location I+1, and the ones digit at location I+2.)
            mnemonicStr = getMnemonicStr("MOVBCD")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("I+0:I+1:I+2, V\(xStr)")
        case (0x0f, let x, 0x05, 0x05):
            // FX55, MEM, Stores V0 to VX (including VX) in memory starting at address I. The offset from I is increased by 1 for each value written, but I itself is left unmodified
            mnemonicStr = getMnemonicStr("MOVM")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("(I), V0-V\(xStr)")
        case (0x0f, let x, 0x06, 0x05):
            // FX65, MEM, Fills V0 to VX (including VX) with values from memory starting at address I. The offset from I is increased by 1 for each value written, but I itself is left unmodified.
            mnemonicStr = getMnemonicStr("MOVM")
            let xStr = getRegisterStr(x)
            opStr = getOpStr("V0-V\(xStr), (I)")
        default:
            mnemonicStr = getMnemonicStr("UNK")
            opStr = getOpStr("")
        }

        let dissassembly = "\(addressAndCodeStr) \(mnemonicStr) \(opStr)"
        print(dissassembly)
    }

    private func getAddressAndCodeStr(_ pc: Int, _ byte1: Byte, _ byte2: Byte) -> String {
        let address = getHexStr(width: 4, pc)
        let byte1Str = getHexStr(width: 2, byte1)
        let byte2Str = getHexStr(width: 2, byte2)
        let addressAndOpStr = "\(address) \(byte1Str) \(byte2Str)"
        return addressAndOpStr
    }

    private func getHexStr<I: BinaryInteger & CVarArg>(width: Int, _ value: I) -> String {
        let valueStr = String(format:"%02X", value as CVarArg)
        let paddedStr = valueStr.padding(toLength: width, withPad: " ", startingAt: 0)
        return paddedStr
    }

    private func getRegisterStr<I: BinaryInteger & CVarArg>(_ value: I) -> String {
        let valueStr = String(format:"%01X", value as CVarArg)
        let paddedStr = valueStr.padding(toLength: 1, withPad: " ", startingAt: 0)
        return paddedStr
    }

    private func getNibblesStr(_ values: [Byte]) -> String {
        let word = Word(nibbles: values)
        let nibblesStr = getHexStr(width: values.count, word)
        return nibblesStr
    }

    private func getAddressNibblesStr(_ nibbles: [Byte]) -> String {
        let nibblesStr = getNibblesStr(nibbles)
        let notatedNibblesStr = "$\(nibblesStr)"
        return notatedNibblesStr
    }

    private func getValueNibblesStr(_ nibbles: [Byte]) -> String {
        let nibblesStr = getNibblesStr(nibbles)
        let notatedNibblesStr = "#$\(nibblesStr)"
        return notatedNibblesStr
    }

    private func getMnemonicStr(_ value: String) -> String {
        let paddedStr = value.padding(toLength: 10, withPad: " ", startingAt: 0)
        return paddedStr
    }

    private func getOpStr(_ value: String) -> String {
        return value
    }
}
