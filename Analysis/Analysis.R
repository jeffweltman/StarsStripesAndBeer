######################################################################
#  Weltman & Woodruff Analytics Co.                 October 8, 2017  #
#  Authors: Claudia Woodruff, President ad Founder                   #
#           Jeff Weltmam, CTO and Chief Data Scientist               #
#                                                                    #
#  Purpose: Analysis for Stars Stripes and Beer Co.                  #
#                                                                    #
#  Description: W&W Analyitcs has been commissioned to analyze       #
#               the Craft Beer market in the United States in        #
#               to help SS&B to make the most profitable decisions   #
#               to gain more market share of the craft beer segment. #
######################################################################


# Read raw data sets
#-------------------#

Beers <- "https://raw.githubusercontent.com/jeffweltman/StarsStripesAndBeer/master/Raw/Beers.csv" 
DFBeers <- repmis::source_data(Beers)

Breweries <- "https://raw.githubusercontent.com/jeffweltman/StarsStripesAndBeer/master/Raw/Breweries.csv"
DFBreweries <- repmis::source_data(Breweries)

# Cleaning data for merging: Rename variable names
#-------------------------------------------------#

colnames(DFBeers) <- c("BeerName","Beer_ID","ABV","IBU","Brewery_ID","Style","Ounces")
colnames(DFBreweries) <- c("Brewery_ID","BreweryName","City","State")

# Merge data sets
#----------------#

BrewsAndBreweries <- merge(x=DFBeers, y=DFBreweries, by="Brewery_ID", all=TRUE)

# Print the first and last 6 observations to check the merged file.
#------------------------------------------------------------------#

head(BrewsAndBreweries, 6)        # Looks okay
tail(BrewsAndBreweries, 6)        # Looks okay

# Report the number of NA's in each column.
#------------------------------------------#

colSums(is.na(BrewsAndBreweries),na.rm=FALSE)    # 62 in "ABV; 1,005 in "IBU"

# Compute the median alcohol content (ABV) and international
# bitterness unit (IBU) for each state.
#-----------------------------------------------------------#

medianIBU <-median(BrewsAndBreweries$IBU, na.rm=TRUE)
ABV_ByState <- aggregate(ABV ~ State, data=BrewsAndBreweries, median)
IBU_ByState <- aggregate(IBU ~ State, data=BrewsAndBreweries, median)

# Plot a bar chart to compare.
#-----------------------------#
# Merge ABV_ByStte and IBU_ByState, (and sort it by state (?or other?)

# AbvIbu <- merge(x=ABV_ByState, y=IBU_ByState, by="State", all=TRUE)
# AbvIbu <- AbvIbu[order(AbvIbu$State), ]  

# barplot - (not sure what is measured in one bar? IBU or ABV? How can we
# compare? Compare what? How to compare ABV and IBU in one Barchart? 
# What does the end product look like? )

# Okay, let's write BrewsAndBreweries merged file and create an
# r sript to analyze through different plotting techniques.
# 

write.csv(BrewsAndBreweries, file = "BrewsAndBreweries.csv", row.names=FALSE)     

# Determine which state has the beer
# with the highest alcohol content (ABV).
#---------------------------------------#

MaxABV <- aggregate(ABV ~ State, 
                    data=BrewsAndBreweries, 
                    max)
MaxABV <- MaxABV[order(-MaxABV$ABV),]
print(MaxABV[1, "State"])            # Colorado

# Determine which state has the most bitter (IBU) beer.
#-----------------------------------------------------#

MaxIBU <- aggregate(IBU ~ State, 
                    data=BrewsAndBreweries, 
                    max)
MaxIBU <- MaxIBU[order(-MaxIBU$IBU), ]
print(MaxIBU[1, "State"])            # Oregon

# Print a summary of statistics for the ABV variable.
#---------------------------------------------------#

print(summary(BrewsAndBreweries$ABV))


