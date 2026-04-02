using Test

using Satisfiability

@testitem "decimal_string_to_rational" begin

    @testset "integers (no dot)" begin
        @test Satisfiability.decimal_string_to_rational("0")   == 0//1
        @test Satisfiability.decimal_string_to_rational("1")   == 1//1
        @test Satisfiability.decimal_string_to_rational("42")  == 42//1
        @test Satisfiability.decimal_string_to_rational("9999999999999999999999999999") ==
            Rational{BigInt}(BigInt("9999999999999999999999999999"))
    end

    @testset "simple decimals" begin
        @test Satisfiability.decimal_string_to_rational("0.5")   == 1//2
        @test Satisfiability.decimal_string_to_rational("0.1")   == 1//10
        @test Satisfiability.decimal_string_to_rational("0.25")  == 1//4
        @test Satisfiability.decimal_string_to_rational("1.5")   == 3//2
        @test Satisfiability.decimal_string_to_rational("9999.8888888888") ==
            parse(BigInt, "99998888888888") // parse(BigInt, "10000000000")
    end

    @testset "reduction to lowest terms" begin
        @test Satisfiability.decimal_string_to_rational("0.50")  == 1//2
        @test Satisfiability.decimal_string_to_rational("0.500") == 1//2
        @test Satisfiability.decimal_string_to_rational("2.0")   == 2//1
    end

    @testset "zero variants" begin
        @test Satisfiability.decimal_string_to_rational("0.0")   == 0//1
        @test Satisfiability.decimal_string_to_rational("0.00")  == 0//1
        @test Satisfiability.decimal_string_to_rational("0.0000000000000") == 0//1
    end

    @testset "long fractional part" begin
        # 1/3 ≈ 0.3333...3 (30 threes) — not exact, but reduction should work
        s = "0." * "3"^30
        r = Satisfiability.decimal_string_to_rational(s)
        @test denominator(r) <= BigInt(10)^30  # sanity: denom not blown up beyond input
        # exact: 1/7 = 0.142857142857142857142857142857 (30 digits)
        @test Satisfiability.decimal_string_to_rational("0.142857142857142857142857142857") ==
            parse(BigInt, "142857142857142857142857142857") //
            BigInt(10)^30
    end

    @testset "arbitrary length integer part" begin
        big = "9"^50 * ".1"
        r = Satisfiability.decimal_string_to_rational(big)
        @test numerator(r)   == parse(BigInt, "9"^50) * 10 + 1
        @test denominator(r) == 10
    end

end