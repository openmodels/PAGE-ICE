tests = ["ClimateTemperature","CH4cycle","CO2emissions","CH4emissions","CO2forcing","N2Oemissions","N2Oforcing","N2Ocycle", "TotalForcing"]

for t in tests
    fp = joinpath("test_$t.jl")
    println("$fp ...")
    include(fp)
end
