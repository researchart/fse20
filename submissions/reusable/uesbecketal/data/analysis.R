install.packages(c("tidyverse", "car", "compute.es", "multcomp", "pastecs", "WRS2", "psych", "gmodels"))

library(car)
library(compute.es)
library(multcomp)
library(pastecs)
library(WRS2)
library(tidyverse)
library(ez)
library(psych)
library(gmodels)

#Set this to the appropriate path to read the csv file
setwd("~/replication-packet/data/")
d <- read.csv("summary_deindentified.csv")

# Number of entries
nrow(d)

# Count of unique participants
d %>% summarize(count=n_distinct(id))

str(d)

names(d) <- tolower(names(d))


d <- d %>% replace_na(list(year = "Professional"))
d$year <- factor(d$year, levels=c("Freshman", "Sophomore", "Junior", "Senior", "Graduate", "Not Applicable", "Professional"), 
                 labels=c("Freshman", "Sophomore", "Junior", "Senior", "Graduate", "Not Applicable", "Professional"))

# 2 graduates in this experiment,
# they didn't really try (confirmed by manual review)
d <- d %>% filter(year != "Graduate")

# # # # # # # # # # # # # # # # # # # #
# Replacing non-americans that selected 
# Not Applicable with professional (didn't recruit non-american students)
d <- d %>% mutate(year = replace(year, year == "Not Applicable", "Professional"))

d %>% group_by(year) %>%
  summarize(count=n_distinct(id))

d$lang <- factor(d$lang, levels=c("1", "2", "3"),
                 labels=c("hybrid", "string-based", "object"))

# new features
d$notenglish <- as.numeric(!d$englishmain)
d$maxtime <- as.numeric(d$time >= 2700)
d$notmaxtime <- as.numeric(!d$maxtime)
d$dbexp <- as.numeric(d$dbclass == "Complete" | d$sqlxp > 0)

d %>% group_by(lang) %>%
  summarize(count = n_distinct(id))

# Inspect id + task combinations
ezDesign(d, x=id, y=task)

# Get list of participants missing tasks
incomplete.ids <- d %>% group_by(id) %>% 
  summarize(sumtasknum = sum(task)) %>%
  filter(sumtasknum < 15) %>% 
  select(id) %>%
  pull(id)

# Id's not having completed all tasks
incomplete.ids

# Number of id's to remove
length(incomplete.ids)

d <- d %>%
  filter (!(id %in% incomplete.ids))

# Number of entries
nrow(d)

# Recheck count of unique participants
d %>% summarize(count=n_distinct(id))

ezDesign(d, id, task)



# # # # # # # # # # # # # # # # # # # # # 
# Check for extremely long times that only
# occure when someone isn't moving on
toolongids.ids <- d %>% 
  filter(time > 3000) %>% 
  select(id) %>%
  pull(id)

d.toolong <- d %>% filter(id %in% toolongids.ids)

toolongids.ids

# filter these ID's out. After review by hand
# they weren't even trying
d <- d %>%
  filter (!(id %in% toolongids.ids))

nrow(d)

# Recheck count of unique participants
d %>% summarize(count=n_distinct(id))



# # # # # # # # # # # # # # # # # # # #
# Check out ids with ceiling times to 
# see if they tried.
long.ids <- d %>% 
  filter(time > 2699) %>% 
  select(id) %>%
  pull(id)

d.long <- d %>% filter(id %in% long.ids)

ggplot(d.long, aes(x=time)) + geom_histogram()

# replace slight differences with max time
d <- d %>% mutate(time = replace(time, time > 2700, 2700))


d <- d %>% mutate(fluency = replace(fluency, fluency == -1, 10))


d$task <- factor(d$task, levels=c("0","1","2","3","4","5"), 
                 labels=c("1","2","3","4","5","6"))
d %>% group_by(year) %>% summarize(n=sum(as.numeric(notenglish)/6))


