@testitem "Real Rational" begin

    using Satisfiability

    @testset "Construct Int and Real expressions (Rational)" begin
        @satvariable(a, Int)
        @satvariable(b[1:2], Int)
        @satvariable(c[1:1,1:2], Int)

        @satvariable(ar, Real)
        @satvariable(br[1:2], Real)
        @satvariable(cr[1:1,1:2], Real)

        @satvariable(z, Bool)

        # convert(RealExpr, z): Rational{BigInt} version of line 16
        @test isequal(convert(RealExpr, z), ite(z, Rational{BigInt}(1//1), Rational{BigInt}(0//1)))

        # Real variable value assignment: Rational{BigInt} version of line 24
        ar.value = Rational{BigInt}(21//10); br[1].value = Rational{BigInt}(9//10)
        @test isequal((ar .> br)[1], BoolExpr(:gt, AbstractExpr[ar, br[1]], true, Satisfiability.__get_hash_name(:gt, [ar,br[1]])))
        @test isequal((ar .<= br)[1], BoolExpr(:leq, AbstractExpr[ar, br[1]], false, Satisfiability.__get_hash_name(:leq, [ar,br[1]])))

        # Construct with constants on RHS: Rational{BigInt} version of line 34
        @test isequal((cr .<= Rational{BigInt}(0//1))[1,1], cr[1,1] <= Rational{BigInt}(0//1))

        # Construct with constants on LHS: Rational{BigInt} version of line 40
        @test isequal((Rational{BigInt}(0//1) .<= c)[1,1], Rational{BigInt}(0//1) <= c[1,1])

        # distinct: Rational{BigInt} version of line 55
        @test isequal(distinct(ar, 2), distinct(ar, Rational{BigInt}(2//1)))
    end

    @testset "Construct n-ary ops (Rational)" begin
        @satvariable(a, Int)
        @satvariable(b[1:2], Int)
        @satvariable(ar, Real)
        @satvariable(br[1:2], Real)

        # Power with negative exponent: Rational{BigInt} version of line 71
        @test isequal(a^(-1), Rational{BigInt}(1//1)/to_real(a))

        # Power with negative exponent: Rational{BigInt} version of line 72
        @test isequal((Rational{BigInt}(1//1)/ar)*(Rational{BigInt}(1//1)/ar), ar^(-2))

        # Type promotion to RealExpr via Rational literal: Rational{BigInt} version of line 81
        children = [a, RealExpr(:const, AbstractExpr[], Rational{BigInt}(3//1), "const_3_d_1")]
        @test isequal(sum([Rational{BigInt}(1//1), a, true, 1]), RealExpr(:add, children, nothing, Satisfiability.__get_hash_name(:add, children, is_commutative=true)))

        # Type promotion to RealExpr via Rational literal with two expr operands: Rational{BigInt} version of line 88
        children = [to_real(a), to_real(b[1]), RealExpr(:const, AbstractExpr[], Rational{BigInt}(2//1), "const_2_d_1")]
        @test isequal(sum([a, Rational{BigInt}(1//1), 1, false, b[1]]), RealExpr(:add, children, nothing, Satisfiability.__get_hash_name(:add, children, is_commutative=true)))

        # Division children: Rational{BigInt} version of line 95
        @test all(isequal.((ar/Rational{BigInt}(3//1)).children, [ar, RealExpr(:const, AbstractExpr[], Rational{BigInt}(3//1), "const_3_d_1")]))

        # div/mod type coercion: Rational{BigInt} versions of lines 98-102
        @test isequal(div(Rational{BigInt}(2//1), ar), div(2, to_int(ar)))
        @test isequal(div(ar, Rational{BigInt}(2//1)), div(to_int(ar), 2))
        @test isequal(mod(ar, Rational{BigInt}(3//1)), mod(to_int(ar), 3))
        @test isequal(mod(Rational{BigInt}(3//1), ar), mod(3, to_int(ar)))
        @test isequal(a/2, to_real(a)/Rational{BigInt}(2//1))

        # abs rewrites to ite: Rational{BigInt} version of line 107
        @satvariable(z, Bool)
        @test isequal(abs(ar), ite(ar >= Rational{BigInt}(0//1), ar, -ar))
    end

    @testset "Assignment and conversion (Rational)" begin
        @satvariable(aR, Real)
        @satvariable(a, Int)

        # Dict assignment with Rational{BigInt}: Rational{BigInt} version of line 113
        d = Dict("aR" => Rational{BigInt}(1//1), "a"=>-1)
        e1 = aR + a <= 0 # this should promote to real
        e2 = to_int(aR) + a <= 0 # this should be int
        assign!(e1, d)
        assign!(e2, d)
        @test(isa(value(to_real(a)), Rational{BigInt}) && value(to_real(a)) == -1)
        @test(isa(value(to_int(aR)), Integer) && value(to_int(aR)) == 1)
    end
end
