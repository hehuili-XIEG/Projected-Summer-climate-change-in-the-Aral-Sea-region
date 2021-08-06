

rm(list=ls())
library(Rfa)
stry = 1980
endy = 1989
years = seq(stry,endy,1)
#months=seq(1,12,1)
months = c(5,6,7,8)
days = c(31,30,31,31)

datadir = "/scratch-a/heheuili/CMIP5/HIS/FSFS12km/"
savedir = "/home/heheuili/FILE/HIS/"
compty = 0

file1 <- "/home/heheuili/FILE/Aral_Station_1.txt"

dat <- read.table(file1,header = FALSE,sep = "\t")
ID = dat[,1]
lat = dat[,4]
lon = dat[,5]
num1 = length(ID)
#output="/home/heheuili/re_cas/"
prefix="AROMOUT_.00"
times=c(12:35)

ll = 920
t2m = array(NA,dim=c(num1,ll))
bb = c(1:4)
qq=1

for(yy in years){
  #print(yy)
  for (mm in bb){
    mn = months[mm]
    if(mn<6){
      for(dd in 29:31){
        tmp0=array(NA,dim=c(200,200,24))

        for(time in times){
          spath=paste(datadir,yy,i2a(mn,2),i2a(dd,2),"/",prefix,time,".lfi")
          tmp=LFIdec(spath,'T2M')
          
        }
        
      }#dd
      
    }
    #print(mn)
    for (dd in 1:days[mm]){
      for(time in 1:24){
        
        vt2m = LFIdec(spath,"T2M")
        t2m[1:num1,qq] = sapply(1:num1,function(x)lalopoint(vt2m,lon[x],lat[x])$data, simplify="array")
        
        print(paste(yy,mn,dd,time,qq,sep="_"))
        qq=qq+1
      }#time
    }#dd
  }#mm
}#yy

savedir = "/home/heheuili/ca_res/T2M/station/"
dir.create(savedir)

nn = data.frame(IDname = ID,Prevalue = t2m[,])
write.table(nn,paste(savedir,"full_t2m_station_hour_.txt",sep=""),quote = FALSE, sep=",",na = "NA",row.names=FALSE,col.names=FALSE,qmethod="double")


##############################################################################################################
###---------------------------------------with real aral sea-------------------------------------------

rm(list=ls())
library(Rfa)
years = seq(1984,1986,1)
#months=seq(1,12,1)
months = c(6,7,8)
days = c(30,31,31)

datadir = "/scratch-b/heheuili/CASIA/4km_AralBasin/Aral_desiccation/"
savedir = "/home/heheuili/ca_res/T2M/"
compty = 0

file1 <- "/home/heheuili/FILE/Aral_Station_1.txt"

dat <- read.table(file1,header = FALSE,sep = "\t")
ID = dat[,1]
lat = dat[,4]
lon = dat[,5]
num1 = length(ID)
#output="/home/heheuili/re_cas/"
prefix="AROMOUT_.00"
times=c(12:35)

ll = sum(days)*length(years)*24
t2m = array(NA,dim=c(num1,ll))
bb = c(1:3)
qq=1

for(yy in years){
  #print(yy)
  for (mm in bb){
    mn = months[mm]
    #print(mn)
    for (dd in 1:days[mm]){
      for(time in 1:24){
        spath=paste(datadir,yy,"/",i2a(mn,2),"/",i2a(dd,2),"/r00/",sep="",prefix,times[time],".lfi")
        vt2m = LFIdec(spath,"T2M")
        t2m[1:num1,qq] = sapply(1:num1,function(x)lalopoint(vt2m,lon[x],lat[x])$data, simplify="array")
        
        print(paste(yy,mn,dd,time,qq,sep="_"))
        qq=qq+1
      }#time
    }#dd
  }#mm
}#yy

savedir = "/home/heheuili/ca_res/T2M/station/"
nn = data.frame(IDname = ID,Prevalue = t2m[,])
write.table(nn,paste(savedir,"real_t2m_station_hour_8486.txt",sep=""),quote = FALSE, sep=",",na = "NA",row.names=FALSE,col.names=FALSE,qmethod="double")


##############################################################################################################
###---------------------------------------with real aral sea-------------------------------------------

rm(list=ls())
library(Rfa)
years = seq(1984,1986,1)
#months=seq(1,12,1)
months = c(6,7,8)
days = c(30,31,31)

datadir = "/scratch-a/heheuili/CASIA/4km_AralBasin/noaral/"
savedir = "/home/heheuili/ca_res/T2M/"
compty = 0

file1 <- "/home/heheuili/FILE/Aral_Station_1.txt"

dat <- read.table(file1,header = FALSE,sep = "\t")
ID = dat[,1]
lat = dat[,4]
lon = dat[,5]
num1 = length(ID)
#output="/home/heheuili/re_cas/"
prefix="AROMOUT_.00"
times=c(12:35)

ll = sum(days)*length(years)*24
t2m = array(NA,dim=c(num1,ll))
bb = c(1:3)
qq=1

for(yy in years){
  #print(yy)
  for (mm in bb){
    mn = months[mm]
    #print(mn)
    for (dd in 1:days[mm]){
      for(time in 1:24){
        spath=paste(datadir,yy,"/",i2a(mn,2),"/",i2a(dd,2),"/r00/",sep="",prefix,times[time],".lfi")
        vt2m = LFIdec(spath,"T2M")
        t2m[1:num1,qq] = sapply(1:num1,function(x)lalopoint(vt2m,lon[x],lat[x])$data, simplify="array")
        
        print(paste(yy,mn,dd,time,qq,sep="_"))
        qq=qq+1
      }#time
    }#dd
  }#mm
}#yy

savedir = "/home/heheuili/ca_res/T2M/station/"
nn = data.frame(IDname = ID,Prevalue = t2m[,])
write.table(nn,paste(savedir,"no_t2m_station_hour_8486.txt",sep=""),quote = FALSE, sep=",",na = "NA",row.names=FALSE,col.names=FALSE,qmethod="double")
