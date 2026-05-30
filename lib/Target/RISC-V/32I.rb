require_relative "encoding"
require "ADL/base"
require "ADL/builder"

module RV32I
  include SimInfra
  extend SimInfra

  Interface { Function(:sysCall) }

  RegisterFile(:XRegs) {
    r32 :x0, zero
    r32 :x1
    r32 :x2, sp
    for i in 3..31 do; r32 :"x#{i}"; end
    r32 :pc, pc
  }

  def self.build_from_table(table)
    table.each do |name, encoding_args, asm_str, code_str|
      Instruction(name) {
        encoding *encoding_args
        asm { "#{name} #{asm_str}" }
        code { instance_eval(code_str) }
      }
    end
  end

  INSTRUCTION_TABLE = [

    [:add,  format_r(0b0110011,0b000,0b0000000), "%{rd}, %{rs1}, %{rs2}", "rd[]= rs1.u + rs2.u"],
    [:sub,  format_r(0b0110011,0b000,0b0100000), "%{rd}, %{rs1}, %{rs2}", "rd[]= rs1.u - rs2.u"],
    [:sll,  format_r(0b0110011,0b001,0b0000000), "%{rd}, %{rs1}, %{rs2}", "rd[]= rs1.u << rs2.u"],
    [:slt,  format_r(0b0110011,0b010,0b0000000), "%{rd}, %{rs1}, %{rs2}", "rd[]= (rs1.s < rs2.s).b32"],
    [:sltu, format_r(0b0110011,0b011,0b0000000), "%{rd}, %{rs1}, %{rs2}", "rd[]= (rs1.u < rs2.u).b32"],
    [:xor,  format_r(0b0110011,0b100,0b0000000), "%{rd}, %{rs1}, %{rs2}", "rd[]= rs1 ^ rs2"],
    [:srl,  format_r(0b0110011,0b101,0b0000000), "%{rd}, %{rs1}, %{rs2}", "rd[]= rs1.u >> rs2.u"],
    [:sra,  format_r(0b0110011,0b101,0b0100000), "%{rd}, %{rs1}, %{rs2}", "rd[]= rs1.s >> rs2.s"],
    [:or,   format_r(0b0110011,0b110,0b0000000), "%{rd}, %{rs1}, %{rs2}", "rd[]= rs1 | rs2"],
    [:and,  format_r(0b0110011,0b111,0b0000000), "%{rd}, %{rs1}, %{rs2}", "rd[]= rs1 & rs2"],

    [:addi,  format_i(0b0010011,0b000), "%{rd}, %{rs1}, %{imm}", "rd[]= rs1 + imm"],
    [:slti,  format_i(0b0010011,0b010), "%{rd}, %{rs1}, %{imm}", "rd[]= (rs1.s < imm.s).b32"],
    [:sltiu, format_i(0b0010011,0b011), "%{rd}, %{rs1}, %{imm}", "rd[]= (rs1.u < imm.u).b32"],
    [:xori,  format_i(0b0010011,0b100), "%{rd}, %{rs1}, %{imm}", "rd[]= rs1 ^ imm"],
    [:ori,   format_i(0b0010011,0b110), "%{rd}, %{rs1}, %{imm}", "rd[]= rs1 | imm"],
    [:andi,  format_i(0b0010011,0b111), "%{rd}, %{rs1}, %{imm}", "rd[]= rs1 & imm"],
    [:slli,  format_i_shift(0b0010011,0b001,0b00000), "%{rd}, %{rs1}, %{imm}", "rd[]= rs1 << imm"],
    [:srli,  format_i_shift(0b0010011,0b101,0b00000), "%{rd}, %{rs1}, %{imm}", "rd[]= rs1.u >> imm"],
    [:srai,  format_i_shift(0b0010011,0b101,0b01000), "%{rd}, %{rs1}, %{imm}", "rd[]= rs1.s >> imm"],

    [:beq,  format_b(0b1100011,0b000), "%{rs1}, %{rs2}, %{imm}", "branch(select(rs1 == rs2, pc + imm, pc + 4))"],
    [:bne,  format_b(0b1100011,0b001), "%{rs1}, %{rs2}, %{imm}", "branch(select(rs1 != rs2, pc + imm, pc + 4))"],
    [:blt,  format_b(0b1100011,0b100), "%{rs1}, %{rs2}, %{imm}", "branch(select(rs1.s < rs2.s, pc + imm, pc + 4))"],
    [:bge,  format_b(0b1100011,0b101), "%{rs1}, %{rs2}, %{imm}", "branch(select(rs1.s >= rs2.s, pc + imm, pc + 4))"],
    [:bltu, format_b(0b1100011,0b110), "%{rs1}, %{rs2}, %{imm}", "branch(select(rs1.u < rs2.u, pc + imm, pc + 4))"],
    [:bgeu, format_b(0b1100011,0b111), "%{rs1}, %{rs2}, %{imm}", "branch(select(rs1.u >= rs2.u, pc + imm, pc + 4))"],

    [:sb, format_s(0b0100011,0b000), "%{rs2}, %{imm}(%{rs1})", "mem[rs1 + imm]= rs2[7,0]"],
    [:sh, format_s(0b0100011,0b001), "%{rs2}, %{imm}(%{rs1})", "mem[rs1 + imm]= rs2[15,0]"],
    [:sw, format_s(0b0100011,0b010), "%{rs2}, %{imm}(%{rs1})", "mem[rs1 + imm]= rs2"],

    [:lb,  format_i(0b0000011,0b000), "%{rd}, %{imm}(%{rs1})", "rd[]= mem[rs1 + imm, :b8].s32"],
    [:lh,  format_i(0b0000011,0b001), "%{rd}, %{imm}(%{rs1})", "rd[]= mem[rs1 + imm, :b16].s32"],
    [:lw,  format_i(0b0000011,0b010), "%{rd}, %{imm}(%{rs1})", "rd[]= mem[rs1 + imm, :b32]"],
    [:lbu, format_i(0b0000011,0b100), "%{rd}, %{imm}(%{rs1})", "rd[]= mem[rs1 + imm, :b8].u32"],
    [:lhu, format_i(0b0000011,0b101), "%{rd}, %{imm}(%{rs1})", "rd[]= mem[rs1 + imm, :b16].u32"]
  ]

  build_from_table(INSTRUCTION_TABLE)

  Instruction(:lui) {
    encoding *format_u(0b0110111)
    asm { "lui %{rd}, %{imm}" }
    code { rd[]= imm }
  }

  Instruction(:auipc) {
    encoding *format_u(0b0010111)
    asm { "auipc %{rd}, %{imm}" }
    code { rd[]= imm + pc }
  }

  Instruction(:jal) {
    encoding *format_j(0b1101111)
    asm { "jal %{rd}, %{imm}" }
    code { rd[]= pc + 4; branch(pc + imm) }
  }

  Instruction(:jalr) {
    encoding *format_i(0b1100111, 0b000)
    asm { "jalr %{rd}, %{rs1}, %{imm}" }
    code { let :t, :b32, pc + 4; branch((rs1 + imm) & (~1)); rd[]= t }
  }
end
