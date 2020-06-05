#required library
library("likert")

args <- commandArgs(trailingOnly = TRUE)

#import data
path = args[1]
data <- read.csv(file=path, header=TRUE, sep=",")

# give a title and rename columns
title <- "Decisions on our posts"
names(data) = c("Fuzzy Version", "Manual Execution", "Retry Failure", "Fake Success", "Overall")

#factor data
levels = c( "ignore", "reject", "pending", "accept", "fix")

data$`Fake Success` =factor(data$`Fake Success`,
                            levels,
                            ordered = TRUE)

data$`Retry Failure` =factor(data$`Retry Failure`,
                            levels,
                            ordered = TRUE)

data$`Manual Execution` =factor(data$`Manual Execution`,
                            levels,
                            ordered = TRUE)

data$`Fuzzy Version` =factor(data$`Fuzzy Version`,
                            levels,
                            ordered = TRUE)

data$`Overall` = factor(data$`Overall`,
                        levels,
                        ordered = TRUE)

#convert to likert
likertData <- likert(data)
str(likertData)

#summary results
likertDatas <- likert(summary = likertData$results)
str(likertDatas)
summary(likertDatas)

#plots
scale_height = knitr::opts_chunk$get('fig.height')*0.5
scale_width = knitr::opts_chunk$get('fig.width')*1.25
knitr::opts_chunk$set(fig.height = scale_height, fig.width = scale_width)

theme_update(legend.text = element_text(size = rel(0.7)))
#plot(likertDatas)

png(filename=args[2])
plot(likertDatas, include.center=TRUE) 
head(data); ncol(data)
dev.off()