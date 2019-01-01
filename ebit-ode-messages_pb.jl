# syntax: proto2
using Compat
using ProtoBuf
import ProtoBuf.meta

struct __enum_Status <: ProtoEnum
    Idle::Int32
    SolivingODEInProgress::Int32
    __enum_Status() = new(0,1)
end #struct __enum_Status
const Status = __enum_Status()

struct __enum_ProblemType <: ProtoEnum
    ODEProblem::Int32
    __enum_ProblemType() = new(0)
end #struct __enum_ProblemType
const ProblemType = __enum_ProblemType()

struct __enum_ReturnCode <: ProtoEnum
    Default::Int32
    Success::Int32
    MaxIters::Int32
    DtLessThanMin::Int32
    Unstable::Int32
    InitialFailure::Int32
    ConvergenceFailure::Int32
    Failure::Int32
    __enum_ReturnCode() = new(0,1,2,3,4,5,6,7)
end #struct __enum_ReturnCode
const ReturnCode = __enum_ReturnCode()

struct __enum_MessageType <: ProtoEnum
    SolveODE::Int32
    ODEResult::Int32
    StatusUpdate::Int32
    StopServer::Int32
    Error::Int32
    __enum_MessageType() = new(1,2,3,4,5)
end #struct __enum_MessageType
const MessageType = __enum_MessageType()

mutable struct Nuclide <: ProtoType
    A::UInt32
    Z::UInt32
    q::UInt32
    i::UInt32
    Nuclide(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Nuclide
const __req_Nuclide = Symbol[:A,:Z,:q,:i]
meta(t::Type{Nuclide}) = meta(t, __req_Nuclide, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct MatrixValue <: ProtoType
    value::Float64
    row::UInt32
    column::UInt32
    MatrixValue(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct MatrixValue
const __req_MatrixValue = Symbol[:value,:row,:column]
meta(t::Type{MatrixValue}) = meta(t, __req_MatrixValue, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Update <: ProtoType
    status::Int32
    message::AbstractString
    Update(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Update
const __req_Update = Symbol[:status,:message]
meta(t::Type{Update}) = meta(t, __req_Update, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Progress <: ProtoType
    time::Float64
    Progress(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Progress
const __req_Progress = Symbol[:time]
meta(t::Type{Progress}) = meta(t, __req_Progress, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct TimeSpan <: ProtoType
    start::Float64
    stop::Float64
    TimeSpan(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct TimeSpan
const __req_TimeSpan = Symbol[:start,:stop]
meta(t::Type{TimeSpan}) = meta(t, __req_TimeSpan, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct InitialValue <: ProtoType
    index::UInt32
    number_of_particles::Float64
    temperature_in_ev::Float64
    InitialValue(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct InitialValue
const __req_InitialValue = Symbol[:index,:number_of_particles,:temperature_in_ev]
meta(t::Type{InitialValue}) = meta(t, __req_InitialValue, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct DiffEqParameters <: ProtoType
    qVe::Base.Vector{Float64}
    qVt::Base.Vector{Float64}
    mass_number::Base.Vector{Float64}
    spitzer_divided_by_overlap::Base.Vector{Float64}
    q::Base.Vector{Float64}
    inverted_collision_constant::Base.Vector{MatrixValue}
    dCharge_ex_divided_by_N_times_tau::Base.Vector{MatrixValue}
    rate_of_change_divided_by_N::Base.Vector{MatrixValue}
    no_dimensions::UInt32
    V_0::Float64
    r_e::Float64
    r_dt::Float64
    l_dt::Float64
    initial_values::Base.Vector{InitialValue}
    initial_temperature::Float64
    minimum_N::Float64
    source_terms_n::Base.Vector{Float64}
    source_terms_kt::Base.Vector{Float64}
    DiffEqParameters(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct DiffEqParameters
const __req_DiffEqParameters = Symbol[:no_dimensions,:V_0,:r_e,:r_dt,:l_dt,:initial_temperature,:minimum_N]
const __fnum_DiffEqParameters = Int[1,2,3,4,15,6,7,8,9,16,17,18,19,10,11,12,13,14]
meta(t::Type{DiffEqParameters}) = meta(t, __req_DiffEqParameters, __fnum_DiffEqParameters, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct ProblemParameters <: ProtoType
    problem_type::Int32
    time_span::TimeSpan
    ProblemParameters(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct ProblemParameters
const __req_ProblemParameters = Symbol[:problem_type,:time_span]
meta(t::Type{ProblemParameters}) = meta(t, __req_ProblemParameters, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct SolverParameters <: ProtoType
    saveat::Base.Vector{Float64}
    SolverParameters(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct SolverParameters

mutable struct SolveODEProblem <: ProtoType
    nuclides::Base.Vector{Nuclide}
    problem_parameters::ProblemParameters
    diff_eq_parameters::DiffEqParameters
    solver_parameters::SolverParameters
    SolveODEProblem(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct SolveODEProblem
const __req_SolveODEProblem = Symbol[:problem_parameters,:diff_eq_parameters,:solver_parameters]
meta(t::Type{SolveODEProblem}) = meta(t, __req_SolveODEProblem, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct ValuesPerNuclide <: ProtoType
    nuclide::Nuclide
    values::Base.Vector{Float64}
    ValuesPerNuclide(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct ValuesPerNuclide
const __req_ValuesPerNuclide = Symbol[:nuclide]
meta(t::Type{ValuesPerNuclide}) = meta(t, __req_ValuesPerNuclide, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Result <: ProtoType
    problem::SolveODEProblem
    return_code::Int32
    start_time::Float64
    stop_time::Float64
    times::Base.Vector{Float64}
    n::Base.Vector{ValuesPerNuclide}
    kT::Base.Vector{ValuesPerNuclide}
    Result(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Result
const __req_Result = Symbol[:problem,:return_code,:start_time,:stop_time]
meta(t::Type{Result}) = meta(t, __req_Result, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct ErrorEncountered <: ProtoType
    msg::AbstractString
    ErrorEncountered(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct ErrorEncountered
const __req_ErrorEncountered = Symbol[:msg]
meta(t::Type{ErrorEncountered}) = meta(t, __req_ErrorEncountered, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Message <: ProtoType
    msg_type::Int32
    ode_problem::SolveODEProblem
    ode_result::Result
    status::Int32
    err::ErrorEncountered
    progress::Progress
    Message(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Message
const __req_Message = Symbol[:msg_type]
meta(t::Type{Message}) = meta(t, __req_Message, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

export Status, ProblemType, ReturnCode, MessageType, Nuclide, MatrixValue, Update, Progress, TimeSpan, InitialValue, DiffEqParameters, ProblemParameters, SolverParameters, SolveODEProblem, ValuesPerNuclide, Result, ErrorEncountered, Message
