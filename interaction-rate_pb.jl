# syntax: proto3
using Compat
using ProtoBuf
import ProtoBuf.meta

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

export Index, Rate, RateList
