### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ de55f4a6-441f-11ec-33c2-69f215c517f3
begin

	using Pkg
	Pkg.activate(".")
	using Measurements
	using Plots
	using Dates
	using PlutoUI
	using Chain
	using DataFrames
	using DataFramesMeta
	using StatsFuns

	"start"
end


# ╔═╡ 56586883-d4cf-46ef-8d7b-dbfac65c2f81
begin
	
	types=["Call", "Put", "Butterfly-Call", "Butterfly-Put", "Vertical-Call", "Vertical-Put"]
	
	md"""

	Time: $(@bind t Slider(.00001:.00001:10.0, default=1))
	Vol: $(@bind vol Slider(.3:.01:.6, default=.5))
	Vol Uncertainty: $(@bind volrange Slider(.01:.01:.3, default=.1))
	
	Spot: $(@bind spot Slider(3300:10:3700, default=3400))

	
	Contract:
	
	$(@bind a1 CheckBox(default=true)) $(@bind c1 Select(string.(collect(-4:4)), default="1")) $(@bind t1 Select(types, default="Butterfly-Call"))) $(@bind d1 TextField(default="3380/3400/3450"))
	
	$(@bind a2 CheckBox(default=true)) $(@bind c2 Select(string.(collect(-4:4)), default="-1")) $(@bind t2 Select(types, default="Vertical-Call")) $(@bind d2 TextField(default="3400/3450"))
	
	$(@bind a3 CheckBox()) $(@bind c3 Select(string.(collect(-4:4)), default="1")) $(@bind t3 Select(types, default="Put")) $(@bind d3 TextField())
	
	Stock: $(@bind sname   TextField(default="AMZN"))
	Exp Date: $(@bind expDate   TextField(default="2021-10-15"))

	
	"""
end

# ╔═╡ aca6e9a9-69a0-423c-bbbc-2cf4a97fc682
begin
		v = measurement(vol, volrange)
		t, v, spot
end

# ╔═╡ 8c25d0c9-ad02-456e-9ead-b09d35f2a049
begin
		# opt =1 * bs.butterfly("AMZN", 3380.,3400.,3450., Date("2021-10-15"), bs.CALL) -3 * bs.vertical("AMZN",3400.,3450., Date("2021-10-15"), bs.CALL)
	
		# opt=1*bs.call("AMZN", 3400., Date("2021-10-15") ) - 1*bs.call("AMZN", 3450., Date("2021-10-15") )
		
	
end

# ╔═╡ 576a1833-85ff-4153-99c7-5667cdfd80af
	# df = @chain data.getAllData() (
	# 	data.outOfMoneyOptions!();
	# 	data.ff(:delta => x -> .005 < abs(x) );   ## remove way out of money quotes
	# 	transform!([:strikePrice, :gamma] => ((s,g) -> .5 * .01  .* g .* s .^2) => :dollarGamma);
	# 	)

	# plot(df.delta, df.vol, st=:scatter)

# ╔═╡ d9588c0e-06be-43ea-b9e4-e298e75e7ebf
module bs include("./src/blackschole.jl") end

# ╔═╡ 5cb134cf-982b-4de0-896b-cb4360283a49
begin
	function contractParser(a, c, t, d, name=sname, exp=Date(expDate))
	
		o=nothing
		if a 
			cnt = parse(Int, c)
			if t == "Call"
				o = bs.call(name, parse(Float64, d), exp)
			elseif t == "Put"
				o = bs.put(name, parse(Float64, d), exp)
			elseif t == "Vertical-Call"
				l, r = parse.(Float64, split(d, '/'))
				o = bs.vertical(name,l, r , exp, bs.CALL)
			elseif t == "Vertical-Put"
				l, r = parse.(Float64, split(d, '/'))
				o = bs.vertical(name,l, r , exp, bs.PUT)
			elseif t == "Butterfly-Call"
				l, m, r = parse.(Float64, split(d, '/'))
				o = bs.butterfly(name,l, m, r , exp, bs.CALL)
			elseif t == "Butterfly-Call"
				l, m, r = parse.(Float64, split(d, '/'))
				o = bs.butterfly(name,l, m, r , exp, bs.CALL)
			end
			o = cnt * o
		end
		o 
	end
		
	opt = sum(filter(!isnothing, [contractParser(a1, c1, t1, d1) contractParser(a2, c2, t2, d2) contractParser(a3, c3, t3, d3)]))
end

# ╔═╡ a9a8a9d1-9d60-458e-b150-fac70742cad3
begin
		
	p1=plot([(s, bs.dollarGamma(opt, s, v,t)) for s in 3100.:10.:3700], label="",  title="dollargamma", size=(600,400))
	p1=plot!([spot], st=:vline,  label="")

	p2=plot([(s, bs.greeks(opt, s, v,t)[1]) for s in 3100.:10.:3700],label="", color=:black, lw=2,  title="mark", size=(600,400))
	plot!(p2, [spot], st=:vline,  label="")

		p3=plot([(s, bs.greeks(opt, s, v,t)[2]) for s in 3100.:10.:3700],label="", color=:black, lw=2,  title="delta", size=(600,400), yrange=(-.5,.5))
	plot!(p3, [spot], st=:vline,  label="")

	dg=bs.dollarGamma(opt, spot, v,t)
		# the dollar gamma pl for the returns
	p4=plot([((1+r)*spot, 50*dg*r^2) for r in -.05:.003:.05], label="", title=string("Dollar Gamma PL, spot= ", spot), size=(600,400),
	xlabel="future spot", yrange=(-15,15) )
	
	plot(p1,p2, p3, p4, size=(800,600))
	
end

# ╔═╡ 3f4e455e-b4ec-4d2b-bacf-32002f0f293a
module data include("./src/data.jl") end

# ╔═╡ Cell order:
# ╟─a9a8a9d1-9d60-458e-b150-fac70742cad3
# ╟─aca6e9a9-69a0-423c-bbbc-2cf4a97fc682
# ╟─56586883-d4cf-46ef-8d7b-dbfac65c2f81
# ╠═5cb134cf-982b-4de0-896b-cb4360283a49
# ╟─8c25d0c9-ad02-456e-9ead-b09d35f2a049
# ╟─576a1833-85ff-4153-99c7-5667cdfd80af
# ╟─d9588c0e-06be-43ea-b9e4-e298e75e7ebf
# ╟─3f4e455e-b4ec-4d2b-bacf-32002f0f293a
# ╟─de55f4a6-441f-11ec-33c2-69f215c517f3
