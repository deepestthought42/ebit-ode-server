module EbitODEServer

export start_ode_server
using Sockets
using Main.EbitSolver
using Main.EbitODEMessages
using ProtoBuf

function create_proto_msg(buffer)
    @debug "Creating EbitODEMessages.Message() from buffer"
    return readproto(PipeBuffer(buffer), EbitODEMessages.Message())
end


function create_proto_err_msg(msg::AbstractString)
    return EbitODEMessages.Message(msg_type=EbitODEMessages.MessageType.Error, 
                                   err = EbitODEMessages.ErrorEncountered(msg=msg))
end

function read_msg_from_stream(socket::IO)
    read_no_bytes = read(socket, UInt32)
    @debug "Read message size: $read_no_bytes bytes"
    buffer = read(socket, read_no_bytes)
    msg = create_proto_msg(buffer)
    @debug "Read message buffer and created Message"
    return msg
end    


function process(msg::EbitODEMessages.Message, report_progress)
    try 
        if msg.msg_type == EbitODEMessages.MessageType.SolveODE
            ret = EbitSolver.solve_ode(msg.ode_problem, report_progress)
            return ret
        end
        return create_proto_err_msg("Unable to handle msg type: $msg.msg_type")
    catch e
        @warn "Catched exception" e
        return create_proto_err_msg("exception: $e")
    end
end

function send_proto_msg_to_stream(message, socket)
    iob = PipeBuffer()
    @debug "Created buffer"
    len = writeproto(iob, message)
    @debug "Writing return size: $len"
    write(socket, convert(UInt32, len))
    @debug "Writing message"
    write(socket, iob)
    @debug "Written message"
end



server = Sockets.TCPServer()

function ode_bind_server(port)
    global server
    if ( server.status == Base.StatusActive 
         || server.status == Base.StatusOpen 
         || server.status == Base.StatusConnecting )
        close(server)
    end        
    new_server = Sockets.TCPServer()
    
    !bind(new_server, IPv4(UInt(0)), port) && error("cannot bind to port; may already be in use or access denied")
    global server = new_server
end


progress_message = EbitODEMessages.Message(msg_type=EbitODEMessages.MessageType.StatusUpdate, 
                                           status = EbitODEMessages.Status.SolivingODEInProgress,
                                           progress = EbitODEMessages.Progress(time = 0.0))



function send_progress(socket, t, abort)
    progress_message.progress.time = t
    send_proto_msg_to_stream(progress_message, socket)
    return abort()
end



@noinline function start_ode_server(port=2000)
    ode_bind_server(port)
    listen(server)
    @info "Created server" port
    try
        while true
            socket = accept(server)
            @info "Accepting connection on port: $port"
            @async while isopen(socket)
                try
                    abort = false
                    msg = read_msg_from_stream(socket)
                    
                    @async while isopen(socket)
                        msg = read_msg_from_stream(socket)
                        if (msg.msg_type == EbitODEMessages.MessageType.StopServer)
                            abort = true
                        end
                    end
                    
                    ret_val = process(msg, t -> send_progress(socket, t, () -> abort))
                    send_proto_msg_to_stream(ret_val, socket)
                catch e
                    if isa(e, EOFError)
                        nothing
                    else
                        @warn "Caught exception" e
                    end
                end
            end
        end
    catch e 
        @debug "Caught exception" e 
    end
    @debug "Closing EbitODEServer on port $port"
end

function async_server_start(port=2000)
    @async start_ode_server(port)
    return server
end


function restart(port=2000)
    include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitSolver.jl")
    include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitODEServer.jl")
    close(server)
    EbitODEServer.async_server_start(port)
end



end
