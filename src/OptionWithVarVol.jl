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

# ╔═╡ c80e25be-403f-11ec-0682-5f79386d7a47
begin

	using Pkg
	Pkg.add("StatsFuns")
	Pkg.add("PlutoUI")
	Pkg.add("Measurements")
	using Measurements
	using Plots
	using Dates
	using PlutoUI
	using StatsFuns
end



# ╔═╡ 2b5f1b06-8877-4648-88ef-ac3b3ef075dd
module bs include("./blackschole.jl") end


# ╔═╡ 5478862a-d865-4f44-bdd6-6c378a22db96
md"""
Time: $(@bind t Slider(.00001:.00001:5.0))
Vol: $(@bind vol Slider(.3:.01:.6))
Vol Uncertainty: $(@bind volrange Slider(.01:.01:.1))
"""

# ╔═╡ 912fbbce-b4d4-4ecc-b06c-ddd40cf72e52
begin
	v = measurement(vol, volrange)
	t, v
end

# ╔═╡ 503ac5e1-5c2e-4272-936d-a04151070cad
begin
	opt =1 * bs.bwb("AMZN", 3380.,3400.,3450., Date("2021-10-15"), bs.CALL) -3 * bs.vertical("AMZN",3400.,3450., Date("2021-10-15"), bs.CALL)
	plot([(s, bs.greeks(opt, s, v,t)[1]) for s in 3300.:10.:3600])
end

# ╔═╡ 0d79878c-9139-44c9-96c9-8f908686a520


# ╔═╡ Cell order:
# ╠═c80e25be-403f-11ec-0682-5f79386d7a47
# ╠═2b5f1b06-8877-4648-88ef-ac3b3ef075dd
# ╠═5478862a-d865-4f44-bdd6-6c378a22db96
# ╠═912fbbce-b4d4-4ecc-b06c-ddd40cf72e52
# ╠═503ac5e1-5c2e-4272-936d-a04151070cad
# ╠═0d79878c-9139-44c9-96c9-8f908686a520
