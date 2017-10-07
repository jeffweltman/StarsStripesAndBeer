Beers <- "https://raw.githubusercontent.com/jeffweltman/StarsStripesAndBeer/master/Raw/Beers.csv" 
DFBeers <- repmis::source_data(Beers)

Breweries <- "https://raw.githubusercontent.com/jeffweltman/StarsStripesAndBeer/master/Raw/Breweries.csv"
DFBreweries <- repmis::source_data(Breweries)

colnames(DFBeers) <- c("BeerName","Beer_ID","ABV","IBU","Brewery_ID","Style","Ounces")
colnames(DFBreweries) <- c("Brewery_ID","BreweryName","City","State")

BrewsAndBreweries <- merge(x=DFBeers, y=DFBreweries, by="Brewery_ID", all=TRUE)

colSums(is.na(BrewsAndBreweries),na.rm=FALSE)

 Brewery_ID    BeerName     Beer_ID         ABV         IBU        Syle      Ounces BreweryName        City 
          0           0           0          62        1005           0           0           0           0 
      State 
          0 

BreweryCount <- sqldf("select count(distinct(Brewery_id)) as BreweryCount, State from BrewsAndBreweries group by State")

OR

##### ans = as.data.table(BrewsAndBreweries)[, count := uniqueN(Brewery_id), by = State] will add to a table, but meh

BreweryCount <- BreweryCount[-1,]
# removed the NAs

head(BrewsAndBreweries,6)
tail(BrewsAndBreweries,6)
medianIBU <-median(BrewsAndBreweries$IBU, na.rm=TRUE)
ABV_ByState <- aggregate(ABV ~ State, data=BrewsAndBreweries, median)
IBU_ByState <- aggregate(IBU ~ State, data=BrewsAndBreweries, median)

MaxABV <- aggregate(ABV ~ State, data=BrewsAndBreweries, max)
MaxABV <- MaxABV[order(-MaxABV$ABV),]
head(MaxABV)
 State   ABV
6     CO 0.128

MaxIBU <- aggregate(IBU ~ State, data=BrewsAndBreweries, max)
MaxIBU <- MaxIBU[order(-MaxIBU$IBU),]
head(MaxIBU)
   State IBU
38    OR 138

summary(BrewsAndBreweries$ABV)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
0.00100 0.05000 0.05600 0.05977 0.06700 0.12800      62 
