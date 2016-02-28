# Run Analysis
# By Alexander Carlton
# In February 2016
#
# Getting and Cleaning Data Course Project
# Week 4 of Getting and Cleaning Data
# Part of the John Hopkins Coursera Data Science Certification Series

# This code is intended to work with a copy of some of the data
# from the UCI Human Activity Recognition projects
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# 
# The work performed is to load the datafiles for the test and train datasets
# (not including the raw materials inside the 'Inertial Signals' directory)
# These datasets are to be joined correctly to create a single tidy dataset

# The assigmnent states:
# You should create one R script called run_analysis.R that does the following.
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation
#    for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

# Important files for this script
# 'UCI HAR Dataset' -- directory created when unzipping downloaded file
# 'test' and 'train' -- subdirectories, each with a subset of the desired data
# '.../test/subject_test.txt' has 1 column, an integer
# '.../train/subject_train.txt', 1 column (integer) different values than test
# '.../test/y_test.txt' has 1 column, an integer (maps to activities)
# '.../train/y_train.txt', 1 column (integer) same values as for test
# '.../test/X_test.txt' has many columns, all reals in scientific notation
# '.../train/X_train.txt' has many columns, all reals in scientific notation
# '.../features.txt' names for columns in 'X' files, details in 'features_info.txt'
# '.../activity_labels.txt' names for activities in 'y' files

###############################################################################
# Configuration

#
# Libraries required
#
library(dplyr)              # Favorite way to tidy datasets

#
# File and path names
#
basedir <- 'UCI HAR Dataset'
testdir <- 'test'
traindir <- 'train'
testXfile <- 'X_test.txt'
testYfile <- 'y_test.txt'
testSfile <- 'subject_test.txt'
trainXfile <- 'X_train.txt'
trainYfile <- 'y_train.txt'
trainSfile <- 'subject_train.txt'
featuresfile <- 'features.txt'
activityfile <- 'activity_labels.txt'
writefile <- 'UCI-HAR-tidied-and-averaged.txt'


###############################################################################
# Fetch and read the files

#
# (Re)Fetch from source if necessary
#
if (!dir.exists(basedir)) {
    # Then we need to (re)fetch and unzip to local working directory
    
    url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
    file <- 'getdata-projectfiles-UCI HAR Dataset.zip'

    if (!file.exists(file)) {
        message('(Re)Fetching dataset...')
        download.file(url, file)
    }
    message('Unzipping dataset...')
    filelist <- unzip(file)
}

message('Reading data files...')

#
# Read data from local files into dataframes
#
testSdf <- read.table(file.path(basedir, testdir, testSfile))
testYdf <- read.table(file.path(basedir, testdir, testYfile))
testXdf <- read.table(file.path(basedir, testdir, testXfile))
trainSdf <- read.table(file.path(basedir, traindir, trainSfile))
trainYdf <- read.table(file.path(basedir, traindir, trainYfile))
trainXdf <- read.table(file.path(basedir, traindir, trainXfile))

# Check dataframes seem to be of the right sizes
print('Dimensions for dataframes loaded:')
print(dim(testSdf))
print(dim(testYdf))
print(dim(testXdf))
print(dim(trainSdf))
print(dim(trainYdf))
print(dim(trainXdf))


###############################################################################
# "Appropriately labels the data set with descriptive variable names."

message('Fetching and applying feature names...')

#
# Read feature names
#
featuresdf <- read.table(file.path(basedir, featuresfile), stringsAsFactors = FALSE)
print('Dimension for features file [should match column count for X-files]')
print(dim(featuresdf))

#
# Massage feature names to be useful (and valid) column names
#

# The transformations below use the '-' (dash) as a parts separator
# this is following the convention in the source
# but obviously dash can be parsed as a minus sign hence is not suitable
# As a last transformation the dashes could be replaced with dots,
# but in this case the customer specifies no dots, so they are just striped out

# Get a vector of names to work with
desc_var_names <- featuresdf$V2

