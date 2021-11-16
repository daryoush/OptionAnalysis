
using StatsFuns
using Measurements

include("OptionContract.jl")

standardConfig = Dict(:daysInYear => 252,  :r => .001)
fullYearConfig = Dict(:daysInYear => 365,  :r => .001)



function d1d2( strike, spot, iv, dtoexp, cfg=standardConfig)
	τ=dtoexp /cfg[:daysInYear]
	a = iv * sqrt(τ)
	d1=(log(spot/strike) + (cfg[:r] + .5*iv^2)*τ)/a
	d2 = d1 - a
	erfτ=exp(-cfg[:r] * τ)
	d1, d2, dtoexp, τ, erfτ, a
end


# Simple Test for now, TODO: write a unit test!

# (906.5052286309792, 0.5354032748728236, 0.42342218974397755, 0.00016432306961839755, 14.230454544352018, -10.911808231390165)
#@show greeks(8700.,8572.,.6750, 44., CALL )
# (944.8682997022215, -0.4307189572858482, -0.5456042252022355, 0.00015849621213688658, 14.07153393862377, -11.06159311981074)
#@show greeks(8500.,8572.,.6920, 44., PUT  )

function greeks(strike, spot, iv,timeToExpInDays=7, type::OptType=CALL, cfg=standardConfig)
 	d1,d2, days, τ, erfτ,a = d1d2(strike,spot,iv,timeToExpInDays, cfg)
	Nd1=normcdf(d1)
	Nd2=normcdf(d2)
	Nd_1=normcdf(-d1)
	Nd_2=normcdf(-d2)
	nd1=normpdf(d1)
	if type == CALL
		p=(spot * Nd1 - strike*erfτ*Nd2)
		del=erfτ*Nd1
		del2=erfτ*Nd2
	elseif type == PUT
		p=-spot*Nd_1 +strike*erfτ* Nd_2
		del=-erfτ*Nd_1
		del2=-erfτ*Nd_2
	else  throw("invalid type")
	end
	gamma=erfτ *nd1 / (spot*a)
	vega=spot * erfτ *sqrt(τ)*nd1 /100
	yearθ = cfg[:r]*p - .5 * gamma* spot^2 * iv^2
	theta=yearθ/cfg[:daysInYear]

	p, del, del2, gamma, vega, theta
end


# greeks for a single option


function greeks(o::Option, d::DateTime = now())
	#TODO: subtract d from exp date then use the time as daysToExp in call to greeks
end

#greeks(Option("TSLA220617C00106000"), 100., .54, 10.)
function greeks(o::Option, spot, iv, daysToExp)
	greeks(o.strike, spot,iv,daysToExp, o.type)
end




# oc1=2*Option("TSLA220617C00106000")  # test option parse
# oc2=-2*Option("TSLA220617C00120000")  # test option parse
# greeks(x, 100., .54, 10.)
# assume all options have same greeks.
# TODO:  make iv to be a function of spot and time to exp to capture smile
function greeks( x::opContract , spot, iv,  daysToExp)
	sum([c .* [greeks(o, spot, iv, daysToExp)...] for (c, o) in x.os], dims=2)[1]
end


function dollarGamma( x::opContract , spot, iv,  daysToExp)
		.01 * spot^2 * greeks(x,spot,iv,daysToExp )[4]
end

# # 764 10/11/21 BOT 4 AMZN October 15, 2021 15 Oct 3380/3400/3450 call bwb (0.14) $56.00) bwb for small credit setting up adjustment for larger gain later
# # 764 10/12/21 BOT 4 AMZN October 15, 2021 15 Oct 3380/3400/3450 call bwb 0.00) $0.00) added four more units at even money
# # 764 10/13/21 SLD 2 AMZN October 15, 2021 15 Oct 3400/3450 call vert (0.60) $120.00)
#x=greeks(4 * butterfly("AMZN", 3380.,3400.,3450., Date("2021-10-15"), CALL) - 2 * vertical("AMZN",3400.,3450., Date("2021-10-15"), CALL),
 #   3400., .55, 2.)


#d1d2(100., 120., .5, 5.)

# dollarGamma(4 * butterfly("AMZN", 3380.,3400.,3450., Date("2021-10-15"), CALL) - 2 * vertical("AMZN",3400.,3450., Date("2021-10-15"), CALL),
#     3400., .55, .05)