require_relative "../encoding"
require "ADL/base"
require "ADL/builder"

module RV
    include SimInfra
    extend SimInfra

    assert(XLEN == 32 || XLEN == 64, "XLEN must be 32 or 64")
    xreg = :"r#{XLEN}"

    Interface {
        Function(:sysCall)
    }

    RegisterFile(:XRegs) do
        send(xreg, :x0, zero)
        send(xreg, :x1)
        send(xreg, :x2)
        send(xreg, :x3)
        send(xreg, :x4)
        send(xreg, :x5)
        send(xreg, :x6)
        send(xreg, :x7)
        send(xreg, :x8)
        send(xreg, :x9)
        send(xreg, :x10)
        send(xreg, :x11)
        send(xreg, :x12)
        send(xreg, :x13)
        send(xreg, :x14)
        send(xreg, :x15)
        send(xreg, :x16)
        send(xreg, :x17)
        send(xreg, :x18)
        send(xreg, :x19)
        send(xreg, :x20)
        send(xreg, :x21)
        send(xreg, :x22)
        send(xreg, :x23)
        send(xreg, :x24)
        send(xreg, :x25)
        send(xreg, :x26)
        send(xreg, :x27)
        send(xreg, :x28)
        send(xreg, :x29)
        send(xreg, :x30)
        send(xreg, :x31)
        send(xreg, :pc, pc) 
    end
end
