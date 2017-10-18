# Stars, Stripes, and Beer - README.md
Jeff Weltman and Claudia Woodruff

## Project Description
W&W Analytics has been commissioned by *Stars, Stripes, and Beer Co.* - hereafter referred to as *SS&B* - to analyze a sample of the craft beer market in order to answer the following research questions:

* How many breweries are present in each state?
* What is the median alcohol content (ABV) for each state? What is the median international bitterness unit (IBU) for each state?
* Which state has the maximum alcoholic (ABV) beer? Which state has the most bitter (IBU) beer?
* Is there any apparent relationship between the bitterness of the beer and its alcoholic content

## Directory Structure:

* *Analysis directory*
  + *Analysis.R* - R script for ingesting raw data, tidying the data, and answering research questions
  + *Readme.md*
* *Data directory*
  + *BrewsAndBreweries.csv* - Merged tidy data file
  + *Readme.md*
  + *TidyBeers.csv* - Tidy beer data file
  + *TidyBreweries.csv* - Tidy breweries data file
* *Presentation directory*
  + *Readme.md*
  + *WW_Logo.png* - Our logo
  + Final presentation document (various extensions)
    * StarsStripsAndBeerFinal.Rmd
    * StarsStripsAndBeerFinal.md
    * StarsStripsAndBeerFinal.html
    * StarsStripsAndBeerFinal.docs
* *Raw directory*
  + *Beers.csv* - Raw beer data file
  + *Breweries.csv* - Raw breweries data file
  + *Readme.csv*
* *Project Root*
  + Project codebook (various extensions)
    * Codebook.Rmd
    * Codebook.md
    * Codebook.html
  + *README.md*
  + *StarsStripesAndBeer.rproj*
  
## FAQs
### Where did this data come from?
*These data were collected from the public domain across a variety of sources, including *ratebeer.com*, the craft breweries' websites, and social media.*
  
### I especially loved (insert plot/section here). Which one of you is responsible for this?
This project for *SS&B* was a truly collaborative endeavor. Both Claudia and Jeff applied their expertise to the research questions, data files, and code. The Codebook and this Readme have been prepared largely by Jeff. The final presentation document was largely Claudia's masterpiece.
  
### Do you have a way I could view this presentation on the web?
*We do indeed! Jeff created a Shiny app for just that purpose.*
*For access to this interactive web presentation, visit http://192.241.226.80/shiny/StarsStripesAndBeer/*

### This is exceptional work! Can I contact W&W Analytics regarding other projects?
*We would love to hear from you! Thank you for your interest.*
  
***
  
### Session Info
**R version 3.4.0 (2017-04-21)**

**Platform:** x86_64-w64-mingw32/x64 (64-bit) 

**locale:**
_LC_COLLATE=English_United States.1252_, _LC_CTYPE=English_United States.1252_, _LC_MONETARY=English_United States.1252_, _LC_NUMERIC=C_ and _LC_TIME=English_United States.1252_

**attached base packages:** 
_stats_, _graphics_, _grDevices_, _utils_, _datasets_, _methods_ and _base_

**other attached packages:** 
_pander(v.0.6.1)_, _ggplot2(v.2.2.1)_, _reshape2(v.1.4.2)_, _sqldf(v.0.4-11)_, _RSQLite(v.2.0)_, _gsubfn(v.0.6-6)_ and _proto(v.1.0.0)_

**loaded via a namespace (and not attached):** 
_Rcpp(v.0.12.12)_, _compiler(v.3.4.0)_, _plyr(v.1.8.4)_, _R.methodsS3(v.1.7.1)_, _R.utils(v.2.5.0)_, _tools(v.3.4.0)_, _digest(v.0.6.12)_, _bit(v.1.1-12)_, _evaluate(v.0.10.1)_, _memoise(v.1.1.0)_, _tibble(v.1.3.4)_, _gtable(v.0.2.0)_, _R.cache(v.0.12.0)_, _pkgconfig(v.2.0.1)_, _rlang(v.0.1.2)_, _DBI(v.0.7)_, _curl(v.2.8.1)_, _yaml(v.2.1.14)_, _httr(v.1.3.1)_, _stringr(v.1.2.0)_, _knitr(v.1.17)_, _rprojroot(v.1.2)_, _bit64(v.0.9-7)_, _grid(v.3.4.0)_, _data.table(v.1.10.4)_, _R6(v.2.2.2)_, _rmarkdown(v.1.6)_, _blob(v.1.1.0)_, _magrittr(v.1.5)_, _scales(v.0.5.0)_, _backports(v.1.1.1)_, _htmltools(v.0.3.6)_, _repmis(v.0.5)_, _colorspace(v.1.3-2)_, _labeling(v.0.3)_, _stringi(v.1.1.5)_, _lazyeval(v.0.2.0)_, _munsell(v.0.4.3)_, _chron(v.2.3-50)_ and _R.oo(v.1.21.0)_
  
