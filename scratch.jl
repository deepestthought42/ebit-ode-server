push!(LOAD_PATH, "/home/renee/phd/src/charge-distribution.project/ebit-ode-server/")

using ProtoBuf
using EbitODE
using EbitSolver
# using Sockets
using MicroLogging


function create_proto_msg(buffer)
    @info "Creating EbitODE.Message() from buffer"
    return readproto(PipeBuffer(buffer), EbitODE.Message())
end


function create_proto_err_msg(msg)
    return EbitODE.Message(MsgType=EbitODE.MessageType.Error, 
                           err = EbitODE.ErrorEncountered(msg=msg))
end

function read_msg_from_stream(socket)
    read_no_bytes = read(socket, UInt32)
    @info "Read message size: $read_no_bytes bytes"
    buffer = read(socket, read_no_bytes)
    msg = create_proto_msg(buffer)
    @info "Read message buffer and created Message"
    return msg
end    


function process(msg)
    try 
        if msg.MsgType == EbitODE.MessageType.SolveODE
            ret = EbitSolver.solveODE(msg.ODEProblem)
            return ret
        end
        return create_proto_err_msg("Unable to handle msg type: $msg.MsgType")
    catch e 
        return create_proto_err_msg("exception: $e")
    end
end

function send_proto_msg_to_stream(message, socket)
    iob = PipeBuffer()
    @info "Created buffer"
    len = writeproto(iob, message)
    @info "Writing return size: $len"
    write(socket, convert(UInt32, len))
    @info "Writing message"
    write(socket, iob)
    @info "Written message"
end

function createStartListeningServer(port)
    return @async begin
        server = listen(port)
        try while true 
            socket = accept(server)
            @async while isopen(socket)
                try 
                    msg = read_msg_from_stream(socket)
                    ret_val = process(msg)
                    send_proto_msg_to_stream(ret_val, socket)
                catch e
                    @warn "Caught exception" e
                end
            end
        end
        catch e 
            @info "Caught exception" e 
        end
    end
end

