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

mutable struct Index <: ProtoType
    A::Int32
    Z::Int32
    q::Int32
    i::Int32
    Index(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Index
const __req_Index = Symbol[:A,:Z,:q,:i]
meta(t::Type{Index}) = meta(t, __req_Index, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Rate <: ProtoType
    RateInHz::Float64
    Description::AbstractString
    origin::Index
    destination::Index
    Rate(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Rate
const __req_Rate = Symbol[:RateInHz,:Description,:origin,:destination]
meta(t::Type{Rate}) = meta(t, __req_Rate, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct RateList <: ProtoType
    rates::Base.Vector{Rate}
    dimension::Int32
    RateList(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct RateList
const __req_RateList = Symbol[:dimension]
meta(t::Type{RateList}) = meta(t, __req_RateList, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Update <: ProtoType
    status::Int32
    Message::AbstractString
    Update(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Update
const __req_Update = Symbol[:status,:Message]
meta(t::Type{Update}) = meta(t, __req_Update, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct ProblemConfiguration <: ProtoType
    ProblemConfiguration(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct ProblemConfiguration

mutable struct TimeSpan <: ProtoType
    start::Float64
    stop::Float64
    TimeSpan(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct TimeSpan
const __req_TimeSpan = Symbol[:start,:stop]
meta(t::Type{TimeSpan}) = meta(t, __req_TimeSpan, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct InitialPopulation <: ProtoType
    index::Index
    value::Float64
    InitialPopulation(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct InitialPopulation
const __req_InitialPopulation = Symbol[:index,:value]
meta(t::Type{InitialPopulation}) = meta(t, __req_InitialPopulation, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Problem <: ProtoType
    problem_type::Int32
    time_span::TimeSpan
    rate_list::RateList
    initial_values::Base.Vector{Float64}
    saveat::Base.Vector{Float64}
    config::ProblemConfiguration
    indices::Base.Vector{Index}
    initial_population::Base.Vector{InitialPopulation}
    Problem(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Problem
const __req_Problem = Symbol[:problem_type,:time_span,:rate_list,:config]
meta(t::Type{Problem}) = meta(t, __req_Problem, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct ValuesPerIndex <: ProtoType
    index::Index
    values::Base.Vector{Float64}
    ValuesPerIndex(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct ValuesPerIndex
const __req_ValuesPerIndex = Symbol[:index]
meta(t::Type{ValuesPerIndex}) = meta(t, __req_ValuesPerIndex, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Result <: ProtoType
    problem::Problem
    return_code::Int32
    start_time::Float64
    stop_time::Float64
    times::Base.Vector{Float64}
    values::Base.Vector{ValuesPerIndex}
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
    MsgType::Int32
    ODEProblem::Problem
    ODEResult::Result
    status::Int32
    err::ErrorEncountered
    Message(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Message
const __req_Message = Symbol[:MsgType]
meta(t::Type{Message}) = meta(t, __req_Message, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

export Status, ProblemType, ReturnCode, MessageType, Index, Rate, RateList, Update, ProblemConfiguration, TimeSpan, InitialPopulation, Problem, ValuesPerIndex, Result, ErrorEncountered, Message
