# MIT License
# 
# Copyright (c) 2020 Sergio García
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#   
#   The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require('likert')
library('plyr')
require('lattice')
library("ggplot2")  # Data visualization
library("dplyr")    # Data manipulation
library(tidyverse)
library(ggthemes)

rm(list = ls())

## You may need to set the path to your folder
#setwd("path-to-your-folder")

## Import data from csv file 
MyRData <- read.csv("Robotics-2019.csv", header = TRUE)

#Filter out by occupation
pract_programmer<-MyRData[1, ]
pract_leading<-MyRData[5, ]
academic<-MyRData[2, ]
practitioner<-MyRData[1, ]
c_programmer<-1
c_leading<-1
c_academic<-1
c_practitioner<-1
c_other<-0

for (i in 1:length(MyRData[[1]])){
  if(((grepl("Industrial practitioner: Programmer", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Industrial researcher", MyRData[[94]][[i]], fixed=TRUE)) |
     (grepl("Industrial practitioner: Data Scientist, Developer", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Electrical Engineering", MyRData[[94]][[i]], fixed=TRUE)) |
     (grepl("a little bit of all of the above", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Programmer in Research Institute", MyRData[[94]][[i]], fixed=TRUE)) |
     (grepl("Hardware and firmware engineer", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Both academic and industrial", MyRData[[94]][[i]], fixed=TRUE)) | 
     (grepl("Industrial practitioner: Leading Technical Role", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Director of Robotics", MyRData[[94]][[i]], fixed=TRUE)) |
     (grepl("Business Development Manager", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Applied researcher for industrial domain", MyRData[[94]][[i]], fixed=TRUE)) |
     (grepl("CEO", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Business Manager - Robotics", MyRData[[94]][[i]], fixed=TRUE))) & i!=1){
      practitioner[c_practitioner, ]<-MyRData[i, ]
      c_practitioner<-c_practitioner+1

      if((grepl("Industrial practitioner: Programmer", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Industrial researcher", MyRData[[94]][[i]], fixed=TRUE)) |
         (grepl("Industrial practitioner: Data Scientist, Developer", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Electrical Engineering", MyRData[[94]][[i]], fixed=TRUE)) |
         (grepl("a little bit of all of the above", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Programmer in Research Institute", MyRData[[94]][[i]], fixed=TRUE)) | 
         (grepl("Applied researcher for industrial domain", MyRData[[94]][[i]], fixed=TRUE)) |
         (grepl("Hardware and firmware engineer", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Both academic and industrial", MyRData[[94]][[i]], fixed=TRUE))){
            pract_programmer[c_programmer, ]<-MyRData[i, ]
            c_programmer<-c_programmer+1
      }
      else if(((grepl("Industrial practitioner: Leading Technical Role", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Director of Robotics", MyRData[[94]][[i]], fixed=TRUE)) |
        (grepl("Business Development Manager", MyRData[[94]][[i]], fixed=TRUE)) |
        (grepl("CEO", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Business Manager - Robotics", MyRData[[94]][[i]], fixed=TRUE))) & i!=5){
          pract_leading[c_leading, ]<-MyRData[i, ]
          c_leading<-c_leading+1
        }
  }
  else if(((grepl("Academic/Scientist", MyRData[[94]][[i]], fixed=TRUE)) | (grepl("Government scientist", MyRData[[94]][[i]], fixed=TRUE)) | 
    (grepl("Principal researcher at research and technology transfer organization (interface organization not academic and not industrial)", MyRData[[94]][[i]], fixed=TRUE))) & i!=2){
      academic[c_academic, ]<-MyRData[i, ]
      c_academic<-c_academic+1
  }
  #1 and 2 have been already counted
  else if (i!=1 & i!=2) c_other<-c_other+1
}


#Create a funtion to simplify the process
analyze <- function(MyRData,role){
  print(role)
  
  #Check if the folders were created, and if not creats them
  currDir <- getwd()
  
  if (!dir.exists(file.path(currDir, "open-ended-answers"))) 
    dir.create(file.path(currDir, "open-ended-answers")) 
  if (!dir.exists(file.path(currDir, paste("open-ended-answers", role, sep = "/", collapse = "/")))) 
    dir.create(file.path(currDir, paste("open-ended-answers", role, sep = "/", collapse = "/"))) 
  
  if (!dir.exists(file.path(currDir, "graphs"))) 
    dir.create(file.path(currDir, "graphs")) 
  if (!dir.exists(file.path(currDir, paste("graphs", role, sep = "/", collapse = "/")))) 
    dir.create(file.path(currDir, paste("graphs", role, sep = "/", collapse = "/"))) 
  if (!dir.exists(file.path(currDir, paste("graphs", role, "barplot", sep = "/", collapse = "/")))) 
    dir.create(file.path(currDir, paste("graphs", role, "barplot", sep = "/", collapse = "/"))) 
  if (!dir.exists(file.path(currDir, paste("graphs", role, "likert", sep = "/", collapse = "/")))) 
    dir.create(file.path(currDir, paste("graphs", role, "likert", sep = "/", collapse = "/"))) 
  if (!dir.exists(file.path(currDir, paste("graphs", role, "piechart", sep = "/", collapse = "/")))) 
    dir.create(file.path(currDir, paste("graphs", role, "piechart", sep = "/", collapse = "/"))) 
  
  ## Changes
  piechart_c <-  MyRData[, c(2:4, 45:47, 57:59, 68, 70)]
  likert_c <-  MyRData[, c(5:13, 23:28, 30:33, 35:43, 48:55, 61:66, 71:75, 77:88)]
  likert_c_filtered<-likert_c
  openended_c <-  MyRData[, c(14:22, 29, 34, 44, 56, 60, 67, 69, 76,89:93)]
  background_c <- MyRData[, c(94:97)]
  
  names(openended_c) <- c("Which activities are performed in your projects?",
                          "Which tools do you use for Project management in your projects?",
                          "Which tools do you use for Requirements engineering in your projects?",
                          "Which tools do you use for Architectural and detailed design in your projects?",
                          "Which tools do you use for Implementation in your projects?",
                          "Which tools or languages do you use for Automatic code generation in your projects?",
                          "Which tools do you use for Testing and simulation in your projects?",
                          "Which tools do you use for Real-world experimentation in your projects?",
                          "Which tools do you use for Software maintenance and evolution in your projects?",
                          "Which paradigms are applied in your projects?",
                          "Which of these software engineering processes do you apply in your projects?",
                          "Which of these software languages do you use in your projects?",
                          "Which software artifacts are reused across projects in your organization?",
                          "Which mechanisms to facilitate interoperability among components are applied in your projects?",
                          "Which kind of quality assurance techniques do you perform in your projects?",
                          "How do you find the root causes of failures in your projects?",
                          "Which mission specification method do you use in your projects?",
                          "For the following items, to which extent do you agree that they describe a challenge in your projects?",
                          "For the encountered challenges, which solutions do you apply to address them?",
                          "Is there something you would like to add regarding the biggest challenges in robotics software engineering?",
                          "How do you think robotics software engineering differs from software engineering in other domains?",
                          "Do you think the practices applied in robotics software engineering should change If yes, in what way?")
  
  
  openended_c$"Which types of robots are used in your projects?"<-length(openended_c)+1
  openended_c$"Which is the application field of your projects?"<-length(openended_c)+1
  openended_c$"Which type of service or product do you provide6in your projects?"<-length(openended_c)+1
  openended_c$"Which of these robotic frameworks do you use in your projects?"<-length(openended_c)+1
  openended_c$"When you use third-party software (e.g., libraries), what are their licensing models?"<-length(openended_c)+1
  openended_c$"Under which license do you release your own software?"<-length(openended_c)+1
  openended_c$"Have you ever developed a software component from scratch rather reusing an existing (either self-developed or third-party) one?"<-length(openended_c)+1
  openended_c$"From where do you get test data in your projects?"<-length(openended_c)+1
  openended_c$"Who specifies missions for robots in your projects?"<-length(openended_c)+1
  

  pycharm<-0
  for (i in 1:length(openended_c[[16]])){
    if(grepl(gsub(" ", "", "simulat", fixed = TRUE), gsub(" ", "",openended_c[[16]][[i]], fixed = TRUE), fixed=TRUE)){
      pycharm<-pycharm+1
    }
  }
  #print(pycharm)
  
  names(likert_c) <- c(######Activities
                      "Project management",
                      "Requirements engineering",
                      "Architectural/detailed design",
                      "Implementation",
                      "Automatic code generation",
                      "Testing and simulation",
                      "Real-world experimentation",
                      "Maintenance/evolution",
                      "Other",
                      ######Paradigms
                      "OOP",
                      "FP",
                      "CBSE",
                      "MBSD",
                      "SPLE",
                      "Other",
                      ######Methodologies
                      "Waterfall",
                      "Hybrid",
                      "Agile",
                      "Other",
                      ######Languages
                      "Java",
                      "C",
                      "C++",
                      "Python",
                      "UML",
                      "MATLAB/Simulink",
                      "Self-developed DSLs",
                      "Third-party DSLs",
                      "Other",
                      ######Artifacts
                      "Source code",
                      "Conf. files",
                      "Software models",
                      "Libraries",
                      "Components",
                      "Documentation",
                      "Test cases",
                      "Other",
                      ######QA
                      "Unit tests",
                      "Integration tests",
                      "Performance tests",
                      "Code reviews",
                      "Formal methods",
                      "Other",
                      ######Mission
                      "Hard-coded",
                      "Logical language",
                      "Third-party DSL",
                      "Own DSL",
                      "Other",
                      ######Challenges
                      "Specifying missions",
                      "Software reuse",
                      "Lack of documentation",
                      "Lack of standards",
                      "Int. among components",
                      "Validation",
                      "Safety certification",
                      "Robustness",
                      "Dynamic adaptation",
                      "Simulation to real world",
                      "AI",
                      "Other") 
  names(likert_c_filtered)<-names(likert_c)
  names(piechart_c) <- c("Types of robots",
                         "Application field",
                         "Type of service or product",
                         "Robotic frameworks",
                         "Licensing model (used)",
                         "Licensing model (developed)",
                         "Reasons not reusing",
                         "Reuse style",
                         "Mechanisms",
                         "Test data",
                         "Who specifies missions?")
  
  # Labeling for likert scale, with and without filtering the "don't know" option
  i <- 1
  while(i<=(ncol(likert_c)-12)) {
    likert_c[[i]] = factor(likert_c[[i]],labels = c("Never","Almost never","Sometimes", "Very often", "Always", "I do not know"), levels=c("0 (never)","1 (almost never)","2 (sometimes)","3 (very often)","4 (always)","Don't know"))
    likert_c_filtered[[i]] = factor(likert_c_filtered[[i]],labels = c("Never","Almost never","Sometimes", "Very often", "Always"), levels=c("0 (never)","1 (almost never)","2 (sometimes)","3 (very often)","4 (always)"))
    i <- i + 1
  }
  while(i<=ncol(likert_c)) {
    likert_c[[i]] = factor(likert_c[[i]],labels = c("Strongly disagree","Disagree","Neutral", "Agree", "Strongly agree", "I do not know"), levels=c("0 (strongly disagree)","1 (disagree)","2 (neutral)","3 (agree)","4 (strongly agree)","Don't know"))
    likert_c_filtered[[i]] = factor(likert_c_filtered[[i]],labels = c("Strongly disagree","Disagree","Neutral", "Agree", "Strongly agree"), levels=c("0 (strongly disagree)","1 (disagree)","2 (neutral)","3 (agree)","4 (strongly agree)"))
    i <- i + 1
  }
   
  # Parsing data for pie charts
  #This loop goes through all the answers and creates a matrix, separating answers by commas
  #options[question number][participant's number][answer index] options[[i]][[j]][[k]]
  i <- 1
  l<-0
  cont<-0
  options <- list()
  while(i<=(ncol(piechart_c))) {
    #First, I remove the commas between paranthesis
    options[[i]]<-gsub('([ \\.,;\'\"\\*\\?A-Za-z0-9_-]*)(\\(+?)([ \\.;\'\"\\*\\?A-Za-z0-9_-]*),([ \\.;\'\"\\*\\?A-Za-z0-9_-]*),*([ \\.;\'\"\\*\\?A-Za-z0-9_-]*),*([ \\.;\'\"\\*\\?A-Za-z0-9_-]*),*([ \\.;\'\"\\*\\?A-Za-z0-9_-]*)(\\)?)([ \\.\'\",;\\*\\?A-Za-z0-9_-]*)','\\1\\2\\3\\4\\5\\6\\7\\8\\9',as.character(piechart_c[[i]][[1]]))
    for (j in 2:length(piechart_c[[i]])){
      helper<-gsub('([ \\.,;\'\"\\*\\?A-Za-z0-9_-]*)(\\(+?)([ \\.;\'\"\\*\\?A-Za-z0-9_-]*),([ \\.;\'\"\\*\\?A-Za-z0-9_-]*),*([ \\.;\'\"\\*\\?A-Za-z0-9_-]*),*([ \\.;\'\"\\*\\?A-Za-z0-9_-]*),*([ \\.;\'\"\\*\\?A-Za-z0-9_-]*)(\\)?)([ \\.\'\",;\\*\\?A-Za-z0-9_-]*)','\\1\\2\\3\\4\\5\\6\\7\\8\\9',as.character(piechart_c[[i]][[j]]))
      options[[i]]<-paste(options[[i]], helper, sep=", ")
    }
    #Then I split by commas
    options[[i]] <- strsplit(as.character(options[[i]]), ",")
    i <- i + 1
  }
  #print(options)
  
  #Create an empty bidemensional list to store the quantification for piecharts
  k <- length(options)
  ind <- 8
  answers <- vector(mode="list", k)
  for(i in seq(k)){
    answers[[i]] <- NaN*seq(ind)
    for (j in seq(ind)){
      answers[[i]][j] <- 0
    }
  }
  
  #The following loop quantifies each response
  i <- 1
  counter<-list(rep(1,length(options)))
  while(i<=length(options)){
    j <- 1
    while(j<=length(options[[i]])){
      k <- 1
      while(k<=length(options[[i]][[j]])){
        if (i==1) {
          if(grepl("Mobile robots", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[1]]<-answers[[i]][[1]]+1
          }
          else if(grepl("Mobile manipulators", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[2]]<-answers[[i]][[2]]+1
          }
          else if(grepl("Humanoid robots", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[3]]<-answers[[i]][[3]]+1
          }
          else if(grepl("Collaborative robots", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[4]]<-answers[[i]][[4]]+1
          }
          else if(grepl("Drones", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[5]]<-answers[[i]][[5]]+1
          }
          else if(grepl("Underwater robots", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[6]]<-answers[[i]][[6]]+1
          }
          else if(grepl("Industrial arms", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[7]]<-answers[[i]][[7]]+1
          }
          else{
            if(! grepl(options[[i]][[j]][[k]], " ", fixed=TRUE)){   
              answers[[i]][[8]]<-answers[[i]][[8]]+1
              openended_c[[23]][[counter[[1]][[1]]]]<-options[[i]][[j]][[k]]
              counter[[1]][[1]]<-counter[[1]][[1]]+1
            }
          }
        } else if (i==2) {
            if(grepl("Factory automation", options[[i]][[j]][[k]], fixed=TRUE)){
              answers[[i]][[1]]<-answers[[i]][[1]]+1
            }
            else if(grepl("Agriculture", options[[i]][[j]][[k]], fixed=TRUE)){
              answers[[i]][[2]]<-answers[[i]][[2]]+1
            }
            else if(grepl("Cleaning", options[[i]][[j]][[k]], fixed=TRUE)){
              answers[[i]][[3]]<-answers[[i]][[3]]+1
            }
            else if(grepl("Transportation", options[[i]][[j]][[k]], fixed=TRUE)){
              answers[[i]][[4]]<-answers[[i]][[4]]+1
            }
            else if(grepl("Medical", options[[i]][[j]][[k]], fixed=TRUE)){
              answers[[i]][[5]]<-answers[[i]][[5]]+1
            }
            else if(grepl("Defense", options[[i]][[j]][[k]], fixed=TRUE)){
              answers[[i]][[6]]<-answers[[i]][[6]]+1
            }
            else if(grepl("General research on service robots", options[[i]][[j]][[k]], fixed=TRUE)){
              answers[[i]][[7]]<-answers[[i]][[7]]+1
            }
            else{
              if(! grepl(options[[i]][[j]][[k]], " ", fixed=TRUE)){   
                answers[[i]][[8]]<-answers[[i]][[8]]+1
                openended_c[[24]][[counter[[1]][[2]]]]<-options[[i]][[j]][[k]]
                counter[[1]][[2]]<-counter[[1]][[2]]+1
              }
            }
        } else if (i==3) {
          if(grepl("Drivers of low-level components", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[1]]<-answers[[i]][[1]]+1
          }
          else if(grepl("Low-level functionalities", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[2]]<-answers[[i]][[2]]+1
          }
          else if(grepl("Planning and orchestration modules", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[3]]<-answers[[i]][[3]]+1
          }
          else if(grepl("Complete robotic system", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[4]]<-answers[[i]][[4]]+1
          }
          else{
            if(! grepl(options[[i]][[j]][[k]], " ", fixed=TRUE)){   
              answers[[i]][[5]]<-answers[[i]][[5]]+1
              openended_c[[25]][[counter[[1]][[3]]]]<-options[[i]][[j]][[k]]
              counter[[1]][[3]]<-counter[[1]][[3]]+1
            }
          }
        } else if (i==4) {
          if(grepl("ROS 2.0", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[2]]<-answers[[i]][[2]]+1
          }
          else if(grepl("ROS", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[1]]<-answers[[i]][[1]]+1
          }
          else if(grepl("OROCOS", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[3]]<-answers[[i]][[3]]+1
          }
          else if(grepl("SmartSoft", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[4]]<-answers[[i]][[4]]+1
          }
          else if(grepl("Yarp", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[5]]<-answers[[i]][[5]]+1
          }
          else{
            if(! grepl(options[[i]][[j]][[k]], " ", fixed=TRUE)){   
              answers[[i]][[6]]<-answers[[i]][[6]]+1
              openended_c[[26]][[counter[[1]][[4]]]]<-options[[i]][[j]][[k]]
              counter[[1]][[4]]<-counter[[1]][[4]]+1
            }
          }
        } else if (i==5) {
          if(grepl("Proprietary", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[1]]<-answers[[i]][[1]]+1
          }
          else if(grepl("Open source", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[2]]<-answers[[i]][[2]]+1
          }
          else if(grepl("Don't know", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[3]]<-answers[[i]][[3]]+1
          }
          else{
            if(! grepl(options[[i]][[j]][[k]], " ", fixed=TRUE)){   
              answers[[i]][[4]]<-answers[[i]][[4]]+1
              openended_c[[27]][[counter[[1]][[5]]]]<-options[[i]][[j]][[k]]
              counter[[1]][[5]]<-counter[[1]][[5]]+1
            }
          }
        } else if (i==6) {
          if(grepl("Proprietary", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[1]]<-answers[[i]][[1]]+1
          }
          else if(grepl("Open source", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[2]]<-answers[[i]][[2]]+1
          }
          else if(grepl("Don't know", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[3]]<-answers[[i]][[3]]+1
          }
          else{
            if(! grepl(options[[i]][[j]][[k]], " ", fixed=TRUE)){   
              answers[[i]][[4]]<-answers[[i]][[4]]+1
              openended_c[[28]][[counter[[1]][[6]]]]<-options[[i]][[j]][[k]]
              counter[[1]][[6]]<-counter[[1]][[6]]+1
            }
          }
        } else if (i==7) {
          if(grepl("Lack of documentation", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[1]]<-answers[[i]][[1]]+1
          }
          else if(grepl("Lack of trust", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[2]]<-answers[[i]][[2]]+1
          }
          else if(grepl("Licensing issues", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[3]]<-answers[[i]][[3]]+1
          }
          else if(grepl("Internal policies", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[4]]<-answers[[i]][[4]]+1
          }
          else if(grepl("Technical problems", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[5]]<-answers[[i]][[5]]+1
          }
          else if(grepl("Favouring self-developed solutions", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[6]]<-answers[[i]][[6]]+1
          }
          else{
            if(! grepl(options[[i]][[j]][[k]], " ", fixed=TRUE)){   
              answers[[i]][[7]]<-answers[[i]][[7]]+1
              openended_c[[29]][[counter[[1]][[7]]]]<-options[[i]][[j]][[k]]
              counter[[1]][[7]]<-counter[[1]][[7]]+1
            }
          }
        } else if (i==8) {
          if(grepl("Copy-paste-modify", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[1]]<-answers[[i]][[1]]+1
          }
          else if(grepl("Systematic reuse", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[2]]<-answers[[i]][[2]]+1
          }
          else if(grepl("Both equally", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[3]]<-answers[[i]][[3]]+1
          }
        } else if (i==9) {
          if(grepl("We rely on the experience and skills of our team", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[1]]<-answers[[i]][[1]]+1
          }
          else if(grepl("We follow a precise architecture of the system", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[2]]<-answers[[i]][[2]]+1
          }
          else if(grepl("We have a clear definition of interfaces of each component", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[3]]<-answers[[i]][[3]]+1
          }
          else if(grepl("We follow a standard", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[4]]<-answers[[i]][[4]]+1
          }
          else if(grepl("Other", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[5]]<-answers[[i]][[5]]+1
          }
        } else if (i==10) {
          if(grepl("Manual specification based on experience", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[1]]<-answers[[i]][[1]]+1
          }
          else if(grepl("Simulation", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[2]]<-answers[[i]][[2]]+1
          }
          else if(grepl("Runtime monitoring", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[3]]<-answers[[i]][[3]]+1
          }
          else if(grepl("Don't know", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[4]]<-answers[[i]][[4]]+1
          }
          else{
            if(! grepl(options[[i]][[j]][[k]], " ", fixed=TRUE)){   
              answers[[i]][[5]]<-answers[[i]][[5]]+1
              openended_c[[30]][[counter[[1]][[10]]]]<-options[[i]][[j]][[k]]
              counter[[1]][[10]]<-counter[[1]][[10]]+1
            }
          }
        } else if (i==11) {
          if(grepl("Developer", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[1]]<-answers[[i]][[1]]+1
          }
          else if(grepl("Non-technical end-user", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[2]]<-answers[[i]][[2]]+1
          }
          else if(grepl("Technically skilled end-user", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[3]]<-answers[[i]][[3]]+1
          }
          else if(grepl("Integrator", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[4]]<-answers[[i]][[4]]+1
          }
          else if(grepl("Don't know", options[[i]][[j]][[k]], fixed=TRUE)){
            answers[[i]][[5]]<-answers[[i]][[5]]+1
          }
          else{
            if(! grepl(options[[i]][[j]][[k]], " ", fixed=TRUE)){   
              answers[[i]][[6]]<-answers[[i]][[6]]+1
              openended_c[[31]][[counter[[1]][[11]]]]<-options[[i]][[j]][[k]]
              counter[[1]][[11]]<-counter[[1]][[11]]+1
            }
          }
        } 
  
        #################Logic must go above
        #print(options[[i]][[j]][[k]])
        k <- k + 1
      }
      j <- j + 1
    }
    i <- i + 1
  }
  
  path_likert<-paste("open-ended-answers/",role, sep="")
  path_likert<-paste(path_likert, "/", sep="")
  
  for (i in 1:length(openended_c)){
    path<-paste(path_likert, colnames(openended_c[i]), sep="")
    path = substr(path,1,nchar(path)-1)
    write.table(openended_c[i], file = paste(path, ".txt", sep=""), sep = "\n",
                             row.names = TRUE)
  }
  #Remove extra items in vectors
  answers[[3]]<-answers[[3]][-(6:8)]
  answers[[4]]<-answers[[4]][-(7:8)]
  answers[[5]]<-answers[[5]][-(5:8)]
  answers[[6]]<-answers[[6]][-(5:8)]
  answers[[7]]<-answers[[7]][-8]
  answers[[8]]<-answers[[8]][-(4:8)]
  answers[[9]]<-answers[[9]][-(6:8)]
  answers[[10]]<-answers[[10]][-(6:8)]
  answers[[11]]<-answers[[11]][-(7:8)]
  #print(answers)
  
  ## Plotting 
  # Example of manual ordering
  # Result2 = likert(MyRData2)
  # my_plot2=plot(Result2, group.order=names(MyRData2), type="bar")
  # ggsave("graphs/likert/paradigms.pdf", plot = my_plot2, width=7, height=2.8)
  
  # Likert
  myColor <- c("aquamarine3", "aquamarine2", "lightgoldenrod", "lightblue", "lightblue3", "dark grey")
  path_likert<-paste("graphs/",role, sep="")
  path_likert<-paste(path_likert, "/likert/", sep="")
  Width<-7
  TextBars<-4.5
  TextOut<-14
  # activities=plot(likert(likert_c[,(1:9)]), type="bar")
  # ggsave(paste(path_likert, "activities.pdf", sep=""), plot = activities, width=7, height=3.6)
  activities_filtered=plot(likert(likert_c_filtered[,(1:9)]), type="bar", text.size=TextBars)+
    labs(y="Percentage of responses")+
    theme(legend.title=element_blank(), 
          legend.text=element_text(size=TextOut),
          axis.text = element_text(size=TextOut))
  ggsave(paste(path_likert, "activities_filtered.pdf", sep=""), plot = activities_filtered, width=Width, height=3.2)
  activities=plot(likert(likert_c[,(1:9)]), ordered = FALSE, centered = FALSE, group.order = names(likert_c[1:9]), col=myColor, plot.percents = TRUE, plot.percent.low=FALSE, plot.percent.high=FALSE)
  ggsave(paste(path_likert, "activities_notcentered.pdf", sep=""), plot = activities , width=9, height=3.6)
  
  # paradigms=plot(likert(likert_c[,(10:15)]), type="bar")
  # ggsave("graphs/likert/paradigms.pdf", plot = paradigms, width=7, height=3.6)
  paradigms_filtered=plot(likert(likert_c_filtered[,(10:15)]), type="bar", text.size=TextBars)+
    labs(y="Percentage of responses")+
    theme(legend.title=element_blank(),
          legend.text=element_text(size=TextOut),
          axis.text = element_text(size=TextOut))
  ggsave(paste(path_likert, "paradigms_filtered.pdf", sep=""), plot = paradigms_filtered, width=Width, height=2.7)
  paradigms=plot(likert(likert_c[,(10:15)]), ordered = FALSE, centered = FALSE, group.order = names(likert_c[10:15]), col=myColor, plot.percents = TRUE, plot.percent.low=FALSE, plot.percent.high=FALSE)
  ggsave(paste(path_likert, "paradigms_notcentered.pdf", sep=""), plot = paradigms , width=7, height=3.6)
  
  # methodologies=plot(likert(likert_c[,(16:19)]), type="bar")
  # ggsave("graphs/likert/methodologies.pdf", plot = methodologies, width=7, height=3.6)
  methodologies_filtered=plot(likert(likert_c_filtered[,(16:19)]), type="bar", text.size=TextBars)+
    labs(y="Percentage of responses")+
    theme(legend.title=element_blank(),
          legend.text=element_text(size=TextOut),
          axis.text = element_text(size=TextOut))
  ggsave(paste(path_likert, "methodologies_filtered.pdf", sep=""), plot = methodologies_filtered, width=Width, height=2)
  methodologies=plot(likert(likert_c[,(16:19)]), ordered = FALSE, centered = FALSE, group.order = names(likert_c[16:19]), col=myColor, plot.percents = TRUE, plot.percent.low=FALSE, plot.percent.high=FALSE)
  ggsave(paste(path_likert, "methodologies_notcentered.pdf", sep=""), plot = methodologies, width=7, height=3.6)
  
  # languages=plot(likert(likert_c[,(20:28)]), type="bar")
  # ggsave("graphs/likert/languages.pdf", plot = languages, width=7, height=3.6)
  languages_filtered=plot(likert(likert_c_filtered[,(20:28)]), type="bar", text.size=TextBars)+
    labs(y="Percentage of responses")+
    theme(legend.title=element_blank(),
          legend.text=element_text(size=TextOut),
          axis.text = element_text(size=TextOut))
  ggsave(paste(path_likert, "languages_filtered.pdf", sep=""), plot = languages_filtered, width=Width, height=3.4)
  languages=plot(likert(likert_c[,(20:28)]), ordered = FALSE, centered = FALSE, group.order = names(likert_c[20:28]), col=myColor, plot.percents = TRUE, plot.percent.low=FALSE, plot.percent.high=FALSE)
  ggsave(paste(path_likert, "languages_notcentered.pdf", sep=""), plot = languages, width=7, height=3.6)
  
  # artifacts=plot(likert(likert_c[,(29:36)]), type="bar")
  # ggsave("graphs/likert/artifacts.pdf", plot = artifacts, width=7, height=3.6)
  artifacts_filtered=plot(likert(likert_c_filtered[,(29:36)]), type="bar", text.size=TextBars)+
    labs(y="Percentage of responses")+
    theme(legend.title=element_blank(),
          legend.text=element_text(size=TextOut),
          axis.text = element_text(size=TextOut))
  ggsave(paste(path_likert, "artifacts_filtered.pdf", sep=""), plot = artifacts_filtered, width=Width, height=3)
  artifacts=plot(likert(likert_c[,(29:36)]), ordered = FALSE, centered = FALSE, group.order = names(likert_c[29:36]), col=myColor, plot.percents = TRUE, plot.percent.low=FALSE, plot.percent.high=FALSE)
  ggsave(paste(path_likert, "artifacts_notcentered.pdf", sep=""), plot = artifacts, width=7, height=3.6)
  
  # qa=plot(likert(likert_c[,(37:42)]), type="bar")
  # ggsave("graphs/likert/qa.pdf", plot = qa, width=7, height=3.6)
  qa_filtered=plot(likert(likert_c_filtered[,(37:42)]), type="bar", text.size=TextBars)+
    labs(y="Percentage of responses")+
    theme(legend.title=element_blank(),
          legend.text=element_text(size=TextOut),
          axis.text = element_text(size=TextOut))
  ggsave(paste(path_likert, "qa_filtered.pdf", sep=""), plot = qa_filtered, width=Width, height=2.7)
  qa=plot(likert(likert_c[,(37:42)]), ordered = FALSE, centered = FALSE, group.order = names(likert_c[37:42]), col=myColor, plot.percents = TRUE, plot.percent.low=FALSE, plot.percent.high=FALSE)
  ggsave(paste(path_likert, "qa_notcentered.pdf", sep=""), plot = qa, width=7, height=3.6)
  
  # mission=plot(likert(likert_c[,(43:47)]), type="bar")
  # ggsave("graphs/likert/mission.pdf", plot = mission, width=7, height=3.6)
  mission_filtered=plot(likert(likert_c_filtered[,(43:47)]), type="bar", text.size=TextBars)+
    labs(y="Percentage of responses")+
    theme(legend.title=element_blank(),
          legend.text=element_text(size=TextOut),
          axis.text = element_text(size=TextOut))
  ggsave(paste(path_likert, "mission_filtered.pdf", sep=""), plot = mission_filtered, width=Width, height=2.4)
  mission=plot(likert(likert_c[,(43:47)]), ordered = FALSE, centered = FALSE, group.order = names(likert_c[43:47]), col=myColor, plot.percents = TRUE, plot.percent.low=FALSE, plot.percent.high=FALSE)
  ggsave(paste(path_likert, "mission_notcentered.pdf", sep=""), plot = mission, width=7, height=3.6)
  
  # challenges=plot(likert(likert_c[,(48:59)]), type="bar")
  # ggsave("graphs/likert/challenges.pdf", plot = challenges, width=7, height=3.6)
  challenges_filtered=plot(likert(likert_c_filtered[,(48:59)]), type="bar", text.size=TextBars)+
    labs(y="Percentage of responses")+
    theme(legend.title=element_blank(),
          legend.text=element_text(size=TextOut),
          axis.text = element_text(size=TextOut))
  ggsave(paste(path_likert, "challenges_filtered.pdf", sep=""), plot = challenges_filtered, width=9, height=4)
  challenges=plot(likert(likert_c[,(48:59)]), ordered = FALSE, centered = FALSE, group.order = names(likert_c[48:59]), col=myColor, plot.percents = TRUE, plot.percent.low=FALSE, plot.percent.high=FALSE)
  ggsave(paste(path_likert, "challenges_notcentered.pdf", sep=""), plot = challenges, width=7, height=3.6)
  
  # Pie charts
  titles<-c("Which types of robots are used in your projects?", 
            "Which is the application field of your projects?",
            "Which type of service or product do you provide in your projects?",
            "Which of these robotic frameworks do you use in your projects?",
            "Which licensing model applies to the software used in your projects?",
            "Which licensing model applies to the software developed in your projects?",
            "Have you ever developed a software component from scratch rather reusing an existing one?",
            "Which reuse style is the most commonly used in your projects?",
            "Which mechanisms to facilitate interoperability among components are applied in your projects?",
            "From where do you get test data in your projects?",
            "Who specifies missions for robots in your projects?")
  
  for (i in 1:length(answers)){
    #Create the data frame, one per answer
    if(i==1){  
      df = data.frame("Types" = c("Mobile robots", "Mobile manipulators", "Humanoid robots", "Collaborative robots", "Drones", "Underwater robots", "Industrial arms", "Others"),
                    "value" = answers[[i]])
    }
    else if(i==2){  
      df = data.frame("Types" = c("Factory automation", "Agriculture", "Cleaning", "Transportation", "Medical", "Defense", "Service robots research", "Others"),
                      "value" = answers[[i]])
    }
    else if(i==3){  
      df = data.frame("Types" = c("Drivers", "Low-level funct.", "Planning modules", "Complete system", "Others"),
                      "value" = answers[[i]])
    }
    else if(i==4){  
      df = data.frame("Types" = c("ROS", "ROS2", "OROCOS", "SmartSoft", "Yarp",  "Others"),
                      "value" = answers[[i]])
    }
    else if(i==5){  
      df = data.frame("Types" = c("Proprietary", "Open source", "Don't know", "Others"),
                      "value" = answers[[i]])
    }
    else if(i==6){  
      df = data.frame("Types" = c("Proprietary", "Open source", "Don't know", "Others"),
                      "value" = answers[[i]])
    }
    else if(i==7){  
      df = data.frame("Types" = c("Lack of documentation", "Lack of trust", "Licensing issues", "Internal policies", "Technical problems", "Self-developed solutions", "Others"),
                      "value" = answers[[i]])
    }
    else if(i==8){  
      df = data.frame("Types" = c("Copy-paste-modify", "Systematic reuse", "Both equally"),
                      "value" = answers[[i]])
    }
    else if(i==9){  
      df = data.frame("Types" = c("Experience and skills", "Precise architecture", "Clear interfaces", "We follow a standard", "Others"),
                      "value" = answers[[i]])
    }
    else if(i==10){  
      df = data.frame("Types" = c("Manually based on experience", "Simulation", "Runtime monitoring", "Don't know", "Others"),
                      "value" = answers[[i]])
    }
    else if(i==11){  
      df = data.frame("Types" = c("Developer", "Non-technical end-user", "Technically skilled end-user", "Integrator", "Don't know", "Others"),
                      "value" = answers[[i]])
    }
    # Create a basic bar
    pie = ggplot(df, aes(x="", y=value, fill=Types)) + geom_bar(stat="identity", width=1)
    # Convert to pie (polar coordinates) and add labels
    pie = pie + coord_polar("y", start=0) + geom_text(aes(label = value), position = position_stack(vjust = 0.5))
    # Remove labels and add title
    pie = pie + labs(x = NULL, y = NULL, fill = NULL, title = titles[[i]])
    # Tidy up the theme
    pie = pie + theme_classic() + theme(axis.line = element_blank(),
                                        axis.text = element_blank(),
                                        axis.ticks = element_blank(),
                                        plot.title = element_text(hjust = 0.5, color = "#666666"))
    path<-paste("graphs/",role, sep="")
    path<-paste(path,"/piechart/plot", sep="")
    path<-paste(path, i, sep="")
    path<-paste(path, ".pdf", sep="")
    ggsave(path, plot = pie, width=7, height=3.6)
    
    #Barplot and percentages
    barplot_per<-list(rep(0,length(answers[[i]])))
    for (j in 1:length(answers[[i]])){
      #barplot_per[[1]][[j]]<-format(round((answers[[i]][[j]]*100)/length(piechart_c[[1]]), 1), nsmall = 1)
      barplot_per[[1]][[j]]<-round((answers[[i]][[j]]*100)/length(piechart_c[[1]]), 1)
    }
    df[["value"]]<-barplot_per[[1]]
    df[["Types"]] <- factor(df[["Types"]], levels = df[["Types"]][order(df[["value"]])])
    plot_per=ggplot(data=df, aes(x=Types, y=value)) +
      geom_bar(stat="identity", fill="steelblue")+
      geom_text(aes(label=value), vjust=1.6, color="white", size=5)+
      theme_minimal()+
      theme(axis.title.x=element_blank(),
            axis.text.x = element_text(size = 15, angle = 45, hjust = 1),
            axis.title.y=element_blank(),
            axis.text.y= element_text(size = 15))
      # theme_minimal()+
      #   theme(axis.title.x=element_blank())
    path<-paste("graphs/",role, sep="")
    path<-paste(path,"/piechart/plot", sep="")
    path<-paste(path, i, sep="")    
    path<-paste(path, "_per.pdf", sep="")
    ggsave(path, plot = plot_per, width=5.55, height=5)
  }

  tools<-list(rep(0,length(openended_c[[9]])))
  
  ## Tools
  activity<-1
  for (i in 2:9){
    answer<-1
    if(i>2) tools[[activity]]<-"0"
    for (j in 1:length(openended_c[[i]])){
      #tools_aux<-gsub(" ", "", openended_c[[i]][[j]], fixed = TRUE)
      tools_aux<-strsplit(toString(openended_c[[i]][[j]]), ",")[[1]]
      tools_aux<-tolower(tools_aux)
      for (l in 1:length(tools_aux))
        if (length(tools_aux[l]) > 0){
            if((!identical(tools_aux[l], character(0))) & (!is.na(tools_aux[l]))){
              tools[[activity]][[answer]]<-tools_aux[l]
              answer<-answer+1
          }
        }
    }
    activity<-activity+1
  }
  
  PM <- list()
  RE <- list()
  Arch <- list()
  Imp <- list()
  Code <- list()
  Testing <- list()
  RW <- list()
  Maint <- list()
  
  
  for (i in 1:length(tools)){
    tools_aux<-c()
    #tools_aux<-list()
    count<- c(rep(0,length(tools[[i]])))
    total<-0
    pycharm<-0
    for (j in 1:length(tools[[i]])){
      if(grepl(gsub(" ", "", "eclipse", fixed = TRUE), gsub(" ", "", tools[[i]][[j]], fixed = TRUE), fixed=TRUE)){
        pycharm<-pycharm+1
      }
      if(length(tools_aux) == 0){
        count[j]<-count[j]+1
        total=total+1
        tools_aux<-append(tools_aux, tools[[i]][[j]])
      }
      else{
        contained<-FALSE
        for (l in 1:length(tools_aux)){
          if(gsub(" ", "", tools[[i]][[j]], fixed = TRUE)==gsub(" ", "", tools_aux[l], fixed = TRUE)){
            contained<-TRUE
            count[l]<-count[l]+1
            total=total+1
            break
          }
        }
        
        if(contained==FALSE){
          tools_aux<-append(tools_aux, tools[[i]][[j]])
          count[length(tools_aux)]<-count[length(tools_aux)]+1
          total=total+1
        }
        #else print(tools[[i]][[j]])
      }
      
    }
    count<-count[1:length(tools_aux)]
    #print(pycharm)
    if(i==1){
      PM[[1]]<-tools_aux
      PM[[2]]<-count
      names(PM)<-c("Tool", "Times")
    } 
    if(i==2){
      RE[[1]]<-tools_aux
      RE[[2]]<-count
      names(RE)<-c("Tool", "Times")
    } 
    if(i==3){
      Arch[[1]]<-tools_aux
      Arch[[2]]<-count
      names(Arch)<-c("Tool", "Times")
    } 
    if(i==4){
      Imp[[1]]<-tools_aux
      Imp[[2]]<-count
      names(Imp)<-c("Tool", "Times")
    } 
    if(i==5){
      Code[[1]]<-tools_aux
      Code[[2]]<-count
      names(Code)<-c("Tool", "Times")
    } 
    if(i==6){
      Testing[[1]]<-tools_aux
      Testing[[2]]<-count
      names(Testing)<-c("Tool", "Times")
    } 
    if(i==7){
      RW[[1]]<-tools_aux
      RW[[2]]<-count
      names(RW)<-c("Tool", "Times")
    } 
    if(i==8){
      Maint[[1]]<-tools_aux
      Maint[[2]]<-count
      names(Maint)<-c("Tool", "Times")
    }
    
    df = data.frame("Tools" = tools_aux,
                    "Times" = count)
    #df <- df[ which(count>2),]
    newdata <- df[order(count,decreasing = TRUE),] 
    df<- newdata[1:8,]
    df[["Tools"]] <- factor(df[["Tools"]], levels = df[["Tools"]][order(df[["Times"]])])
    tools_graph=ggplot(data=df, aes(x=Tools, y=Times)) +
      geom_bar(stat="identity", fill="steelblue")+
      geom_text(aes(label=Times), vjust=1.6, color="white", size=3.5)+
      theme_tufte() +
      theme(axis.text.x = element_text(size = 6)) + 
      labs(x = "", y = "Ocurrences")
    path<-paste("graphs/",role, sep="")
    path<-paste(path,"/barplot/", sep="")
    path<-paste(path, names(openended_c[i+1]), sep="")
    path = substr(path,1,nchar(path)-1)
    path<-paste(path, ".pdf", sep="")
    ggsave(path, plot = tools_graph, width=15, height=3.6)
  }
}

####################### Invoking function
a<-1
##Invoke function
analyze(MyRData, "all")
analyze(pract_leading, "industrial-leading")
analyze(pract_programmer, "industrial-programmer")
analyze(academic, "academic")
analyze(practitioner, "industrial")


#######################Ethnograpics


pie_calculator<-function(dataframe){
  # Create a basic bar
  pie = ggplot(df, aes(x="", y=value, fill=Types)) + geom_bar(stat="identity", width=1)
  # Convert to pie (polar coordinates) and add labels
  pie = pie + coord_polar("y", start=0) + geom_text(aes(label = value), position = position_stack(vjust = 0.5))
  # Remove labels and add title
  pie = pie + labs(x = NULL, y = NULL, fill = NULL, title = "Roles")
  # Tidy up the theme
  pie = pie + theme_classic() + theme(axis.line = element_blank(),
                                      axis.text = element_blank(),
                                      axis.ticks = element_blank(),
                                      plot.title = element_text(hjust = 0.5, color = "#666666"))
}
string_greps<-function(number, string){
  contains=grepl(number, string, fixed=TRUE)
}
###########Roles
total<-length(MyRData[[1]])
practitioner_perc<-c_practitioner*100/total
print(paste("Percentage practitioners (", c_practitioner,"): ", practitioner_perc, sep=""))
programmer_perc<-c_programmer*100/total
print(paste("Percentage programmers (", c_programmer,"): ", programmer_perc, sep=""))
leading_perc<-c_leading*100/total
print(paste("Percentage leading (", c_leading,"): ", leading_perc, sep=""))
academic_perc<-c_academic*100/total
print(paste("Percentage academic/scientists (", c_academic,"): ", academic_perc, sep=""))
other_perc<-c_other*100/total
print(paste("Percentage other (", c_other,"): ", other_perc, sep=""))

roles<-c(c_programmer, c_leading, c_academic, c_other)
df = data.frame("Types" = c("Industrial practitioner: Programmer", "Industrial practitioner: Leading Technical Role", "Academic/Scientist", "Other"),
                "value" = roles)
pie<-pie_calculator(df)
ggsave("graphs/all/piechart/roles.pdf", plot = pie, width=7, height=3.6)
format(round(other_perc, 2), nsmall = 2)
roles<-c(format(round(programmer_perc, 2), nsmall = 2), format(round(leading_perc, 2), nsmall = 2), format(round(academic_perc, 2), nsmall = 2), format(round(other_perc, 2), nsmall = 2))
df = data.frame("Types" = c("Industrial practitioner: Programmer", "Industrial practitioner: Leading Technical Role", "Academic/Scientist", "Other"),
                "value" = roles)
pie<-pie_calculator(df)
ggsave("graphs/all/piechart/roles_perc.pdf", plot = pie, width=7, height=3.6)

###########Years of experience
less_1<-0
more_1<-0
more_5<-1
more_10<-0
more_15<-0
other<-0
years<-c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
         "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31")
for (j in 1:length(MyRData[[1]])){
  for (i in length(years):1) {
    years_other<-TRUE
    if (string_greps(years[i], MyRData[[95]][[j]]) & j!=4){
      if (i>=15){
        more_15<-more_15+1
        #print(paste("More 15 count ", more_15, " on coincidence ", MyRData[[95]][[j]], sep=""))
        years_other<-FALSE
        break
      }
      else if (i>=10){
        more_10<-more_10+1
        #print(paste("More 10 count ", more_10, " on coincidence ", MyRData[[95]][[j]], sep=""))
        years_other<-FALSE
        break
      }
      else if (i>=5){
        more_5<-more_5+1
        #print(paste("More 5 count ", more_5, " on coincidence ", MyRData[[95]][[j]], sep=""))
        years_other<-FALSE
        break
      }
      else if (i>=1){
        more_1<-more_1+1
        #print(paste("More 1 count ", more_1, " on coincidence ", MyRData[[95]][[j]], sep=""))
        years_other<-FALSE
        break
      }
    }
  }
  if(years_other & j!=4){
    other<-other+1
    #print(paste("other count ", other, " on coincidence ", MyRData[[95]][[j]], sep=""))
  }
}

total<-length(MyRData[[1]])
more_15_perc<-more_15*100/total
print(paste("Percentage of respondents with more of 15 years of experience (", more_15,"): ", more_15_perc, sep=""))
more_10_perc<-more_10*100/total
print(paste("Percentage of respondents with more of 10 years of experience (", more_10,"): ", more_10_perc, sep=""))
more_5_perc<-more_5*100/total
print(paste("Percentage of respondents with more of 5 years of experience (", more_5,"): ", more_5_perc, sep=""))
more_1_perc<-more_1*100/total
print(paste("Percentage of respondents with more of 1 year of experience (", more_1,"): ", more_1_perc, sep=""))
other_perc<-other*100/total
print(paste("Percentage other (", other,"): ", other_perc, sep=""))

df = data.frame("Types" = c("More than 15 years", "More than 10 years", "More than 5 years", "More than 1 year", "Other"),
                "value" = c(more_15, more_10, more_5, more_1, other))
pie<-pie_calculator(df)
ggsave("graphs/all/piechart/years.pdf", plot = pie, width=7, height=3.6)

df = data.frame("Types" = c("More than 15 years", "More than 10 years", "More than 5 years", "More than 1 year", "Other"),
                "value" = c(format(round(more_15_perc, 2), nsmall = 2), 
                            format(round(more_10_perc, 2), nsmall = 2), 
                            format(round(more_5_perc, 2), nsmall = 2), 
                            format(round(more_1_perc, 2), nsmall = 2), 
                            format(round(other_perc, 2), nsmall = 2)))
pie<-pie_calculator(df)
ggsave("graphs/all/piechart/years_perc.pdf", plot = pie, width=7, height=3.6)