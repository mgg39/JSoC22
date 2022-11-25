using QuantumClifford
using QuantumClifford.ECC: AbstractECC, Steane5, Steane7, Shor9, Bitflip3, naive_syndrome_circuit, encoding_circuit, code_n, parity_checks, encoding_circuit, code_s, code_k, rate, distance,logx_ops, logz_ops, isdegenerate

c = Shor9()
@show typeof(naive_syndrome_circuit(c))
@show typeof(encoding_circuit(c))
nc = naive_syndrome_circuit(c)
convert(Array{AbstractSymbolicOperator,1}, nc)
@show nc
convert(Vector{AbstractSymbolicOperator}, nc)
@show nc

codes = [Shor9()] #,Steane5(),Steane7(),Bitflip3()]

for c in codes
    #@show encoding_circuit(c)
    #@show naive_syndrome_circuit(c)

    #we need to run a qubit through the circuit and then check results
    physicalqubit = random_stabilizer(code_k(c))
    

    nc = naive_syndrome_circuit(c)
    convert(Vector{AbstractSymbolicOperator}, nc)

    for gate in nc
        try
            apply!(physicalqubit,gate)
        catch
            0
        end
    end

    @show(physicalqubit)
    @show canonicalize!(physicalqubit)
    @show(physicalqubit)
    
    for check in parity_checks(c)
        @show project!(physicalqubit,check)

    end
    
end
