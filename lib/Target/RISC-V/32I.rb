require_relative "encoding"
require_relative "../../ADL/base"
require_relative "../../ADL/builder"

module RV32I
    include SimInfra
    extend SimInfra

    Instruction(:lb) {
        encoding *format_i(0b0000011, 0b000)
        asm { "lb {rd}, {imm}({rs1})" }
        code { rd[]= mem[rs1 + imm, :b8].s32 }
    }

    Instruction(:lh) {
        encoding *format_i(0b0000011, 0b001)
        asm { "lh {rd}, {imm}({rs1})" }
        code { rd[]= mem[rs1 + imm, :b16].s32 }
    }

    Instruction(:lw) {
        encoding *format_i(0b0000011, 0b010)
        asm { "lw {rd}, {imm}({rs1})" }
        code { rd[]= mem[rs1 + imm, :b32] }
    }
    
    Instruction(:lbu) {
        encoding *format_i(0b0000011, 0b100)
        asm { "lbu {rd}, {imm}({rs1})" }
        code { rd[]= mem[rs1 + imm, :b8].u32 }
    }

    Instruction(:lhu) {
        encoding *format_i(0b0000011, 0b101)
        asm { "lhu {rd}, {imm}({rs1})" }
        code { rd[]= mem[rs1 + imm, :b16].u32 }
    }
end
