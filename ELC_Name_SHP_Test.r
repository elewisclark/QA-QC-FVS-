library(sp)
library(raster)
library(maptools)
library(rgdal)
library(fields)
library(dplyr)
library(odbc)
library(DBI)
library(RSQLite)

setwd("C:/Users/EricLewis-Clark/New Forests/Forest Carbon Partners - FCP English Bay Corporation/nwkNanwalekEBC_analysis/nwkNanwalekEBC_fvs")


###Check to make sure that the names form the GIS Shapefiles are the same
####as the inpt files 

###Bring in the shapefiles
plots<- readOGR("../nwkNanwalekEBC_spatial/nwkNanwalekEBC_input/EBC COMPLETED PLOTS2/EBC COMPLETED PLOTS.shp")
outline <- readOGR("../nwkNanwalekEBC_spatial/nwk_project_forest_area.shp")

##Plot shapefile and outline to make sure everything looks right
plot(outline)
plot(plots, add = T, col = "Red")

##Create a dataframe from the shapefile pulling in the correct names 
###for most shapefiles the plot names should be found in "ID"
head(plots@data)###Run this code if you are not sure where your plot names are located 

new.df <- data.frame(plots$ID)
head(new.df) 
length(new.df$plots.ID)
##Dont need below code
##new.df.t <- data.frame(new.df)
##head(new.df.t)
###colnames(new.df.t)[colnames(new.df.t)=="new.df"] <- "plotID"

#order(new.df.t)
#test <-new.df.t[order(new.df.t$plotID),]
#test

ELC <- c(1,2,3,4,5,6,7,8,9,NA)
PT <- c(25,26,27,28,29,30,31,32,33,34)
RB <- c(3,4,5,6,7,8,9,10,11,12)

EW <- c(9,8,7,6,5,4,3,2,1,10)
BS  <- c(26,27,25,33,30,29,32,28,31,34)
TR <- c(3,4,5,6,7,8,9,10,11,12)

test.df <- data.frame(ELC, PT, RB)
test.df2 <- data.frame(EW, BS, TR)

df.test <- merge(test.df, test.df2, by.x = "ELC", by.y = "EW") 


NewDFT<-as.numeric(as.character(new.df.t$plotID))
#############Below works but keep going down to find better/more direct code


TreeINIT <- read.csv("C:/Users/EricLewis-Clark/Downloads/FVS_TreeInIt.csv")
plot(Ht ~ DBH, data = TreeINIT, xlim = c(0, 60), ylim = c(0,130),
     col =TreeINIT$Plot_ID)

Tree.test<- merge(TreeINIT,new.df, by.x = "Plot_ID", by.y = "plots.ID")
Tree.test
length(Tree.test$Plot_ID)
length(TreeINIT$Plot_ID)
length(new.df$plots.ID) #### Just plots not trees thats why this is different

#############Communicate with the database using R and SQLite!!!!!!

####con <- dbConnect(drv="SQLite", dbname="EBC_FVS_DATA_7_25_18.db")####THis does not work
con <- dbConnect(RSQLite::SQLite(), "./EBC_FVS_DATA_7_25_18.db")     
###The above does work
con
alltables = dbListTables(con)
alltables

####Lets try and pull out the TreeINIt file as a dataframe

Tree <- dbGetQuery(con, 'select * from FVS_TreeInIt')
head(Tree)
plot(Ht ~ DBH, data = Tree)

###Checking to see if there is any missing data. 
###If anyhting comes back NA then you know there is data missing

mean(Tree$DBH)
mean(Tree$Ht)
mean(Tree$HtTopK)
mean(Tree$Stand_ID)
mean(Tree$Plot_ID)
mean(Tree$Tree_ID)
mean(Tree$Tree_Count)
mean(Tree$Species)
mean(Tree$History)
mean(Tree$CrRatio)
mean(Tree$Damage1)
mean(Tree$Severity1)
mean(Tree$Damage2)
mean(Tree$Severity2)


####Ok Now for something a little more advanced. Lets try to pull out just the 
###column of plots from the PlotInIt file

plotID <- dbGetQuery(con, 'select Plot_ID from FVS_PlotInIt')
head(plotID)

#### OK Now lets merge the two lists together (PlotID vs GPSID)

SameNames <- merge(plotID,new.df.t, by.x = "Plot_ID", by.y = "new.df")
SameNames

dbDisconnect(con)

length(SameNames$Plot_ID)
length(plotID$Plot_ID)
length(new.df.t$new.df)
####Boom it merged so we know that they infact are the same names 
###(if they were not we would have gotten an NA)

#####Check the data to see if it makes sense

##Range for DBH should be between 1 and 100

range(Tree$DBH)

###Range for Heights should be between 5 and 200

range(Tree$Ht)

