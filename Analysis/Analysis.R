######################################################################
#  Authors: Claudia Woodruff and Jeff Weltmam, W & W Analytics       #
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

# Read raw data sets and initial analysis
######################################################################

Beers <- "https://raw.githubusercontent.com/jeffweltman/StarsStripesAndBeer/master/Raw/Beers.csv" 
DFBeers <- repmis::source_data(Beers)
#SHA-1 hash of the downloaded data file is:
#  d3e3e8f8e9cf27e0df038f47ccfcfc2dfccf4217

Breweries <- "https://raw.githubusercontent.com/jeffweltman/StarsStripesAndBeer/master/Raw/Breweries.csv"
DFBreweries <- repmis::source_data(Breweries)
#SHA-1 hash of the downloaded data file is:
#  4579c1fc92624c25cb2643d7e61c542972fdc7ab

# Cleaning data for merging: Rename variable names to aid in merging
# and if there are N/A values in the ABV or IBU we'll remove those observations.

colnames(DFBeers) <- c("BeerName","Beer_ID","ABV","IBU","Brewery_ID","Style","Ounces")
colnames(DFBreweries) <- c("Brewery_ID","BreweryName","City","State")

colSums(is.na(DFBeers))      # DFBeers has 1,005 rows with NA IBU and 62 NA ABV
colSums(is.na(DFBreweries))  # DFBreweries has no NA.
                             # Note; Rows with NA found above will be removed after merge.

# Note: All beers from South Dakota are missing IBU data. We will
#       handle these after merging.

# Check for outliers

summary(DFBeers)
summary(DFBreweries)
sd(DFBeers$ABV)      # 0.0126
sd(DFBeers$IBU)      # 25.954
# NO outliers detected in this set of observations.
# Note: IBU values have a wide range. Reference:
# https://www.brewersfriend.com/2017/05/07/beer-styles-ibu-chart-2017-update/

# Merge raw data sets and tidy up the new merged data set
######################################################################

BrewsAndBreweries <- merge(x=DFBeers, y=DFBreweries, by="Brewery_ID", all=TRUE)

# Since all beers from South Dakota were missing IBU data, the line below sets their
# IBU to 0.  Otherwise all their beers are deleted by the following step.

BrewsAndBreweries$IBU <- ifelse(BrewsAndBreweries$State=="SD",0,BrewsAndBreweries$IBU)
BrewsAndBreweries[which(BrewsAndBreweries$Style=="N/A"),]

# Two beers - OktoberFiesta and Kilt Lifter Scottish-Style Ale have no Style provided.
# Re-coded as "N/A".

BrewsAndBreweries$Style <- ifelse(BrewsAndBreweries$Style=="","N/A",BrewsAndBreweries$Style)

# Any NA's from merged (breweries with beers with no ABV or IBU rating)? 

colSums(is.na(BrewsAndBreweries))                            # Yes
BrewsAndBreweries <- subset(BrewsAndBreweries, !is.na(IBU))  # Remove them

# Print the first and last 6 observations to check the merged file.

head(BrewsAndBreweries, 6)         # Looks okay
tail(BrewsAndBreweries, 6)         # Looks okay

# Report the number of NA's in each column.

colSums(is.na(BrewsAndBreweries))  # 0

# Determine count of breweries per state

library(sqldf)
BreweryCount <- sqldf("select count(distinct(Brewery_id)) as BreweryCount, State from BrewsAndBreweries group by State")

# Compute the median alcohol content (ABV) and international
# bitterness unit (IBU) for each state.

medianIBU <-median(BrewsAndBreweries$IBU, na.rm=TRUE)
ABV_ByState <- aggregate(ABV ~ State, data=BrewsAndBreweries, median)
IBU_ByState <- aggregate(IBU ~ State, data=BrewsAndBreweries, median)

#
# Plot bar chart to compare side-by-side median IBU and ABV data per state:
#  1. Merge the median ABV and median IBU data with the state data to
#     get a "wide" table.
#  2. For easier side-by-side comparison, multiply ABV by 807 to approximate
#     the same range of values.
#  3. Melt these facts to get a long table with ABV and IBU as variables,
#     and their values in the Value column
##############################################################################

library(reshape2)
BeerFacts <- merge(x=ABV_ByState,y=IBU_ByState,by="State")
BeerFacts$ABV <- BeerFacts$ABV * 807
BeerFacts.long <- melt(BeerFacts)
BeerFacts.long <- BeerFacts.long[order(BeerFacts.long$State),]

library(ggplot2)
theme(plot.title = element_text(hjust = 0.5))
theme_update(plot.title = element_text(hjust = 0.5))

ggplot(BeerFacts.long, aes(x=State,y=value,fill=factor(variable)))+
  geom_bar(stat="identity",position="dodge", width=0.8)+
  scale_fill_discrete(name="Measurement",
                      breaks=c(0,1),
                      labels=c("ABV","IBU"))+
  xlab("State")+ylab("Level")+
  ggtitle("Median ABV and Median IBU Per State")+  
  coord_flip()                                    # Sets value on y axis, states on x.                                 
                                                  # Comment out the + above and this
                                                  # line will reverse.

