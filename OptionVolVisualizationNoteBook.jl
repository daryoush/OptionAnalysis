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

# ╔═╡ bcd400d4-4197-11ec-1f50-279c5be53843
begin
	using Pkg
	Pkg.activate(".")
	using Plots
	using Dates
	using DataFrames
	using DataFramesMeta
	using PlutoUI

	
end

# ╔═╡ 130c2a1d-fe0c-4f69-bed8-6955ca369cbd
module data include("./src/data.jl") end

# ╔═╡ 916737db-a49b-40fa-8065-9fbdf96344d9
begin
	df = @chain data.getAllData() (
		data.outOfMoneyOptions!();
		data.ff(:delta => x -> .005 < abs(x) );   ## remove way out of money quotes
		transform!([:strikePrice, :gamma] => ((s,g) -> .5 * .01  .* g .* s .^2) => :dollarGamma);
		)
	
end

# ╔═╡ 951d85c6-b1bc-4652-9078-aefc8dd19dcb
begin
	expDaysChoices = string.(sort(unique(df.daysToExpiration)))
	 @bind daysFilter Radio(expDaysChoices)

end

# ╔═╡ dc7255a0-6279-48f9-b683-b8bdb12dc2fe
begin
	daysToExpChoice = parse(Int,daysFilter)
	quotesOnDays = data.ff(df, :daysToExpiration => ==(daysToExpChoice))
	qq = sort(unique(quotesOnDays.quoteGroupId))
	@bind quoteTime Radio(string.(qq))
end

# ╔═╡ 6637ad7c-6a22-464a-b224-2cd21e9ab768
# TODO Chance the plotting so its is recursive and keeps adding to the previous one
# util there is a initalize again.

# ╔═╡ 97633161-94ac-44c2-af5f-cf2c7d3d805b
basePlot() = plot([3380.,3400.,3450], st=:vline, style=:dot, lw=4)


# ╔═╡ 02ae96f4-88ff-46ec-8117-403bed12367c
function volPlot(d, p=plot )   # note p is a function that generates base plot
	p1 = p()
	plot!(p1, [d.strikePrice[1]], st=:vline, label="")
	plot!(p1, d.strikePrice, d.vol, st=:scatter, markersize=hour.(d.quoteGroupId), markershape=data.optionTypeToShape.(d.putCall), label="", title="vol") 

	p2 = plot!(p(), [d.strikePrice[1]], st=:vline, label="")
	plot!( p2, d.strikePrice, d.mark, st=:scatter, markersize=hour.(d.quoteGroupId), markershape=data.optionTypeToShape.(d.putCall), label="", title="mark")
	plot(p1, p2)


end

# ╔═╡ b5e86a33-94ec-45a3-98cd-2371c18afe96
begin
	q = DateTime(quoteTime)
	quotes = @chain df (
		data.ff(:quoteGroupId => ==(q));
		data.ff(:daysToExpiration => ==(daysToExpChoice));
	)
	 volPlot(quotes, basePlot)
end

# ╔═╡ 7d1da594-e0e4-4b81-95e5-f6558502db1f
begin
	res=groupby(df, :quoteGroupId)
	#df.quoteGroupId[1])
	
	p=plot()
	for q in res
	    volPlot(q, p)
	end
	plot(p)
end

# ╔═╡ Cell order:
# ╠═bcd400d4-4197-11ec-1f50-279c5be53843
# ╠═130c2a1d-fe0c-4f69-bed8-6955ca369cbd
# ╠═916737db-a49b-40fa-8065-9fbdf96344d9
# ╠═951d85c6-b1bc-4652-9078-aefc8dd19dcb
# ╠═dc7255a0-6279-48f9-b683-b8bdb12dc2fe
# ╠═6637ad7c-6a22-464a-b224-2cd21e9ab768
# ╠═97633161-94ac-44c2-af5f-cf2c7d3d805b
# ╠═b5e86a33-94ec-45a3-98cd-2371c18afe96
# ╠═02ae96f4-88ff-46ec-8117-403bed12367c
# ╠═7d1da594-e0e4-4b81-95e5-f6558502db1f
