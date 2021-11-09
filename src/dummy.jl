using Plots
using Measurements
using Dates
module bs include("./blackschole.jl") end

t=2
v = measurement(.3, .1)
opt =1 * bs.bwb("AMZN", 3380.,3400.,3450., Date("2021-10-15"), bs.CALL) -3 * bs.vertical("AMZN",3400.,3450., Date("2021-10-15"), bs.CALL)
plot([(s, bs.greeks(opt, s, v,t)[1]) for s in 3300.:10.:3600])