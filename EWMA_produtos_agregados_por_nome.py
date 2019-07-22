# -*- coding: utf-8 -*-
"""
Created on Thu Sep 15 13:58:59 2016

@author: Monica
"""
## Importações variadas
## get_ipython().magic(u'matplotlib inline')
import numpy as np
import pandas as pd
# import matplotlib.pyplot as plt
import matplotlib as mpl
from scipy import optimize
# from scipy.optimize import curve_fit
# from scipy.optimize import leastsq
from scipy.optimize import *
# Funcoes de data e tempo para criar nome do arquivo de previsao
import time
import datetime
import pymysql


# Identificar quais versões dos módulos principais estão sendo usadas
print "Versão Pandas     " +str(pd.__version__)
print "Versão Numpy      " + str(np.__version__)
print "Versão MatplotLib      " + str(mpl.__version__)


###############################################################################
# Creates Connection to Database
################################################################################
       
# Conecta com Base de Dados
conn = pymysql.Connect(host = '139.82.111.110',user = 'monica',
                          password = 'a2i2',database = 'a2i2_producao', port = 3306, use_unicode = 'TRUE')

cur = conn.cursor()


# Prepares query  
# =================================================================
#  Losartana genérico 
# nome_prod_param = "losartana"
# Atenolol generico
nome_prod_param = "atenolol"
lin1 = "SELECT codBarra, nome, fabricante FROM produto "
lin2 = " WHERE nome like '%" + nome_prod_param + "%' and categoria = 8 order by  codBarra, fabricante;"

nome_query = lin1 + lin2 


# ===========================================================
# Executes query
# ===========================================================                   
   
cur.execute(nome_query)   

# gets the number of rows in the result set (or the maximum specified in the SELECT statement)
num_rows= cur.rowcount

#print num_rows

#  Creates a Dataframe directly from the SQL query
df_produto = pd.read_sql(nome_query, conn)

#(rows, cols) = df_produto.shape
#print(rows, cols)


#print(df_produto.head())
#print(df_produto.tail())

# Dimensions of the dataframe
df_produto.shape

# Closes cursor
cur.close()

# Reads in data (14 weeks of sales)
df = pd.read_csv('C://Users//Monica//Dropbox//a2i2_flashfarma//Estudos//Prev_Vendas_ROI//Previsao_Loja1.csv', sep = ';', encoding = 'utf-8')

# Selects barcodes to be forecasted
lista_cod_barras = df_produto['codBarra'].tolist()

df =df.rename(columns = {'Codigo de Barra do Produto':'codBarra'})

# Changes type to string to allow comparison
df['codBarra2'] = df['codBarra'].astype(str).tolist()

# Obtains Dataframe with ONLY the items of interest to be forecasted
df = df[df['codBarra2'].isin(lista_cod_barras)]


# Computes totals
dfsum = df.sum(axis=0, skipna=None, level=None, numeric_only='TRUE')
dfsum = pd.DataFrame(dfsum)
# Transposes
x = dfsum.T
(rows, cols) = x.shape   # Contains data with totals (to be predicted)


df1= x['Venda S01']
df2= x['Venda S02']
df3= x['Venda S03']
df4 = x['Venda S04']
df5 = x['Venda S05']
df6 = x['Venda S06']
df7 = x['Venda S07']
df8 = x['Venda S08']
df9= x['Venda S09']
df10= x['Venda S10']
df11 = x['Venda S11']
df12 = x['Venda S12']
df13 = x['Venda S13']
df14 = x['Venda S14']
#
## Defina a função de previsão usando apenas as ultimas 8 semanas
#
def prev(df1,df2, df3, df4, df5, df6, df7, df8, alfa):
    return alfa*df1 + alfa*(1-alfa)*df2 + alfa*((1-alfa)**2)* df3
    + alfa*((1-alfa)**3)*df4 + alfa*((1-alfa)**4)*df5 + alfa*((1-alfa)**5)*df6 
    + alfa*((1-alfa)**6)*df7 + alfa*((1-alfa)**7)*df8 #+ alfa*((1-alfa)**8)*df['Venda S09']
