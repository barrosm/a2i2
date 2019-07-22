# Preparacao arquivos de transacoes
#
# 26/07/2016

# setwd('C://Users//Monica//Dropbox//a2i2_mb//PROGRAMAS')
setwd('C://Users//barro/Dropbox///a2i2_mb//scripts')

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

# LEITURA DOS DADOS USA PACOTE READR
# =====================================================
# Change to read_csv2 which is part of "readr" package

nome_arq = 'C://Users//barro//Dropbox//a2i2_mb//Scripts//tbl_pereira_produtos_desde_20120101_20160502.csv'
df = read_csv2(nome_arq, col_names = TRUE, locale = default_locale(), progress = interactive())
df = df[,-8]  # joga fora coluna idRede

nome_arq = 'C://Users//barro//Dropbox//a2i2_mb//Scripts//tbl_peixoto_produtos_20160422.csv'
df2= read_csv2(nome_arq, col_names = TRUE, locale = default_locale(), progress = interactive())
df2 = df2[,-8]  # joga fora coluna idRede

nome_arq = 'C://Users//barro//Dropbox//a2i2_mb//Scripts//tbl_pereira_produtos_desde_20160503_20160711.csv'
# LER COMO read_csv e NÃO COMO read_csv2 pois o separador é , e não ;
df3= read_csv(nome_arq, col_names = TRUE, locale = default_locale(), progress = interactive())


nome_arq = 'C://Users//barro//Dropbox//a2i2_mb//Scripts//tbl_pereira_produtos_desde_20160503_20160711.csv'
# LER COMO read_csv e NÃO COMO read_csv2 pois o separador é , e não ;
df3= read_csv(nome_arq, col_names = TRUE, locale = default_locale(), progress = interactive())


nome_arq = 'C://Users//barro//Dropbox//a2i2_mb//Scripts//tbl_pereira_produtos_desde_20160711.csv'
# LER COMO read_csv e NÃO COMO read_csv2 pois o separador é , e não ;
df4= read_csv(nome_arq, col_names = TRUE, locale = default_locale(), progress = interactive())

# Juntando as partes
df_tudo = merge(df,df2, all = TRUE)
df_tudo=merge(df_tudo,df3, all = TRUE)
df_tudo=merge(df_tudo,df4, all = TRUE)

# Escrevendo um csv (para ser lido por read.transactions)
# usa pacote readr
# append If FALSE, will overwrite existing file. If TRUE, will append to existing file. In
# both cases, if file does not exist a new file is created.
# col_names Write columns names at the top of the file ?

write_delim(df_tudo, 'transacoes.csv', delim = " ;", na = "NA", append = FALSE)

# Read data from csv file into transaction matrix
#trans = read.transactions(nome_arq, format = "single", sep = ";", cols = c("idNotaVenda","codBarra"), rm.duplicates = TRUE, encoding = "UTF-8")
#
# Por alguma razao obscura a dataframe NÃO FOI SALVA EM CSV COM SEPARADOR ;
# ASSIM A LEITURA SÓ DA CERTO COM SEPARADOR " "
#
# SE TIVESSE SIDO ESCRITO COMO EU IMAGINEI, O SEPARADOR SERIA ; E ABAIXO A LEITURA TAMBÉM USARIA ESTE SEPARADOR
trans = read.transactions("transacoes.csv", format = "single", sep = "", cols = c("idNotaVenda","nome"), rm.duplicates = TRUE, encoding = "UTF-8")

save(trans, file = "transacoes.RData")
