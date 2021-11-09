using Plots
using Measurements
using Dates
using CSV
using DataFrames
using DataFramesMeta

## %%
module bs include("./blackschole.jl") end

t=2
v = measurement(.3, .1)
opt =1 * bs.bwb("AMZN", 3380.,3400.,3450., Date("2021-10-15"), bs.CALL) -3 * bs.vertical("AMZN",3400.,3450., Date("2021-10-15"), bs.CALL)
plot([(s, bs.greeks(opt, s, v,t)[1]) for s in 3300.:10.:3600])

## %%

timeConv(x) = unix2datetime.(x ./ 1000)
# <(10,3)
# flip(<)(10,3)
flip(f)= (x,y)-> f(y,x)
ff=flip(filter)
ff! = flip(filter!)

# code to take an existing TD option quote to simple quote for exploration
r="tmp/"
df=vcat([ DataFrame(CSV.File(string(r,d))) for d in readdir(r)]...)

df[!, :quoteGroupId]=convert.(Int64,df[!,:quoteGroupId ])
@chain df (
  transform!( :expirationDate => timeConv  => :expirationDate);
 # transform!(:quoteGroupId => x -> convert.(Int64, x) => :quoteGroupId);
  transform!( :quoteGroupId => (x -> unix2datetime.(x)) => :quoteGroupId);
  transform!(:volatility => :vol);
  select!([:quoteGroupId, :mark, :spot, :strikePrice, :daysToExpiration, :vol, :symbol, :delta, 
  :gamma, :theta, :bid, :openInterest, :ask, :expirationDate, :putCall]);

)
ff!(df, :quoteGroupId => x -> (Date(x) < Date("2021-10-16")))
ff!(df, :daysToExpiration => <(5))

## %%
CSV.write(string("data/", "AMZN_2021-10-15_EXP.csv"), df)