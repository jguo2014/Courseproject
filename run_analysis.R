## Script cleans sensor data from Galaxy S device for analysis.
## 1. Merges the training and test sets to create "finalData" data set.
## 2. Cleans all working files.
## 3. Get the dataLables and calculate average of mean and std.
## 4. Decode activity label and put result in new activity name column.
## 5. Output the cleanData to current directory 


## Load required libraries.
library(plyr)
library(reshape2)

## Prepare data for processing.
trainSubj<-read.table("./UCI HAR Dataset/train/subject_train.txt")
trainY<-read.table("./UCI HAR Dataset/train/y_train.txt")
trainX<-read.table("./UCI HAR Dataset/train/X_train.txt")
testSubj<-read.table("./UCI HAR Dataset/test/subject_test.txt")
testY<-read.table("./UCI HAR Dataset/test/y_test.txt")
testX<-read.table("./UCI HAR Dataset/test/X_test.txt")
features<-read.table("./UCI HAR Dataset/features.txt")
activityLabels<-read.table("./UCI HAR Dataset/activity_labels.txt")

## Merge train and test files.
trainData<-cbind(trainSubj, trainY, trainX)
testData<-cbind(testSubj, testY, testX)
finalData<- rbind(trainData, testData )

## Remove working files.
rm(trainSubj,testSubj,trainY,testY,trainX,testX)

# Read data labels for column name of finaleSet 
dataLabels <- read.table("./UCI HAR Dataset/features.txt")$V2

## Clean feature names removing '()'
dataLabels<-gsub("([()])", "", dataLabels)

dataLabels <- append(c("Subject", "Activity"), dataLabels)
colnames(finalData)<-dataLabels

# Determine the columns which we want. Explanation of regular expressions:

dataColumns <- grep("std|-mean-|-mean$", names(finalData))
dataColumns <- append(c(1, 2), dataColumns)

# Apply subset to get only mean and standard deviations
finalSet <- finalData[dataColumns]

## Decode activity label and put result in new activity name column.
finalSet$Activity<-activityLabels[finalSet$Activity,2]

# Melt and recast to get cleanData
myMelt <- melt(finalSet, id = c("Subject", "Activity"),
                   measure.vars = names(finalSet)[-c(1, 2)])
cleanData <- dcast(myMelt, Subject + Activity ~ variable, mean)

# Check if file exists. If it does, delete it.
if (file.exists("./cleanData.txt")) { unlink("./cleanData.txt") }

# Write cleanData and put under current directory

write.table(cleanData, file="./cleanData.txt", row.name=FALSE)



