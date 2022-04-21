using CSV
using DataFrames
using Dates
using Plots
theme(:ggplot2)
using TypedTables
using Clustering
using VegaLite
using Distances
using Statistics
using JSON
using StatsPlots: @df
using Chain


graphs = CSV.File("2small_graphs_new.csv") |> DataFrame
label_graphs =  CSV.File("3small_graphs_new.csv") |> DataFrame

groupby_length = groupby(label_graphs,:Length)
groubby_pattern = groupby(label_graphs,:Pattern)


rising = groubby_pattern[1] #graphs categorized by pattern type rising
complex = groubby_pattern[2] #graph categorized by patter type complex

long = groupby_length[2] #dataframe categorized by long length
medium = groupby_length[1] #dataframe categorzied by medium length
short = groupby_length[3] #dataframe categorized by short length

#DOMINATION NUMBER counted the # of instances for a given attribute based on rising/complex 
rising_domination_count = combine(groupby(rising, [:Length, :domination_number]), nrow => :count)
complex_domination_count = combine(groupby(complex, [:Length, :domination_number]), nrow => :count)
long_domination_count = combine(groupby(long, [:Pattern, :domination_number]), nrow => :count)
medium_domination_count = combine(groupby(medium, [:Pattern, :domination_number]), nrow => :count)
short_domination_count = combine(groupby(short, [:Pattern, :domination_number]), nrow => :count)

#RADIUS 
rising_radius_count = combine(groupby(rising, [:Length, :radius]), nrow => :count)
complex_radius_count = combine(groupby(complex, [:Length, :radius]), nrow => :count)
long_radius_count = combine(groupby(long, [:Pattern, :radius]), nrow => :count)
medium_radius_count = combine(groupby(medium, [:Pattern, :radius]), nrow => :count)
short_radius_count = combine(groupby(short, [:Pattern, :radius]), nrow => :count)

#DIAMETER
rising_diameter_count = combine(groupby(rising, [:Length, :diameter]), nrow => :count)
complex_diameter_count = combine(groupby(complex, [:Length, :diameter]), nrow => :count)
long_diameter_count = combine(groupby(long, [:Pattern, :diameter]), nrow => :count)
medium_diameter_count = combine(groupby(medium, [:Pattern, :diameter]), nrow => :count)
short_diameter_count = combine(groupby(short, [:Pattern, :diameter]), nrow => :count)

#ZERO FORCING NUMBER
rising_zero_forcing_count = combine(groupby(rising, [:Length, :zero_forcing_number]), nrow => :count)
complex_zero_forcing_count = combine(groupby(complex, [:Length, :zero_forcing_number]), nrow => :count)
long_zero_forcing_count = combine(groupby(long, [:Pattern, :zero_forcing_number]), nrow => :count)
medium_zero_forcing_count = combine(groupby(medium, [:Pattern, :zero_forcing_number]), nrow => :count)
short_zero_forcing_count = combine(groupby(short, [:Pattern, :zero_forcing_number]), nrow => :count)




@df rising groupedhist(:diameter, group =:Length, bar_position = :dodge, bar_width = 0.5, xlabel = "Zero forcing number",
ylabel = "# of counts",framestyle = :box, title = " Zero forcing Distribution (Rising)")

@df complex groupedhist(:diameter, group =:Length, bar_position = :dodge, bar_width = 0.5, xlabel = "Diameter",
ylabel = "# of counts",framestyle = :box, title = "Diameter  Distribution (Complex)")

@df long groupedhist(:diameter,group =:Pattern, bar_position = :dodge, bar_width = 0.5,xlabel = "Diameter",ylabel = "# of times", title = "Diameter Distribution (Long)")
@df short groupedhist(:diameter,group =:Pattern, bar_position = :dodge, bar_width = 0.5,xlabel = "Diameter", ylabel = "# of times", title = "Diameter Distribution (Short)")
@df medium groupedhist(:diameter,group =:Pattern, bar_position = :dodge, bar_width = 0.5,xlabel = "Diameter", ylabel = "# of times", title = "Diameter Distribution (Medium)")


rising_pattern_nrow = @chain rising begin
        groupby(:Length)
        combine(nrow)
end
rising_pattern_nrow = rename(rising_pattern_nrow, :nrow => :rising_pattern)


long_pattern_nrow = @chain long begin
        groupby(:Pattern)
        combine(nrow)       
end
long_pattern_nrow = rename(long_pattern_nrow, :nrow => :long_length)
#out of 61 long sound samples, 38 where rising, 23 were complex

medium_pattern_nrow = @chain medium begin
        groupby(:Pattern)
        combine(nrow )
end
medium_pattern_nrow = rename(medium_pattern_nrow,:nrow => :medium_length)
#out of 11 medium sound samples, 8 were rising, 3 complex

short_pattern_nrow = @chain short begin
        groupby(:Pattern)
        combine(nrow)
end
short_pattern_nrow = rename(short_pattern_nrow,:nrow => :short_length)


complete_pattern_nrow = innerjoin(short_pattern_nrow,medium_pattern_nrow,long_pattern_nrow, on = :Pattern)


####################################################

rising = groubby_pattern[1] #graphs categorized by pattern type rising
complex = groubby_pattern[2] #graph categorized by patter type complex

