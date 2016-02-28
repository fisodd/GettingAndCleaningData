# CodeBook for Getting and Cleaning Data Project Results

This codebook is to explain the file generated to satisfy
the requirements of the Week 4 project in the Getting and Cleaning Data
course that is part of the Data Science Specialization in
Coursera from John Hopkins University.


## Background


### Motivations

The specific demand of this assignment was to pull data from
several source files into one tidy data set,
c.f. http://vita.had.co.nz/papers/tidy-data.pdf

In addition to the tidy requirements,
the course lectures covered several important points about text in data sets  
* Names of variables should be  
   + All lower case when possible  
   + Descriptive  
   + Not duplicated  
   + Not have underscores or dots or white spaces  
* Variables with character values  
   + Should usually be made into factor variables  
   + Should be descriptive  
   
These two sources were the basis of the implementation decisions.


#### Tidy Data Form

As is described in the original Tidy Data paper,
the requirements are summarized as:

>  In tidy data:
>     1. Each variable forms a column.
>     2. Each observation forms a row.
>     3. Each type of observational unit forms a table

In this case we have retained the 'wide' format
that flows from how the source data is provided,
but care was taken to merge the datasets together
so there is only one row for each observation (where an
observation is a 'subjectid' performing an 'activity'
at a point in time).  Our variables then are the
'subjectid', the 'activity', and a column for each
of the measured variables (or features as the source
refers to them).  This does lead to the table being
wide, but still in accordance with the principles of
tidy data.

Note: further discussion of the ways that this assignment
can be tidied can be found at
https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/


#### Descriptive Variable Names

One of the key decisions was how to manage column labels for the
more than 500 columns in the original dataset.
With this many columns it is not a simple task for the names to all be
descriptive, short, and devoid of special characters.
The description files supplied with the source data does include
a 'features.txt' file that provides a descriptive name for each of
the 561 variables, which sort and descriptive -- but these names do rely
on a fair degree of special characters: parentheses, commas, dashes
are all in common use in the provided names and do need some
processesing to make them suitable for use as column names.

If implementing for other customers,
use of the '.' conventions as provided by R's oft-cited 'make.names()'
function and replace some of these special characters and strip the rest.
However, the direction here was
'not to have underscores or dots or white spaces',
so in this case all such characters were stripped;
and in accorance with the directions,
the remaining characters were lower-cased.

Though not actually exported into the final dataset,
there was one set of names that required special handling
as the provided 'features.txt' mapping did repeat names
for features from the 'bandsEnergy()' sensoring,
each was repeated three times.
The comments in the 'features_info.txt' file noted
that this sensoring was from 3D work so the interim
processing applied 'X', 'Y', and 'Z' suffixes to
ensure that we maintained unique names throughout
the processing.


## Source

The source for this data is via the UCI Machine Learning Repository
as the Human Activity Recognition Using Smartphones Dataset.
See 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

For the purposes of this class exercise, we obtain the file
directly from the link provided in the class materials:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The action of unzipping this download creates a directory,
'UCI HAR Dataset'.  This documentation and the associated
script assumes that this directory exists (or it will be
rebuilt) and that the files are available there for access and review.

The materials for this work are taken from a train and a test dataset
used for developing models to detect 6 defined activities from a
wide series of readings and derived readings from the sensors on
a smartphone worn by the study participants.

Specifically, we pull the contents of three files in each of the
test and the train directories.

* 'subject_test.txt' and 'subject_train.txt' -- contain a single column
  of integers in the range of 1:30 marking which participant is the subject
  of the measurement at that point (for that row in the datafiles)
  
* 'y_test.txt' and 'y_train.txt' -- contain a single column of integers
  in the range of 1:6 marking which activity is being performed at that
  point (for that row in the datafiles)

* 'X_test.txt' and 'X_train.txt' -- contain the measurements, 561 columns
  of readings at each point (matching row by row the "subject" and "y" files)

Also there are two desciptive files used.

* 'features.txt' -- maps each of the 561 columns of values to a name of
  the sensor reading (or derived value), more complete information is
  available in the 'features_info.txt' file.
  
* 'activity_labels.txt' -- provides a mapping of the 6 activity levels (1:6)
  to a descriptive name.
  

## Transformations

All transformations can be reviewed and redone via the 'run_analysis.R'
script provided with this CodeBook.

0. Download and unzip the complete data set file if necessary.

1. Each of the files noted above is read into its own dataframe.

2. Rework the values from the 'features.txt' file into suitable
  form for use as column names for the "X" measurements.

3. Column names are added.  For the "X" files the column names come
  from the 'features.txt' values as reworked above.  For the "Y" files
  the one column is given a fixed name of 'activity'.  Similarly for
  the "subject" files the single column is given a fixed name of
  'subjectid'
  
