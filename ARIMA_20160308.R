# Read data - use read.csv or mamp.mapInput depending on 
# whether running in RStudio or Azure ML

# df <- maml.mapInputPort(1) 
# df = read.csv('Historico_Categorias_e_lojas_desde_20120101.csv', sep = ",", header = TRUE)

instala_pacote <- function(pacote) {
  if (!pacote %in% installed.packages()) install.packages(pacote)
}
# ==================================================================================

instala_pacote("forecast")
instala_pacote("ggplot2")


library(forecast)
library(ggplot2)

# file_name=file.path(("C:/Users/barro/Dropbox/a2i2_flashfarma/Estudos"), "Historico_Categorias_e_lojas_desde_20120101.csv") 

# File starts at date when store # 3 begins operations
file_name=file.path(("C:/Users/barro/Dropbox/a2i2_flashfarma/Estudos"), "Historico_Categorias_e_lojas_desde_entrada_operacao_loja_03.csv") 

# creates dataframe to hold data
df = read.csv(file=file_name,header = TRUE, sep = ",", dec = ".")

#====================================================
# preprocessing
#====================================================
# frequency = 365 if nonseasonal daily data
frequency = 7 # weekly seasonal
horizon = 7*4

dates  = as.Date(df$dataVenda, format = '%d-%m-%y') # verify if date format needs changing
values <- as.numeric(df$Faturamento_total)

n = length(dates)

# time stamp for beginning of series
start_date = as.Date(dates[1], format = "%d-%m-%y")  # verify if date format needs changing
weekdays(start_date)  # if Thrusday ok for 28-06-2012

end = as.Date(dates[n], "%d-%m-%y") # time stamp for end of series
start_forecast = as.Date(end)+ 1 # time stamp for 1st forecast

# Plot AcF and PACF
# ==================
tsdisplay(df$Faturamento_total, lag.max = 78, main = "Faturamento Total")

# creates a time series for "training" (i.e., model fitting)
#==============================================================
# explicitly wrote starting period - originally was 01/01/2012
train_ts = ts(values, frequency=frequency, start = start_date)  
train_ts = as.ts(train_ts)  # Apparently forcing this is necessary to avoid errors in the estimation

# fit a time-series model using AUTO.ARIMA
#==============================================================
fit1 <- auto.arima(train_ts, max.p = 14, max.q = 7, max.P = 2, max.Q = 2, max.d =2, max.D = 2, ic = c("bic"))
train_model <- forecast(fit1, h = horizon)

# Produce model summary
#========================
sumary(train_model)

# plots fitted values and forecasts
plot(train_model)


# plots fitted values in last year
plot(train_model$fitted[(n-364):n], type = "l", col = "navy", ylab = "Fitted Values", 
     main = "Fitted Values in Last 365 days")


# plots residuals in last year
plot(train_model$residuals[(n-364):n], type = "l", col = "red", ylab = " ", 
     main = "Residuals in Last 365 days")


# produce forecasts and 95% CI (rounded to 2 decimal places)
# ==============================================================
lower95 = round(train_model$lower[,2],2)
train_pred = round(train_model$mean,2)
upper95 = round(train_model$upper[,2],2)

# Creates data frame with forecasts and 95% Confidence Interval
# ==============================================================
data.forecast = as.data.frame(cbind(c(1:horizon),train_pred,lower95,upper95))
colnames(data.forecast) =  c("Horizon", "Forecast", "Lower_CI_95%", "Upper_CI_95%")


# Point Forecasts plot using ggplot
# ================================================
# plot(data.forecast$Forecast, type = "l", col = "steelblue", ylab = " ", main = "Forecasts")
ggplot(data.forecast, aes(Horizon,Forecast)) + geom_line(color='#000033') + ggtitle("Point Forecasts")



# Creating a Forecast and 95% CI plot using ggplot
# ================================================
library(reshape2)
new_data.forecast<-melt(data.forecast,"Horizon")
ggplot(new_data.forecast,aes(x=Horizon,y=value,group=variable,color=variable) ) + geom_line() + ggtitle("Forecasts and 95% CI")



# Time Series Linear Model Forecast
# ============================================================
# This script fits a linear model to a time series including 
# trend and seasonality components
# We use tslm() and forecast() in the "forecast" R package 


# tslm function - time series wrapper (analogous to lm)
# USAGE: tslm(formula, data, lambda=NULL, ...)
#
# For example:

Carnaval = as.ts(df$Carnaval)
Pascoa = as.ts(df$Pascoa)
Tiradentes = as.ts(df$Tiradentes)
Dia_Trabalho = as.ts(df$Dia_Trabalho) 
Natal = as.ts(df$Natal)
Corpus_Christi=as.ts(df$Corpus_Christi)
Independencia = as.ts(df$Independencia)
NSAparecida = as.ts(df$NSAparecida)
Finados = as.ts(df$Finados)
Republica= as.ts(df$Republica)
Reveillon=as.ts(df$Reveillon)

fit2 <- tslm(train_ts ~ season  + Carnaval + Pascoa + Tiradentes + Dia_Trabalho + Natal + Corpus_Christi+Independencia + NSAparecida + Finados + Republica + Reveillon+ lag(train_ts,-1) + lag(train_ts,-2)+lag(train_ts,-7))


train_model2 <- forecast(fit2, h = horizon)


# Produce model summary
#========================
sumary(train_model2)

# plots fitted values and forecasts
plot(train_model2)

# data output
#maml.mapOutputPort("data.forecast");