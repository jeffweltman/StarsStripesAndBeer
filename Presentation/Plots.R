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
#                                                                    #
#  Plots.r - Plots and Diagnostics on ABV and IBU data               #
#                                                                    #
######################################################################

# Read in master data file outputted from Analysis.R

BrewsAndBreweriesURL <- "https://raw.githubusercontent.com/jeffweltman/StarsStripesAndBeer/master/Data/BrewsAndBreweries.csv"
BrewsAndBreweries <- repmis::source_data(BrewsAndBreweriesURL)

# Initial scatterplot of IBU and ABV

plot(x=BrewsAndBreweries$ABV, y=BrewsAndBreweries$IBU, xlab = "Alcohol Content (ABV)", ylab = "Bitterness (IBU)", main = "Relationship Between Bitterness and Alcohol Content")

# A positive correlation does appear likely. Let's confirm with a correlation test to get Pearson's R.

cor.test(BrewsAndBreweries$ABV, BrewsAndBreweries$IBU)

# Getting the intercept and slope for abline
reg <- lm(IBU ~ ABV, data=BrewsAndBreweries)
reg

# Now we can peform a scatterplot in ggplot2 - perhaps it might be more enlightening?
library(ggplot2)
ggplot(BrewsAndBreweries, aes(x=ABV, y=IBU)) + geom_point(size=2) + geom_abline(intercept=-34.1, slope = 1282.0)
