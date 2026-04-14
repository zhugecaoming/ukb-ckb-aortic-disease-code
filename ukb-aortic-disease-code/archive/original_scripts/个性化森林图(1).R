library(ggplot2)


data<-read.xlsx('F:/桌面/data1.xlsx')
data$x <- factor(data$x, levels = rev(unique(data$x)))

data$group_col<-c(rep("#e7a40e",6),rep("#78bee5",3),rep("#1c6891",5),rep("#a59d70",2),rep("#4f4a30",6))
data$p_col[data$p%in%c('*',"**","***")&data$med>1]<-"Postive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med >1]<- "Postive effect(P>=0.05)"
data$p_col[data$p%in%c('*',"**","***")& data$med<=1]<-"Negtive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med<=1]<- "Negtive effect(P>=0.05)"

###作图
ggplot(data)+
geom_hline(yintercept=0.8,linewidth=0.3)+
geom_linerange(aes(x,ymin =min,ymax= max,color = p_col), show.legend = F)+
geom_point(aes(x,med,color=p_col))+
geom_text(aes(x=x,y=max+0.17,label=p,color = p_col), show.legend = F)+
scale_color_manual(name ="",values =c("Postive effect(P<0.05)"="#d55e00",
"Postive effect(P>=0.05)"="#ffbd88",
"Negtive effect(P<0.05)"="#0072b2",
"Negtive effect(P>=0.05)"="#7acfff"))+
annotate("rect",
         xmin = c(0.5, 6.5, 8.5, 13.5, 16.5),
         xmax = c(6.5, 8.5, 13.5, 16.5, 22.5),
           ymin =0.8,ymax=4,alpha=0.2,fill=rev(unique(data$group_col)))+
scale_y_continuous(expand=c(0,0))+
xlab("")+
ylab("Regression Coefficient (95% CI)")+
theme_bw()+
theme(axis.text.y=element_text(color =rev(data$group_col)))+
coord_flip()


######5*6
data<-read.xlsx('F:/桌面/data2.xlsx')
data$x <- factor(data$x, levels = rev(unique(data$x)))

data$group_col<-c(rep("#e7a40e",6),rep("#78bee5",3),rep("#1c6891",5),rep("#a59d70",2),rep("#4f4a30",6))
data$p_col[data$p%in%c('*',"**","***")&data$med>1]<-"Postive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med >1]<- "Postive effect(P>=0.05)"
data$p_col[data$p%in%c('*',"**","***")& data$med<=1]<-"Negtive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med<=1]<- "Negtive effect(P>=0.05)"

###作图
ggplot(data)+
  geom_hline(yintercept=0.8,linewidth=0.3)+
  geom_linerange(aes(x,ymin =min,ymax= max,color = p_col), show.legend = F)+
  geom_point(aes(x,med,color=p_col))+
  geom_text(aes(x=x,y=max+0.4,label=p,color = p_col), show.legend = F)+
  scale_color_manual(name ="",values =c("Postive effect(P<0.05)"="#d55e00",
                                        "Postive effect(P>=0.05)"="#ffbd88",
                                        "Negtive effect(P<0.05)"="#0072b2",
                                        "Negtive effect(P>=0.05)"="#7acfff"))+
  annotate("rect",
           xmin = c(0.5, 6.5, 8.5, 13.5, 16.5),
           xmax = c(6.5, 8.5, 13.5, 16.5, 22.5),
           ymin =0.8,ymax=10,alpha=0.2,fill=rev(unique(data$group_col)))+
  scale_y_continuous(expand=c(0,0))+
  xlab("")+
  ylab("Regression Coefficient (95% CI)")+
  theme_bw()+
  theme(axis.text.y=element_text(color =rev(data$group_col)))+
  coord_flip()






######5*6
data<-read.xlsx('F:/桌面/data3.xlsx')
data$x <- factor(data$x, levels = rev(unique(data$x)))

data$group_col<-c(rep("#e7a40e",6),rep("#78bee5",3),rep("#1c6891",5),rep("#a59d70",2),rep("#4f4a30",6))
data$p_col[data$p%in%c('*',"**","***")&data$med>1]<-"Postive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med >1]<- "Postive effect(P>=0.05)"
data$p_col[data$p%in%c('*',"**","***")& data$med<=1]<-"Negtive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med<=1]<- "Negtive effect(P>=0.05)"

###作图
ggplot(data)+
  geom_hline(yintercept=1,linewidth=0.3)+
  geom_linerange(aes(x,ymin =min,ymax= max,color = p_col), show.legend = F)+
  geom_point(aes(x,med,color=p_col))+
  geom_text(aes(x=x,y=max+0.3,label=p,color = p_col), show.legend = F)+
  scale_color_manual(name ="",values =c("Postive effect(P<0.05)"="#d55e00",
                                        "Postive effect(P>=0.05)"="#ffbd88",
                                        "Negtive effect(P<0.05)"="#0072b2",
                                        "Negtive effect(P>=0.05)"="#7acfff"))+
  annotate("rect",
           xmin = c(0.5, 6.5, 8.5, 13.5, 16.5),
           xmax = c(6.5, 8.5, 13.5, 16.5, 22.5),
           ymin =0,ymax=6,alpha=0.2,fill=rev(unique(data$group_col)))+
  scale_y_continuous(expand=c(0,0))+
  xlab("")+
  ylab("Regression Coefficient (95% CI)")+
  theme_bw()+
  theme(axis.text.y=element_text(color =rev(data$group_col)))+
  coord_flip()



