library(ggplot2)
library(dplyr)
library(gridExtra)

# 疾病顺序
new_order <- c("hypertension", "coronary heart disease", 
               "peripheral vascular disease", "atrial fibrillation", 
               "heart failure", "stroke and TIA", 
               "COPD", "osteoporosis")

# 构造数据
data <- data.frame(
  Condition = rep(c("hypertension", "coronary heart disease", "stroke and TIA", 
                    "osteoporosis", "COPD", "atrial fibrillation", 
                    "peripheral vascular disease", "heart failure"), each = 2),
  Gender = rep(c("Female", "Male"), times = 8),
  HR = c(4.45, 2.95, 4.07, 3.17, 2.14, 1.39, 1.42, 0.95,
         2.14, 1.67, 3.75, 2.31, 4.17, 2.09, 3.45, 2.18),
  Lower = c(3.80, 2.71, 3.51, 2.94, 1.76, 1.25, 1.16, 0.73,
            1.75, 1.50, 3.18, 2.13, 3.33, 1.82, 2.79, 1.97),
  Upper = c(5.21, 3.22, 4.72, 3.41, 2.61, 1.54, 1.74, 1.22,
            2.62, 1.86, 4.42, 2.51, 5.23, 2.41, 4.26, 2.42),
  p_val = rep(c("<0.01", "0.03", "<0.01", "0.04", "0.03", "<0.01", "<0.01", "<0.01"), each = 2)
)

# 设置因子顺序
data$Condition <- factor(data$Condition, levels = rev(new_order))

# 提取 Female 行以生成 P 值标签
p_labels <- data %>%
  filter(Gender == "Female") %>%
  mutate(y_pos = as.numeric(Condition))

# 绘图
ggplot(data, aes(x = HR, y = Condition, color = Gender)) +
  geom_point(position = position_dodge(width = 0.7), size = 4) +
  geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.3,
                 position = position_dodge(width = 0.7), linewidth = 1.1) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "black") +
  geom_hline(yintercept = 1:(length(new_order) - 1) + 0.5, 
             linetype = "dashed", color = "grey80") +
  geom_text(data = p_labels, aes(x = 6, y = Condition, label = paste0( p_val)),
            inherit.aes = FALSE, size = 4.5, hjust = 0, color = "black") +
  annotate("text", x = 6.2, y = 8.5, label = "P for interaction", size = 4, fontface = "bold") +
  scale_color_manual(values = c("Female" = "red", "Male" = "blue")) +
  labs(x = "Hazard Ratio", y = NULL, color = "Gender") +
  scale_x_continuous(breaks = 1:6, limits = c(0.6, 6.5)) +  # 设置底部刻度
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "top",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.line.x = element_line(color = "black", linewidth = 0.6),  # 实线X轴
    axis.ticks.x = element_line(color = "black"),
    axis.text.x = element_text(color = "black", size = 13),
    axis.text.y = element_text(color = "black", size = 13),
    axis.title.x = element_text(size = 14),
    legend.text = element_text(size = 13),
    legend.title = element_text(size = 13),
    plot.margin = unit(c(1, 5, 1.5, 2), "lines")  # 上右下左
  )
##land 10 and 6

library(ggplot2)
library(dplyr)

# 疾病顺序
new_order <- c("hypertension", "coronary heart disease", 
               "peripheral vascular disease", "atrial fibrillation", 
               "heart failure", "stroke and TIA", 
               "COPD", "osteoporosis")

# 构造数据
data <- data.frame(
  Condition = rep(c("hypertension", "coronary heart disease", "stroke and TIA", 
                    "osteoporosis", "COPD", "atrial fibrillation", 
                    "peripheral vascular disease", "heart failure"), each = 2),
  Gender = rep(c("Male", "Female"), times = 8),  # ✅ 男性在上，女性在下
  HR = c(2.95, 4.45, 3.17, 4.07, 1.39, 2.14, 0.95, 1.42,
         1.67, 2.14, 2.31, 3.75, 2.09, 4.17, 2.18, 3.45),
  Lower = c(2.71, 3.80, 2.94, 3.51, 1.25, 1.76, 0.73, 1.16,
            1.50, 1.75, 2.13, 3.18, 1.82, 3.33, 1.97, 2.79),
  Upper = c(3.22, 5.21, 3.41, 4.72, 1.54, 2.61, 1.22, 1.74,
            1.86, 2.62, 2.51, 4.42, 2.41, 5.23, 2.42, 4.26),
  p_val = rep(c("<0.01", "0.03", "<0.01", "<0.01", "<0.01", "<0.01", "0.03", "0.04"), each = 2)
)

data$Condition <- factor(data$Condition, levels = rev(new_order))

# 构建 HR 标签
hr_labels <- data %>%
  mutate(hr_label = paste0(round(HR, 2), " (", round(Lower, 2), ", ", round(Upper, 2), ")"))

# 提取 P 值（只取一次即可）
p_labels <- hr_labels %>%
  filter(Gender == "Male") %>%
  mutate(y_pos = as.numeric(Condition))

# 绘图
ggplot(data, aes(x = HR, y = Condition, color = Gender)) +
  # 主图点和误差线
  geom_point(position = position_dodge(width = 0.7), size = 5) +
  geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.3,
                 position = position_dodge(width = 0.7), linewidth = 1.2) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "black") +
  geom_hline(yintercept = 1:(length(new_order)-1) + 0.5, 
             linetype = "dashed", color = "grey80") +
  
  # ✅ HR 数值标签（纵向错开，男性在上，女性在下）
  geom_text(data = hr_labels %>% filter(Gender == "Male"),
            aes(x = 5.9, y = as.numeric(Condition) + 0.15, label = hr_label),
            inherit.aes = FALSE, size = 4.5, hjust = 0, color = "blue") +
  geom_text(data = hr_labels %>% filter(Gender == "Female"),
            aes(x = 5.9, y = as.numeric(Condition) - 0.15, label = hr_label),
            inherit.aes = FALSE, size = 4.5, hjust = 0, color = "red") +
  
  # ✅ P 值标签
  geom_text(data = p_labels, aes(x = 7.4, y = Condition, label = paste0("P = ", p_val)),
            inherit.aes = FALSE, size = 4.5, hjust = 0, color = "black") +
  
  # ✅ 添加列标题（适当右移）
  annotate("text", x = 6.3, y = 8.5, label = "HR (95% CI)", size = 4, fontface = "bold") +
  annotate("text", x = 7.8, y = 8.5, label = "P for interaction", size = 4, fontface = "bold") +
  
  # 设置颜色
  scale_color_manual(values = c("Female" = "red", "Male" = "blue")) +
  
  # 轴和标签
  labs(x = "Hazard Ratio", y = NULL, color = "Gender") +
  scale_x_continuous(breaks = 1:6, limits = c(0.6, 8.4)) +
  
  # 主题美化
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "top",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.line.x = element_line(color = "black", linewidth = 0.6),
    axis.ticks.x = element_line(color = "black"),
    axis.text.x = element_text(color = "black", size = 13),
    axis.text.y = element_text(color = "black", size = 13),
    axis.title.x = element_text(size = 14),
    legend.text = element_text(size = 13),
    legend.title = element_text(size = 13),
    plot.margin = unit(c(1.5, 10, 1.5, 2), "lines")  # ✅ 拉开右边空白，确保标题和文本完整
  )
