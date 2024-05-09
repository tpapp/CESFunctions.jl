"""
FIXME Placeholder for a short summary about CESFunctions.
"""
module CESFunctions

export CESProduction, output_quantity, output_price, input_demands

using ArgCheck: @argcheck
using DocStringExtensions: SIGNATURES

"""
NTuple with at least one element, having a total of `Nm1+1` elements.

This is a workaround for ambiguities with empty tuples.
"""
const NTuple1{Nm1,T} = Tuple{T,Vararg{T,Nm1}}

struct CESProduction{N,T}
    "elasticity of substitution"
    σ::T
    "share parameters, >0, sum to 1"
    A::NTuple{N,T}
    @doc """
    """
    function CESProduction(σ::T, A::NTuple{N,T}) where {N,T<:Real}
        @argcheck N > 0
        @argcheck all(a -> a > 0, A)
        @argcheck sum(A) ≈ 1
        @argcheck σ > 0
        new{N,T}(σ, A)
    end
end

function CESProduction(σ::Real, A::NTuple)
    σp, Ap... = promote(σ, A...)
    CESProduction(σp, Ap)
end

"""
$(SIGNATURES)
"""
function output_quantity(F::CESProduction{N}, inputs::NTuple1{Nm1,S}) where {N,Nm1,S<:Real}
    @argcheck N == Nm1 + 1 "Incompatible dimensions."
    (; σ, A) = F
    ρ = (σ - 1) / σ
    mapreduce((a, x) -> a * x^ρ, +, A, inputs)^(1/ρ)
end

"""
$(SIGNATURES)
"""
function output_price(F::CESProduction{N}, input_prices::NTuple1{Nm1,S}) where {N,Nm1,S<:Real}
    @argcheck N == Nm1 + 1 "Incompatible dimensions."
    (; σ, A) = F
    mapreduce((a, p) -> a^σ * p^(1-σ), +, A, input_prices)^(1/(1-σ))
end

"""
$(SIGNATURES)
"""
function input_demands(F::CESProduction{N}, input_prices::NTuple1{Nm1,S}, output_quantity::T1,
                       output_price::T2 = output_price(F, input_prices)) where {N,Nm1,S<:Real,T1<:Real,T2<:Real}
    @argcheck N == Nm1 + 1 "Incompatible dimensions."
    (; σ, A) = F
    map((a, p) -> (output_price * a / p)^σ * output_quantity, A, input_prices)
end

end # module
