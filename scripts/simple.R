# Load Data
matches <- read.csv("../input/SampleSubmission.csv", header = TRUE, stringsAsFactors = FALSE)
seeds <- read.csv("../input/TourneySeeds.csv", header = TRUE, stringsAsFactors = FALSE)

matches$year <- sapply(matches$Id, FUN=function(x) {strsplit(x, split='[_]')[[1]][1]})
matches$lowId <- sapply(matches$Id, FUN=function(x) {strsplit(x, split='[_]')[[1]][2]})
matches$highId <- sapply(matches$Id, FUN=function(x) {strsplit(x, split='[_]')[[1]][3]})

seeds <- subset(seeds, Season >= 2012)
seeds$seedNumber <- as.numeric(substring(seeds$Seed, 2, 3))

matches <- cbind(matches, merge(matches, seeds, by.x=c("year","lowId"), by.y=c("Season","Team"))["seedNumber"])
colnames(matches)[6] <- "lowIdSeed"

test <- merge(matches, seeds, by.x=c("year","highId"), by.y=c("Season","Team"))
test <- test[order(test$Id), ]

matches <- cbind(matches, test["seedNumber"])
colnames(matches)[7] <- "highIdSeed"
rownames(matches) <- NULL

matches$calculated <- 0.50 + (matches$highIdSeed - matches$lowIdSeed)* 0.031
submit <- data.frame(Id = matches$Id, Pred = matches$calculated)
write.csv(submit, file = "../submissions/simple_seed_31.csv", 
          row.names = FALSE, quote=FALSE)
