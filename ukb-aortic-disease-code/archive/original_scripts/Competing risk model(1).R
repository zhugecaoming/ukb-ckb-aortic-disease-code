library('dplyr')
library('data.table')
library('tidyverse')
library('ggplot2')
library('ggpubr')
library("survival")
library("survminer")
library(readxl)
library(riskRegression)
ukb <- fread("D:/科研/UKB/data/divorce_tongji.csv",
             sep = ",",
             header = T,
             stringsAsFactors = FALSE)

##physical active
ukb$low <- 3*ukb$low_day*ukb$low_time
ukb$moderate <- 4.5*ukb$moderate_day*ukb$moderate_time
ukb$vigorous <- 8*ukb$high_day*ukb$high_time
ukb <- filter(ukb,ukb$low>=0|ukb$moderate>=0|ukb$vigorous>=0)
ukb$low[is.na(ukb$low)]<-'0'
ukb$moderate[is.na(ukb$moderate)]<-'0'
ukb$vigorous[is.na(ukb$vigorous)]<-'0'
ukb$low[ukb$low<0] <- '0'
ukb$moderate[ukb$moderate<0] <- '0'
ukb$vigorous[ukb$vigorous<0] <- '0'
ukb$low <- as.numeric(ukb$low)
ukb$moderate <- as.numeric(ukb$moderate)
ukb$vigorous <- as.numeric(ukb$vigorous)
ukb$MET <- ukb$low+ukb$moderate+ukb$vigorous

##factor
ukb$centre[ukb$region==11012|ukb$region==11021|ukb$region==11011|ukb$region==11008|ukb$region==11003|ukb$region==11024
           |ukb$region==11020|ukb$region==11018|ukb$region==11010|ukb$region==11016|ukb$region==11001|ukb$region==11017
           |ukb$region==11009|ukb$region==11013|ukb$region==11002|ukb$region==11007|ukb$region==11014|ukb$region==10003
           |ukb$region==11006|ukb$region==11025|ukb$region==11026|ukb$region==11027|ukb$region==11028] <- '1'
ukb$centre[ukb$region==11005|ukb$region==11004] <- '2'
ukb$centre[ukb$region==11022|ukb$region==11023] <- '3' 

ukb$income[ukb$income=='-3'|ukb$income=='-1'] <- '9'
ukb$income <- as.factor(ukb$income)

edu <- fread("D:/科研/UKB/data/education.csv",
             sep = ",",
             header = T,
             stringsAsFactors = FALSE)
ukb <- merge(ukb,edu,by='eid')
ukb$edu <- pmax(ukb$edu1,ukb$edu2,ukb$edu3,ukb$edu4,
                ukb$edu5,ukb$edu6,na.rm = T)
ukb$edu[ukb$edu=='-7'|ukb$edu=='-3'] <- '9'
ukb$edu<- as.factor(ukb$edu)

ukb$race[ukb$ethnic==1|ukb$ethnic==1001|ukb$ethnic==1002|ukb$ethnic==1003] <- '1'
ukb$race[ukb$ethnic==4|ukb$ethnic==4001|ukb$ethnic==4002|ukb$ethnic==4003] <- '2'
ukb$race[ukb$ethnic==3|ukb$ethnic==3001|ukb$ethnic==3002|ukb$ethnic==3003|ukb$ethnic==3004|ukb$ethnic==5] <- '3'
ukb$race[ukb$ethnic==2|ukb$ethnic==2001|ukb$ethnic==2002|ukb$ethnic==2003|ukb$ethnic==2004] <- '4'
ukb$race[ukb$ethnic==6|ukb$ethnic=='-1'|ukb$ethnic=='-3'] <- '5'
ukb$race<- as.factor(ukb$race)

ukb$smoke[ukb$smoke=='-3'] <- '9'
ukb$smoke <- as.numeric(ukb$smoke)
ukb$smoke <- as.factor(ukb$smoke)

ukb$drink[ukb$drink=='-3'] <- '9'
ukb$drink <- as.numeric(ukb$drink)
ukb$drink <- as.factor(ukb$drink)

