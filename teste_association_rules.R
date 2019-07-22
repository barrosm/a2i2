# program to obtain association rules
# Monica Barros
#
# Date: 22/04/2016
#
# Changing directory to where the PROGRAM is
# 
# Em Windows usar estas "//". As vezes "/" funciona. Em Unix usar "\", eu acho.
#
#
# setwd('C://Users//Monica//Dropbox//a2i2_mb//PROGRAMAS')
setwd('C://Users//barro/Dropbox///a2i2_mb//PROGRAMAS')

# ==================================================================================
# Function Instala_Pacote
# It works silently, echoing nothing if package "pacote" is already installed 
# and installing it otherwise. 
# Don't forget to write the name of the package between quotes!

instala_pacote <- function(pacote) {
  if (!pacote %in% installed.packages()) install.packages(pacote)
}

# ==================================================================================

instala_pacote("arules")
instala_pacote("arulesViz")
instala_pacote("readr")  # Faster file reading
instala_pacote("xlsx")

library("arules")
library("arulesViz")
library("readr")
# Note - to avoid error in the installation of xlsx
# make sure Java and R are both 32 or 64 bits
# 
# To check the current Java version, write at the Windows command prompt:
# java -d64 -version
#
# If necessary, go to Java.com and manually install the 64 bit version 
# (provided you´re using R 64 bits)
library("xlsx")  


#nome_arq = 'C://Users//barro//Dropbox//a2i2_mb//Scripts//tbl_peixoto_produtos_20160422.csv'
#nome_arq = 'C://Users//barro//Dropbox//a2i2_mb//Scripts//tbl_pereira_produtos_desde_20150101_v2.csv'
# nome_arq = 'C://Users//barro//Dropbox//a2i2_mb//Scripts//tbl_pereira_produtos_desde_20140101_20160502.csv'
nome_arq = 'C://Users//barro//Dropbox//a2i2_mb//Scripts//tbl_pereira_produtos_desde_20120101_20160502.csv'

# Read data into dataframe 
# df = read.csv2(nome_arq, header = TRUE, sep = ";",dec = ",")
# Change to read_csv2 which is part of "readr" package
df = read_csv2(nome_arq, col_names = TRUE, locale = default_locale(), progress = interactive())


# Read data from csv file into transaction matrix
#trans = read.transactions(nome_arq, format = "single", sep = ";", cols = c("idNotaVenda","codBarra"), rm.duplicates = TRUE, encoding = "UTF-8")
trans = read.transactions(nome_arq, format = "single", sep = ";", cols = c("idNotaVenda","nome"), rm.duplicates = TRUE, encoding = "UTF-8")

# Descriptive stats of transactions
# ================================================================
summary(trans)
dim(trans)
size_transactions=size(trans)
quantile(size_transactions, probs=seq(0,1,0.1))

# Check which are the very large transactions (more than 25items)
transactionInfo(trans[size(trans) > 25])


# Calculate item frequencies
# Note that the numbers are VERY SMALL!!!
item_frequency = itemFrequency(trans)
max(item_frequency)
summary(item_frequency)

item_count = (item_frequency/sum(item_frequency))*sum(size_transactions)

# Summary statistics - item counts - all transactions
# ===================================================
summary(item_count)
quantile(item_count, probs=seq(0,1,0.1))
# Now the upper quantiles
quantile(item_count, probs=seq(0.8,1,0.05))

# Most common items - all transactions
# =====================================
ordered_item=sort(item_count, decreasing = T)
# Top 10  items
ordered_item[1:10]

# Save ordered items to file
# ==========================================
# Uses write.xlsx (requires xlsx package)
tt=as.data.frame(ordered_item)
# some data manipulation to export the temporary dataframe in a nice format
tt$produto = rownames(tt)
row.names(tt)=NULL
write.xlsx(tt, "C://Users//barro//Dropbox//a2i2_mb//Scripts//ordered_items.xlsx")
# remove unnecessary file
rm(tt)

# ========================================================================
# Most common items (top 30) - all transactions
# ========================================================================
# The default plot is vertical, changed to horizontal
# itemFrequencyPlot(trans,support = 0.7/100, cex.names = 0.8, horiz=TRUE)
itemFrequencyPlot(trans,topN=30, cex.names = 0.8, horiz=TRUE, main="top 30 products", col="red")


# ========================================================================
# Create matrix where transactions involve more than one item
# ========================================================================
more_one = trans[size(trans) > 1]

summary(more_one)
dim(more_one)

# take a look at the first few transactions
inspect(head(more_one))

# Create matrix where transactions involve more than TEN items
more_ten = trans[size(trans) > 10]

# take a look at the first few transactions that include more than 10 items
summary(more_ten)
dim(more_ten)

# check which are the most frequent items in the transaction set that 
# contains more than one product
# The default plot is vertical, changed to horizontal
itemFrequencyPlot(more_one,topN=40, cex.names = 0.8, horiz=TRUE, main="top 40 products - baskets with 2 or more items", col=69)

