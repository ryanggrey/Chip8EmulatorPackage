//
//  CHIP_8Tests.swift
//  CHIP-8Tests
//
//  Created by Ryan Grey on 22/01/2021.
//

import XCTest
@testable import Chip8Emulator

class OpExecutorTests: XCTestCase {
    let registerSize = 0x0f + 0x01
    var opExecutor = OpExecutor(cpuHz: 1/600)

    func test_CLS_0x00_clears_pixels() {
        var state = ChipState()

        let dirtyPixels = [Byte](repeating: 1, count: state.screen.size.area)

        state.screen.pixels = dirtyPixels
        XCTAssertEqual(state.screen.pixels, dirtyPixels)

        let op = Word(nibbles: [0x00, 0x00, 0x0e, 0x00])
        let newState = try! opExecutor.handle(state: state, op: op)

        let observedPixels = newState.screen.pixels
        let expectedPixels = [Byte](repeating: 0, count: state.screen.size.area)
        XCTAssertEqual(observedPixels, expectedPixels)
    }

    func test_CLS_0x00_increments_pc() {
        let op = Word(nibbles: [0x00, 0x00, 0x0e, 0x00])
        assertPcIncremented(op: op)
    }

    func test_RTS_0x00_sets_pc_to_last_stack_address_plus_two() {
        let lastPc: Word = 0x02
        let expectedPc: Word = lastPc + 2
        let stack = [lastPc]

        var state = ChipState()
        state.stack = stack

        let op = Word(nibbles: [0x00, 0x00, 0x0e, 0x0e])
        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_RTS_0x00_removes_last_stack_address() {
        let stack: [Word] = [0x03, 0x04]

        var state = ChipState()
        state.stack = stack

        let op = Word(nibbles: [0x00, 0x00, 0x0e, 0x0e])
        let newState = try! opExecutor.handle(state: state, op: op)

        let observedStack = newState.stack
        let expectedStack = [stack[0]]
        XCTAssertEqual(observedStack, expectedStack)
    }

    func test_CALL_0x00_sets_pc_to_NNN() {
        let n1: Byte = 0x02, n2: Byte = 0x0e, n3: Byte = 0x04
        let op = Word(nibbles: [0x00, n1, n2, n3])
        let state = ChipState()
        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = createPcFrom(n1, n2, n3)
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_JUMP_0x01_sets_pc_to_NNN() {
        let n1: Byte = 0x01, n2: Byte = 0x0e, n3: Byte = 0x03
        let op = Word(nibbles: [0x01, n1, n2, n3])
        let state = ChipState()
        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = createPcFrom(n1, n2, n3)
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_CALL_0x02_adds_current_pc_to_stack() {
        let n1: Byte = 0x02, n2: Byte = 0x0a, n3: Byte = 0x0b
        let op = Word(nibbles: [0x02, n1, n2, n3])
        let initialPc: Word = 0x2b1
        var state = ChipState()
        state.pc = initialPc
        XCTAssertTrue(state.stack.isEmpty)

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedStack = newState.stack
        let expectedStack = [initialPc]
        XCTAssertEqual(observedStack, expectedStack)
    }

    func test_CALL_0x02_sets_pc_to_NNN() {
        let n1: Byte = 0x0b, n2: Byte = 0x0c, n3: Byte = 0x0d
        let op = Word(nibbles: [0x02, n1, n2, n3])

        let newState = try! opExecutor.handle(state: ChipState(), op: op)
        let observedPc = newState.pc
        let expectedPc = createPcFrom(n1, n2, n3)
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_SKIP_EQ_0x03_skips_next_instruction_if_Vx_equal_to_NN() {
        let x: Byte = 2, n1: Byte = 0x0c, n2: Byte = 0x0f
        let op = Word(nibbles: [0x03, x, n1, n2])

        var v = [Byte](repeating: 0, count: 3)
        v[x] = Byte(nibbles: [n1, n2])
        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = state.pc + 4
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_SKIP_EQ_0x03_moves_to_next_instruction_if_Vx_NOT_equal_to_NN() {
        let x: Byte = 2, n1: Byte = 0x0c, n2: Byte = 0x01
        let op = Word(nibbles: [0x03, x, n1, n2])
        var v = [Byte](repeating: 0, count: 3)
        v[x] = Byte(nibbles: [n1, n1])

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = state.pc + 2
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_SKIP_NE_0x04_skips_next_instruction_if_Vx_NOT_equal_to_NN() {
        let x: Byte = 2, n1: Byte = 0x09, n2: Byte = 0x0c
        let op = Word(nibbles: [0x04, x, n1, n2])
        var v = [Byte](repeating: 0, count: 3)
        v[x] = Byte(nibbles: [n1, n1])

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = state.pc + 4
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_SKIP_NE_0x04_moves_to_next_instruction_if_Vx_equal_to_NN() {
        let x: Byte = 2, n1: Byte = 0x05, n2: Byte = 0x0d
        let op = Word(nibbles: [0x04, x, n1, n2])
        var v = [Byte](repeating: 0, count: 3)
        v[x] = Byte(nibbles: [n1, n2])

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = state.pc + 2
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_SKIP_EQ_0x05_skips_next_instruction_if_Vx_equal_to_Vy() {
        let x: Byte = 2, y: Byte = 13
        let op = Word(nibbles: [0x05, x, y, 0x00])
        var v = [Byte](repeating: 0, count: 14)
        v[x] = 0x4e
        v[y] = v[x]

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = state.pc + 4
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_SKIP_EQ_0x05_moves_to_next_instruction_if_Vx_NOT_equal_to_Vy() {
        let x: Byte = 2, y: Byte = 13
        let op = Word(nibbles: [0x05, x, y, 0x00])
        var v = [Byte](repeating: 0, count: 14)
        v[x] = 0x4e
        v[y] = 0x5b

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = state.pc + 2
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_MVI_0x06_sets_Vx_to_NN() {
        let x: Byte = 11, n1: Byte = 0x03, n2: Byte = 0x03
        let op = Word(nibbles: [0x06, x, n1, n2])
        var v = [Byte](repeating: 0, count: 12)
        let expectedVx = Byte(nibbles: [n1, n2])
        v[x] = expectedVx

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_MVI_0x06_moves_to_next_instruction() {
        let x: Byte = 11, n1: Byte = 0x03, n2: Byte = 0x03
        let op = Word(nibbles: [0x06, x, n1, n2])
        var v = [Byte](repeating: 0, count: 12)
        v[x] = Byte(nibbles: [n1, n2])

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = state.pc + 2
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_ADD_0x07_adds_NN_to_Vx() {
        let x: Byte = 5, n1: Byte = 0x0c, n2: Byte = 0x0c
        let op = Word(nibbles: [0x07, x, n1, n2])
        var v = [Byte](repeating: 0, count: 6)
        v[x] = 0x07

        var state = ChipState()
        state.v = v

        let expectedVx = v[x] + Byte(nibbles: [n1, n2])

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_ADD_0x07_adds_NN_to_Vx_with_overflow() {
        let x: Byte = 5, n1: Byte = 0x00, n2: Byte = 0x01
        let op = Word(nibbles: [0x07, x, n1, n2])
        var v = [Byte](repeating: 0, count: 6)
        v[x] = Byte.max
        let expectedVx = v[x] &+ Byte(nibbles: [n1, n2])

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_ADD_0x07_does_NOT_change_flag() {
        let x: Byte = 0x0e, n1: Byte = 0x0b, n2: Byte = 0x01, f = 0x0f
        let op = Word(nibbles: [0x07, x, n1, n2])
        var v = [Byte](repeating: 0, count: 0x0f + 0x01)
        let expectedCarryFlag: Byte = 0x06
        v[f] = expectedCarryFlag

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        // v[f] is carry flag
        let observedCarryFlag = newState.v[0x0f]
        XCTAssertEqual(observedCarryFlag, expectedCarryFlag)
    }

    func test_ADD_0x07_increments_pc() {
        let x: Byte = 0x0e, n1: Byte = 0x0b, n2: Byte = 0x01
        let op = Word(nibbles: [0x07, x, n1, n2])
        assertPcIncremented(op: op)
    }

    func test_MOV_0x08_sets_Vx_to_Vy() {
        let x: Byte = 0x0e, y: Byte = 0x0b
        let op = Word(nibbles: [0x08, x, y, 0x00])
        let initialVy: Byte = 0x06
        var v = createEmptyRegisters()
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        let expectedVx = initialVy
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_MOV_0x08_increments_pc() {
        let x: Byte = 0x0a, y: Byte = 0x07
        let op = Word(nibbles: [0x08, x, y, 0x00])
        assertPcIncremented(op: op)
    }

    func test_OR_0x08_sets_Vx_to_Vy_bitwise_or_Vx() {
        let x: Byte = 2, y: Byte = 3
        let op = Word(nibbles: [0x08, x, y, 0x01])
        let initialVx: Byte = 0b1101
        let initialVy: Byte = 0b0110
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        // 0b1101 | 0b0110 = 0b1111
        let expectedVx: Byte = 0b1111
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_OR_0x08_increments_pc() {
        let x: Byte = 3, y: Byte = 7
        let op = Word(nibbles: [0x08, x, y, 0x01])
        assertPcIncremented(op: op)
    }

    func test_AND_0x08_sets_Vx_to_Vy_bitwise_and_Vx() {
        let x: Byte = 3, y: Byte = 14
        let op = Word(nibbles: [0x08, x, y, 0x02])
        let initialVx: Byte = 0b1100
        let initialVy: Byte = 0b1010
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        // 0b1100 & 0b1010 = 0b1000 = 8
        let expectedVx: Byte = 8
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_AND_0x08_increments_pc() {
        let x: Byte = 3, y: Byte = 7
        let op = Word(nibbles: [0x08, x, y, 0x02])
        assertPcIncremented(op: op)
    }

    func test_XOR_0x08_sets_Vx_to_Vy_bitwise_xor_Vx() {
        let x: Byte = 7, y: Byte = 13
        let op = Word(nibbles: [0x08, x, y, 0x03])
        let initialVx: Byte = 0b1100
        let initialVy: Byte = 0b1010
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        // 0b1100 ^ 0b1010 = 0b0110 = 6
        let expectedVx: Byte = 6
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_XOR_0x08_increments_pc() {
        let x: Byte = 3, y: Byte = 7
        let op = Word(nibbles: [0x08, x, y, 0x03])
        assertPcIncremented(op: op)
    }

    func test_ADD_dot_0x08_adds_Vy_to_Vx_and_sets_flag() {
        let x: Byte = 0, y: Byte = 1
        let op = Word(nibbles: [0x08, x, y, 0x04])
        let initialVx: Byte = 0b11111111
        let initialVy: Byte = 0b00000001
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        // 0b11111111 + 0b00000001 = 0b00000000 = 0 with overflow
        let expectedVx: Byte = 0b00000000
        XCTAssertEqual(observedVx, expectedVx)

        let expectedVf: Byte = 1
        let observedVf = newState.v[0x0f]
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_ADD_dot_0x08_adds_Vy_to_Vx_and_does_not_set_flag() {
        let x: Byte = 0, y: Byte = 1
        let op = Word(nibbles: [0x08, x, y, 0x04])
        let initialVx: Byte = 0b11111110
        let initialVy: Byte = 0b00000001
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)

        let observedVx = newState.v[x]
        // 0b11111110 + 0b00000001 = 0b11111111 = 255 with no overflow
        let expectedVx: Byte = 0b11111111
        XCTAssertEqual(observedVx, expectedVx)

        let expectedVf: Byte = 0
        let observedVf = newState.v[0x0f]
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_ADD_dot_0x08_increments_pc() {
        let x: Byte = 3, y: Byte = 7
        let op = Word(nibbles: [0x08, x, y, 0x04])
        assertPcIncremented(op: op)
    }

    func test_SUB_dot_0x08_sbtracts_Vy_from_Vx_and_does_not_set_flag() {
        let x: Byte = 0, y: Byte = 1
        let op = Word(nibbles: [0x08, x, y, 0x05])
        let initialVx: Byte = 0b00000000
        let initialVy: Byte = 0b00000001
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        // 0b00000000 - 0b00000001 = 0b11111111 = 255 with borrow
        let expectedVx: Byte = 0b11111111
        XCTAssertEqual(observedVx, expectedVx)

        let expectedVf: Byte = 0
        let observedVf = newState.v[0x0f]
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_SUB_dot_0x08_sbtracts_Vy_from_Vx_and_does_set_flag() {
        let x: Byte = 0, y: Byte = 1
        let op = Word(nibbles: [0x08, x, y, 0x05])
        let initialVx: Byte = 0b00000001
        let initialVy: Byte = 0b00000001
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)

        let observedVx = newState.v[x]
        // 0b00000001 - 0b00000001 = 0b00000000 = 0 without borrow
        let expectedVx: Byte = 0b00000000
        XCTAssertEqual(observedVx, expectedVx)

        let expectedVf: Byte = 1
        let observedVf = newState.v[0x0f]
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_SUB_dot_0x08_increments_pc() {
        let x: Byte = 3, y: Byte = 7
        let op = Word(nibbles: [0x08, x, y, 0x05])
        assertPcIncremented(op: op)
    }

    func test_SHR_dot_0x08_stores_the_lsb_of_Vx_in_Vf_when_lsb_is_1() {
        let x: Byte = 0x0c
        let f: Byte = 0x0f
        let op = Word(nibbles: [0x08, x, 0x00, 0x06])
        let initialVx: Byte = 0b10100101
        let initialVf: Byte = 0b00000000
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[f] = initialVf

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVf = newState.v[f]
        // lsb of 0b10110101 is 0b00000001
        let expectedVf: Byte = 0b00000001
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_SHR_dot_0x08_stores_the_lsb_of_Vx_in_Vf_when_lsb_is_0() {
        let x: Byte = 0x0c
        let f: Byte = 0x0f
        let op = Word(nibbles: [0x08, x, 0x00, 0x06])
        let initialVx: Byte = 0b11110100
        let initialVf: Byte = 0b00000001
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[f] = initialVf

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVf = newState.v[f]
        // lsb of 0b10110101 is 0b00000000
        let expectedVf: Byte = 0b00000000
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_SHR_dot_0x08_shifts_Vx_right_by_1() {
        let x: Byte = 0x0c
        let op = Word(nibbles: [0x08, x, 0x00, 0x06])
        let initialVx: Byte = 0b10100101
        var v = createEmptyRegisters()
        v[x] = initialVx

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        // 0b10100101 shifted right by 1 = 0b01010010
        let expectedVx: Byte = 0b01010010
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_SHR_dot_0x08_increments_pc() {
        let x: Byte = 0, y: Byte = 15
        let op = Word(nibbles: [0x08, x, y, 0x06])
        assertPcIncremented(op: op)
    }

    func test_SUBB_dot_0x08_sets_Vx_to_Vy_minus_Vx_and_does_set_flag() {
        // Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.

        let x: Byte = 0, y: Byte = 1
        let op = Word(nibbles: [0x08, x, y, 0x07])
        let initialVx: Byte = 0b00000010
        let initialVy: Byte = 0b00000011
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        // 0b00000011 - 0b00000010 = 0b00000001 with NO borrow
        let expectedVx: Byte = 0b00000001
        XCTAssertEqual(observedVx, expectedVx)

        let expectedVf: Byte = 1
        let observedVf = newState.v[0x0f]
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_SUBB_dot_0x08_sets_Vx_to_Vy_minus_Vx_and_does_NOT_set_flag() {
        let x: Byte = 4, y: Byte = 5
        let op = Word(nibbles: [0x08, x, y, 0x07])
        let initialVx: Byte = 0b00000110
        let initialVy: Byte = 0b00000011
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        // 0b00000011 - 0b00000110 = 3 - 6 = 0 - 3 = 255 - 2 = 253 = 0b11111101 with borrow
        let expectedVx: Byte = 0b11111101
        XCTAssertEqual(observedVx, expectedVx)

        let expectedVf: Byte = 0
        let observedVf = newState.v[0x0f]
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_SUBB_dot_0x08_increments_pc() {
        let x: Byte = 1, y: Byte = 4
        let op = Word(nibbles: [0x08, x, y, 0x07])
        assertPcIncremented(op: op)
    }

    func test_SHL_dot_0x08_stores_the_msb_of_Vx_in_Vf_when_msb_is_1() {
        let x: Byte = 0x0c
        let f: Byte = 0x0f
        let op = Word(nibbles: [0x08, x, 0x00, 0x0e])
        let initialVx: Byte = 0b10100101
        let initialVf: Byte = 0b00000000
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[f] = initialVf

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVf = newState.v[f]
        // msb of 0b10110101 is 0b1000000
        let expectedVf: Byte = 0b10000000
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_SHL_dot_0x08_stores_the_msb_of_Vx_in_Vf_when_msb_is_0() {
        let x: Byte = 0x0c
        let f: Byte = 0x0f
        let op = Word(nibbles: [0x08, x, 0x00, 0x0e])
        let initialVx: Byte = 0b01010100
        let initialVf: Byte = 0b00000001
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[f] = initialVf

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVf = newState.v[f]
        // msb of 0b01010100 is 0b00000000
        let expectedVf: Byte = 0b00000000
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_SHL_dot_0x08_shifts_Vx_left_by_1() {
        let x: Byte = 0x0c
        let op = Word(nibbles: [0x08, x, 0x00, 0x0e])
        let initialVx: Byte = 0b10100101
        var v = createEmptyRegisters()
        v[x] = initialVx

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        // 0b10100101 shifted left by 1 = 0b01001010
        let expectedVx: Byte = 0b01001010
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_SHL_dot_0x08_increments_pc() {
        let x: Byte = 5, y: Byte = 9
        let op = Word(nibbles: [0x08, x, y, 0x0e])
        assertPcIncremented(op: op)
    }

    func test_SKIP_NE_0x09_skips_if_Vx_does_NOT_equal_Vy() {
        let x: Byte = 0x0c, y: Byte = 0x0e
        let op = Word(nibbles: [0x09, x, y, 0x00])
        let initialVx: Byte = 1, initialVy: Byte = 2
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v


        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = state.pc + 4
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_SKIP_NE_0x09_increments_if_Vx_does_equal_Vy() {
        let x: Byte = 0x0c, y: Byte = 0x0e
        let op = Word(nibbles: [0x09, x, y, 0x00])
        let initialVx: Byte = 3, initialVy: Byte = 3
        var v = createEmptyRegisters()
        v[x] = initialVx
        v[y] = initialVy

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)

        let observedPc = newState.pc
        let expectedPc = state.pc + 2
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_MVI_0x0a_sets_i_to_NNN() {
        let n1: Byte = 0x0a, n2: Byte = 0x0b, n3: Byte = 0x0c
        let op = Word(nibbles: [0x0a, n1, n2, n3])

        let state = ChipState()

        let newState = try! opExecutor.handle(state: state, op: op)

        let observedI = newState.i
        let expectedI = Word(nibbles: [n1, n2, n3])
        XCTAssertEqual(observedI, expectedI)
    }

    func test_MVI_0x0a_increments_pc() {
        let n1: Byte = 0x0a, n2: Byte = 0x0b, n3: Byte = 0x0c
        let op = Word(nibbles: [0x0a, n1, n2, n3])
        assertPcIncremented(op: op)
    }

    func test_JUMP_0x0b_sets_pc_to_NNN_plus_V0() {
        let x: Byte = 0, n1: Byte = 0x02, n2: Byte = 0x0a, n3: Byte = 0x06
        let op = Word(nibbles: [0x0b, n1, n2, n3])
        let initialVx: Byte = 0b00011010
        var v = createEmptyRegisters()
        v[x] = initialVx

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        // nnn + V0 = 0x02, 0x0a, 0x06 + 0b00011010 = 0b0000, 0b0010, 0b1010, 0b0110 + 0b00011010
        // 0b0000, 0b0010, 0b1010, 0b0110 = 0b0000001010100110 + 0b00011010 = 678 + 26 = 704
        let expectedPc: Word = 704
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_JUMP_0x0b_sets_pc_to_NNN_plus_V0_with_maximums() {
        let x: Byte = 0, n1: Byte = 0b1111, n2: Byte = 0b1111, n3: Byte = 0b1111
        let op = Word(nibbles: [0x0b, n1, n2, n3])
        let initialVx: Byte = 0b11111111
        var v = createEmptyRegisters()
        v[x] = initialVx

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        // nnn + V0 = 0b1111, 0b1111, 0b1111 + 0b11111111 =
        // 0b0000111111111111 + 0b11111111 = 4095 + 255 = 4350
        // TODO: this address is outside of the normal 4k Chip-8 memory, should rom programmer or Chip-8 implementation handle this?
        let expectedPc: Word = 4350

        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_RAND_0x0c_sets_Vx_to_rand_bitwise_and_nn() {
        let x: Byte = 0, n1: Byte = 0b0011, n2: Byte = 0b1001
        let op = Word(nibbles: [0x0c, x, n1, n2])
        let initialVx: Byte = 0b11111111
        var v = createEmptyRegisters()
        v[x] = initialVx

        var state = ChipState()
        state.v = v

        // inject a random byte generating function to allow deterministic test
        let randomByteFunction: () -> Byte = { 0b10001001 }
        let opExecutor = OpExecutor(
            cpuHz: 1/600,
            randomByteFunction: randomByteFunction
        )
        let newState = try! opExecutor.handle(state: state, op: op)

        let observedVx = newState.v[x]
        // rand() & nn = 0b10001001 & 0b0011,0b1001
        // = 0b10001001 & 0b00111001 = 0b00001001

        let expectedVx: Byte = 0b00001001

        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_RAND_0x0c_increments_pc() {
        let x: Byte = 0, n1: Byte = 0b0011, n2: Byte = 0b1001
        let op = Word(nibbles: [0x0c, x, n1, n2])
        assertPcIncremented(op: op)
    }

    func test_SPRITE_0x0d_draws_pixel_on_row_0() {
        let x: Byte = 0, y: Byte = 1, n: Byte = 4
        let initialVx: Byte = 3, initialVy: Byte = 5, initialIAddress: Word = 12
        let op = Word(nibbles: [0x0d, x, y, n])

        var state = ChipState()
        state.v[x] = initialVx
        state.v[y] = initialVy
        state.i = initialIAddress
        let initialIValue: Byte = 0b00000001
        state.ram[initialIAddress] = initialIValue

        var expectedPixels = [Byte](repeating: 0, count: state.screen.size.area)
        // Vx, Vy = (initialVy + rowIndex) * screenWidth + (initialVx + colIndex) =
        // where colIndex is the index (counting l to r) in initialIValue of the '1'
        // where colIndex = 7
        // (5 + 0) * 64 + 3 + 7 = 330
        let pixelAddress = 330
        expectedPixels[pixelAddress] = 1

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPixels = newState.screen.pixels

        XCTAssertEqual(observedPixels, expectedPixels)
    }

    func test_SPRITE_0x0d_draws_pixel_on_row_1() {
        let x: Byte = 0, y: Byte = 1, n: Byte = 4
        let initialVx: Byte = 3, initialVy: Byte = 5, initialIAddress: Word = 12
        let op = Word(nibbles: [0x0d, x, y, n])

        var state = ChipState()
        state.v[x] = initialVx
        state.v[y] = initialVy
        state.i = initialIAddress
        let initialIValue: Byte = 0b00000001

        // row 0 is the byte at initialIAddress
        // so row 1 is the byte at initialIAddress + 1
        let ramAddress = initialIAddress + 1
        state.ram[ramAddress] = initialIValue

        var expectedPixels = [Byte](repeating: 0, count: state.screen.size.area)
        // Vx, Vy = (initialVy + rowIndex) * screenWidth + (initialVx + colIndex) =
        // where colIndex is the index (counting l to r) in initialIValue of the '1'
        // where colIndex = 7
        // (5 + 1) * 64 + 3 + 7 = 394
        let pixelAddress = 394
        expectedPixels[pixelAddress] = 1

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPixels = newState.screen.pixels

        XCTAssertEqual(observedPixels, expectedPixels)
    }

    func test_SPRITE_0x0d_draws_overflow_pixels() {
        // DXYN, Disp, Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N+1 pixels. Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesn’t change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn’t happen
        let x: Byte = 5, y: Byte = 12, n: Byte = 2

        // make Vx so that drawing 8 pixels horizontally makes 1 pixel wrap
        // rightmost x index = screen width - 1 = 64 - 1
        // deduct not quite enough space for the width of a sprite = (sprite width - 1)
        // Vx = (rightmost x index) - (sprite width - 1)
        // Vx = 64 - 1 - 8 + 1 = 56
        let initialVx: Byte = 56

        // make Vy so that drawing n pixels vertically makes 1 pixel wrap
        // bottom-most y index = screen height - 1 = 32 - 1
        // deduct not quite enough space for the height of n = (n - 1)
        // Vy = (bottom-most y index) - (n - 1)
        // Vy = 32 - 1 - 2 + 1 = 32
        let initialVy: Byte = 32

        let initialIAddress: Word = 12
        let op = Word(nibbles: [0x0d, x, y, n])

        var state = ChipState()
        state.v[x] = initialVx
        state.v[y] = initialVy
        state.i = initialIAddress
        let initialIValue: Byte = 0b00000001

        // row 0 is the byte at initialIAddress
        let ramAddress = initialIAddress
        state.ram[ramAddress] = initialIValue

        var expectedPixels = [Byte](repeating: 0, count: state.screen.size.area)
        // Vx, Vy = (initialVy + rowIndex) * screenWidth + (initialVx + colIndex) =
        // where colIndex is the index (counting l to r) in initialIValue of the '1'
        // where colIndex = 7
        // (32 + 0) * 64 + 56 + 7 = 2111
        // then wrap around screen
        // 2111 % (64 * 2) = 63
        let pixelAddress = 63
        expectedPixels[pixelAddress] = 1

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPixels = newState.screen.pixels

        XCTAssertEqual(observedPixels, expectedPixels)
    }

    func test_SPRITE_0x0d_sets_flag_for_1_to_0() {
        let x: Byte = 0, y: Byte = 1, n: Byte = 4
        let initialVx: Byte = 9, initialVy: Byte = 20, initialIAddress: Word = 0x2ae
        let op = Word(nibbles: [0x0d, x, y, n])

        var state = ChipState()
        state.v[x] = initialVx
        state.v[y] = initialVy
        state.i = initialIAddress
        let initialFlag: Byte = 0
        state.v[0x0f] = initialFlag

        let initialIValue: Byte = 0b01000000

        // row 0 is the byte at initialIAddress
        // so row 1 is the byte at initialIAddress + 1
        let ramAddress = initialIAddress + 1
        state.ram[ramAddress] = initialIValue

        // Vx, Vy = (initialVy + rowIndex) * screenWidth + (initialVx + colIndex) =
        // where colIndex is the index (counting l to r) in initialIValue (col[1])
        // where colIndex = 1
        // (20 + 1) * 64 + 9 + 1 = 1354
        let pixelAddress = 1354

        // ensure we move from 1 -> 0
        state.screen.pixels[pixelAddress] = 1

        let newState = try! opExecutor.handle(state: state, op: op)
        let expectedFlag: Byte = 1
        let observedFlag = newState.v[0x0f]

        XCTAssertEqual(observedFlag, expectedFlag)
    }

    func test_SPRITE_0x0d_does_not_set_flag_for_0_to_1() {
        let x: Byte = 0, y: Byte = 1, n: Byte = 4
        let initialVx: Byte = 9, initialVy: Byte = 20, initialIAddress: Word = 0x2ae
        let op = Word(nibbles: [0x0d, x, y, n])

        var state = ChipState()
        state.v[x] = initialVx
        state.v[y] = initialVy
        state.i = initialIAddress
        let initialFlag: Byte = 0
        state.v[0x0f] = initialFlag

        let initialIValue: Byte = 0b01000000

        // row 0 is the byte at initialIAddress
        // so row 1 is the byte at initialIAddress + 1
        let ramAddress = initialIAddress + 1
        state.ram[ramAddress] = initialIValue

        // Vx, Vy = (initialVy + rowIndex) * screenWidth + (initialVx + colIndex) =
        // where colIndex is the index (counting l to r) in initialIValue (col[1])
        // where colIndex = 1
        // (20 + 1) * 64 + 9 + 1 = 1354
        let pixelAddress = 1354

        // ensure we move from 0 -> 1
        state.screen.pixels[pixelAddress] = 0

        let newState = try! opExecutor.handle(state: state, op: op)
        let expectedFlag: Byte = 0
        let observedFlag = newState.v[0x0f]

        XCTAssertEqual(observedFlag, expectedFlag)
    }

    func test_SPRITE_0x0d_does_not_set_flag_for_0_to_0() {
        let x: Byte = 0, y: Byte = 1, n: Byte = 4
        let initialVx: Byte = 9, initialVy: Byte = 20, initialIAddress: Word = 0x2ae
        let op = Word(nibbles: [0x0d, x, y, n])

        var state = ChipState()
        state.v[x] = initialVx
        state.v[y] = initialVy
        state.i = initialIAddress
        let initialFlag: Byte = 0
        state.v[0x0f] = initialFlag

        let initialIValue: Byte = 0b00000000

        // row 0 is the byte at initialIAddress
        // so row 1 is the byte at initialIAddress + 1
        let ramAddress = initialIAddress + 1
        state.ram[ramAddress] = initialIValue

        // Vx, Vy = (initialVy + rowIndex) * screenWidth + (initialVx + colIndex) =
        // where colIndex is the index (counting l to r) in initialIValue (col[1])
        // where colIndex = 1
        // (20 + 1) * 64 + 9 + 1 = 1354
        let pixelAddress = 1354

        // ensure we move from 0 -> 0
        state.screen.pixels[pixelAddress] = 0

        let newState = try! opExecutor.handle(state: state, op: op)
        let expectedFlag: Byte = 0
        let observedFlag = newState.v[0x0f]

        XCTAssertEqual(observedFlag, expectedFlag)
    }

    func test_SPRITE_0x0d_does_not_set_flag_for_1_to_1() {
        let x: Byte = 0, y: Byte = 1, n: Byte = 4
        let initialVx: Byte = 9, initialVy: Byte = 20, initialIAddress: Word = 0x2ae
        let op = Word(nibbles: [0x0d, x, y, n])

        var state = ChipState()
        state.v[x] = initialVx
        state.v[y] = initialVy
        state.i = initialIAddress
        let initialFlag: Byte = 0
        state.v[0x0f] = initialFlag

        let initialIValue: Byte = 0b00000000

        // row 0 is the byte at initialIAddress
        // so row 1 is the byte at initialIAddress + 1
        let ramAddress = initialIAddress + 1
        state.ram[ramAddress] = initialIValue

        // Vx, Vy = (initialVy + rowIndex) * screenWidth + (initialVx + colIndex) =
        // where colIndex is the index (counting l to r) in initialIValue (col[1])
        // where colIndex = 1
        // (20 + 1) * 64 + 9 + 1 = 1354
        let pixelAddress = 1354

        // ensure we move from 1 -> 1
        state.screen.pixels[pixelAddress] = 1

        let newState = try! opExecutor.handle(state: state, op: op)
        let expectedFlag: Byte = 0
        let observedFlag = newState.v[0x0f]

        XCTAssertEqual(observedFlag, expectedFlag)
    }

    func test_SPRITE_0x0d_increments_pc() {
        let x: Byte = 1, y: Byte = 3, n: Byte = 4
        let op = Word(nibbles: [0x0d, x, y, n])
        assertPcIncremented(op: op)
    }

    func test_ADD_0x0f_adds_Vx_to_I() {
        let x: Byte = 4
        let op = Word(nibbles: [0x0f, x, 0x01, 0x0e])
        var v = [Byte](repeating: 0, count: 6)
        v[x] = 1

        var state = ChipState()
        state.v = v
        state.i = Word.max - Word(v[x])

        let expectedI = state.i + Word(v[x])

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedI = newState.i
        XCTAssertEqual(observedI, expectedI)
    }

    func test_ADD_0x0f_adds_Vx_to_I_with_overflow() {
        let x: Byte = 4
        let op = Word(nibbles: [0x0f, x, 0x01, 0x0e])
        var v = [Byte](repeating: 0, count: 6)
        v[x] = 2

        var state = ChipState()
        state.v = v
        state.i = Word.max - 1

        // I + Vx =
        // Word.max-1 + 2 =
        // 0b1111111111111110 + 0b0000000000000010 =
        // 0b0000000000000000 with overflow of 0b0000000000000001
        let expectedI: Word = 0b0000000000000000

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedI = newState.i
        XCTAssertEqual(observedI, expectedI)
    }

    func test_ADD_0x0f_does_NOT_change_flag_when_1() {
        let x: Byte = 4
        let op = Word(nibbles: [0x0f, x, 0x01, 0x0e])
        let expectedVf: Byte = 1

        var state = ChipState()
        state.v[x] = 2
        let f = 0x0f
        state.v[f] = expectedVf
        state.i = Word.max - 1

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVf = newState.v[f]
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_ADD_0x0f_does_NOT_change_flag_when_0() {
        let x: Byte = 4
        let op = Word(nibbles: [0x0f, x, 0x01, 0x0e])
        let expectedVf: Byte = 0

        var state = ChipState()
        state.v[x] = 2
        let f = 0x0f
        state.v[f] = expectedVf
        state.i = Word.max - 1

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVf = newState.v[f]
        XCTAssertEqual(observedVf, expectedVf)
    }

    func test_ADD_0x0f_increments_pc() {
        let x: Byte = 0x0e
        let op = Word(nibbles: [0x0f, x, 0x01, 0x0e])
        assertPcIncremented(op: op)
    }

    func test_SKIP_KEY_0x0e_skips() {
        let x: Byte = 0x09
        let op = Word(nibbles: [0x0e, x, 0x09, 0x0e])
        let triggerKey = 1
        let initialPc: Word = 0x6e6
        var v = createEmptyRegisters()
        v[x] = Byte(triggerKey)

        var state = ChipState()
        state.pc = initialPc
        state.v = v
        state.downKeys.append(Byte(triggerKey))

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc: Word = initialPc + 4
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_SKIP_KEY_0x0e_does_not_skip() {
        let x: Byte = 0x00
        let op = Word(nibbles: [0x0e, x, 0x09, 0x0e])
        let triggerKey = 12
        let initialPc: Word = 0xaae6
        var v = createEmptyRegisters()
        v[x] = Byte(triggerKey)

        var state = ChipState()
        state.pc = initialPc
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc: Word = initialPc + 2
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_SKIP_NOKEY_0x0e_skips() {
        let x: Byte = 0x09
        let op = Word(nibbles: [0x0e, x, 0x0a, 0x01])
        let triggerKey = 1
        let initialPc: Word = 0x6e6
        var v = createEmptyRegisters()
        v[x] = Byte(triggerKey)

        var state = ChipState()
        state.pc = initialPc
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc: Word = initialPc + 4
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_SKIP_NOKEY_0x0e_does_not_skip() {
        let x: Byte = 0x00
        let op = Word(nibbles: [0x0e, x, 0x0a, 0x01])
        let triggerKey = 12
        let initialPc: Word = 0xaae6
        var v = createEmptyRegisters()
        v[x] = Byte(triggerKey)

        var state = ChipState()
        state.pc = initialPc
        state.v = v
        state.downKeys.append(Byte(triggerKey))

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc: Word = initialPc + 2
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_MOV_0x0f_sets_Vx_to_delayTimer() {
        let x: Byte = 0x0d
        let op = Word(nibbles: [0x0f, x, 0x00, 0x07])
        var v = createEmptyRegisters()
        v[x] = 1

        var state = ChipState()
        state.v = v
        let expectedVx: Byte = 100
        state.delayTimer = TimeInterval(expectedVx)

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_MOV_0x0f_increments_pc() {
        let x: Byte = 0x05
        let op = Word(nibbles: [0x0f, x, 0x00, 0x07])
        assertPcIncremented(op: op)
    }

    func test_WAITKEY_0x0f_awaits() {
        let x: Byte = 0x02
        let op = Word(nibbles: [0x0f, x, 0x00, 0x0a])

        var state = ChipState()
        state.downKeys = []

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedAwaiting = newState.isAwaitingKey
        XCTAssertTrue(observedAwaiting)
    }

    func test_WAITKEY_0x0f_awaits_without_incrementing_pc() {
        let x: Byte = 0x02
        let op = Word(nibbles: [0x0f, x, 0x00, 0x0a])
        let initialPc: Word = 0x88a

        var state = ChipState()
        state.downKeys = []
        state.pc = initialPc

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = initialPc
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_WAITKEY_0x0f_resets_isAwaiting_when_awaited_key_pressed() {
        let x: Byte = 0x02
        let op = Word(nibbles: [0x0f, x, 0x00, 0x0a])
        let awaitedKey: Byte = 1
        let initialIsAwaiting = true

        var state = ChipState()
        state.downKeys = [awaitedKey]
        state.isAwaitingKey = initialIsAwaiting

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedAwaiting = newState.isAwaitingKey
        XCTAssertFalse(observedAwaiting)
    }

    func test_WAITKEY_0x0f_sets_Vx_to_pressed_key_when_awaited_key_pressed() {
        let x: Byte = 0x02
        let op = Word(nibbles: [0x0f, x, 0x00, 0x0a])
        var v = createEmptyRegisters()
        v[x] = 1
        let awaitedKey: Byte = 5
        let initialIsAwaiting = true

        var state = ChipState()
        state.v = v
        state.downKeys = [awaitedKey]
        state.isAwaitingKey = initialIsAwaiting

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVx = newState.v[x]
        let expectedVx = awaitedKey
        XCTAssertEqual(observedVx, expectedVx)
    }

    func test_WAITKEY_0x0f_increments_pc_when_awaited_key_pressed() {
        let x: Byte = 0x02
        let op = Word(nibbles: [0x0f, x, 0x00, 0x0a])
        let awaitedKey: Byte = 5
        let initialPc: Word = 0x88a

        var state = ChipState()
        state.downKeys = [awaitedKey]
        state.pc = initialPc
        state.isAwaitingKey = true

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = initialPc + 2
        XCTAssertEqual(observedPc, expectedPc)
    }

    func test_MOV_0x0f_sets_decremented_delayTimer_to_Vx() {
        let x: Byte = 0x0d
        let op = Word(nibbles: [0x0f, x, 0x01, 0x05])
        var v = createEmptyRegisters()
        v[x] = 1

        var state = ChipState()
        state.v = v
        let initialDelayTimer: TimeInterval = 7
        state.v[x] = Byte(initialDelayTimer)

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedDelayTimer = newState.delayTimer
        let expectedDelayTimer = initialDelayTimer - opExecutor.cpuHz / opExecutor.delayHz
        XCTAssertEqual(observedDelayTimer, expectedDelayTimer)
    }

    func test_MOV_0x0f_delayTimer_to_Vx_increments_pc() {
        let x: Byte = 0x05
        let op = Word(nibbles: [0x0f, x, 0x01, 0x05])
        assertPcIncremented(op: op)
    }

    func test_MOV_0x0f_sets_decremented_soundTimer_to_Vx() {
        let x: Byte = 0x0d
        let op = Word(nibbles: [0x0f, x, 0x01, 0x08])
        var v = createEmptyRegisters()
        v[x] = 1

        var state = ChipState()
        state.v = v
        let initialSoundTimer: TimeInterval = 213
        state.v[x] = Byte(initialSoundTimer)

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedSoundTimer = newState.soundTimer
        let expectedSoundTimer = initialSoundTimer - opExecutor.cpuHz / opExecutor.soundHz
        XCTAssertEqual(observedSoundTimer, expectedSoundTimer)
    }

    func test_MOV_0x0f_soundTimer_to_Vx_increments_pc() {
        let x: Byte = 0x05
        let op = Word(nibbles: [0x0f, x, 0x01, 0x08])
        assertPcIncremented(op: op)
    }

    func test_SPRITECHAR_0x0f_sets_I_to_Vx_multiplied_by_font_height() {
        let x: Byte = 0x04
        let op = Word(nibbles: [0x0f, x, 0x02, 0x09])
        var v = createEmptyRegisters()
        let initialVx: Word = 5
        v[x] = Byte(initialVx)

        var state = ChipState()
        state.v = v

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedI = newState.i
        let expectedI = initialVx * 5
        XCTAssertEqual(observedI, expectedI)
    }

    func test_SPRITECHAR_0x0f_soundTimer_to_Vx_increments_pc() {
        let x: Byte = 0x05
        let op = Word(nibbles: [0x0f, x, 0x02, 0x09])
        assertPcIncremented(op: op)
    }

    func test_MOVBCD_0x0f_sets_ram_at_I_to_ones_tens_and_hundreds_of_Vx() {
        let x: Byte = 0x07
        let op = Word(nibbles: [0x0f, x, 0x03, 0x03])
        var v = createEmptyRegisters()
        v[x] = 104
        let initialI: Word = 0x4a3

        var state = ChipState()
        state.v = v
        state.i = initialI

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedRam = [
            newState.ram[initialI + 0],
            newState.ram[initialI + 1],
            newState.ram[initialI + 2],
        ]
        let expectedRam: [Byte] = [1, 0, 4]
        XCTAssertEqual(observedRam, expectedRam)
    }

    func test_MOVBCD_increments_pc() {
        let x: Byte = 0x05
        let op = Word(nibbles: [0x0f, x, 0x03, 0x03])
        assertPcIncremented(op: op)
    }

    func test_MOVM_0x0f_stores_V0_to_Vx_in_memory_starting_at_I() {
        let x: Byte = 0x04
        let op = Word(nibbles: [0x0f, x, 0x05, 0x05])
        var v = createEmptyRegisters()
        let expectedRam: [Byte] = [241, 242, 243, 111, 104]
        v[0] = expectedRam[0]
        v[1] = expectedRam[1]
        v[2] = expectedRam[2]
        v[3] = expectedRam[3]
        v[x] = expectedRam[4]
        let initialI: Word = 0x4b3

        var state = ChipState()
        state.v = v
        state.i = initialI

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedRam = [
            newState.ram[initialI + 0],
            newState.ram[initialI + 1],
            newState.ram[initialI + 2],
            newState.ram[initialI + 3],
            newState.ram[initialI + 4],
        ]
        XCTAssertEqual(observedRam, expectedRam)
    }

    func test_MOVM_0x0f_increments_pc() {
        let x: Byte = 0x05
        let op = Word(nibbles: [0x0f, x, 0x05, 0x05])
        assertPcIncremented(op: op)
    }

    func test_MOVM_0x0f_stores_I_onwards_in_memory_to_V0_to_Vx() {
        let x: Byte = 0x04
        let op = Word(nibbles: [0x0f, x, 0x06, 0x05])
        let expectedVs: [Byte] = [241, 242, 243, 111, 104]
        var initialRam = [Byte](repeating: 0, count: 4096)
        let initialI: Word = 0x77a
        initialRam[initialI + 0] = expectedVs[0]
        initialRam[initialI + 1] = expectedVs[1]
        initialRam[initialI + 2] = expectedVs[2]
        initialRam[initialI + 3] = expectedVs[3]
        initialRam[initialI + Word(x)] = expectedVs[x]

        var state = ChipState()
        state.i = initialI
        state.ram = initialRam

        let newState = try! opExecutor.handle(state: state, op: op)
        let observedVs = [
            newState.v[0],
            newState.v[1],
            newState.v[2],
            newState.v[3],
            newState.v[x],
        ]
        XCTAssertEqual(observedVs, expectedVs)
    }

    func test_MOVM_0x0f_stores_I_onwards_in_memory_to_V0_to_Vx_increments_oc() {
        let x: Byte = 0x05
        let op = Word(nibbles: [0x0f, x, 0x06, 0x05])
        assertPcIncremented(op: op)
    }
}

// Utils
extension OpExecutorTests {
    func createEmptyRegisters() -> [Byte] {
        return [Byte](repeating: 0, count: registerSize)
    }

    func assertPcIncremented(op: Word) {
        let state = ChipState()
        let newState = try! opExecutor.handle(state: state, op: op)
        let observedPc = newState.pc
        let expectedPc = state.pc + 2
        XCTAssertEqual(observedPc, expectedPc)
    }

    func createPcFrom(_ n1: Byte, _ n2: Byte, _ n3: Byte) -> Word {
        let word = Word(nibbles: [n1, n2, n3])
        return word
    }

    func createOp(_ n1: Byte, _ n2: Byte, _ n3: Byte, _ n4: Byte) -> [Byte] {
        let byte1 = n1 << 4 | n2
        let byte2 = n3 << 4 | n4
        return [byte1, byte2]
    }

    func createRamWithOp(_ n1: Byte, _ n2: Byte, _ n3: Byte, _ n4: Byte, pc: Word = 0x200) -> [Byte] {
        var ram = [Byte](repeating: 0, count: 4096)
        let opBytes = createOp(n1, n2, n3, n4)
        let pcInt = Int(pc)
        let opRange = pcInt..<pcInt + opBytes.count
        ram.replaceSubrange(opRange, with: opBytes)
        return ram
    }

    func getHexStr<I: BinaryInteger & CVarArg>(width: Int, _ value: I) -> String {
        let valueStr = String(format:"%02X", value as CVarArg)
        let paddedStr = valueStr.padding(toLength: width, withPad: " ", startingAt: 0)
        return paddedStr
    }
}
