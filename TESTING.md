# Steps for manual testing of the app

This document is to guide developers on how to manually test the app.
Steps should be followed in order and be done in a single session from start to finish. 

1. Open app: https://bcgov-env.shinyapps.io/shinywqbench/
2. Select chemical (-)-Riboflavin by name and hit run
	a. Go through tabs 1.1, 1.2 and 1.3 to confirm plots and tables have rendered properly and objects download 
3. Select chemical 100005 by CAS and hit run
	a. Select Penaeus chinensis row of data on tab 1.1 and remove data point by clicking on edit data button
		i. Row should go red
	b. Go to Tab 1.2 and confirm Penaeus chinensis is not in the plot 
	c. Go to Tab 1.3 and confirm Penaeus chinensis is not in the table
4. Go to Benchmark tab and hit Generate Benchmark
	a. Should take a couple minutes to run 5:41
		i. SSD should be run
		ii. Download SSD plot
		iii. Go to tab 2.2
			1)  Confirm output looks correct
			2) Download pdf and confirm same info and formatting is correct
5. Go to Summary Tab
	a. Download pdf report
	b. Download data set
6. Go to About Tab 
	a. Confirm it looks valid
	b. Check URLs are not broken 
	c. Check if ECOTOX version is up to date
	d. Check if wqbench version is up to date
	e. Check if shinywqbench is up to date
7. Go to User Guide
	a. Confirm formatting/content looks readable
	b. Check URLs are not broken 
8. Go back to Data Tab
	a. Confirm links in box that provides info on chemical name vs CAS
	b. Switch back to (-)-Riboflavin chemical, hit run
	c. Download data template
	d. Upload data template with a couple rows of data
	e. Hit add button
	f. Click through tabs and confirm new species were added
	g. Go to Benchmark tab and generate benchmark 
    i. Should run in seconds since it will be deterministic 
9. Go to Footer
  	a. Confirm all links are working
