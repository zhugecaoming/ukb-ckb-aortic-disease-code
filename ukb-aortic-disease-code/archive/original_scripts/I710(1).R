library('dplyr')
library('data.table')
library('tidyverse')
library('ggplot2')
library('ggpubr')
library("survival")
library("survminer")
library(readxl)
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
death <- fread("D:/科研/UKB/data/death_tongji.csv",
               sep = ",",
               header = T,
               stringsAsFactors = FALSE)
# 需要检查的特定诊断编码
values_to_check <- c('I710')
death$death_cause <- apply(
  death[, c("cause1", "cause2", "cause3", "cause4", "cause5", "cause6", "cause7", "cause8", "cause9", "cause10",
            "cause11","cause12", "cause13", "cause14", "cause15", "cause16", "cause17", "cause18", "cause19", "cause20",
            "cause21", "cause22", "cause23", "cause24", "cause25", "cause26", "cause27", "cause28", "cause29", "cause30",
            "cause31", "cause32")],
  1,  # 按行遍历
  function(x) {
    if(any(x %in% values_to_check)) 1 else 0
  }
)
death_cause <- select(death, eid, death_data1, death_data2, death_cause)

##ICD-10
Outcome <- read.csv("D:/科研/UKB/data/outcome.csv")
for (i in 2:260) {
  Outcome[, i][grepl("I710", Outcome[, i])] <- 1
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

Outcome$I710 <- 0
Outcome$I710 <- rowSums(Outcome[,c(2:260)], na.rm = FALSE, dims = 1)
table(Outcome$I710)
Outcome$I710[Outcome$I710 >= 1] <- 1
table(Outcome$I710)
Outcome$I710_date <- 20000
Outcome$I710_date <-apply(Outcome[,c(261:519)], 1, FUN=min)
summary(Outcome$I710_date)
Outcome$I710_date <- as.Date(Outcome$I710_date)
Outcome$I710_date[Outcome$I710_date == "2024-10-04"] <- "2023-10-30"  ## 
Disease <- select(Outcome,eid,I710,I710_date)

#operation
UKB_I710 <- read.csv("D:/科研/UKB/data/buchong.csv")
df <- read_excel("C:/Users/余00/Desktop/Multimorbidity/data/OPCS4_I710.xlsx")
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
UKB_I710$case[UKB_I710$case >= 1] <- 1
table(UKB_I710$case)
UKB_I710$date <- 20000
UKB_I710$date <-apply(UKB_I710[,c(128:253)], 1, FUN=min)
summary(UKB_I710$date)
UKB_I710$date <- as.Date(UKB_I710$date)
UKB_I710$date[UKB_I710$date == "2024-10-04"] <- "2023-10-30"  ##
OPCS <- select(UKB_I710,eid,case,date)

merge1 <- merge(ukb,death,by='eid')
merge1_1 <- merge(merge1,OPCS,,by='eid')
merge2 <- merge(merge1_1,Disease,by='eid')
merge2$death_data1 <- as.Date(merge2$death_data1)
merge2$death_data2 <- as.Date(merge2$death_data2)
merge2$date <- as.Date(merge2$date)
merge2$I710_date <- as.Date(merge2$I710_date)
merge2$AN_date <- pmin(merge2$I710_date,merge2$date,
                       merge2$death_data1,merge2$death_data2,na.rm = T)
merge2$AN_date[is.na(merge2$AN_date)]<-as.character("2023/10/30")
merge2$AN_ctime <- difftime(merge2$AN_date,merge2$data_attending,units="weeks")
merge2$AN[merge2$I710==1|merge2$death_cause==1|merge2$case==1] <- "1"
merge2$AN[is.na(merge2$AN)]<-'0'

merge2_2 <- filter(merge2,AN_ctime>0)
disease <- fread("D:/科研/UKB/data/disease.csv",sep = ",",header = T,stringsAsFactors = FALSE)

merge3 <- merge(merge2_2,disease,by='eid')
merge3 <- filter(merge2_3,sex==0)

"hyp","pain","cancer","asthma", "dyspepsia", "CHD", "thy", "diabetes", 
"depression", "PE", "prostate","RA", "stroke", "osteoporosis", "COPD", 
"migraine","IBS",  "glaucoma", "DDI", "anxiety", "AF","IBD",  "epilepsy","CS","end",
"PA", "MD", "bronch", "CFS", "PVD", "sch","PD", "CKD", "MS", "viral", 
"CLD", "HF", "AP", "TC", "PO", "AB", "opsm"
##循环
# 定义所有疾病及对应的诊断时间列名
diseases <- c("pain", "depression","CKD", "viral", "AP", "opsm")

# 处理每一种疾病
for (disease in diseases) {
  disease_date <- paste0(disease, "_date")  # 获取对应的日期列名
  disease_col <- paste0(disease)  # 获取对应的疾病列名
  
  # 过滤出该疾病为1的样本
  merge3_3 <- filter(merge3, get(disease_col) == 1)
  
  # 计算时间差，单位为周
  merge3_3$cctime <- difftime(merge3_3$AN_date, merge3_3[[disease_date]], units = "weeks")
  
  # 筛选cctime小于0的样本
  merge3_4 <- filter(merge3_3, cctime < 0)
  
  # 从原数据中删除cctime小于0的样本
  merge4 <- filter(merge3, !eid %in% merge3_4$eid)
  
  # 选择所需的变量
  TOTAL <- select(merge4, eid, age_base, sex, centre, race, edu, smoke, BMI, drink, income, AN_ctime, AN, MET, disease_col)
  
  # 清理缺失值
  Total <- na.omit(TOTAL)
  
  # 转换变量类型
  Total$sex <- as.factor(Total$sex)
  Total$centre <- as.factor(Total$centre)
  Total$race <- as.factor(Total$race)
  
  # 处理MET变量
  Total$grp_met[Total$MET >= 3000] <- "3"
  Total$grp_met[Total$MET < 3000 & Total$MET >= 600] <- "2"
  Total$grp_met[Total$MET < 600] <- "1"
  Total$grp_met <- as.numeric(Total$grp_met)
  Total$grp_met <- as.factor(Total$grp_met)
  
  # 将AN转化为数值
  Total$AN <- as.numeric(Total$AN)
  
  # 进行生存分析
  f1 <- coxph(Surv(AN_ctime, AN) ~ get(disease_col) + age_base + centre + race + edu + smoke + BMI + drink + income + grp_met, data = Total)
  
  # 打印输出生存分析结果
  print(summary(f1))
}

##P VALUE
df <- read_xlsx('C:/Users/余00/Desktop/P value.xlsx')
df$FDR <- p.adjust(df$p_value, method = "fdr")
# 导出结果为 CSV 文件
write.csv(df, file="C:/Users/余00/Desktop/FDR_adjusted_results.csv", row.names = FALSE)

##PAF的循环 
library(survival)
library(dplyr)
library(AF)
library(rlang)   # 用 sym()/!!

## 42 种慢性病 ---------------------------
diseases <- c("hyp","pain","cancer","asthma","dyspepsia","CHD","thy","diabetes",
              "depression","PE","prostate","RA","stroke","osteoporosis","COPD",
              "migraine","IBS","glaucoma","DDI","anxiety","AF","IBD","epilepsy",
              "CS","PA","MD","bronch","CFS","PVD","sch","PD","CKD","MS",
              "viral","CLD","HF","AP","TC","PO","AB","opsm")

## 结果容器 ------------------------------
res <- list()

## 主循环 -------------------------------
for (d in diseases) {
  
  date_var <- paste0(d, "_date")   # 诊断日期列
  exp_var  <- d                    # 暴露指示列
  
  ## -- 1⃣  时间顺序：剔除“结局先于疾病”的个体 ------------
  invalid_id <- merge3 %>%
    filter(.data[[exp_var]] == 1) %>%
    mutate(cctime = difftime(AN_date, .data[[date_var]], units = "weeks")) %>%
    filter(cctime < 0) %>% pull(eid)
  
  dat_raw <- merge3 %>% filter(!eid %in% invalid_id)
  
  ## -- 2⃣  构建分析数据 -------------------------------
  Total <- dat_raw %>%
    select(eid, age_base, sex, centre, race, edu, smoke, BMI, drink,
           income, AN_ctime, AN, MET, !!sym(exp_var)) %>%
    mutate(
      sex    = factor(sex),
      centre = factor(centre),
      race   = factor(race),
      grp_met = cut(MET,
                    breaks = c(-Inf, 600, 3000, Inf),
                    labels = c("1","2","3"),
                    right  = FALSE),
      AN     = as.numeric(AN)
    ) %>%
    select(-MET) %>%                 # MET 已转成 grp_met
    na.omit()
  
  ## -- 3⃣  Cox 回归 (Breslow ties) ---------------------
  fml <- as.formula(
    paste0("Surv(AN_ctime, AN) ~ ", exp_var,
           "+ sex  + age_base + centre + race + edu + smoke + BMI + ",
           "drink + income + grp_met"))
  fit <- coxph(fml, data = Total, ties = "breslow")
  
  ## -- 4⃣  计算 PAF (Greenland-Drescher) ---------------
  af  <- AF::AFcoxph(fit,
                     data     = as.data.frame(Total),    # data.frame 而非 data.table
                     exposure = exp_var,
                     times    = max(Total$AN_ctime))     
  
  ## -- 5⃣  提取结果 -----------------------------------
  HR   <- exp(coef(fit)[exp_var])
  PAR  <- af$AF.est
  SE   <- sqrt(af$AF.var)
  CIlo <- PAR - 1.96*SE
  CIhi <- PAR + 1.96*SE
  
  res[[d]] <- data.frame(Disease = d,
                         HR      = HR,
                         PAR     = PAR,
                         CI_low  = CIlo,
                         CI_high = CIhi,
                         Events  = sum(Total$AN),
                         N       = nrow(Total))
}

## -- 6⃣  汇总输出 ------------------------------------
PAR_table <- bind_rows(res) %>% arrange(desc(PAR))
print(PAR_table)

# 若需保存
write.csv(PAR_table,file="C:/Users/余00/Desktop/PAR_I710.csv", row.names = FALSE)
