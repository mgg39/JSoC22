using QuantumClifford
using QuantumClifford.ECC: AbstractECC, Steane5, Steane7, Shor9, Bitflip3, naive_syndrome_circuit, code_n, parity_checks, encoding_circuit, code_s, code_k, rate, distance,logx_ops, logz_ops, isdegenerate

function test_op(c::AbstractECC)

        physicalqubit = random_stabilizer(code_k(c))

        gate = rand((:x,:z))
        physicalgate, logicalgate = if gate==:x
            P"X",logx_ops(c)[1]
        elseif gate == :z
            P"Z",logz_ops(c)[1]
        end

        #run 1
        #start physical state
        physicalqubit1 = copy(physicalqubit)

        #perform physical gate
        apply!(physicalqubit1,physicalgate)
        #encode into logical state
        bufferqubits1 = one(Stabilizer,code_s(c))
        logicalqubit1 = physicalqubit1⊗bufferqubits1 
        for gate in encoding_circuit(c)
            apply!(logicalqubit1,gate)
        end
        

        #run 2
        #start same physical state
        physicalqubit2 = copy(physicalqubit)
        #encode logical state
        bufferqubits2 = one(Stabilizer,code_s(c))
        logicalqubit2 = physicalqubit2⊗bufferqubits2 
        for gate in encoding_circuit(c)
            apply!(logicalqubit2,gate)
        end
        #apply logical gate
        apply!(logicalqubit2,logicalgate)

        if canonicalize!(logicalqubit1) == canonicalize!(logicalqubit2) #ERROR codeSteane5() & sometimes Shor9
            println("test1 passed")
        else
            println("error test1")
            println("code",c)
            println("physical q",physicalqubit)
            println("logicalgate",logicalgate)
            println("physicalgate",physicalgate)
        end
       
        #physicalqubit
        encoding_circuit_physical = encoding_circuit(c)
        physicalqubit = S"X"
        apply!(physicalqubit,P"X")

        #logicalqubit
        encoding_circuit_logical = encoding_circuit(c)

        if c == Steane5()
            ancillary_qubit_count = 3
        elseif c == Steane7()
            ancillary_qubit_count = 4
        elseif c == Shor9()
            ancillary_qubit_count = 8
        elseif c == Bitflip3()
            ancillary_qubit_count = 2
        end

        

        bufferqubits = one(Stabilizer,ancillary_qubit_count)
        logicalqubit = physicalqubit⊗bufferqubits 
        for gate in encoding_circuit_logical
            apply!(logicalqubit,gate)
        end

        canonicalize!(logicalqubit)

        for gate in encoding_circuit(c)
            if encoding_circuit_physical == encoding_circuit_logical
                println("passed tst2")
            else
                println("error test2")
            end
        end

end

codes = [Shor9(),Steane5(),Steane7(),Bitflip3()]

for c in codes
    test_op(c)
end

#=
Error

error test1
codeSteane5()
physical q+ Y
logicalgate+ Z__ZX
physicalgate+ X

error test1
codeSteane5()
physical q- X
logicalgate+ Z__ZX
physicalgate+ X

error test1
codeSteane5()
physical q+ Y
logicalgate+ Z__ZX
physicalgate+ X

error test1
codeSteane5()
physical q+ Y
logicalgate+ Z__ZX
physicalgate+ X

error test1
codeSteane5()
physical q- Z
logicalgate+ Z__ZX
physicalgate+ X

error test1
codeSteane5()
physical q- Y
logicalgate+ Z__ZX
physicalgate+ X

error test1
codeSteane5()
physical q+ Z
logicalgate+ Z__ZX
physicalgate+ X

error test1
codeSteane5()
physical q- Z
logicalgate+ ZZZZZ
physicalgate+ Z

codeSteane5()
physical q+ Z
logicalgate+ Z__ZX
physicalgate+ X

codeShor9()
physical q+ X
logicalgate+ Z__Z____Z
physicalgate+ Z

codeShor9()
physical q- Z
logicalgate+ Z__Z____Z
physicalgate+ Z

codeShor9()
physical q+ Z
logicalgate+ ______XXX
physicalgate+ X
passed tst2

=#