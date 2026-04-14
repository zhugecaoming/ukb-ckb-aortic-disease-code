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
            merge2$I718==1|merge2$I719==1|merge2$Q253==1|merge2$M314==1|merge2$I700==1|
            merge2$death_cause==1|merge2$case==1] <- "1"
merge2$AN[is.na(merge2$AN)]<-'0'
merge2_1 <- filter(merge2,AN_ctime>0)

factor <- fread("D:/科研/UKB/data/factor.csv",sep = ",",header = T,stringsAsFactors = FALSE)
merge2_2 <- merge(merge2_1,factor,by='eid')

disease <- fread("D:/科研/UKB/data/disease.csv",sep = ",",header = T,stringsAsFactors = FALSE)
merge3 <- merge(merge2_1,disease,by='eid')

MED <- fread("D:/科研/UKB/data/medication.csv",sep = ",",header = T,stringsAsFactors = FALSE)
merge3 <- merge(merge2_3,MED,by='eid')

MED <- fread("D:/科研/UKB/data/gene_sex.csv",sep = ",",header = T,stringsAsFactors = FALSE)
merge3 <- merge(merge2_2,MED,by='eid')
merge3$gene_sex <- merge3$`22001-0.0`
merge3 <- merge2_3
summary(merge3$SHBG)



##循环
# 定义所有疾病及对应的诊断时间列名
diseases <- c("hyp","pain","cancer","asthma", "dyspepsia", "CHD", "thy", "diabetes", 
              "depression", "PE", "prostate","RA","stroke", "osteoporosis", "COPD", 
              "migraine","IBS",  "glaucoma", "DDI", "anxiety", "AF","IBD",  "epilepsy","CS"
              ,"end","PA", "MD", "bronch", "CFS", "PVD", "sch","PD", "CKD", "MS", "viral",
              "CLD", "HF", "AP", "TC", "PO", "AB", "opsm"
              )

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
  Total$drink <- as.factor(Total$drink)
  
  # 处理MET变量
  Total$grp_met[Total$MET >= 3000] <- "3"
  Total$grp_met[Total$MET < 3000 & Total$MET >= 600] <- "2"
  Total$grp_met[Total$MET < 600] <- "1"
  Total$grp_met <- as.numeric(Total$grp_met)
  Total$grp_met <- as.factor(Total$grp_met)
  
  # 将AN转化为数值
  Total$AN <- as.numeric(Total$AN)
  
  # 进行生存分析
  f1 <- coxph(Surv(AN_ctime, AN) ~ get(disease_col)+BMI+drink  +  age_base  + centre + race + edu + smoke +  income + grp_met+sex, data = Total)
  
  # 打印输出生存分析结果
  print(summary(f1))
}


##FDR校正
df <- read.csv("C:/Users/余00/Desktop/pvalue.csv")  # 修改为你的实际路径

# FDR 校正（Benjamini-Hochberg）
df$FDR_pvalue <- p.adjust(df$pvalue, method = "fdr")

# 输出校正结果
write.csv(df, file="C:/Users/余00/Desktop/FDR_corrected_results.csv", row.names = FALSE)

##multimorbidity
merge4 <- merge3
# 定义所有疾病名称
diseases <- c("hyp","pain","cancer","asthma", "dyspepsia", "CHD", "thy", "diabetes", 
              "depression", "PE", "prostate","RA", "stroke", "osteoporosis", "COPD", 
              "migraine","IBS",  "glaucoma", "DDI", "anxiety", "AF","IBD",  "epilepsy","CS","end",
              "PA", "MD", "bronch", "CFS", "PVD", "sch","PD", "CKD", "MS", "viral", 
              "CLD", "HF", "AP", "TC", "PO", "AB", "opsm")

# 遍历每个疾病
for (disease in diseases) {
  disease_date <- paste0(disease, "_date")  # 获取对应的日期列名
  
  # 创建新变量：若 _date 在 AN_date 之前，设置为 1，否则为 0
  merge4[, paste0(disease, "_new_var") := ifelse(as.Date(get(disease_date)) < as.Date(merge4$AN_date), 1, 0)]
}