ggplot(ABV_ByState, aes(State,ABV))+   # This bar plot shows median ABV data per state
  geom_col(fill="#45415E")+
  coord_cartesian(ylim=c(0.03,0.075))+
  ggtitle("Median ABV Per State")+
  coord_flip()                         # sets value on y axis, states on x. 
                                       # Commenting out the + above and this 
                                       # line will reverse

ggplot(IBU_ByState, aes(State,IBU))+   # This bar plot shows median IBU data per state
  geom_col(fill="#91B3BC")+            # (South Dakota == 0)
  coord_cartesian(ylim=c(0,63))+
  ggtitle("Median IBU Per State")+
  coord_flip()                         # sets value on y axis, states on x. 
                                       # Commenting out the + above and this
                                       # line will reverse

# Which state has the beer with the highest alcohol content (ABV), and 
# which state has the most bitter beer (high IBU)?
############################################################################################

MaxABV <- aggregate(ABV ~ State,                 # Determine the state with the highest ABV.
                    data=BrewsAndBreweries,
                    max)
MaxABV <- MaxABV[order(-MaxABV$ABV),]

paste("With an ABV of ", (MaxABV[1, "ABV"]),
      ", ", (MaxABV[1, "State"]), 
      " has the beer with highest alcohol content: ", 
      BrewsAndBreweries$BeerName[which(BrewsAndBreweries$ABV==MaxABV[1, "ABV"])],
      ".", sep="")

MaxIBU <- aggregate(IBU ~ State,                 # Determine the state with the highest IBU.
                    data=BrewsAndBreweries, 
                    max)
MaxIBU <- MaxIBU[order(-MaxIBU$IBU), ]

paste("With an IBU of ", 
      (MaxIBU[1, "IBU"]), ", ", 
      (MaxIBU[1, "State"]), " has the beer with highest bitterness: ",
      BrewsAndBreweries$BeerName[which(BrewsAndBreweries$IBU==MaxIBU[1, "IBU"])],
      ".", sep="")


# Initial scatterplot of IBU and ABV and initial conclusion.
###########################################################
plot(x=BrewsAndBreweries$ABV, y=BrewsAndBreweries$IBU, 
     xlab = "Alcohol Content (ABV)", ylab = "Bitterness (IBU)", 
     main = "Relationship Between Bitterness and Alcohol Content")

# Positive correlation appears likely. Confirm with a correlation test to get Pearson's R.
cor.test(BrewsAndBreweries$ABV, BrewsAndBreweries$IBU)   # 66.6% of the variation in IBU
                                                         # is explained by a change in ABV.
# Getting the intercept and slope for abline
reg <- lm(IBU ~ ABV, data=BrewsAndBreweries)
reg

# A second scatterplot (ggplot2) to confirm our conclusion
################################################################

print(summary(BrewsAndBreweries$ABV)) 

# Add a factor column on the ABV to help visualize ABV in the next scatterplot:
# Number | Label      | Value of ABV
# ______ | __________ | ____________
# 1      | low        | min-050
# 2      | med low    | 0.050-0.059
# 3      | med high   | 0.060-0.069
# 4      | high       | 0.069-max
#

BrewsAndBreweries$ABVlvl[BrewsAndBreweries$ABV < 0.05 ] <- 1
BrewsAndBreweries$ABVlvl[BrewsAndBreweries$ABV
                         >= 0.05 &
                           BrewsAndBreweries$ABV < 0.06 ] <- 2
BrewsAndBreweries$ABVlvl[BrewsAndBreweries$ABV
                         >= 0.06 &
                           BrewsAndBreweries$ABV < 0.069 ] <- 3
BrewsAndBreweries$ABVlvl[BrewsAndBreweries$ABV >= 0.069 ] <- 4

ABVlabels <- c("low", "med low", "med high", "high")  # Create factor level labels.
BrewsAndBreweries$ABVlvl <- factor(BrewsAndBreweries$ABVlvl, labels = ABVlabels)

library(ggplot2)
ggplot(data = BrewsAndBreweries, aes(x=ABV, y=IBU, color = ABVlvl))+
  geom_point(size=2)+
  geom_abline(intercept=-34.1, slope = 1282.0)+
  ggtitle("Correlation Between ABV and IBU")

# Finish up: Write our data sets to file 
######################################################################
# Create tidy data files for future use.
TidyBeers <- BrewsAndBreweries[,c(2:7)]
TidyBreweries <- BrewsAndBreweries[,c(1,8:10)]
write.csv(TidyBeers,"TidyBeers.csv",row.names=FALSE)
write.csv(TidyBreweries,"TidyBreweries.csv",row.names=FALSE)

# Write the merged data set to a csv file:
write.csv(BrewsAndBreweries, file = "BrewsAndBreweries.csv", row.names=FALSE)