long = groupby_length[2] #dataframe categorized by long length
medium = groupby_length[1] #dataframe categorzied by medium length
short = groupby_length[3] #dataframe categorized by short length


labels = long.Pattern

x = long.radius
y = long.diameter

scatter(x,
        xlim = (0,8),
        ylim = (0,10),
        y,
        xlabel = "Radius",
        ylabel = "Diameter",
        group = labels,
        legend = :bottomright, 
        markersize = [10 10 10], 
        alpha = .44,
        title = "Radius/Diameter (Long)")



long_mean = @chain long begin
        dropmissing
        groupby(:Pattern)
        combine(Between(:domination_number,:radius) .=> mean)
end
#long rising patterns, had avrg of the foll

medium_mean = @chain medium begin
        dropmissing
        groupby(:Pattern)
        combine(Between(:domination_number,:radius) .=> mean)
end

short_mean = @chain short begin
        dropmissing
        groupby(:Pattern)
        combine(Between(:domination_number,:radius) .=> mean)
end
        
        

rising1 = groupby(rising,:Length)[1] #medium rising
rising2 = rising1[:,[4,5,6,7,8,9,10,11,12,13]]
rising3 = describe(rising2)
CSV.write("rising3.csv", rising3)

rising11 = groupby(rising,:Length)[2] #long rising
rising22 = rising11[:,[4,5,6,7,8,9,10,11,12,13]]
rising33 = describe(rising22)
CSV.write("rising34.csv", rising33)

rising12 = groupby(rising,:Length)[3] #short rising
rising23 = rising12[:,[4,5,6,7,8,9,10,11,12,13]]
rising34 = describe(rising23)
CSV.write("rising35.csv", rising34)

complex1 = groupby(complex,:Length)[1] #medium complex
complex2 = complex1[:,[4,5,6,7,8,9,10,11,12,13]]
complex3 = describe(complex2)
CSV.write("complex3.csv", complex3)

complex22 = groupby(complex,:Length)[2] #long complex
complex23 = complex22[:,[4,5,6,7,8,9,10,11,12,13]]
complex33 = describe(complex23)
CSV.write("complex33.csv", complex33)

describe(rising.domination_number)

complex_domination = complex.domination_number
complex_independence = complex.independence_number




total_labels = combine(groupby_length, nrow)
total_pattern = combine(groubby_pattern,nrow)


scatter(
    complex_domination,
    complex_independence,
    title = "Confirmed cases US",
    xlabel = "Date",
    ylabel = "Number of cases",
)

#Pie chart1 - percentage of length Data
Plots.gr()
x = total_labels.Length
y = total_labels.nrow
pie(x, y, title="Graphs by Length of Sound", l=0.5, )

#Pie chart
Plots.gr()
x = total_pattern.Pattern
y = total_pattern.nrow
pie(x, y, title="Graphs by pattern of Sound", l=0.5)



xx = graphs.domination_number
yy = graphs.independence_number

#Data Analyisis 

#medium_rising
equals_medium_rising(Description) = Description == "Medium rising"
graphs_medium_rising = filter(:Description => equals_medium_rising, graphs)


#medium_rising, domination number
mr_dr = graphs_medium_rising.domination_number

#long_rising, domination number
lr_dr = graphs_long_rising.domination_number

#short rising, domination number
sr_dr = graphs_short_rising.domination_number

gdf = groupby(graphs,:Description)
sc_dr = gdf[4].domination_number
sr_dr = gdf[5].domination_number

#plotting how many instances of 
histogram(mr_dr, alpha=0.2, bar_position=:edge,bar_edges=true,orientation=:h)
histogram!(lr_dr,alpha=0.2,bar_position=:edge,bar_edges=true)
histogram!(sr_dr, alpha=0.2)
histogram!(sc_dr,alpha=0.10)
histogram!(sr_dr,alpha=.20)



total_rows = combine(gdf, nrow)

#Pie chart2
Plots.gr()
x = total_rows.Description
y = total_rows.nrow
pie(x, y, title="Description Percentage", l=0.5)

#histogram
mean_total = combine(gdf, [:domination_number,:diameter] .=> mean; renamecols = false)



#finds the mean for the domination number and diameter for each of the Description categories

CSV.write("Path.csv", dd)


num_graph = graphs[:,[:domination_number,:diameter]]
describe(num_graph[!,[:diameter,:domination_number]])
f



#clustering algorithim 
a = graphs[!, [:domination_number,:diameter]] #dateframe spectrum_to_amplitude
c = kmeans(Matrix(a)',6) #need to pass it as a Matrix, 6 = # of clusters
c
insertcols!(graphs, 3, cluster3 = c.assignments)


xmatrix = Matrix(a)'
D = pairwise(Euclidean(), xmatrix, dims = 2)
K = kmedoids(D, 6)
insertcols!(graphs, 3, clustering = K.assignments) 


#Hierachial clustering

labels = graphs.Description

scatter(xx,
        #xlim = (0,0.75),
        yy,
        xlabel = "domination_number",
        ylabel = "Independence_number",
        group = labels,
        legend = :bottomright, 
        color = [:darkviolet :green3 :red3],
        #markersize = [10 7 13], 
        alpha = .44,
        title = "domination_number /Independence_number")