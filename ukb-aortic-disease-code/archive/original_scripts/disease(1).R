
##疾病诊断
Outcome <- read.csv("D:/科研/UKB/data/outcome.csv")

for (i in 2:260) {
  Outcome[, i][grepl("^B18", Outcome[, i])] <- 1
  Outcome[, i][is.na(Outcome[, i])] <- 0
  Outcome[, i][Outcome[, i] != 1] <- 0
  Outcome[, i] <- as.numeric(Outcome[, i])
}


for (i in 261:519){
  Outcome[,i] <- as.numeric(as.Date.character(Outcome[,i]))
  Outcome[,i][is.na(Outcome[,i])] <-0
  Outcome[,i] <- Outcome[,i]*Outcome[,(i-259)]
  Outcome[,i][Outcome[,i] == 0] <- 20000
}

Outcome$opsm <- 0
Outcome$opsm <- rowSums(Outcome[,c(2:260)], na.rm = FALSE, dims = 1)
table(Outcome$opsm)
Outcome$opsm[Outcome$opsm > 1] <- 1
table(Outcome$opsm)
Outcome$opsm_date <- 20000
Outcome$opsm_date <-apply(Outcome[,c(261:519)], 1, FUN=min)
summary(Outcome$opsm_date)
Outcome$opsm_date <- as.Date(Outcome$opsm_date)
Outcome$opsm_date[Outcome$opsm_date == "2024-10-04"] <- "2023-10-30"  ## 

Disease <- select(Outcome,eid,opsm,opsm_date)
write.csv(Disease,file="C:/Users/余00/Desktop/Multimorbidity/disease/alcohol.csv",row.names = T)


disease1 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/disease.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease2 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/disease_1129.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease3 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/disease_1129.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease4 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/prostate.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease5 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/RA.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease6 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/stroke.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease7 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/osteoporosis.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease8 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/COPD.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease9 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/migraine.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease10 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/disease.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease11 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/disease_1129.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease12 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/disease_1129.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease13 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/CFS.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease14 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/PVD.csv",sep = ",",header = T,stringsAsFactors = FALSE)
disease15 <- fread("C:/Users/余00/Desktop/Multimorbidity/Disease/sch.csv",sep = ",",header = T,stringsAsFactors = FALSE)
f1 <- merge(disease1,disease2,by='eid')
f2 <- merge(f1,disease3,by='eid')
f3 <- merge(f2,disease4,by='eid')
f4 <- merge(f3,disease5,by='eid')
f5 <- merge(f4,disease6,by='eid')
f6 <- merge(f5,disease7,by='eid')
f7 <- merge(f6,disease8,by='eid')
f8 <- merge(f7,disease9,by='eid')
f9 <- merge(f8,disease10,by='eid')
f10 <- merge(f9,disease11,by='eid')
f11 <- merge(f10,disease12,by='eid')
f12 <- merge(f11,disease13,by='eid')
f13 <- merge(f12,disease14,by='eid')
f14 <- merge(f13,disease15,by='eid')
write.csv(f10,file="C:/Users/余00/Desktop/Multimorbidity/disease/Disease.csv",row.names = T)


