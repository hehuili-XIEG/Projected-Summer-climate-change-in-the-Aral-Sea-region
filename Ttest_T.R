###########################################################
#
#
#                 Temperature Annual 
#
#
#############################################################
######  CTR and LU2050 #####
module purge
module load R 

R

rm(list=ls())
library(Rfa)
inway = '/scratch-a/heheuili/CMIP5_RData/Year_RData/'

md = LFIdec("/scratch-b/heheuili/DOM/19800601/AROMOUT_.0024.lfi","T2M")
dom = attr(md,"domain")
corr=DomainPoints(md)
out_lat0=corr$lat
out_lon0=corr$lon


itc=seq(1,40000,200)
out_lat=array(NA,dim = c(200,200))
out_lon=array(NA,dim = c(200,200))

for(i in 1:200){
  str=itc[i]
  ed=itc[i]+199
  tmp1=as.numeric(out_lat0[str:ed])
  tmp2=as.numeric(out_lon0[str:ed])
  for(j in 1:200){
    out_lat[j,i]=tmp1[j]
    out_lon[j,i]=tmp2[j]
  }
}


con=load(paste(inway,'CTR/',"T2M_yearly.RData",sep=""))
#aa=load(paste(inway,'CTR/',"DTR_yearly.RData",sep=""))
con_mean_y = yr_mean
con_max_y = yr_max
con_min_y = yr_min
con_dtr_y=yr_dtr
rm(yr_mean,yr_max,yr_dtr,yr_min,con)

chg = load(paste(inway,'HIS/',"T2M_yearly.RData",sep=""))
aa = load(paste(inway,'HIS/',"DTR_yearly.RData",sep=""))

###### ------First step to calculate the year value 

exp_mean_y = yr_mean
exp_min_y = yr_min
exp_max_y = yr_max
exp_dtr_y=yr_dtr

###### Second Step to make the Ttest
tmean=c(0,0)
tmin=c(0,0)
tmax=c(0,0)
tdtr=c(0,0)

pvalue_mean=array(NA,dim=c(200,200))
sig_mean = array(NA,dim=c(200,200))

pvalue_min=array(NA,dim=c(200,200))
sig_min = array(NA,dim=c(200,200))

pvalue_max=array(NA,dim=c(200,200))
sig_max = array(NA,dim=c(200,200))

pvalue_dtr=array(NA,dim=c(200,200))
sig_dtr = array(NA,dim=c(200,200))

pvalue=0.01

for(i in 1:200)
{
  for(j in 1:200)
  {
    #pvalue[i,j]=t.test(newpre[i,j,],oldpre[i,j,],paired=T,conf.level=0.99)$p.value
    pvalue_mean[i,j]=t.test(con_mean_y[i,j,],exp_mean_y[i,j,],paired=T)$p.value
    pvalue_min[i,j]=t.test(con_min_y[i,j,],exp_min_y[i,j,],paired=T)$p.value
    pvalue_max[i,j]=t.test(con_max_y[i,j,],exp_max_y[i,j,],paired=T)$p.value
    pvalue_dtr[i,j]=t.test(con_dtr_y[i,j,],exp_dtr_y[i,j,],paired=T)$p.value
    
    if(pvalue_mean[i,j] <= pvalue){
      tmp1=out_lon[i,j]
      tmp2=out_lat[i,j]
      tmp3=c(tmp1,tmp2)
          
      tmean=rbind(tmean,tmp3)
      rm(tmp1,tmp2,tmp3)
      sig_mean[i,j] = -as.numeric(mean(exp_mean_y[i,j,])) + as.numeric(mean(con_mean_y[i,j,]))
    }#if
    if(pvalue_max[i,j] <= pvalue){
      tmp1=out_lon[i,j]
      tmp2=out_lat[i,j]
      tmp3=c(tmp1,tmp2)
      
      tmax=rbind(tmax,tmp3)
      rm(tmp1,tmp2,tmp3)
      sig_max[i,j] = -as.numeric(mean(exp_max_y[i,j,]))+as.numeric(mean(con_max_y[i,j,]))
    }#if
    if(pvalue_min[i,j] <= pvalue){
      tmp1=out_lon[i,j]
      tmp2=out_lat[i,j]
      tmp3=c(tmp1,tmp2)
      
      tmin=rbind(tmin,tmp3)
      rm(tmp1,tmp2,tmp3)
      sig_min[i,j] = -as.numeric(mean(exp_min_y[i,j,])) + as.numeric(mean(con_min_y[i,j,]))
    }#if
        
    if(pvalue_dtr[i,j] < pvalue){
      tmp1=out_lon[i,j]
      tmp2=out_lat[i,j]
      tmp3=c(tmp1,tmp2)
      
      tdtr=rbind(tdtr,tmp3)
      rm(tmp1,tmp2,tmp3)
      sig_dtr[i,j] = -as.numeric(mean(exp_dtr_y[i,j,])) + as.numeric(mean(con_dtr_y[i,j,]))
    }#if    
  }#j
}#i


outpth = "/home/heheuili/Fig/FUTURE/"
dir.create(outpth)

#Aral = read.table("/home/heheuili/FILE/Aral.txt",header = T, sep=",")
Aral = read.table("/home/heheuili/FILE/2005Aral.txt",header = T, sep=",")
Araldry_p1 = read.table("/home/heheuili/FILE/2015Aral_p1.txt",header = T, sep=",")
Araldry_p2 = read.table("/home/heheuili/FILE/2015Aral_p2.txt",header = T, sep=",")
Araldry_p3 = read.table("/home/heheuili/FILE/2015Aral_p3.txt",header = T, sep=",")
Araldry_p4 = read.table("/home/heheuili/FILE/2015Aral_p4.txt",header = T, sep=",")

pdf(paste(outpth,"T2max_sig.pdf",sep=""))
iview(subgrid(as.geofield(sig_max,dom),10,190,10,190),legend=T)

#points(project(Aral$Lon1,Aral$Lat1,dom$projection),type="l",lwd=1)
points(project(Aral$Lon1,Aral$Lat1,dom$projection),type="l",lwd=1,col="blue")
points(project(Araldry_p1$Lon1,Araldry_p1$Lat1,dom$projection),type="l",lwd=1,col="red")
points(project(Araldry_p2$Lon1,Araldry_p2$Lat1,dom$projection),type="l",lwd=1,col="red")
points(project(Araldry_p3$Lon1,Araldry_p3$Lat1,dom$projection),type="l",lwd=1,col="red")
points(project(Araldry_p4$Lon1,Araldry_p4$Lat1,dom$projection),type="l",lwd=1,col="red")
dev.off()
###########################