# =========================================================================
# Item frequencies and item counts in transaction matrix that includes ONLY
# transactions with more than 1 item
# =========================================================================
size_transactions_more_one = size(more_one)
item_frequency_more_one = itemFrequency(more_one)
item_count_more_one = (item_frequency_more_one/sum(item_frequency_more_one))*sum(size_transactions_more_one)
# =======================================================================
# Summary statistics - item counts - only baskets with more than one item
# =======================================================================
summary(item_count_more_one)
quantile(item_count_more_one, probs=seq(0,1,0.1))
# Now the upper quantiles
quantile(item_count_more_one, probs=seq(0.8,1,0.05))

# ===================================================
# Most common items - baskets with more than one item
# ===================================================
ordered_item_more_one=sort(item_count_more_one, decreasing = T)
# Top 10  items
ordered_item_more_one[1:10]


# =========================================================================
# A priori rules
# =========================================================================
rules = apriori(more_one, parameter = list(support = 0.1/1000, confidence = 0.50))
summary(rules)

# if you have just a few rules you can execute this command, otherwise subset
inspect(rules)

rules@info

rules@lhs
nrow(rules@lhs@itemInfo)

# place labels in a character vector
labels_rules=labels(rules)

plot(rules, method = NULL, measure = "support", shading = "lift",interactive = FALSE)#, data = NULL, control = NULL, ...)

# =========================================================================
# Using two measures in the matrix plots
# Create graph with ALL RULES that where created from sets with > 1 product
# ============================================================================
plot(rules, method="matrix", measure=c("lift", "confidence"), control = list(main = "All Rules - Consequent vs Antecedent", cex = 0.6))
plot(rules, method="matrix", measure=c("support", "confidence"), control = list(main = "All Rules - Consequent vs Antecedent", cex = 0.5))


# Build subset of rules according to different criteria
# =========================================================================
# top 50 rules by confidence with support above a certain level
subrules_conf = subset(rules, support > 0.02/1000)
subrules_conf = head(sort(subrules_conf, by="confidence"), 50) 
inspect(subrules_conf)
# place labels in a character vector
labels_subrules_conf=labels(subrules_conf)

# ============================================================================
# Create graph with top 50 rules that where created from sets with > 1 product
# ============================================================================
plot(subrules_conf, method="graph", control=list(main = "Top 50 rules by Confidence based on sets with + 1 product", cex = 0.5))

plot(subrules_conf, method="matrix", measure="confidence", control=list(reorder=TRUE))

plot(subrules_conf, method="graph", control=list(type="itemsets", cex = 0.6, main = "Top 50 rules by Confidence"))







# =========================================================================
# USING THE ENTIRE DATASET
# THE RESULTS SEEM WORSE THAN WHEN CONSIDERING THE DATASET WITH 
# TRANSACTIONS THAT INCLUDE MORE THAN ONE ITEM
# A priori rules
# =========================================================================
rules_all = apriori(trans, parameter = list(support = 0.1/1000, confidence = 0.5))
summary(rules_all)
inspect(rules_all)

plot(rules_all, method = NULL, measure = "support", shading = "lift",interactive = FALSE)#, data = NULL, control = NULL, ...)

plot(rules_all, measure=c("support", "lift"), shading="confidence")

# order = number of els in rule
plot(rules_all, shading="order", control=list(main = "Two-key plot"))
plot(rules_all, shading="order", control=list(main = "Lift vs Confidence arranged by order"), measure=c("confidence", "lift"))
plot(rules_all, shading="order", control=list(main = "Lift vs Support arranged by order"), measure=c("support", "lift"))

plot(rules_all, shading="order", control=list(main = "Lift vs Support arranged by order"), measure=c("support", "lift"), interactive = TRUE)

# Build subset of rules according to different criteria
subrules_conf_all = subset(rules_all, support > 0.02/1000)
subrules_conf_all = head(sort(subrules_conf_all, by="confidence"), 30)
inspect(subrules_conf_all)
labels(subrules_conf_all)

# =========================================================================
# Create graph with top 30 rules
# =========================================================================
plot(subrules_conf_all, method="graph", main = "Top 30 rules by Confidence")

plot(subrules_conf_all, method="matrix", measure="confidence", control=list(reorder=TRUE))

plot(subrules_conf_all, method="graph", control=list(type="itemsets", cex = 0.6, main = "Top 30 rules by Confidence"))

# =========================================================================
# Using two measures in the matrix plots
# Now we use the ENTIRE SET OF RULES
# =========================================================================
plot(rules_all, method="matrix", measure=c("lift", "confidence"), control = list(main = "All Rules - Consequent vs Antecedent", cex = 0.6))
plot(rules_all, method="matrix", measure=c("support", "confidence"), control = list(main = "All Rules - Consequent vs Antecedent", cex = 0.5))