# 创建新变量 'multimorbidity'
merge4$new_var <- merge4$hyp+merge4$cancer+merge4$asthma+merge4$dyspepsia+merge4$CHD+merge4$thy+
  merge4$RA+merge4$stroke+merge4$osteoporosis+merge4$COPD+merge4$migraine+merge4$IBS+
  merge4$DDI+merge4$AF+merge4$bronch+merge4$CFS+merge4$PVD+merge4$CKD+merge4$CLD+merge4$HF+
  merge4$AP+merge4$TC
merge4$multimorbidity <- ifelse(merge4$new_var > 6, 6,
                                ifelse(merge4$new_var < 1, 0, merge4$new_var))
TOTAL <- dplyr::select(merge4,eid,age_base,sex,centre,race,edu,smoke,BMI,drink,income,AN_ctime,AN,MET,multimorbidity)
Total <- na.omit(TOTAL)
Total$sex <- as.factor(Total$sex)
Total$centre <- as.factor(Total$centre)
Total$race <- as.factor(Total$race)
Total$grp_met[Total$MET>=3000] <- "3"
Total$grp_met[Total$MET<3000&Total$MET>=600] <- "2"
Total$grp_met[Total$MET<600] <- "1"
Total$grp_met <- as.numeric(Total$grp_met)
Total$grp_met <- as.factor(Total$grp_met)
Total$AN <- as.numeric(Total$AN)
Total$grp_met <- as.factor(Total$grp_met)
total <- filter(Total,sex==1)
Total$multimorbidity <- as.factor(Total$multimorbidity)
f1 <- coxph(Surv(AN_ctime, AN)~multimorbidity*sex+BMI+drink  +  age_base  + centre + race + edu + smoke +  income + grp_met, data =  Total)
summary(f1)
median(merge2_1$AN_ctime)

##TableOne
crp','wbc','pla','lym','mon','neu','eos','bas','lym_p','mon_p','neu_p','eos_p','bas_p','ratio
library(tableone)
Total$AN <- as.factor(Total$AN)
merge2_1$sex <- as.factor(merge2_1$sex)
vars <- c('AN_ctime')
tableOne <- CreateTableOne(vars = vars,strata=c('AN'),data=merge2_1 )
table1 <- print(tableOne,nonnormal = c(''),catDigits = 2,contDigits = 2,pDigits = 4, 
                showAllLevels=TRUE, 
                quote = FALSE, 
                noSpaces = TRUE,
                printToggle = TRUE)
write.csv(table1,file="C:/Users/余00/Desktop/table1.csv")

##senlin
data1<-read.csv('C:/Users/余00/Desktop/Multimorbidity/图/Aortic_0410.csv')
data1$`HR (95% CI)`<-data1$OR
data1$` `<-paste(rep(" ",42),collapse = " ")
names(data1)
tm <- forest_theme(
  base_size = 10,
  ci_pch = 15,
  ci_col = "black",
  ci_fill = 'black',
  ci_alpha = 1,
  ci_lty = 1,
  ci_lwd =1,
  ci_Theight = 0.1,
  refline_lwd = 1,
  refline_lty = "dashed",
  refline_col = "grey20"
)
forest(data1[,c(1,7,5,8)],         #选择要在森林图中显示的数据列，包括变量名称，样本数，绘图的空白列，HR（95%ci），p值
       est = data1$HR,
       lower = data1$lower,
       upper = data1$upper,
       sizes = 0.5,
       ci_column = 4,
       ref_line = 1,
       arrow_lab = c("Low risk","High risk"),
       xlim = c(0.3,4),
       ticks_at = c(0.3,1,2,3,4),theme=tm)

###8*25

# 加载必要的包
library(ggplot2)
# 创建数据
data <- data.frame(
  Categories = c("0-1", "2", "3", "4", "5", ">6"),
  HR = c(1, 3.5622, 5.8863, 8.6520, 11.6106,18.2703),
  Lower_CI = c(1,3.1268, 5.1863, 7.6145, 10.1679,16.2186),
  Upper_CI = c(1,4.0583, 6.6807, 9.8309, 13.2580, 20.5816)
)

