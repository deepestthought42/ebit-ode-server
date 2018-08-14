# syntax: proto3
using Compat
using ProtoBuf
import ProtoBuf.meta

struct __enum_Status <: ProtoEnum
    Idle::Int32
    SolivingODE::Int32
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

mutable struct Index <: ProtoType
    A::Int32
    Z::Int32
    q::Int32
    i::Int32
    Index(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Index

mutable struct Rate <: ProtoType
    RateInHz::Float64
    Description::AbstractString
    origin::Index
    destination::Index
    Rate(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Rate

mutable struct RateList <: ProtoType
    rates::Base.Vector{Rate}
    dimension::Int32
    RateList(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct RateList

mutable struct Update <: ProtoType
    status::Int32
    Message::AbstractString
    Update(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Update

mutable struct ProblemConfiguration <: ProtoType
    ProblemConfiguration(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct ProblemConfiguration

mutable struct TimeSpan <: ProtoType
    start::Float64
    _end::Float64
    TimeSpan(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct TimeSpan

mutable struct Problem <: ProtoType
    problem_type::Int32
    time_span::TimeSpan
    rate_list::RateList
    initial_values::Base.Vector{Float64}
    saveat::Base.Vector{Float64}
    config::ProblemConfiguration
    Problem(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Problem
const __pack_Problem = Symbol[:initial_values,:saveat]
meta(t::Type{Problem}) = meta(t, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, __pack_Problem, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct ValuesAtTime <: ProtoType
    time::Float64
    values::Base.Vector{Float64}
    ValuesAtTime(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct ValuesAtTime
const __pack_ValuesAtTime = Symbol[:values]
meta(t::Type{ValuesAtTime}) = meta(t, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, __pack_ValuesAtTime, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

mutable struct Result <: ProtoType
    problem::Problem
    return_code::Int32
    start_time::Float64
    stop_time::Float64
    times::Base.Vector{Float64}
    values::Base.Vector{ValuesAtTime}
    Result(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Result
const __pack_Result = Symbol[:times]
meta(t::Type{Result}) = meta(t, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, true, __pack_Result, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES, ProtoBuf.DEF_FIELD_TYPES)

export Status, ProblemType, ReturnCode, Index, Rate, RateList, Update, ProblemConfiguration, TimeSpan, Problem, ValuesAtTime, Result
