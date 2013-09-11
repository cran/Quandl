R-package
=========
---

This is Quandl's R Package

License: GPL-2

For more information please contact raymond@quandl.com

# Installation #
---


## CRAN ##

To install the most recent package from CRAN type:

    > install.packages("Quandl")
    > library(Quandl)
    
Note that the version on CRAN might not reflect the most recent changes made to this package.

## Github ##

    git clone git://github.com/quandl/R-package.git
    R CMD build R-package/

This will create a file named "Quandl_VERSION.tar.gz". 

Then move the file into your working directory in R and type:

    > install.packages("Quandl_VERSION.tar.gz",repos=NULL,type="source")
    > library(Quandl)

A simpler solution is to use the 'devtools' package.

    > install.packages("devtools")
    > library(devtools)
    > install_github('R-package','quandl')
# Usage #
---

Once you find the data you'd like to load into R on Quandl, copy the Quandl code from the description box and past it into the function.

    > data <- Quandl("NSE/OIL")

To extend your access to the Quandl API, use your authentication token. To do this sign into your account (or create one) and go to the API tab under in your account page. Then copy your authentication token and type(with quotes):

    > Quandl.auth("authenticationtoken")

This will then extend your usage.

To check how much usage you have left type:

    > Quandl.limit()

This number is updated everytime Quandl is called or when passed force_check=TRUE.

### Example ###
Create a graph of the Nasdaq, with a monthly frequency
	 
	 plot(stl(Quandl("GOOG/NASDAQ_GOOG",type="ts",collapse="monthly")[,1],s.window="per"))


## Uploads ##
There are a few things you need to do before you can proceed with uploading data.
 * Make an account and set your authentication token within the package with the Quandl.auth() function.
 *   Get your data into a data frame with the dates in the first column.
 * Pick a code for your dataset - only capital letters, numbers and underscores are acceptable.

Then call this function 	

	Quandl.push(code="TEST", name="This is a test dataset", desc="This description can include extra information about the time series including units,data=yourdataset)`

The function returns a link to your newly created dataset. The description is optional but all other fields are mandatory.

If you would like to overwrite the dataset TEST with another dataset, call the function again with the parameter

    override=TRUE
    

### Example ###
Downloading a partial dataset and uploading it with code TEST. 

    Quandl.auth("enteryourauthenticationtoken")
    mydata = Quandl("NSE/OIL", rows=5)
    Quandl.push("TEST","This is a test dataset","This is a 	description",mydata)
    

Will return a link to your newly uploaded dataset
    
## Search ##
Searching Quandl from within the R console is now supported. An authorization token is not required, but for extended use specify your token using `Quandl.auth()`.  The search function is:

	Quandl.search(query = "Search Term", page = n, source = "Specific source to search", silent = TRUE|FALSE)

* **Query**: Required; Your search term, as a string
* **Page**: Optional; page number of search you wish returned, defaults to 1.
* **Source**: Optional; Name of a specific source you wish to search, as a string
* **Silent**: Optional; specifies whether you wish the first three results printed to the console, defaults to True (see example below).

Which returns a list containing the following information for every item returned by the search:

* Name
* Quandl code
* Description
* Frequency
* Column names  


###Example###
A search for Oil,  searching only the National Stock Exchange of India (NSE).

	Quandl.search("Oil", source = "NSE")
	
prints:

	Oil India Limited
	Code: NSE/OIL
	Desc: Historical prices for Oil India Limited (OIL), (ISIN: INE274J01014),  National Stock Exchange of India.
	Freq: daily
	Cols: Date|Open|High|Low|Last|Close|Total Trade Quantity|Turnover (Lacs)

	Crude Oil (petroleum) Price
	Code: IMF/POILAPSP_INDEX
	Desc: Crude Oil (petroleum), Price index, 2005 = 100, simple average of three spot prices; Dated Brent, West Texas Intermediate, and the Dubai Fateh
	Freq: monthly
	Cols: Date|Price

	China Crude Oil Consumption
	Code: INDEXMUNDI/ENERGY_CHINA_CRUDEOIL
	Desc: Energy production of Crude Oil in China. Units=Thousand Barrels per Day
	Freq: annual
	Cols: Year|Thousand Barrels per Day

# Additional Resources #
---
    
More help can be found at [Quandl](http://www.quandl.com) in our [R](http://www.quandl.com/help/r) and [API](http://www.quandl.com/api) help pages.