data$Categories<-factor(data$Categories,levels = c('0-1','2','3','4','5','>6'))
# 绘制棒状图
ggplot(data, aes(x = Categories, y = HR)) +
  geom_point(size = 3, shape=15,fill = "#008080") +  # 绘制点
  geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.15, color = "black") + # 添加误差线
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray") + # 添加参考线
  labs(
    x = "Multimorbidities, No.",
    y = "HR (95% CI)",
    title = ""
  ) +
  theme_classic() + # 使用简洁主题
  theme(
    plot.title = element_text(hjust = 0.5, color = "black"),
    axis.text = element_text(size = 12, color = "black"),
    axis.title = element_text(size = 14, color = "black")
  )

##survival
# 加载必要的包
library(ggplot2)
library(survival)
library(survminer)
library(survMisc)
total <- filter(Total,sex==1)
# 模拟数据
set.seed(123)
total$AN <- as.numeric(total$AN)
# 创建生存对象
surv_obj <- Surv(time = total$AN_ctime, event = total$AN)
fit <- survfit(Surv(AN_ctime, AN) ~ multimorbidity, data = total)
# 手动简化生存曲线：保留部分数据点
reduce_fit <- function(fit, keep = 0.1) {
  fit_df <- data.frame(time = fit$time/52, surv = fit$surv, strata = rep(names(fit$strata), fit$strata))
  # 按比例抽样时间点
  reduced_df <- fit_df[seq(1, nrow(fit_df), by = 1 / keep), ]
  return(reduced_df)
}

# 生成简化数据
fit_reduced <- reduce_fit(fit, keep = 0.1) # 保留10%的数据点
ggsurvplot(fit_reduced,
           fun = "event", 
           size = 0.5, 
           conf.int = TRUE, # 可信区间
           palette = "Dark2", # 支持ggsci配色，自定义颜色，brewer palettes中的配色，等npg
           ggtheme = theme_bw() # 支持ggplot2及其扩展包的主题
)+
  labs(x = "Follow-up Time (years)", y = "Cumulative Incidence")
##6*5

##PAF
install.packages(c("survival","dplyr","AF","rlang"))

  # 过滤出该疾病为1的样本
  merge3_3 <- filter(merge3, hyp == 1)
  
  # 计算时间差，单位为周
  merge3_3$cctime <- difftime(merge3_3$AN_date, merge3_3$hyp_date, units = "weeks")
  
  # 筛选cctime小于0的样本
  merge3_4 <- filter(merge3_3, cctime < 0)
  
  # 从原数据中删除cctime小于0的样本
  merge4 <- filter(merge3, !eid %in% merge3_4$eid)
  
  # 选择所需的变量
  TOTAL <- select(merge4, eid, age_base, sex, centre, race, edu, smoke, BMI, drink, income, AN_ctime, AN, MET, hyp)
  
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
  Total$AN <- as.numeric(Total$AN)
  
  f1 <- coxph(
    Surv(AN_ctime, AN) ~ hyp + sex + age_base + centre + race + edu +
      smoke + BMI + drink + income + grp_met,
    data = Total,
    ties = "breslow"          # ★ 关键修改
  )
  
  Total_df <- as.data.frame(Total)          # 去掉 data.table 特性
  
  af_obj <- AF::AFcoxph(
    object   = f1,
    data     = Total_df,           # ← 用普通 data.frame
    exposure = "hyp",
    times    = max(Total_df$AN_ctime)
  )
  summary(af_obj)
  
 ##PAF的循环 
  library(survival)
  library(dplyr)
  library(AF)
  library(rlang)   # 用 sym()/!!
  
  ## 42 种慢性病 ---------------------------
  diseases <- c("hyp","pain","cancer","asthma", "dyspepsia", "CHD", "thy", "diabetes", 
                "depression", "PE", "prostate","RA", "stroke", "osteoporosis", "COPD", 
                "migraine","IBS",  "glaucoma", "DDI", "anxiety", "AF","IBD",  "epilepsy","CS","end",
                "PA", "MD", "bronch", "CFS", "PVD", "sch","PD", "CKD", "MS", "viral", 
                "CLD", "HF", "AP", "TC", "PO", "AB", "opsm")
  
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
             " +sex + age_base + centre + race + edu + smoke + BMI + ",
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
  write.csv(PAR_table,file="C:/Users/余00/Desktop/Aortic_disease.csv", row.names = FALSE)
  
  