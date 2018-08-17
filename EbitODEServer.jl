module EbitODEServer

using EbitSolver
using EbitODE
using MicroLogging
using ProtoBuf

function create_proto_msg(buffer)
    @info "Creating EbitODE.Message() from buffer"
    return readproto(PipeBuffer(buffer), EbitODE.Message())
end


function create_proto_err_msg(msg::AbstractString)
    return EbitODE.Message(MsgType=EbitODE.MessageType.Error, 
                           err = EbitODE.ErrorEncountered(msg=msg))
end

function read_msg_from_stream(socket::IO)
    read_no_bytes = read(socket, UInt32)
    @info "Read message size: $read_no_bytes bytes"
    buffer = read(socket, read_no_bytes)
    msg = create_proto_msg(buffer)
    @info "Read message buffer and created Message"
    return msg
end    


function process(msg::EbitODE.Message)
    try 
        if msg.MsgType == EbitODE.MessageType.SolveODE
            ret = EbitSolver.solve_ode(msg.ODEProblem)
            return ret
        end
        return create_proto_err_msg("Unable to handle msg type: $msg.MsgType")
    catch e
        @warn "Catched exception" e
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

function start_ode_server(port)
    return @async begin
        server = listen(port)
        try while true
            socket = accept(server)
            @info "Accepting connection on port: $port"
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



end