##death
death <- fread("D:/科研/UKB/data/aortic_cause.csv",
               sep = ",",
               header = T,
               stringsAsFactors = FALSE)
ukb <- merge(ukb,death,by='eid')

#operation
UKB_I710 <- read.csv("D:/科研/UKB/data/buchong.csv")
df <- read_excel("D:/科研/UKB/data/OPCS4.xlsx")
values_matrix <- as.matrix(df)
allowed_values <- values_matrix # 循环遍历指定列范围
for (i in 2:127) { 
  UKB_I710[, i][UKB_I710[, i] %in% allowed_values] <- 1
  UKB_I710[, i][is.na(UKB_I710[, i])] <- 0
  UKB_I710[, i][UKB_I710[, i] != 1] <- 0
  UKB_I710[, i] <- as.numeric(UKB_I710[, i])
}

for (i in 128:253){
  UKB_I710[,i] <- as.numeric(as.Date.character(UKB_I710[,i]))
  UKB_I710[,i][is.na(UKB_I710[,i])] <-0
  UKB_I710[,i] <- UKB_I710[,i]*UKB_I710[,(i-126)]
  UKB_I710[,i][UKB_I710[,i] == 0] <- 20000
}

UKB_I710$case <- 0
UKB_I710$case <- rowSums(UKB_I710[,c(2:127)], na.rm = FALSE, dims = 1)
table(UKB_I710$case)
UKB_I710$case[UKB_I710$case > 1] <- 1
table(UKB_I710$case)
UKB_I710$date <- 20000
UKB_I710$date <-apply(UKB_I710[,c(128:253)], 1, FUN=min)
summary(UKB_I710$date)
UKB_I710$date <- as.Date(UKB_I710$date)
UKB_I710$date[UKB_I710$date == "2024-10-04"] <- "2023-10-30"  ##
OPCS <- select(UKB_I710,eid,case,date)

##ICD-10
AN <- fread("D:/科研/UKB/data/Aortic disease.csv",sep = ",",header = T,stringsAsFactors = FALSE)
merge1 <- merge(ukb,AN,by='eid')
merge2 <- merge(merge1,OPCS,by='eid')
merge2$death_data1 <- as.Date(merge2$death_data1)
merge2$death_data2 <- as.Date(merge2$death_data2)
merge2$date <- as.Date(merge2$date)
merge2$date_I710 <- as.Date(merge2$date_I710)
merge2$date_I711 <- as.Date(merge2$date_I711)
merge2$date_I712 <- as.Date(merge2$date_I712)
merge2$date_I713 <- as.Date(merge2$date_I713)
merge2$date_I714 <- as.Date(merge2$date_I714)
merge2$date_I715 <- as.Date(merge2$date_I715)
merge2$date_I716 <- as.Date(merge2$date_I716)
merge2$date_I718 <- as.Date(merge2$date_I718)
merge2$date_I719 <- as.Date(merge2$date_I719)
merge2$date_Q253 <- as.Date(merge2$date_Q253)
merge2$date_M314 <- as.Date(merge2$date_M314)
merge2$date_I700 <- as.Date(merge2$date_I700)
merge2$AN_date <- pmin(merge2$date_I710,merge2$date_I711,merge2$date_I712,merge2$date_I713,
                       merge2$date_I714,merge2$date_I715,merge2$date_I716,merge2$date_I718,
                       merge2$date_I719,merge2$date_Q253,merge2$date_M314,merge2$date_I700,
                       merge2$death_data1,merge2$death_data2,merge2$date,na.rm = T)
merge2$AN_date[is.na(merge2$AN_date)]<-as.character("2023/10/30")
merge2$AN_ctime <- difftime(merge2$AN_date,merge2$data_attending,units="weeks")
merge2$AN[merge2$I710==1|merge2$I711==1|merge2$I712==1|merge2$I713==1|merge2$I714==1|merge2$I715==1|merge2$I716==1|
            merge2$I718==1|merge2$I719==1|merge2$date_Q253==1|merge2$date_M314==1|merge2$date_I700==1|
            merge2$death_cause==1|merge2$case==1] <- "1"
