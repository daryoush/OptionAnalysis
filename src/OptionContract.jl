using Dates
import  Base: *,+, -, convert

@enum OptType CALL PUT

function parseOption(a::Array{String,1})
	parseOption.(a)
end
#Examples
# parseOption( "TSLA220617C00106000")
# parseOption( "GME_022621P3.5")

function parseOption(s::String)::Tuple{OptType, String, Date,Float64,String}
	# try yahoo syntax, if failed try td ameritrade
	yahooregex=r"^(?<sym>[A-Z]+)(?<year>\d{2})(?<month>\d{2})(?<day>\d{2})(?<pc>[P|C])(?<strike>\d{8})"   ### Use named groups, do an or of yahoo and td ameritrade syntax with same named groups
	tdAmeritradeRegEx = r"^(?<sym>[A-Z]+)_(?<month>\d{2})(?<day>\d{2})(?<year>\d{2})(?<pc>[P|C])(?<strike>\d*\.?\d*)"

	m=match(yahooregex, s)
	local strike
	if m != nothing
		strike=parse(Float32, m["strike"])/1000
	else
		m=match(tdAmeritradeRegEx, s)
		m == nothing && error("Failed to parse ", s, " as yahoo or tdAmeritrade option symbol")
		strike =parse(Float32, m["strike"])
	end
	name=m["sym"]
	dt=Date(2000+parse(Int,m["year"]),parse(Int, m["month"]),parse(Int,m["day"]))
	type = m["pc"] == "C" ? CALL : PUT
	(type, name, dt, strike , s)
end


struct Option{T}
	type::OptType   # call or put
	name::String
	expdate::Date
	strike::Float64
	symbol::T

end


Option(s::String)=Option(parseOption(s)...)

# list of option names to list of Options
function Option(a::Array{String,1})
	Option.(a)
end

struct opContract
	os::Array{Tuple{Int, Option}}
end

opContract(c,o)=opContract([(c,o)])

optionSymbolsInContract(oc) =  [o.name for (o,c) in oc]

function *(c::Int,o::Option)
    opContract(c,o)
end

function *(d::Int,x::opContract)
	z=[(d*c, o) for (c,o) in x.os]
    opContract([z...])
end

function +(x::opContract, y::opContract)
    opContract([x.os...  y.os...])
end

function -(x::opContract, y::opContract)
	z=[(-c, o) for (c,o) in y.os]
    opContract([x.os...  z...])
end

function +(x::Option, y::Option)
    opContract([(1,x)  (1,y)])
end

function -(x::Option, y::Option)
    opContract([(1,x)  (-1,y)])
end

function +(x::Option, y::opContract)
    opContract([(1,x)  y.os...])
end


function +(y::opContract, x::Option, )
    opContract([(1,x)  y.os...])
end
function -(x::Option, y::opContract)
	z=[(-c, o) for (c,o) in y.os]
    opContract([(1,x)  z...])
end

function -(y::opContract, x::Option)
    opContract([(-1,x)  y.os...])
end



#bwb("AMZN", 3380.,3400.,3450., Date("2021-10-15"), CALL)

function option( s::String, k::Float64, dt::Date, t::OptType=CALL)
	Option(t, s, dt, k, "OPTSYM-TBD")
end


function call( s::String, k::Float64, dt::Date)
	option(s,k,dt, CALL)
end

function put( s::String, k::Float64, dt::Date)
	option(s,k,dt, PUT)
end

function bwb(s::String, l::Float64, m::Float64, r::Float64, dt::Date, t::OptType=CALL ) 
	left=Option(t, s, dt, l , "OPTSYM-TBD")
	middle=Option(t, s, dt, m , "OPTSYM-TBD")
	right=Option(t, s, dt, r , "OPTSYM-TBD")
	left -2* middle + right
end
# vertical("AMZN",3400.,3450., Date("2021-10-15"), CALL)
function vertical(s::String, l::Float64,  r::Float64, dt::Date, t::OptType=CALL ) 
	left=Option(t, s, dt, l , "OPTSYM-TBD")
	right=Option(t, s, dt, r , "OPTSYM-TBD")
	left - right
end

# 764 10/11/21 BOT 4 AMZN October 15, 2021 15 Oct 3380/3400/3450 call bwb (0.14) $56.00) bwb for small credit setting up adjustment for larger gain later
# 764 10/12/21 BOT 4 AMZN October 15, 2021 15 Oct 3380/3400/3450 call bwb 0.00) $0.00) added four more units at even money
# 764 10/13/21 SLD 2 AMZN October 15, 2021 15 Oct 3400/3450 call vert (0.60) $120.00)
#print(4 * bwb("AMZN", 3380.,3400.,3450., Date("2021-10-15"), CALL) - 2 * vertical("AMZN",3400.,3450., Date("2021-10-15"), CALL))



# todo Unit test and verification

# # Some code to make sure the module works before its included
# Option("TSLA220617C00106000")  # test option parse
# #local x::Option{AbstractString} ="TSLA220617C00106000"   ## convert
# oc1=2*Option("TSLA220617C00106000")  # test option parse
# oc2=-2*Option("TSLA220617C00200000")  # test option parse

# oc1+oc2
# Option("TSLA220617C00106000") + 2*Option("TSLA220617C00106000")
# Option("TSLA220617C00106000") - 2*Option("TSLA220617C00106000")

# oc1-oc2