#    #+ alfa*((1-alfa)**9)*df['Venda S10'] + alfa*((1-alfa)**10)*df['Venda S11'] + alfa*((1-alfa)**11)*df['Venda S12']
#    #+ alfa*((1-alfa)**12)*df['Venda S13'] + alfa*((1-alfa)**13)*df['Venda S14'];
#    
# Definicao dos residuos
def resid(y, df1, df2, df3, df4, df5, df6, df7, df8,alfa):
    return y - prev(df1,df2, df3, df4, df5, df6, df7, df8, alfa)

# SS Residuos - segundo o timeit do Python foi um pouco mais rápida
def sq_forec_error(alfa):
    return (resid(df1,df2, df3, df4, df5, df6, df7, df8, df9, alfa))**2
    + (resid(df2, df3, df4, df5, df6, df7, df8, df9, df10,  alfa))**2 + (resid(df3, df4, df5, df6, df7, df8, df9, df10, df11, alfa))**2
    + (resid(df4, df5, df6, df7, df8, df9, df10, df11, df12, alfa))**2 + (resid(df5, df6, df7, df8, df9, df10, df11, df12, df13,alfa))**2
    + (resid(df6, df7, df8, df9, df10, df11, df12, df13, df14, alfa))**2

# Para ver quanto tempo demora
tic=time.clock()

# get_ipython().magic(u'timeit')
# =======================================================
# IMPLEMENTACAO DE ALFA OTIMIZADO
# =======================================================

# esta parte do codigo necessaria se quiser implementar com bounds
lim_inf = np.zeros([rows,1])
lim_sup = np.ones(([rows,1]))
bounds = np.column_stack((lim_inf, lim_sup))
bounds.shape
# =========================================================
alfa = 0.2;
alfa_opt=[]

x0=0.2*np.ones(([rows,1]))

for i in range(rows):
    def temp(x):
        return sq_forec_error(x)[i]
    otimiza = minimize_scalar(temp, x0,bounds=(0.0, 1.0), method='bounded'); #constraints=(), tol=None, callback=None, options=None) 
    #otimiza = minimize(temp, x0, bounds = bd, constraints=(), tol=None, callback=None, options=None) 
    alfa_opt.append(otimiza.x);
    

toc = time.clock()
elapsed_time=toc-tic
print("tempo de execução:  ")+str("%.2f" % elapsed_time) + " segundos" + '\n'


def previsao(alfa):
    return alfa*df1 + alfa*(1-alfa)*df2 + alfa*((1-alfa)**2)*df3 + alfa*((1-alfa)**3)*df4 + alfa*((1-alfa)**4)*df5 + alfa*((1-alfa)**5)*df6
    + alfa*((1-alfa)**6)*df7 + alfa*((1-alfa)**7)*df8 + alfa*((1-alfa)**8)*df9
    + alfa*((1-alfa)**9)*df10 + alfa*((1-alfa)**10)*df11 + alfa*((1-alfa)**11)*df12
    + alfa*((1-alfa)**12)*df13 + alfa*((1-alfa)**13)*df14;
    

yhat=previsao(alfa_opt[0])
# Alfa_opt is a list - Need to apply function to 'element" of the list
#for i in alfa_opt:
#    yhat = previsao(i)
#    
print ('Previsão   ') + str(yhat)

print("Tamanho de yhat é:  ")+str(yhat.shape)

yhat = pd.DataFrame(yhat)
yhat.columns = ['Previsao']


now = datetime.datetime.now();

# Cria arquivo contendo previsões
nome_arq=str("EWMA_previsao_")+str(nome_prod_param)+str("_")+str(now.strftime("%Y%m%d"));
# Exporta previsoes para csv
yhat.to_csv(nome_arq+str(".csv"), sep = ';', index = False, header = True)
#