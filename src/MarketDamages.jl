include("load_parameters.jl")

@defcomp MarketDamages begin
    region = Index(region)

    y_year = Parameter(index=[time], unit="year")

    #incoming parameters from Climate
    rt_realizedtemperature = Parameter(index=[time, region], unit="degreeC")

    #tolerability parameters
    plateau_increaseintolerableplateaufromadaptation = Parameter(index=[region], unit="degreeC")
    pstart_startdateofadaptpolicy = Parameter(index=[region], unit="year")
    pyears_yearstilfulleffect = Parameter(index=[region], unit="year")
    impred_eventualpercentreduction = Parameter(index=[region], unit= "%")
    impmax_maxtempriseforadaptpolicy = Parameter(index=[region], unit= "degreeC")
    istart_startdate = Parameter(index=[region], unit = "year")
    iyears_yearstilfulleffect = Parameter(index=[region], unit= "year")

    #tolerability variables
    atl_adjustedtolerableleveloftemprise = Variable(index=[time,region], unit="degreeC")
    imp_actualreduction = Variable(index=[time, region], unit= "%")
    i_regionalimpact = Variable(index=[time, region], unit="degreeC")

end

function run_timestep(s::MarketDamages, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        #calculate tolerability
        if (p.y_year[t] - p.pstart_startdateofadaptpolicy[r]) < 0
            v.atl_adjustedtolerableleveloftemprise[t,r]= 0
        elseif ((p.y_year[t]-p.pstart_startdateofadaptpolicy[r])/p.pyears_yearstilfulleffect[r])<1.
            v.atl_adjustedtolerableleveloftemprise[t,r]=
                ((p.y_year[t]-p.pstart_startdateofadaptpolicy[r])/p.pyears_yearstilfulleffect[r]) *
                p.plateau_increaseintolerableplateaufromadaptation[r]
        else
            p.plateau_increaseintolerableplateaufromadaptation[r]
        end

        if (p.y_year[t]- p.istart_startdate[r]) < 0
            v.imp_actualreduction[t,r] = 0
        elseif ((p.y_year[t]-istart_a[r])/iyears_a[r]) < 1
            v.imp_actualreduction[t,r] =
                (p.y_year[t]-p.istart_startdate[r])/p.iyears_yearstilfulleffect[r]*
                p.impred_eventualpercentreduction[r]
        else
            v.imp_actualreduction[t,r] = p.impred_eventualpercentreduction[r]
        end
        if (p.rt_realizedtemperature[t,r]-v.atl_adjustedtolerableleveloftemprise[t,r]) < 0
            v.i_regionalimpact[t,r] = 0
        else
            v.i_regionalimpact[t,r] = p.rt_realizedtemperature[t,r]-v.atl_adjustedtolerableleveloftemprise[t,r]
        end
    end


end

function addmarketdamages(model::Model)
    tolerabilitymarketcomp = addcomponent(model, Tolerability, :MarketTolerability)

    tolerabilitymarketcomp[:plateau_increaseintolerableplateaufromadaptation] = readpagedata(model, "../data/market_plateau.csv")
    tolerabilitymarketcomp[:pstart_startdateofadaptpolicy] = readpagedata(model, "../data/marketadaptstart.csv")
    tolerabilitymarketcomp[:pyears_yearstilfulleffect] = readpagedata(model, "../data/marketadapttimetoeffect.csv")
    tolerabilitymarketcomp[:impred_eventualpercentreduction] = readpagedata(model, "../data/marketimpactreduction.csv")
    tolerabilitymarketcomp[:impmax_maxtempriseforadaptpolicy] = readpagedata(model, "../data/marketmaxtemprise.csv")
    tolerabilitymarketcomp[:istart_startdate] = readpagedata(model, "../data/marketadaptstart.csv")
    tolerabilitymarketcomp[:iyears_yearstilfulleffect] = readpagedata(model, "../data/marketimpactyearstoeffect.csv")

    return tolerabilitymarketcomp
end