###########################################################################################################################################
# All kinds of descriptive statistics
###########################################################################################################################################
# ##################################################
# Participants not having finished each task completely
d %>% 
  filter (time > 2699) %>%
  group_by(lang) %>%
  summarize(count=n_distinct(id))

# hybrid : 23
# polyglot: 18
# object: 25

d %>% 
  filter (time > 2699) %>%
  summarize(count=n_distinct(id))
# count 66

d %>% 
  summarize(count=n_distinct(id))
# 109
66/109
# 0.6055

d %>% 
  filter (time > 2699) %>%
  summarize(count=n_distinct(id, task))
# count 233
d %>% 
  summarize(count=n_distinct(id, task))
# 654
233/654
# 0.3562

# Mean and SD for missed tasks per participant
d %>%
  group_by(id) %>%
  summarize(count=sum(maxtime)) %>%
  summarize(mean=mean(count), sd=sd(count))
 

d %>% group_by(lang) %>%
  summarize(count=n_distinct(id))

# hybrid : 38
# polyglot: 35
# object: 36

# percentages
hybrid.max <- 23/38
polyglot.max <- 18/35
object.max <- 25/36

hybrid.max   #60.53%  
polyglot.max #51.43%
object.max   #70.27%

d %>% group_by(id)  %>% summarize(notenglish=max(notenglish)) %>% group_by(notenglish) %>% summarize(count = n_distinct(id), percent = count/(82+27))


## ####
# Breakdown by task instance (id,task) key
d %>% 
  filter (time > 2699) %>%
  group_by(lang) %>%
  summarize(count=n_distinct(id, task))

# hybrid      66
# polyglot    70
# object      97

d %>% group_by(lang) %>%
  summarize(count=n_distinct(id,task))

# hybrid     228
# polyglot   210
# object     216

hybrid.task.max <- 66/228
polyglot.task.max <- 70/210
object.task.max <- 97/216

hybrid.task.max   #28.95%
polyglot.task.max #33.33%
object.task.max   #44.91%

# Numbers in years
d %>% group_by(year) %>%
  summarize(count=n_distinct(id))

# Numbers by programming experience
d %>% group_by(totalxp) %>%
  summarize(count=n_distinct(id))

# Numbers by job experience
d %>% group_by(jobxp) %>%
  summarize(count=n_distinct(id))

# Numbers in groups
d %>% group_by(lang) %>%
  summarize(count=n_distinct(id))

# Numbers in genders (gender removed from de-identified data)
#d %>% group_by(gender) %>% 
#  summarize(count=n_distinct(id))

# Average age (age removed from de-identified data)
#d %>% summarize(avgage=mean(age), sd = sd(age))

d %>% group_by(lang) %>% 
  summarize(n=n_distinct(id), mean=mean(time), sd=sd(time)) %>% mutate_if(is.numeric, format, 1)

d %>% group_by(task, lang) %>% 
  summarize(n=n_distinct(id), mean=mean(time), sd=sd(time)) %>% mutate_if(is.numeric, format, 1)

d %>% group_by(task) %>% 
  summarize(n=n_distinct(id), mean=mean(time), sd=sd(time)) %>% mutate_if(is.numeric, format, 1)

d %>% group_by(notenglish) %>% summarize(n=n_distinct(id))

d %>% group_by(fluency) %>% summarize(n=n_distinct(id))

describe(d)

summary(d)


d$totalxp <- as.numeric(d$totalxp)
d$id <- factor(d$id)

###########################################################################################################################################
# ANOVAs and T-tests
###########################################################################################################################################

model <- ezANOVA(data=d, dv= .(time), wid= .(id), between=.(lang, year), within = .(task), observed = .(year), detailed=TRUE, type=3)
model

model <- ezANOVA(data=d, dv= .(time), wid= .(id), between=.(fluency), observed = .(fluency), detailed=TRUE, type=3)
model

pairwise.t.test(d$time, d$task, paired = TRUE, p.adjust.method= "bonferroni")

