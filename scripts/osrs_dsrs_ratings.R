# Load Data
matches <- read.csv("../input/SampleSubmission.csv", header = TRUE, stringsAsFactors = FALSE)
matches$year <- sapply(matches$Id, FUN=function(x) {strsplit(x, split='[_]')[[1]][1]})
matches$lowId <- sapply(matches$Id, FUN=function(x) {strsplit(x, split='[_]')[[1]][2]})
matches$highId <- sapply(matches$Id, FUN=function(x) {strsplit(x, split='[_]')[[1]][3]})
teams <- read.csv("../input/teams.csv", header = TRUE, stringsAsFactors = FALSE)
teams$team_fullname <- teams$Team_Name

srs_2012 <- read.csv("../input/cbb_seasons_2012_ratings.csv", header = TRUE, stringsAsFactors = FALSE)
srs_2013 <- read.csv("../input/cbb_seasons_2013_ratings.csv", header = TRUE, stringsAsFactors = FALSE)
srs_2014 <- read.csv("../input/cbb_seasons_2014_ratings.csv", header = TRUE, stringsAsFactors = FALSE)
srs_2015 <- read.csv("../input/cbb_seasons_2015_ratings.csv", header = TRUE, stringsAsFactors = FALSE)
srs_2012$year <- 2012
srs_2013$year <- 2013
srs_2014$year <- 2014
srs_2015$year <- 2015

srs_ratings <- rbind(srs_2012, srs_2013, srs_2014, srs_2015)
merged <- merge(srs_ratings, teams, by.x=c("School"), by.y=c("team_fullname"))
merged2 <- merge(matches, merged, by.x=c("year","lowId"), by.y=c("year","Team_Id"))
matches <- cbind(matches, merged2["OSRS"])
colnames(matches)[6] <- "lowIdOSRS"
matches <- cbind(matches, merged2["DSRS"])
colnames(matches)[7] <- "lowIdDSRS"

merged3 <- merge(matches, merged, by.x=c("year","highId"), by.y=c("year","Team_Id"))
merged3 <- merged3[order(merged3$Id), ]
matches <- cbind(matches, merged3["OSRS"])
colnames(matches)[8] <- "highIdOSRS"
matches <- cbind(matches, merged3["DSRS"])
colnames(matches)[9] <- "highIdDSRS"

matches$calculated <- 0.50 + (matches$lowIdOSRS - matches$highIdOSRS)*0.018 + (matches$lowIdDSRS - matches$highIdDSRS)*0.026
matches$calculated[matches$calculated > 1] <- 1
matches$calculated[matches$calculated < 0] <- 0


submit <- data.frame(Id = matches$Id, Pred = matches$calculated)
write.csv(submit, file = "../submissions/osrs_and_dsrs_ratings.csv", row.names = FALSE, quote=FALSE)