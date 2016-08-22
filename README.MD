# UW DS 450 Capstone Project

## To Run (Prepare Data)

1. download the data files (see /data/README.MD)
2. Run /prepareData.R

At this point, the script should have processed the data and created results in the /output folder.

## Notes on the directory structure

/adjusted-data
 - output data files that were slightly changed from the original (e.g. only unique rows from original data set)

/data
 - see README.MD inside this directory
 
/output
 - files created while certain scripts are run are saved here

/prepareAdjustedData.R
 - created data files slightly changed from the originals (e.g. only unique rows from original data set)

/prepareData.R
 - The main entry point for reading and manipulating the data.
 
/prepareDataUtils.R
 - utilities for flattening the data (used by prepareData.R)

/sup-data
 - supplemental data that was not included in the original /data files