4. Bind the tables into one tidier form.  First 'cbind()' to bring
  the 'subjectid' and the 'activity' together with the "X" columns;
  perform this column binding for both the "test" and the "train" files.
  Then 'rbind()' the "test" and "train" parts together.
  
5. Extract the specific columns requested.  The 'subjectid' and 'activity'
  columns are selected directly, but for the rest only those that match
  a regular expression seeking 'mean' or 'std' (for standard deviation)
  are selected.  Note: most cases where there is a 'mean' variable
  there is a 'std' variable next, but there are are a few readings
  where a "mean" is calculated but not any standard deviation, notably
  'meanFreq()', for the sake of this exercise (to err with a broader
  reading of the requirements) these extra "mean" measurements are
  retained.

6. Update 'activity' values (1:6) to be replaced by activity labels
  read in from the 'activity_labels.txt' file.  The labels are read in
  as factors, and are used as factors to replace the integer values.
  
7. Calculate averages by activity and subjectid.  We use 'aggregate()'
  by '. ~ subjectid + activity' to compute an average value for all
  the remaining columns for each pairing of 'subjectid' and 'activity'
  
8. Write the result via a simple call:
  'write.table(DATAFRAME, FILENAME, row.names = FALSE)'  The resulting file
  should be readily available as simply:
  'df <- read.table(FILENAME, header = TRUE)'
  
  
## File Contents

The file is written as a text file, with quoted strings for the header row,
and text strings for the factors in the first column.

The first column is a factor variable for which activity was involved.
The factor is mapped according to the values in 'activity_labels.txt'
based on the values in 'y_test.txt' and 'y_train.txt'.

The second column is an integer ID value designating the test subject.
This is a copy of the value in 'subject_test.txt' and 'subject_train.txt'.

All the remaining are averages of the readings for that variable during
the measured time when that test subject performed that activity.
These values come from the 'X_test.txt' and 'X_train.txt' files.
The mapping of these column names to their position in the 'X' files
can be found in the 'X Col' column below along with the sensor function
name for the corresponding feature (which is described in 'features_info.txt')

Note: the specification for this assignment requested 'only the measurements
on the mean and standard deviation for each measurement', but given the full
list of 561 features it turns out that this requirement is somewhat ambiguous.
For this solution we have chosen to be permissive on the matching of 'mean'
and hence have included features of the type 'meanFreq()'.
A permissive interpretation was chosen based on the
assumption that if these meanFreq() features are not needed
they can be readily dropped from a data.frame at a later time
[e.g. by the use of dplyr::select(-contains('meanfreq')) or other method.]

