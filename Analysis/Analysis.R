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

# Cleaning data for merging: Rename variable names to aid in merging
# and if there are N/A values in the ABV or IBU we'll remove those observations.
#-------------------------------------------------#

colnames(DFBeers) <- c("BeerName","Beer_ID","ABV","IBU","Brewery_ID","Style","Ounces")
colnames(DFBreweries) <- c("Brewery_ID","BreweryName","City","State")

colSums(is.na(DFBeers))                 # DFBeers has 1,005 observations with IBU of NA
DFBeers <- subset(DFBeers, !is.na(IBU)) # Remove them
colSums(is.na(DFBeers))                 # DFBeers has no observations with IBU of NA
                                        # (There were, but were removed with the above.)
colSums(is.na(DFBreweries))             # DFBreweries has no NA

# Check for outliers
#-------------------#
summary(DFBeers)
sd(DFBeers$ABV)    # 0.0126
sd(DFBeers$IBU)    # 25.954
# NO outliers detected in this set of observations.
# Note: IBU values have a wide range. Reference:
# https://www.brewersfriend.com/2017/05/07/beer-styles-ibu-chart-2017-update/


# Merge data sets
#----------------#

BrewsAndBreweries <- merge(x=DFBeers, y=DFBreweries, by="Brewery_ID", all=TRUE)

# Any NA's from merged (breweries with beers with no ABV or IBU rating)?
colSums(is.na(BrewsAndBreweries))
BrewsAndBreweries <- subset(BrewsAndBreweries, !is.na(IBU)) # Remove them

# Print the first and last 6 observations to check the merged file.
#------------------------------------------------------------------#

head(BrewsAndBreweries, 6)        # Looks okay
tail(BrewsAndBreweries, 6)        # Looks okay

# Report the number of NA's in each column.
#------------------------------------------#

colSums(is.na(BrewsAndBreweries))    # 0

# Compute the median alcohol content (ABV) and international
# bitterness unit (IBU) for each state.
#-----------------------------------------------------------#

medianIBU <-median(BrewsAndBreweries$IBU, na.rm=TRUE)
ABV_ByState <- aggregate(ABV ~ State, data=BrewsAndBreweries, median)
IBU_ByState <- aggregate(IBU ~ State, data=BrewsAndBreweries, median)

# Plot a bar chart to compare.
#-----------------------------#
#    (How do we compare ABV and IBU in a Barchart? 
#     What does the end product look like? )


# Add a factor column on the ABV:
# Number | Label      | Value of ABV
# -----------------------------------
# 1      | low        | min-050
# 2      | med low    | 0.050-0.059
# 3      | med high   | 0.060-0.069
# 4      | high       | 0.07-max


BrewsAndBreweries$ABVlvl[BrewsAndBreweries$ABV < 0.05 ] <- 1
BrewsAndBreweries$ABVlvl[BrewsAndBreweries$ABV
                         >= 0.05 &
                         BrewsAndBreweries$ABV < 0.06 ] <- 2
BrewsAndBreweries$ABVlvl[BrewsAndBreweries$ABV
                         >= 0.06 &
                         BrewsAndBreweries$ABV < 0.07 ] <- 3
BrewsAndBreweries$ABVlvl[BrewsAndBreweries$ABV > 0.07 ] <- 4

# Create a vector of factor level labels, and convert labels to a factor.
#-----------------------------------------------------------------------#
ABVlabels <- c("low", "med low", "med high", "high")
BrewsAndBreweries$ABVlvl <- factor(BrewsAndBreweries$ABVlvl, labels = ABVlabels)

   

# Determine which state has the beer
# with the highest alcohol content (ABV).
#---------------------------------------#

MaxABV <- aggregate(ABV ~ State, 
                    data=BrewsAndBreweries, 
                    max)
MaxABV <- MaxABV[order(-MaxABV$ABV),]
print(MaxABV[1, "State"])            # Kentucky

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


# Write the merged data set to a cvs file:
#-----------------------------------------#
write.csv(BrewsAndBreweries, file = "BrewsAndBreweries.csv", row.names=FALSE)  