merge2$AN[is.na(merge2$AN)]<-'0'
merge2_2 <- filter(merge2,AN_ctime>0)

disease <- fread("D:/科研/UKB/data/disease.csv",sep = ",",header = T,stringsAsFactors = FALSE)
merge3 <- merge(merge2_2,disease,by='eid')


##death
death <- fread("D:/科研/UKB/data/death_tongji.csv",
               sep = ",",
               header = T,
               stringsAsFactors = FALSE)
death$death <- ifelse(
  !is.na(death$death_data1) | !is.na(death$death_data2), 
  1,  # 满足条件（任一日期存在）赋值为1
  0   # 否则赋值为0
)
death <- death %>%
  mutate(death_date = coalesce(death_data1, death_data2))
death_1 <- select(death,eid,death_date,death)
merge2_3 <- merge(merge2_2,death_1,by='eid')

disease <- fread("D:/科研/UKB/data/disease.csv",sep = ",",header = T,stringsAsFactors = FALSE)
merge3 <- merge(merge2_3,disease,by='eid')

diseases <- c( "hyp","pain","cancer","asthma", "dyspepsia", "CHD", "thy", "diabetes", 
               "depression", "PE", "prostate","RA", "stroke", "osteoporosis", "COPD", 
               "migraine","IBS",  "glaucoma", "DDI", "anxiety", "AF","IBD",  "epilepsy","CS","end",
               "PA", "MD", "bronch", "CFS", "PVD", "sch","PD", "CKD", "MS", "viral", 
               "CLD", "AP", "AP", "TC", "PO", "AB", "opsm")

# 过滤出该疾病为1的样本
merge3_3 <- filter(merge3, hyp == 1)

# 计算时间差，单位为周
merge3_3$cctime <- difftime(merge3_3$AN_date, merge3_3$hyp_date, units = "weeks")

# 筛选cctime小于0的样本
merge3_4 <- filter(merge3_3, cctime < 0)

# 从原数据中删除cctime小于0的样本
merge4 <- filter(merge3, !eid %in% merge3_4$eid)

merge4$death_date[is.na(merge4$death_date)]<-as.character("2023/11/1")

merge4$AN_date <- as.character(merge4$AN_date)

# 计算随访时间（年）
merge4 <- merge4 %>%
  mutate(
    time = as.numeric(
      difftime(
        pmin(death_date, AN_date, na.rm = TRUE),  # 取最早发生的事件日期
        data_attending,                            # 基线时间
        units = "days"                             # 按天计算
      ) / 365.25                                   # 转换为年
    )
  )
merge4 <- merge4 %>%
  mutate(status = case_when(
    AN == 1 & death == 1 ~ 1,
    AN == 1 ~ 1,
    death == 1 ~ 2,
    TRUE ~ 0
  ))

    # 3. 选择分析变量并删除缺失值
    analysis_data <- merge4 %>%
      select(
        eid, time, status, hyp, 
        age_base, sex, centre, race, edu, smoke, BMI, drink, income, MET
      ) %>%
      na.omit()
    
    # 4. 调整变量类型（因子变量）
    analysis_data <- analysis_data %>%
      mutate(
        sex = as.factor(sex),
        centre = as.factor(centre),
        race = as.factor(race),
        edu = as.factor(edu),
        smoke = as.factor(smoke),
        drink = as.factor(drink),
        income = as.factor(income),
        grp_met = cut(MET, breaks = c(-Inf, 600, 3000, Inf), labels = c("1", "2", "3")) # 分组MET
      )
    # 拟合Fine-Gray竞争风险模型（关注主动脉疾病，死亡作为竞争事件）
    model_csc <- CSC(
      formula = Hist(time, status) ~ hyp + sex + age_base + centre + race + 
        edu + smoke + BMI + drink + income + grp_met,
      data = analysis_data,
      cause = 1  # 1=主动脉疾病是主要事件
    )
    
    # 查看结果
    summary(model_csc)
    