A summary of the 88 columns follows:

                          Column Name                 Sensor Feature Value   X Col
                             activity                                   NA      NA
                            subjectid                                   NA      NA
                        tbodyaccmeanx                    tBodyAcc-mean()-X       1
                        tbodyaccmeany                    tBodyAcc-mean()-Y       2
                        tbodyaccmeanz                    tBodyAcc-mean()-Z       3
                         tbodyaccstdx                     tBodyAcc-std()-X       4
                         tbodyaccstdy                     tBodyAcc-std()-Y       5
                         tbodyaccstdz                     tBodyAcc-std()-Z       6
                     tgravityaccmeanx                 tGravityAcc-mean()-X      41
                     tgravityaccmeany                 tGravityAcc-mean()-Y      42
                     tgravityaccmeanz                 tGravityAcc-mean()-Z      43
                      tgravityaccstdx                  tGravityAcc-std()-X      44
                      tgravityaccstdy                  tGravityAcc-std()-Y      45
                      tgravityaccstdz                  tGravityAcc-std()-Z      46
                    tbodyaccjerkmeanx                tBodyAccJerk-mean()-X      81
                    tbodyaccjerkmeany                tBodyAccJerk-mean()-Y      82
                    tbodyaccjerkmeanz                tBodyAccJerk-mean()-Z      83
                     tbodyaccjerkstdx                 tBodyAccJerk-std()-X      84
                     tbodyaccjerkstdy                 tBodyAccJerk-std()-Y      85
                     tbodyaccjerkstdz                 tBodyAccJerk-std()-Z      86
                       tbodygyromeanx                   tBodyGyro-mean()-X     121
                       tbodygyromeany                   tBodyGyro-mean()-Y     122
                       tbodygyromeanz                   tBodyGyro-mean()-Z     123
                        tbodygyrostdx                    tBodyGyro-std()-X     124
                        tbodygyrostdy                    tBodyGyro-std()-Y     125
                        tbodygyrostdz                    tBodyGyro-std()-Z     126
                   tbodygyrojerkmeanx               tBodyGyroJerk-mean()-X     161
                   tbodygyrojerkmeany               tBodyGyroJerk-mean()-Y     162
                   tbodygyrojerkmeanz               tBodyGyroJerk-mean()-Z     163
                    tbodygyrojerkstdx                tBodyGyroJerk-std()-X     164
                    tbodygyrojerkstdy                tBodyGyroJerk-std()-Y     165
                    tbodygyrojerkstdz                tBodyGyroJerk-std()-Z     166
                      tbodyaccmagmean                   tBodyAccMag-mean()     201
                       tbodyaccmagstd                    tBodyAccMag-std()     202
                   tgravityaccmagmean                tGravityAccMag-mean()     214
                    tgravityaccmagstd                 tGravityAccMag-std()     215
                  tbodyaccjerkmagmean               tBodyAccJerkMag-mean()     227
                   tbodyaccjerkmagstd                tBodyAccJerkMag-std()     228
                     tbodygyromagmean                  tBodyGyroMag-mean()     240
                      tbodygyromagstd                   tBodyGyroMag-std()     241
                 tbodygyrojerkmagmean              tBodyGyroJerkMag-mean()     253
                  tbodygyrojerkmagstd               tBodyGyroJerkMag-std()     254
                        fbodyaccmeanx                    fBodyAcc-mean()-X     266
                        fbodyaccmeany                    fBodyAcc-mean()-Y     267
                        fbodyaccmeanz                    fBodyAcc-mean()-Z     268
                         fbodyaccstdx                     fBodyAcc-std()-X     269
                         fbodyaccstdy                     fBodyAcc-std()-Y     270
                         fbodyaccstdz                     fBodyAcc-std()-Z     271
                    fbodyaccmeanfreqx                fBodyAcc-meanFreq()-X     294
                    fbodyaccmeanfreqy                fBodyAcc-meanFreq()-Y     295
                    fbodyaccmeanfreqz                fBodyAcc-meanFreq()-Z     296
                    fbodyaccjerkmeanx                fBodyAccJerk-mean()-X     345
                    fbodyaccjerkmeany                fBodyAccJerk-mean()-Y     346
                    fbodyaccjerkmeanz                fBodyAccJerk-mean()-Z     347
                     fbodyaccjerkstdx                 fBodyAccJerk-std()-X     348
                     fbodyaccjerkstdy                 fBodyAccJerk-std()-Y     349
                     fbodyaccjerkstdz                 fBodyAccJerk-std()-Z     350
                fbodyaccjerkmeanfreqx            fBodyAccJerk-meanFreq()-X     373
                fbodyaccjerkmeanfreqy            fBodyAccJerk-meanFreq()-Y     374
                fbodyaccjerkmeanfreqz            fBodyAccJerk-meanFreq()-Z     375
                       fbodygyromeanx                   fBodyGyro-mean()-X     424
                       fbodygyromeany                   fBodyGyro-mean()-Y     425
                       fbodygyromeanz                   fBodyGyro-mean()-Z     426
                        fbodygyrostdx                    fBodyGyro-std()-X     427
                        fbodygyrostdy                    fBodyGyro-std()-Y     428
                        fbodygyrostdz                    fBodyGyro-std()-Z     429
                   fbodygyromeanfreqx               fBodyGyro-meanFreq()-X     452
                   fbodygyromeanfreqy               fBodyGyro-meanFreq()-Y     453
                   fbodygyromeanfreqz               fBodyGyro-meanFreq()-Z     454
                      fbodyaccmagmean                   fBodyAccMag-mean()     503
                       fbodyaccmagstd                    fBodyAccMag-std()     504
                  fbodyaccmagmeanfreq               fBodyAccMag-meanFreq()     513
              fbodybodyaccjerkmagmean           fBodyBodyAccJerkMag-mean()     516
               fbodybodyaccjerkmagstd            fBodyBodyAccJerkMag-std()     517
          fbodybodyaccjerkmagmeanfreq       fBodyBodyAccJerkMag-meanFreq()     526
                 fbodybodygyromagmean              fBodyBodyGyroMag-mean()     529
                  fbodybodygyromagstd               fBodyBodyGyroMag-std()     530
             fbodybodygyromagmeanfreq          fBodyBodyGyroMag-meanFreq()     539
             fbodybodygyrojerkmagmean          fBodyBodyGyroJerkMag-mean()     542
              fbodybodygyrojerkmagstd           fBodyBodyGyroJerkMag-std()     543
         fbodybodygyrojerkmagmeanfreq      fBodyBodyGyroJerkMag-meanFreq()     552
             angletbodyaccmeangravity          angle(tBodyAccMean,gravity)     555
     angletbodyaccjerkmeangravitymean angle(tBodyAccJerkMean),gravityMean)     556
        angletbodygyromeangravitymean     angle(tBodyGyroMean,gravityMean)     557
    angletbodygyrojerkmeangravitymean angle(tBodyGyroJerkMean,gravityMean)     558
                    anglexgravitymean                 angle(X,gravityMean)     559
                    angleygravitymean                 angle(Y,gravityMean)     560
                    anglezgravitymean                 angle(Z,gravityMean)     561


