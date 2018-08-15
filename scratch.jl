using ProtoBuf
using EbitODE

EbitSolver.writeResult(EbitSolver.solveODE(readproto(PipeBuffer(read("/home/renee/tmp/test2.serialize")), 
                                                     EbitODE.Problem())),
            "/home/renee/tmp/test4.serialized")


iob = PipeBuffer()
prob = readproto(PipeBuffer(read("/home/renee/tmp/test2.serialize")), EbitODE.Problem())
writeproto(iob, prob)
f = open("/home/renee/tmp/test6.serialize","w")
write(f, iob)
flush(f)

# plot(sol.t, transpose(convert(Array{Float64,2}, VectorOfArray(sol.u)))


