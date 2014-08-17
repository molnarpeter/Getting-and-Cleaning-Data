# Download the data into the project_data directory and unzip it

if (!file.exists("project_data")) {
  dir.create("project_data")
  setwd("./project_data")
  url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
  dest <- 'data.zip'
  download.file(url ,destfile = dest)
  unzip(dest)
} 

# Note that I use Windows so maybe for Mac method = "curl" should be added in the download.file commad

# Merge the training and the test datasets into one training and test set

full_training <- cbind(
  read.table('./UCI HAR Dataset/train/subject_train.txt',header=FALSE),
  read.table('./UCI HAR Dataset/train/X_train.txt',header=FALSE),
  read.table('./UCI HAR Dataset/train/y_train.txt',header=FALSE)
)

full_test <- cbind(
  read.table('./UCI HAR Dataset/test/subject_test.txt',header=FALSE),
  read.table('./UCI HAR Dataset/test/X_test.txt',header=FALSE),
  read.table('./UCI HAR Dataset/test/y_test.txt',header=FALSE)
  )

# To label the variables, create a vector of names by the use the features.txt file plus add subject and activity

names <- c("subject", as.character(read.table('./UCI HAR Dataset/features.txt',header=FALSE)[,2]), "activity")
colnames(full_test) = names
colnames(full_training) = names

# Merge the training and the test data sets

full_data <- rbind(full_training, full_test)

# Select the relevant variables from the names vector using the grepl command

std_and_mean <- (grepl('subject', names) |grepl('activity', names)| grepl('mean()', names) & !grepl('meanFreq()', names)| grepl('std()', names) )

# By the help of this logical vector, one can properly filter the data set

filtered_data <- full_data[std_and_mean]

# Next step is to label the activities

filtered_data$activity <- factor(filtered_data$activity,
                    levels = c(read.table('./UCI HAR Dataset/activity_labels.txt',header=FALSE)[,1]),
                    labels = c(as.character(read.table('./UCI HAR Dataset/activity_labels.txt',header=FALSE)[,2])))

# "Appropriately labels the data set with descriptive variable names" is an ambiguous part of this project work. Many other students complained about it in the forum as well
# I simply removed the invalid characters likes () and - and lowered the uppercase letters

clear_names <- gsub("\\()","",names[std_and_mean])
clear_names <- gsub("\\-","_",clear_names)
clear_names <- tolower(clear_names)

colnames(filtered_data) = clear_names

#At last but not at least I used the aggregate command for the fifth exercise

aggregated_data <- aggregate(filtered_data[,2:67], by = list(factor(filtered_data[,1]), filtered_data[,68]), mean)
colnames(aggregated_data) <- c("subject", "activity",names(filtered_data[,2:67]))

write.table(aggregated_data, './submission_data.txt', row.names = FALSE)