##Make sure that there are enteries in every level in the data 
###i.e. Checking for missing data
length(na.omit(Tree$DBH))
length(na.omit(Tree$Ht))
length(na.omit(Tree$HtTopK))
length(na.omit(Tree$Stand_ID))
length(na.omit(Tree$Plot_ID))
length(na.omit(Tree$Tree_ID))
length(na.omit(Tree$Tree_Count))
length(na.omit(Tree$Species))
length(na.omit(Tree$History))
length(na.omit(Tree$CrRatio))
length(na.omit(Tree$Damage1))
length(na.omit(Tree$Severity1))
length(na.omit(Tree$Damage2))
length(na.omit(Tree$Severity2))

heighttt <- t.test(Tree$Ht, Tree$HtTopK, paired = TRUE)
summary(heighttt)
heighttt


HeightTest <- Tree$Ht - Tree$HtTopK
subset.default(HeightTest, HeightTest <= 0)

Tree98 <- subset.data.frame(Tree, Tree$Species == 98)
Tree42 <- subset.data.frame(Tree, Tree$Species == 42)
Tree920 <- subset.data.frame(Tree, Tree$Species == 920)
Tree747 <- subset.data.frame(Tree, Tree$Species == 747)

plot(Ht~DBH, data = Tree98, col = CrRatio, pch = 19, 
     ylab = "Height (ft)", xlab = "Diameter at Breast Height (DBH; in)")
legend("bottomright", legend = sort.int(unique(Tree98$CrRatio)),
       fill = sort.int(unique(Tree98$CrRatio)), bty = "n", cex = 0.5)

plot(Ht~DBH, data = Tree42, col = CrRatio, pch = 19, 
     ylab = "Height (ft)", xlab = "Diameter at Breast Height (DBH; in)")
legend("bottomright", legend = sort.int(unique(Tree42$CrRatio)),
       fill = sort.int(unique(Tree42$CrRatio)), bty = "n")

plot(Ht~DBH, data = Tree920, col = CrRatio, pch = 19, 
     ylab = "Height (ft)", xlab = "Diameter at Breast Height (DBH; in)")
legend("bottomright", legend = sort.int(unique(Tree920$CrRatio)),
       fill = sort.int(unique(Tree920$CrRatio)), bty = "n")

plot(Ht~DBH, data = Tree747, col = CrRatio, pch = 19, 
     ylab = "Height (ft)", xlab = "Diameter at Breast Height (DBH; in)")
legend("bottomright", legend = sort.int(unique(Tree747$CrRatio)),
       fill = sort.int(unique(Tree747$CrRatio)), bty = "n")

#####
Tree$ME <- Tree$HtTopK

Tree$ME[Tree$ME >0] <- 2
Tree$ME[Tree$ME == 0] <- 1

plot(Ht~DBH, data = Tree98, col = ME, pch = 19, 
     ylab = "Height (ft)", xlab = "Diameter at Base Height (DBH; in)")
legend("bottomright", legend = c("Measured", "Estimated"),
       fill =c(1,2), bty = "n")

plot(Ht~DBH, data = Tree42, col = ME, pch = 19, 
     ylab = "Height (ft)", xlab = "Diameter at Base Height (DBH; in)")
legend("bottomright", legend = c("Measured", "Estimated"),
       fill =c(1,2), bty = "n")

plot(Ht~DBH, data = Tree920, col =ME, pch = 19, 
     ylab = "Height (ft)", xlab = "Diameter at Base Height (DBH; in)")
legend("bottomright", legend = c("Measured", "Estimated"),
       fill =c(1,2), bty = "n")

plot(Ht~DBH, data = Tree747, col = ME, pch = 19, 
     ylab = "Height (ft)", xlab = "Diameter at Base Height (DBH; in)")
legend("bottomright", legend = c("Measured", "Estimated"),
       fill =c(1,2), bty = "n")

#####
head(Tree)

hist(Tree$Plot_ID, ylim = c(0,50))


########
Plotinit <- dbGetQuery(con, 'select * from FVS_PlotInIt')
head(Plotinit)
head(Tree)


######
####small <- subset.data.frame(Tree, Tree$Plot_ID == 2425)
aggregate(Plot_ID ~ DBH, data = Tree, max)
plot(Tree, list(plot = Tree$Plot_ID), max)
plotmeanDBH <- aggregate(Tree, list(plot = Tree$Plot_ID), mean)
summary(plotmeanDBH$DBH)
small <- subset.data.frame(plotmeanDBH, plotmeanDBH$DBH < 5)
small

Tree947P <- subset.data.frame(Tree, Tree$Plot_ID == 947)
summary(Tree947P$DBH)

Tree1776P <- subset.data.frame(Tree, Tree$Plot_ID == 1776)
summary(Tree1776P$DBH)

Tree2394P <- subset.data.frame(Tree, Tree$Plot_ID == 2394)
summary(Tree2394P$DBH)

plotmaxDBH <- aggregate(Tree, list(plot = Tree$Plot_ID), max)
summary(plotmaxDBH$DBH)
smallmax <- subset.data.frame(plotmaxDBH, plotmaxDBH$DBH < 5)
smallmax$Plot_ID

summary(as.factor(Tree$History))
summary(plotmaxDBH$History)
summary(as.factor(plotmaxDBH$History))
summary(as.factor(Tree$Plot_ID))
length(unique(Tree$Plot_ID))