pairwise.t.test(d$time, d$lang, paired = FALSE, p.adjust.method= "bonferroni")

d %>% group_by(notenglish) %>% summarize(m = mean(time), sd = sd(time))  %>% mutate_if(is.numeric, format, 1)

test <- t.test(time ~ notenglish, data = d, paired = FALSE)
test

t.23 <- test$statistic[[1]]
df.23 <- test$parameter[[1]]
t.23
df.23
r <- sqrt(t.23^2/(t.23^2+df.23))
# r of t-test
round(r, 3)
# r^2 of t-test
round(r*r, 4)

d$dbexp <- factor(d$dbexp, levels = c(1, 0), labels=c("Yes","No"))
d$notenglish <- factor(d$notenglish, levels = c(1, 0), labels=c("No","Yes"))

d$fluency <- factor(d$fluency)

df.lang <- d %>% filter(year == "Professional")

#natural lang was taken out of deidentified data set
#df.lang %>% group_by(naturallanguage) %>% summarize(n = n_distinct(id))

test <- t.test(time ~ notenglish, data = df.lang, paired = FALSE)
test

t.23 <- test$statistic[[1]]
df.23 <- test$parameter[[1]]
t.23
df.23
r <- sqrt(t.23^2/(t.23^2+df.23))
# r of t-test
round(r, 3)
# r^2 of t-test
round(r*r, 4)


###########################################################################################################################################
# All the Chi Square calculations
###########################################################################################################################################
g <- d %>% group_by (lang) %>% summarize(maxtime = sum(maxtime), count=n_distinct(id,task), no = count-maxtime)
g

hybrid <- c(162, 66)
polyglot <- c(140, 70)
object <- c(119, 97)

chitable <- cbind(hybrid,polyglot,object)
CrossTable(chitable, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")


chitable <- cbind(hybrid,polyglot)
CrossTable(chitable, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

chitable <- cbind(hybrid,object)
CrossTable(chitable, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

chitable <- cbind(polyglot, object)
CrossTable(chitable, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

loglintable.3 <- xtabs(~lang + year + maxtime, data = d)
loglintable.3

saturated.3.way <- loglm(~lang*year*maxtime, data = loglintable.3, fit = TRUE)
summary(saturated.3.way)
# this is the model

#updated, removing three way interaction
twowayinteractions.3.way <- update(saturated.3.way, .~. - lang:year:maxtime)
summary(twowayinteractions.3.way)

anova(saturated.3.way, twowayinteractions.3.way)
# yeah so that's highly significant and therefore a lot worse


loglintable.year <- xtabs(~year + maxtime, data= d)
maxtimesaturated.year <- loglm(~year + maxtime + year:maxtime, data = loglintable.year, fit = TRUE)
maxtimeNoInteraction.year <- loglm(~year + maxtime, data = loglintable.year, fit = TRUE)

maxtimesaturated.year
maxtimeNoInteraction.year

CrossTable(d$year, d$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

#### DBEXP
CrossTable(d$dbexp, d$notmaxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

dbexptable <- xtabs(~dbexp + lang + maxtime, data = d)
maxtimesaturated.dbexp <- loglm(~dbexp*lang*maxtime, data = dbexptable, fit = TRUE)
maxtimeNoInteraction.dbexp <- update(maxtimesaturated.dbexp, .~. - dbexp:lang:maxtime)

maxtimesaturated.dbexp
maxtimeNoInteraction.dbexp

anova(maxtimesaturated.dbexp, maxtimeNoInteraction.dbexp)

maxtimeNoInteraction.dbexp.2 <- update(maxtimeNoInteraction.dbexp, .~. - dbexp:maxtime)
maxtimeNoInteraction.dbexp.3 <- update(maxtimeNoInteraction.dbexp, .~. - lang:maxtime)
maxtimeNoInteraction.dbexp.4 <- update(maxtimeNoInteraction.dbexp, .~. - dbexp:lang)

anova(maxtimeNoInteraction.dbexp, maxtimeNoInteraction.dbexp.2)
anova(maxtimeNoInteraction.dbexp, maxtimeNoInteraction.dbexp.3)
anova(maxtimeNoInteraction.dbexp, maxtimeNoInteraction.dbexp.4) # not significant
maxtimeNoInteraction.dbexp.2
maxtimeNoInteraction.dbexp.3
maxtimeNoInteraction.dbexp.4

#mosaicplot(maxtimeNoInteraction.dbexp.4, shade= TRUE, main = "DBexp without dbexp:lang ")

langchart <- subset(d, lang == 'object')
CrossTable(langchart$dbexp, langchart$notmaxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

langchart <- subset(d, lang == 'string-based')
CrossTable(langchart$dbexp, langchart$notmaxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

langchart <- subset(d, lang == 'hybrid')
CrossTable(langchart$dbexp, langchart$notmaxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.poly.hybrid <- subset(d, lang != "object")

only.temp <- subset(only.poly.hybrid, year == "Freshman")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.poly.hybrid, year == "Sophomore")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.poly.hybrid, year == "Junior")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.poly.hybrid, year == "Senior")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.poly.hybrid, year == "Professional")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.hybrid.object <- subset(d, lang != "string-based")

only.temp <- subset(only.hybrid.object, year == "Freshman")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.hybrid.object, year == "Sophomore")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.hybrid.object, year == "Junior")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.hybrid.object, year == "Senior")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.hybrid.object, year == "Professional")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.object.polyglot <- subset(d, lang != "hybrid")

only.temp <- subset(only.object.polyglot, year == "Freshman")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.object.polyglot, year == "Sophomore")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.object.polyglot, year == "Junior")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.object.polyglot, year == "Senior")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")