# 'bandsEnergy()' feature labels repeat in sets of three, substitute to add X/Y/Z
desc_var_names[303:316] <- sub('bandsEnergy', 'bandsEnergy-X', desc_var_names[303:316])
desc_var_names[317:330] <- sub('bandsEnergy', 'bandsEnergy-Y', desc_var_names[317:330])
desc_var_names[331:344] <- sub('bandsEnergy', 'bandsEnergy-Z', desc_var_names[331:344])
desc_var_names[382:395] <- sub('bandsEnergy', 'bandsEnergy-Y', desc_var_names[382:395])
desc_var_names[396:409] <- sub('bandsEnergy', 'bandsEnergy-Z', desc_var_names[396:409])
desc_var_names[461:474] <- sub('bandsEnergy', 'bandsEnergy-X', desc_var_names[461:474])
desc_var_names[475:488] <- sub('bandsEnergy', 'bandsEnergy-Y', desc_var_names[475:488])
desc_var_names[489:502] <- sub('bandsEnergy', 'bandsEnergy-Z', desc_var_names[489:502])

# simplify 'angle(); feature labels [parens get stripped later]
desc_var_names <- sub('angle', 'angle-', desc_var_names)

# Lower case, to avoid typos later
desc_var_names <- tolower(desc_var_names)

# Strip difficult characters
desc_var_names <- gsub('[()_. ]', '', desc_var_names)

# Replace '1,2' with an easier '1-2'
desc_var_names <- sub(',', '-', desc_var_names)

# Strip out all dashes (could use dots, but customer doesn't like dots)
desc_var_names <- gsub('-', '', desc_var_names)

# Sanity check: list of names should match features, and all are unique
print('Fixed features to be names, count of all should match count of unique:')
print(length(desc_var_names))
print(length(unique(desc_var_names)))

# Use the descriptive names for the columns
names(testXdf) <- desc_var_names
names(trainXdf) <- desc_var_names
names(testYdf) <- 'activity'
names(trainYdf) <- 'activity'
names(testSdf) <- 'subjectid'
names(trainSdf) <- 'subjectid'


###############################################################################
# "Merges the training and the test sets to create one data set."

message('Merging data sets...')

# Now we can cbind together without column duplication
# Subject, then Activity, then measurements
testdf <- cbind(testSdf, testYdf, testXdf)
traindf <- cbind(trainSdf, trainYdf, trainXdf)

# Finally rbind the test and train dataframes
fulldf <- rbind(traindf, testdf)

# Sanity check: columns should match #features +2, and rows should be test+train
print('Dimension of full dataframe')
print(dim(fulldf))


###############################################################################
# "Extracts only the measurements on the mean and standard deviation for each measurement."

message('Extracting desired columns...')

# create a dataframe by selecting desired columns from full dataframe
df <- fulldf %>% select(
    one_of(c('subjectid', 'activity')),  # Keep the non-measurement columns
    matches('mean|std')                  # Keep all cols that are mean or std
)

# Sanity Check: column count should match expectations
print('Dimension of desired dataframe')
print(dim(df))


###############################################################################
# "Uses descriptive activity names to name the activities in the data set"

message('Updating activity labels...')

#
# Change Activity codes to be Activity names
#

# Read the activity labels file
activitydf <- read.table(file.path(basedir, activityfile))

# Extract the labels and the numeric codes
desc_activity_labels <- tolower(activitydf$V2)
desc_activity_levels <- activitydf$V1

# replace activity codes with corresponding activity label (as a factor)
df$activity <- factor(df$activity, desc_activity_levels, desc_activity_labels)

# Sanity Check: should have a reasonable count of activites for each label
print('Count of rows for each type of activity:')
print(summary(df$activity))


###############################################################################
# "creates a second, independent tidy data set with the average of each variable for each activity and each subject."

message('Calculating averages...')

# Calc averages by activity and subjectid
avgdf <- aggregate(. ~ activity + subjectid, data = df, mean)

# Sanity Check: check the first few rows and the first few cols
print('Dimension of dataframe of average values:')
print(dim(avgdf))
print('Upper left corner of dataframe of averages:')
print(avgdf[1:20,1:5])


###############################################################################
# Save resulting dataframe

message('Saving results...')

# Write out smaller avg dataframe
write.table(avgdf, writefile, row.names = FALSE)
print(paste('Write complete, see', writefile, 'for specified results'))

# Sanity Check: read the file with simple call and check for issues
newdf <- read.table(writefile, header = TRUE)
print('Reload written dataframe; size and upper-left follow')
print(dim(newdf))
print(newdf[1:20,1:5])

# Done
message('End of processing...')
