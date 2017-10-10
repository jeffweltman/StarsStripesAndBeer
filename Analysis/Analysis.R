######################################################################
#  Weltman & Woodruff Analytics Co.                 October 8, 2017  #
#  Authors: Claudia Woodruff, President ad Founder                   #
#           Jeff Weltmam, CTO and Chief Data Scientist               #
#                                                                    #
#  Purpose: Analysis for Stars Stripes and Beer Co.                  #
#                                                                    #
#  Description: W&W Analytics has been commissioned to analyze       #
#               the Craft Beer market in the United States           #
#               to help SS&B to make the most profitable decisions   #
#               and gain more market share of the craft beer segment.#
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
BrewsAndBreweries$IBU <- ifelse(BrewsAndBreweries$State=="SD",0,BrewsAndBreweries$IBU) 
# Since all beers from South Dakota were missing IBU data, the line above sets their IBU to 0. Otherwise all their beers are deleted by the following step.
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


# Write tidy data sets
#----------------#
write.csv(DFBeers,"TidyBeers.csv",row.names=FALSE)
write.csv(DFBreweries,"TidyBreweries.csv",row.names=FALSE)

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

# barplot - (How to compare ABV and IBU in one Barchart? 
#            What does the end product look like? )

# !!!!! Okay, let's write BrewsAndBreweries merged file and create an
# r sript to analyze through some other plotting techniques.

write.csv(BrewsAndBreweries, file = "BrewsAndBreweries.csv", row.names=FALSE)     

# Determine which state has the beer
# with the highest alcohol content (ABV).
#---------------------------------------#

MaxABV <- aggregate(ABV ~ State, 
                    data=BrewsAndBreweries, 
                    max)
MaxABV <- MaxABV[order(-MaxABV$ABV),]
print(MaxABV[1, "State"])            # Kentucky
paste("With an ABV of ", (MaxABV[1, "ABV"]),", ", (MaxABV[1, "State"]), " has the beer with highest alcohol content: ", BrewsAndBreweries$BeerName[which(BrewsAndBreweries$ABV==MaxABV[1, "ABV"])],".", sep="")
# what do you think of outputting that string instead to give more information? 

# Determine which state has the most bitter (IBU) beer.
#-----------------------------------------------------#

MaxIBU <- aggregate(IBU ~ State, 
                    data=BrewsAndBreweries, 
                    max)
MaxIBU <- MaxIBU[order(-MaxIBU$IBU), ]
print(MaxIBU[1, "State"])            # Oregon
paste("With an IBU of ", (MaxIBU[1, "IBU"]),", ", (MaxIBU[1, "State"]), " has the beer with highest bitterness: ", BrewsAndBreweries$BeerName[which(BrewsAndBreweries$IBU==MaxIBU[1, "IBU"])],".", sep="")
# likewise, let me know what you think of this string instead.

# Print a summary of statistics for the ABV variable.
#---------------------------------------------------#

print(summary(BrewsAndBreweries$ABV))


