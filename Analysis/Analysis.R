######################################################################
#  Weltman & Woodruff Analytics Co.                 October 8, 2017  #
#  Authors: Claudia Woodruff, President and Founder                  #
#           Jeff Weltmam, CTO and Chief Data Scientist               #
#                                                                    #
#  Purpose: Analysis for Stars, Stripes, and Beer Co.                #
#                                                                    #
#  Description: W&W Analytics has been commissioned to analyze       #
#               the Craft Beer market in the United States           #
#               to help SS&B to make the most profitable decisions   #
#               and gain more market share of the craft beer segment.#
#                                                                    #
#  Analysis.r - Analyzing data to answer reearch questions           #
#                                                                    #
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

colSums(is.na(DFBeers))                 # DFBeers has 1,005 observations with IBU of NA but will be removed after merge

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

# Since all beers from South Dakota were missing IBU data, the line below sets their IBU to 0. Otherwise all their beers are deleted by the following step.

BrewsAndBreweries$IBU <- ifelse(BrewsAndBreweries$State=="SD",0,BrewsAndBreweries$IBU) 

# Any NA's from merged (breweries with beers with no ABV or IBU rating)?
colSums(is.na(BrewsAndBreweries))
BrewsAndBreweries <- subset(BrewsAndBreweries, !is.na(IBU)) # Remove them


# Create tidy data files #
#------------------------------------------------------------------#
TidyBeers <- BrewsAndBreweries[,c(2:7)]
TidyBreweries <- BrewsAndBreweries[,c(1,8:10)]
write.csv(TidyBeers,"TidyBeers.csv",row.names=FALSE)
write.csv(TidyBreweries,"TidyBreweries.csv",row.names=FALSE)


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

# First, we merge the median ABV and median IBU data with the state data to get a "wide" table

library(reshape2)
BeerFacts <- merge(x=ABV_ByState,y=IBU_ByState,by="State")

# For easier side-by-side comparison, we multiply ABV by 807 to approximate the same range of values

BeerFacts$ABV <- BeerFacts$ABV * 807

# Then we melt these facts to get a long table with ABV and IBU as variables, and their values in the Value column

BeerFacts.long <- melt(BeerFacts)
BeerFacts.long <- BeerFacts.long[order(BeerFacts.long$State),]

# The following plot shows side-by-side median IBU and ABV data per state

library(ggplot2)
theme(plot.title = element_text(hjust = 0.5))
theme_update(plot.title = element_text(hjust = 0.5))

ggplot(BeerFacts.long,aes(x=State,y=value,fill=factor(variable)))+
  geom_bar(stat="identity",position="dodge", width=0.8)+
  scale_fill_discrete(name="Measurement",
                      breaks=c(0,1),
                      labels=c("ABV","IBU"))+
  xlab("State")+ylab("Level")+
  ggtitle("Median ABV and Median IBU Per State")+
  coord_flip() # sets value on y axis, states on x. Commenting out the + above and this line will reverse

# This bar plot shows median ABV data per state

ggplot(ABV_ByState,aes(State,ABV))+
  geom_col(fill="#45415E")+
  coord_cartesian(ylim=c(0.03,0.075))+
  ggtitle("Median ABV Per State")+
  coord_flip() # sets value on y axis, states on x. Commenting out the + above and this line will reverse

# This bar plot shows median IBU data per state (South Dakota == 0)

ggplot(IBU_ByState,aes(State,IBU))+
  geom_col(fill="#91B3BC")+
  coord_cartesian(ylim=c(0,63))+
  ggtitle("Median IBU Per State")+
  coord_flip() # sets value on y axis, states on x. Commenting out the + above and this line will reverse

# ---I like your factor idea, but not sure if we need it considering the above plots. JW--- #

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
BrewsAndBreweries$ABVlvl[BrewsAndBreweries$ABV >= 0.07 ] <- 4

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
paste("With an ABV of ", (MaxABV[1, "ABV"]),", ", (MaxABV[1, "State"]), " has the beer with highest alcohol content: ", BrewsAndBreweries$BeerName[which(BrewsAndBreweries$ABV==MaxABV[1, "ABV"])],".", sep="")




# Determine which state has the most bitter (IBU) beer.
#-----------------------------------------------------#

MaxIBU <- aggregate(IBU ~ State, 
                    data=BrewsAndBreweries, 
                    max)
MaxIBU <- MaxIBU[order(-MaxIBU$IBU), ]
paste("With an IBU of ", (MaxIBU[1, "IBU"]),", ", (MaxIBU[1, "State"]), " has the beer with highest bitterness: ", BrewsAndBreweries$BeerName[which(BrewsAndBreweries$IBU==MaxIBU[1, "IBU"])],".", sep="")

# Print a summary of statistics for the ABV variable.
#---------------------------------------------------#

print(summary(BrewsAndBreweries$ABV))

# Initial scatterplot of IBU and ABV

plot(x=BrewsAndBreweries$ABV, y=BrewsAndBreweries$IBU, xlab = "Alcohol Content (ABV)", ylab = "Bitterness (IBU)", main = "Relationship Between Bitterness and Alcohol Content")

# A positive correlation does appear likely. Let's confirm with a correlation test to get Pearson's R.

cor.test(BrewsAndBreweries$ABV, BrewsAndBreweries$IBU)

# 66.6% of the variation in IBU is explained by a change in ABV.

# Getting the intercept and slope for abline
reg <- lm(IBU ~ ABV, data=BrewsAndBreweries)
reg

# Now we can peform a scatterplot in ggplot2 - perhaps it might be more enlightening?
library(ggplot2)
ggplot(BrewsAndBreweries, aes(x=ABV, y=IBU))+
  geom_point(size=2) + geom_abline(intercept=-34.1, slope = 1282.0)+
  ggtitle("Correlation Between ABV and IBU")


# Write the merged data set to a csv file:
#-----------------------------------------#
write.csv(BrewsAndBreweries, file = "BrewsAndBreweries.csv", row.names=FALSE)  