only.temp <- subset(only.object.polyglot, year == "Professional")
CrossTable(only.temp$lang, only.temp$maxtime, fisher = TRUE, chisq = TRUE, expected = TRUE, sresid = TRUE, format = "SPSS")



###########################################################################################################################################
# Graphs
###########################################################################################################################################

graph2 <- ggplot(d, aes(x=lang , y=time, fill=year)) +
  geom_boxplot() +
  labs (x="Task", y="Time [s]", group="Group", linetype="Group", fill="Group" ) + 
  theme(legend.position = "bottom", panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), panel.background = element_blank(),
        text = element_text(size=12.5),
        axis.line = element_line(colour = "black")) +
  scale_fill_grey(start = 1.0, end = 0.75) +
# ylim(0, 2700) +
  scale_y_continuous(breaks=c(0,1000, 2000, 2700),limits = c(0, 2700))
graph2

ggsave("timebyyear.png", height = 4, width = 9)
ggsave("timebyyear.eps")


graph.dbexp <- ggplot(d, aes(x=lang , y=time, fill=dbexp)) + 
  geom_boxplot() + 
  labs (x="Task", y="Time [s]", group="Database Experience", linetype="Database Experience", fill="Database Experience") + 
  theme(legend.position = "bottom", panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), panel.background = element_blank(), 
        text = element_text(size=20),
        axis.line = element_line(colour = "black")) + 
  scale_fill_grey(start = 1.0, end = 0.75) +
  scale_y_continuous(breaks=c(0,1000, 2000, 2700),limits = c(0, 2700))
graph.dbexp

ggsave("timebyexp.eps")
#ggsave("timebyexp.png")

graph.notenglish <- ggplot(d, aes(x=notenglish , y=time)) + 
  geom_boxplot() + 
  labs (x="English as Primary Language", y="Time [s]", group="Database Experience", 
        linetype="Database Experience", fill="Database Experience" ) + 
  theme(legend.position = "bottom", panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), panel.background = element_blank(), 
        text = element_text(size=20),
        axis.line = element_line(colour = "black")) + 
  scale_fill_grey(start = 1.0, end = 0.75) +
  scale_y_continuous(breaks=c(0,1000, 2000, 2700),limits = c(0, 2700))