######5*6
data<-read.xlsx('F:/桌面/data4.xlsx')
data$x <- factor(data$x, levels = rev(unique(data$x)))

data$group_col<-c(rep("#e7a40e",6),rep("#78bee5",3),rep("#1c6891",5),rep("#a59d70",2),rep("#4f4a30",6))
data$p_col[data$p%in%c('*',"**","***")&data$med>1]<-"Postive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med >1]<- "Postive effect(P>=0.05)"
data$p_col[data$p%in%c('*',"**","***")& data$med<=1]<-"Negtive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med<=1]<- "Negtive effect(P>=0.05)"

###作图
ggplot(data)+
  geom_hline(yintercept=1,linewidth=0.3)+
  geom_linerange(aes(x,ymin =min,ymax= max,color = p_col), show.legend = F)+
  geom_point(aes(x,med,color=p_col))+
  geom_text(aes(x=x,y=max+0.4,label=p,color = p_col), show.legend = F)+
  scale_color_manual(name ="",values =c("Postive effect(P<0.05)"="#d55e00",
                                        "Postive effect(P>=0.05)"="#ffbd88",
                                        "Negtive effect(P<0.05)"="#0072b2",
                                        "Negtive effect(P>=0.05)"="#7acfff"))+
  annotate("rect",
           xmin = c(0.5, 6.5, 8.5, 13.5, 16.5),
           xmax = c(6.5, 8.5, 13.5, 16.5, 22.5),
           ymin =0,ymax=9,alpha=0.2,fill=rev(unique(data$group_col)))+
  scale_y_continuous(expand=c(0,0))+
  xlab("")+
  ylab("Regression Coefficient (95% CI)")+
  theme_bw()+
  theme(axis.text.y=element_text(color =rev(data$group_col)))+
  coord_flip()





######
data<-read.xlsx('F:/桌面/data5.xlsx')
data$x <- factor(data$x, levels = rev(unique(data$x)))

data$group_col<-c(rep("#e7a40e",6),rep("#78bee5",3),rep("#1c6891",5),rep("#a59d70",2),rep("#4f4a30",6))
data$p_col[data$p%in%c('*',"**","***")&data$med>1]<-"Postive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med >1]<- "Postive effect(P>=0.05)"
data$p_col[data$p%in%c('*',"**","***")& data$med<=1]<-"Negtive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med<=1]<- "Negtive effect(P>=0.05)"

###作图5*6
ggplot(data)+
  geom_hline(yintercept=1,linewidth=0.3)+
  geom_linerange(aes(x,ymin =min,ymax= max,color = p_col), show.legend = F)+
  geom_point(aes(x,med,color=p_col))+
  geom_text(aes(x=x,y=max+0.2,label=p,color = p_col), show.legend = F)+
  scale_color_manual(name ="",values =c("Postive effect(P<0.05)"="#d55e00",
                                        "Postive effect(P>=0.05)"="#ffbd88",
                                        "Negtive effect(P<0.05)"="#0072b2",
                                        "Negtive effect(P>=0.05)"="#7acfff"))+
  annotate("rect",
           xmin = c(0.5, 6.5, 8.5, 13.5, 16.5),
           xmax = c(6.5, 8.5, 13.5, 16.5, 22.5),
           ymin =0,ymax=4,alpha=0.2,fill=rev(unique(data$group_col)))+
  scale_y_continuous(expand=c(0,0))+
  xlab("")+
  ylab("Regression Coefficient (95% CI)")+
  theme_bw()+
  theme(axis.text.y=element_text(color =rev(data$group_col)))+
  coord_flip()


####### 5*6
data<-read.xlsx('F:/桌面/data6.xlsx')
data$x <- factor(data$x, levels = rev(unique(data$x)))

data$group_col<-c(rep("#e7a40e",6),rep("#78bee5",3),rep("#1c6891",5),rep("#a59d70",2),rep("#4f4a30",6))
data$p_col[data$p%in%c('*',"**","***")&data$med>1]<-"Postive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med >1]<- "Postive effect(P>=0.05)"
data$p_col[data$p%in%c('*',"**","***")& data$med<=1]<-"Negtive effect(P<0.05)"
data$p_col[is.na(data$p)& data$med<=1]<- "Negtive effect(P>=0.05)"

###作图
ggplot(data)+
  geom_hline(yintercept=1,linewidth=0.3)+
  geom_linerange(aes(x,ymin =min,ymax= max,color = p_col), show.legend = F)+
  geom_point(aes(x,med,color=p_col))+
  geom_text(aes(x=x,y=max+0.25,label=p,color = p_col), show.legend = F)+
  scale_color_manual(name ="",values =c("Postive effect(P<0.05)"="#d55e00",
                                        "Postive effect(P>=0.05)"="#ffbd88",
                                        "Negtive effect(P<0.05)"="#0072b2",
                                        "Negtive effect(P>=0.05)"="#7acfff"))+
  annotate("rect",
           xmin = c(0.5, 6.5, 8.5, 13.5, 16.5),
           xmax = c(6.5, 8.5, 13.5, 16.5, 22.5),
           ymin =0.5,ymax=5.5,alpha=0.2,fill=rev(unique(data$group_col)))+
  scale_y_continuous(expand=c(0,0))+
  xlab("")+
  ylab("Regression Coefficient (95% CI)")+
  theme_bw()+
  theme(axis.text.y = element_text(color = rev(data$group_col)))+
  coord_flip()
