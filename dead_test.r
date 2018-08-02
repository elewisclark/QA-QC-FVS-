dead_test <- read.csv("./dead_test.csv")
head(dead_test)

dead_test$history <- dead_test$dead
head(dead_test)

dead_test$history[dead_test$dead == 9] <- 0
head(dead_test)

DT <- aggregate.data.frame(dead_test, list(dead_test$plot), sum)
DT

DT2 <- aggregate(history ~ plot, data = dead_test, sum)
DT2

DT2sub <- subset(DT2, DT2$history == 0)
DT2sub

subset(DT2, DT2$history == 0)