graph.notenglish

ggsave("notenglish.png", height = 4, width = 9)
ggsave("notenglish.eps")


ggplot (df.lang, aes(x=as.factor(notenglish), y=time)) +
  geom_boxplot() +
  labs (x="English as Primary Language", y="Time [s]", group="Group", linetype="Group", fill="Group") + 
  theme(legend.position = "bottom", panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), panel.background = element_blank(),
        text = element_text(size=20),
        axis.line = element_line(colour = "black")) +
  scale_fill_grey(start = 1.0, end = 0.75) +
  # ylim(0, 2700) +
  scale_y_continuous(breaks=c(0,1000, 2000, 2700),limits = c(0, 2700))

ggsave("lang_professional.png")

graph1 <- ggplot(d, aes(x=task , y=time, fill=lang)) + 
  geom_boxplot() + 
  labs (x="Task", y="Time [s]", group="Group", linetype="Group", fill="Group" ) + 
  theme(legend.position = "bottom", panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), panel.background = element_blank(),
        text = element_text(size=20),
        axis.line = element_line(colour = "black")) + 
  scale_fill_grey(start = 1.0, end = 0.75) +
  scale_y_continuous(breaks=c(0,1000, 2000, 2700),limits = c(0, 2700))
graph1

ggsave("timebytaskgroup.eps")

graph3 <- ggplot(d, aes(x=lang , y=time)) +
  geom_boxplot() + labs (x="Task", y="Time [s]", group="Group", linetype="Group", fill="Group" ) +
  theme(legend.position = "bottom", panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        text = element_text(size=20),
        panel.background = element_blank(), axis.line = element_line(colour = "black")) + 
  scale_fill_grey(start = 1.0, end = 0.75) +
  scale_y_continuous(breaks=c(0,1000, 2000, 2700),limits = c(0, 2700))
graph3

ggsave("overallbygroup.png")
ggsave("overallbygroup.eps")

f <- d %>% group_by (lang, year) %>% 
  summarize(maxtime = sum(maxtime), count=n_distinct(id,task), percent = (maxtime/count)*100, completed = 100-percent)
f

graph4 <- ggplot(f, aes(x=lang , y=percent, fill=year)) + 
  geom_bar(width = 0.75, stat="identity", position=position_dodge(), colour="black") + 
  scale_fill_grey(start=0.6, end=0.9) +
  theme(legend.position = "bottom", panel.grid.major = element_blank(),
        text = element_text(size=20),
        panel.grid.minor = element_blank(), panel.background = element_blank(),
        axis.line = element_line(colour = "black")) +
  labs(x="Group", y = "Percentage failed", fill="Year") +
  ylim(0, 100)
graph4

ggsave("maxtime.png", height = 4, width = 9)
ggsave("maxtime.eps")

#d.freshman <- d %>% filter(year=="Freshman")

ggplot(d, aes(x=time) ) + geom_histogram()

ggsave("histogram.png")

###########################################################################################################################################
#CI graphs (those overwrite tidyverse libraries, use with caution)
###########################################################################################################################################
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

pd <- position_dodge(0.3)
p <- summarySE (d, measurevar = "time", groupvars = c("notenglish"), na.rm=FALSE, conf.interval = .95)
p
ggplot(p, aes(x=notenglish, y=time)) + 
  labs (x="English as Primary Language", y="Time [s]", group="Group", linetype="Group", fill="Group" ) + 
  geom_errorbar(aes(ymin=time-ci, ymax=time+ci), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3) +
  theme(legend.position = "bottom", panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), panel.background = element_blank(), 
        text = element_text(size=20),
        axis.line = element_line(colour = "black")) + 
  scale_fill_grey(start = 1.0, end = 0.75) +
  scale_y_continuous(breaks=c(0,1000, 2000, 3000, 3600),limits = c(0, 3600))

ggsave("fs-ci.png")

