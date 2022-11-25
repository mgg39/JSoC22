using QuantumClifford
using QuantumClifford.ECC: AbstractECC, Steane5, Steane7, Shor9, Bitflip3, naive_syndrome_circuit, code_n, parity_checks, encoding_circuit, code_s, code_k, rate, distance,logx_ops, logz_ops, isdegenerate

function test_ns(c::AbstractECC)

    #println(c)
    #initiate physical qubit
    physicalqubit = random_stabilizer(code_k(c))
    #println(physicalqubit)
    #obtain syndrome circuit
    nc = naive_syndrome_circuit(c)
    convert(Vector{AbstractSymbolicOperator}, nc)

    s = []
    for check in parity_checks(c)
        append!(s,project!(physicalqubit,check))
    end

    i = 1

    for gate in nc
        try
            
            apply!(physicalqubit,gate)

            a = s[i]
            
            b = canonicalize!(physicalqubit)
            project!(b,check)

            if a != NaN && b != NaN #not testing atm
                if a == b
                    println("I work")
                else
                    println("Error")
                    println(a)
                    println(b)
                end
            end
            
                    
        catch
                0
        end
        i+= 1 
    end

    
end
   
test_ns(Steane5())

#=
codes = [Steane5(),Steane7(),Shor9()]
    
for c in codes
    test_ns(c)
end
=#