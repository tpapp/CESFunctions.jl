"""
$(README)

# The API

$(EXPORTS)
"""
module CESFunctions

export CESProduction, output_quantity, output_price, input_demands

using ArgCheck: @argcheck
using DocStringExtensions: SIGNATURES, EXPORTS, README
using StaticArrays: SVector

"""
Argument type with statically known length. Used internally.
"""
const StaticN{N} = Union{NTuple{N},SVector{N}}

struct CESProduction{N,T}
    "elasticity of substitution"
    σ::T
    "share parameters, >0, sum to 1"
    A::NTuple{N,T}
    @doc """
    $(SIGNATURES)

    A constant elasticity of substitution production function of the form

    ```math
    Y = (A_1 X_2^{(σ-1)/σ} + A_2 X_2^{(σ-1)/σ} + ...)^{σ/(σ-1)}
    ```
    where ``σ``, the *elasticity of substitution*, is required to be positive.

    Alternative parametrizations use a substitution parameter ``ρ = (σ - 1)/σ``.

    Fields `σ` and `A` of the result are part of the public API.
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

CESProduction(σ, A::SVector) = CESProduction(σ, Tuple(A))

"""
$(SIGNATURES)

Calculate the output quantity from inputs (`Tuple` or `SVector`).
"""
function output_quantity(F::CESProduction{N}, inputs::StaticN{N}) where N
    (; σ, A) = F
    ρ = (σ - 1) / σ
    mapreduce((a, x) -> a * x^ρ, +, A, inputs)^(1/ρ)
end

"""
$(SIGNATURES)

Calculate the output price from input prices (`Tuple` or `SVector`).
"""
function output_price(F::CESProduction{N}, input_prices::StaticN{N}) where N
    (; σ, A) = F
    mapreduce((a, p) -> a^σ * p^(1-σ), +, A, input_prices)^(1/(1-σ))
end

"""
$(SIGNATURES)

Calculate the input demands from input prices (`Tuple` or `SVector`) and the output
quantity. The `output_price` can be provided for faster calculations, otherwise is
calculated.
"""
function input_demands(F::CESProduction{N}, input_prices::StaticN{N}, output_quantity::Real,
                       output_price::Real = output_price(F, input_prices)) where N
    (; σ, A) = F
    map((a, p) -> (output_price * a / p)^σ * output_quantity, A, input_prices)
end

end # module
