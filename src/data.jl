
using CSV
using DataFrames
using DataFramesMeta
using Chain

# <(10,3)
# flip(<)(10,3)
flip(f)= (x,y)-> f(y,x)
ff=flip(filter)
ff! = flip(filter!)


outOfMoneyOptions(x) =@chain x (
ff([:strikePrice, :spot, :putCall] => (p,s,pc) ->  (pc == "CALL") ? (p>s) : (s>p));  # outof money call and put
)

outOfMoneyOptions!(x) =@chain x (
ff!([:strikePrice, :spot, :putCall] => (p,s,pc) ->  (pc == "CALL") ? (p>s) : (s>p));  # outof money call and put
)

inTheMoneyOptions(x) =@chain x (
ff([:strikePrice, :spot, :putCall] => (p,s,pc) ->  (pc == "CALL") ? (p<s) : (s<p));  # outof money call and put
)

inTheMoneyOptions!(x) =@chain x (
ff!([:strikePrice, :spot, :putCall] => (p,s,pc) ->  (pc == "CALL") ? (p<s) : (s<p));  # outof money call and put
)

optionTypeToInt(x) =  x == "CALL" ? 1 : 10
optionTypeToShape(x) =  x == "CALL" ? :square : :circle

optionTypeToColor(x) =  x == "CALL" ? :blue : :red

getAllData(r="data/") = vcat([ DataFrame(CSV.File(string(r,d))) for d in readdir(r)]...)

## %%
# df = getAllData()

# volPlot(df, p) = plot!(p, df.strikePrice, df.dollarGamma, st=:scatter, markersize=hour.(df.quoteGroupId), markershape=optionTypeToShape.(df.putCall), label="") #df.quoteGroupId[1])
# res=@chain df (
#     outOfMoneyOptions();
#     ff(:daysToExpiration => ==(1));
#     ff(:strikePrice => x -> 3100 < x < 3500);
#     transform([:strikePrice, :gamma] => ((s,g) -> .5 * .01  .* g .* s .^2) => :dollarGamma);
#     groupby(:quoteGroupId);
# )

# p=plot()
# for q in res
#     volPlot(q, p)
# end
# plot(p)