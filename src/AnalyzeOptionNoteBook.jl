### A Pluto.jl notebook ###
# v0.17.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ c3feddb5-623d-4e24-9526-c8d08f2a738f
begin
	using Pkg
	Pkg.add("StatsFuns")
	Pkg.add("PlutoUI")

	using Plots
	using Dates
	using PlutoUI
end

# ╔═╡ c5728a36-3a20-11ec-0d49-9fb0e459c205
module bs include("./blackschole.jl") end

# ╔═╡ 5cb629fe-df4f-48b9-8557-092799a45d42
bs.greeks(8700.,8572.,.6750, 44., bs.CALL )

# ╔═╡ 4905d32e-ce8d-4401-9d43-57a050515bbd
bs.greeks(8500.,8572.,.6920, 44., bs.PUT  )

# ╔═╡ 3cbcbff9-5f8a-4518-a5c2-76e5a5d4afa3
plot( s-> bs.greeks(100.,s,.6750, 100., bs.CALL )[1], xlims=(50, 130))


# ╔═╡ 21de537a-a858-4c8e-a2bc-2dfa3437ad88


# ╔═╡ e7392eee-1b7d-45f2-90d8-1957df325e1f
plot( s-> bs.greeks(100.,s,.6750, 7., bs.CALL )[3], xlims=(50, 150))



# ╔═╡ 3b89950b-216f-4e17-a45d-5f20f380850a
plot( s-> bs.greeks(100.,s,.6750, 7., bs.CALL )[4], xlims=(50, 150))

# ╔═╡ 92595d66-7b0b-474b-8add-212757db2312
plot( s-> bs.greeks(100.,s,.6750, 7., bs.CALL )[5], xlims=(50, 150))

# ╔═╡ 9d395522-8ed0-4e5a-ad59-fe57d8c42d9a
plot( s-> bs.greeks(100.,s,.6750, 7., bs.CALL )[6], xlims=(50, 150))

# ╔═╡ 9c65e06d-ffaa-4a47-bc9a-ef1c0959c44c
md"""
Time: $(@bind t Slider(.0001:.0001:1.0))
Vol: $(@bind vol Slider(.3:.01:.6))
"""

# ╔═╡ 93113e38-c4bf-4e2e-bcb3-c324e4e343fa
t, vol

# ╔═╡ 17f35cf4-84ce-4ab2-a19e-aeb0507cb1fb
begin
	plotly()
	pos = 1 * bs.bwb("AMZN", 3380.,3400.,3450., Date("2021-10-15"), bs.CALL) -3 * bs.vertical("AMZN",3400.,3450., Date("2021-10-15"), bs.CALL)
plot( s-> bs.greeks(pos, s, vol, t)[1] , xlims=(3300, 3600))
	
	
end

# ╔═╡ 536682d7-e4bf-4438-9c94-d5d0e20db9f2
begin
	#pos3 = 1 * bs.call("AMZN", 3380., Date("2021-10-15")) -2 * bs.call("AMZN", 3400., Date("2021-10-15")) + 1 * bs.call("AMZN", 3450., Date("2021-10-15")) 
	pos4= 1*bs.bwb("AMZN", 3380.,3400.,3450., Date("2021-10-15"), bs.CALL)
		plot( s-> bs.greeks(pos4, s, vol, t)[1] , xlims=(3200, 3800))
end

# ╔═╡ f755b415-13e1-4c6b-ac54-04336dcc2027
begin
	plotly()
	pos2 = -3 * bs.vertical("AMZN",3400.,3450., Date("2021-10-15"), bs.CALL)
plot( s-> bs.greeks(pos2, s, vol, t)[1] , xlims=(3300, 3600))
	
	
end

# ╔═╡ Cell order:
# ╠═c3feddb5-623d-4e24-9526-c8d08f2a738f
# ╠═c5728a36-3a20-11ec-0d49-9fb0e459c205
# ╠═5cb629fe-df4f-48b9-8557-092799a45d42
# ╠═4905d32e-ce8d-4401-9d43-57a050515bbd
# ╠═3cbcbff9-5f8a-4518-a5c2-76e5a5d4afa3
# ╠═21de537a-a858-4c8e-a2bc-2dfa3437ad88
# ╠═e7392eee-1b7d-45f2-90d8-1957df325e1f
# ╠═3b89950b-216f-4e17-a45d-5f20f380850a
# ╠═92595d66-7b0b-474b-8add-212757db2312
# ╠═9d395522-8ed0-4e5a-ad59-fe57d8c42d9a
# ╠═9c65e06d-ffaa-4a47-bc9a-ef1c0959c44c
# ╠═93113e38-c4bf-4e2e-bcb3-c324e4e343fa
# ╠═17f35cf4-84ce-4ab2-a19e-aeb0507cb1fb
# ╠═536682d7-e4bf-4438-9c94-d5d0e20db9f2
# ╠═f755b415-13e1-4c6b-ac54-04336dcc2027
