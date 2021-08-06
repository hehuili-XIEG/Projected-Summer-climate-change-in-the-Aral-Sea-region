#!/bin/bash
#PBS -l walltime=2:00:00
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -o /home/heheuili/CMIP5/RCP/log/12km.45.FSFS.{startdate}.log
#PBS -N a.{startdate}
#
#


set -x


STARTDATE={startdate}
STOPDATE={stopdate}
YEAR={year}

RUNSTART_04km=24
RUNSTART_40km=12

NPROC=6
#NPROC=$NCPUS

TSTEP=180.
RUNLENGTH_04km=36

DAYINCREMENT={interval}

ERADIR=/home/heheuili/CMIP5/RCP
REMOTE=gloin

COUPLING=/mnt/HDS_ALD_TEAM/ALD_TEAM/heheuili/CMIP5_RCP45/FS50_LU2050
#COUPLING=/mnt/EQL_FORBIO/FORBIO/CHIMERE/CMIP5/RCP45/FS20km
#COUPLING=/archive/CLIMATE_SURFEX_ALARO/CMIP5/HIST/FS20km


SAVEDIR=/mnt/HDS_ALD_TEAM/ALD_TEAM/heheuili/CMIP5_RCP45/FSFS12km_LU2050
#SAVEDIR=/mnt/EQL_FORBIO/FORBIO/CHIMERE/CMIP5/RCP45/FSFS4km
#SAVEDIR=/archive/CLIMATE_SURFEX_ALARO/CMIP5/HIST/FSFS4km

#SAVEDIRANDY=/mnt/EQL_MASC/MASC/CMIP5/HIST/4km/CHIMERE


EXP=BE04

NAMRFA=$ERADIR/namelist/nam.FAreplace.surf.4km
NAMRFA2=$ERADIR/namelist/nam.FAreplace.surf2
NAM927=$ERADIR/namelist/name.pre36.ALR12
NAM927_SFX=$ERADIR/namelist/name.pre36.surfex.ALR12
NAMPREP=$ERADIR/namelist/PRE_REAL1.nam
NAM001=$ERADIR/namelist/name.fc36.surfex.ALR4.BXL
NAMSFX=$ERADIR/namelist/EXSEG1.nam
NAMCLIM=$ERADIR/namelist/climnam
NAMFACLS=$ERADIR/namelist/nam.CLSTEMPreplace.surf

WORKDIR=/scratch-b/heheuili/CMIP5/RCP45/FSFS12km_LU2050

#MASTER=/home/daand/aladin/rootpack/36t1_op2bf1.01.INTEL1503.x/bin/MASTER
MASTER=/home/ald_team/Aladin/rootpack/36t1_op2bf1.01.INTEL1503.x/bin/MASTER

# Base directory
ENVDIR=/home/daand/aladin/runs/ref38t1/

DECDATE=$HOME/bin/decdate

CLIM_40km=/home/heheuili/CMIP5/CLIM50km/ca_cordex_clim50_
CLIM_04km=/home/heheuili/CMIP5/CLIM12km/clim_model_m

PGDBELG=/home/heheuili/CMIP5/PGD/PGD_2015_2L_10km_emap_future.lfi

#CLIM_ANDY=/home/julieb/CLIMATE_ALARO_SURFEX/clim/clim_andy/be40c_g1

LFI_4km=/mnt/HDS_ALD_TEAM/ALD_TEAM/heheuili/CMIP5_RCP45/10km_LFI_LU2050

LFIREPLACESST=$ERADIR/namelist/LFIreplaceSST.R


function e927
{
set -x

cDATE=$1
cRR=$2
cHH=$3
cCPLNR=$4
cBASE=$5
cEXP=$6

#++++++++++++++++++++++++ typeset -Z4 cHH ++++++++++++++
if [[ $cHH -le 9 ]]
then
cHH=000${cHH}
else
if [[ $cHH -le 99 ]]
then
cHH=00${cHH} 
else
cHH=0${cHH}
fi
fi
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



#if [[ $cHH = 0012 ]]     #------------------------- Creation of TEST.lfi at the 00 range ------------------------
#then

 cYYYY=`echo $cDATE | cut -c1-4`
   cMM=`echo $cDATE | cut -c5-6`
   cDD=`echo $cDATE | cut -c7-8`

# --- Summer -------
  YEARS=$YEAR
  MONTHS='03'
  INITDAYS='01'
  LCOLD=0


# --- Winter -----
#  MONTHS='11'
#  INITDAYS='01'
#  LCOLD=0

for YEAR in $YEARS
  do   
  for MONTH in $MONTHS 
     do  
     for DAY in $INITDAYS
         do
         if [ $cDD = $DAY -a $cMM = $MONTH -a $cYYYY = $YEAR ]  
            then
            LCOLD=1
         fi      
         done 
     done   
done   

   PREVDATE=`/home/julieb/bin/decdate $cDATE +1`
   pYYYY=`echo $PREVDATE | cut -c1-4`
   pMM=`echo $PREVDATE | cut -c5-6`
   pDD=`echo $PREVDATE | cut -c7-8`
   

   ANA_DATE=$cDATE
   let cTIME=10#${cRR}+10#$cHH
   while [ $cTIME -ge 0024 ]
   do
     ANA_DATE=`$DECDATE ${ANA_DATE} +1`
     let cTIME=10#$cTIME-10#24
   done
   ANA_MONTH=`echo ${ANA_DATE} | cut -c5-6`


   if [[ $LCOLD = 0 ]] 
      then

       if [[ $cHH = 0024 ]]     #------------------------- Creation of TEST.lfi at the 00 range ------------------------
       then

#      scp $REMOTE:$SAVEDIR/$pYYYY/$pYYYY$pMM$pDD.tgz $pYYYY$pMM$pDD.tgz
      scp $REMOTE:$SAVEDIR/$pYYYY/$pYYYY$pMM$pDD.tar $pYYYY$pMM$pDD.tar

      tar xf $pYYYY$pMM$pDD.tar
      mv AROMOUT_.0018.lfi TEST.lfi

      scp $REMOTE:${LFI_4km}/${cYYYY}/${ANA_DATE}/INIT_SURF.lfi SST.lfi
#       /home/julieb/bin/R CMD BATCH $LFIREPLACESST
      R CMD BATCH $LFIREPLACESST     
 
      rm -f AROMOUT_.*.lfi pfBE04zzzz+* $pYYYY$pMM$pDD.tar GPFANDY* 
     
   cp ${CLIM_40km}${ANA_MONTH} Const.Clim
   cp ${CLIM_04km}${ANA_MONTH} const.clim.${cEXP}

   cp const.clim.${cEXP} const.clim.${cEXP}
   cp const.clim.${cEXP} Const.Clim 

   fi

   fi

    
   if [[ ! -d prepSurf ]]
      then
        mkdir prepSurf
      fi
   rm -f prepSurf/*
   cd prepSurf

   cp ../$cBASE+$cHH ICMSHE927INIT

   ANA_DATE=$cDATE
   let cTIME=10#${cRR}+10#$cHH
   while [ $cTIME -ge 0024 ]
   do
     ANA_DATE=`$DECDATE ${ANA_DATE} +1`
     let cTIME=10#$cTIME-10#24
   done
   ANA_MONTH=`echo ${ANA_DATE} | cut -c5-6`

   cp ${CLIM_40km}${ANA_MONTH} Const.Clim
   cp ${CLIM_04km}${ANA_MONTH} const.clim.${cEXP}
   ln -sf $PGDBELG    PGDFILE.lfi
      
   echo 'echo MONITOR: $* >&2' >monitor.needs
   chmod +x monitor.needs

export DR_HOOK=1
export DR_HOOK_NOT_MPI=0
export DR_HOOK_SILENT=0
export DR_HOOK_OPT=prof
export OMP_NUM_THREADS
export EC_PROFILE_HEAP=0
export OMP_STACKSIZE=16M
ulimit -s unlimited


   cat $NAM927_SFX  | grep -v '^!' | sed  -e s/!.*// \
                                   -e s/{domain}/${cEXP}/ \
                                   -e s/{nbproc}/${NPROC}/ > fort.4

   cp ${NAMPREP} .

# set environment
source ${ENVDIR}/ENV_ALADIN

# Bring executable binary
ln -sf $MASTER ./master

ls -al
#   mpirun -np 1 ALADIN -eE927 -vmeteo -c001 -maladin -t1800. -ft0 -aeul
#   mpiexec_mpt omplace ./master -eE927 -vmeteo -c001 -maladin -t1800. -ft0 -aeul > log.out 2>log.err
   mpiexec_mpt -np 1 ./master -eE927 -vmeteo -c001 -maladin -t1800. -ft0 -aeul > log.out 2>log.err

 if [[ $cHH = 0024 ]]     #------------------------- Creation of TEST.lfi at the 00 range ------------------------
   then
   if [[ $LCOLD = 1 ]] 
      then     
       mv INIT_SURF.lfi ../TEST.lfi
       cp const.clim.${cEXP} ../const.clim.${cEXP}
       cp const.clim.${cEXP} ../Const.Clim    
   fi
  fi

   mv PFE927BE04+0000 ../SURFVAR.${YEAR}${MONTH}${COMPT_DAY}${cCPLNR}



#   cp const.clim.${cEXP} ../const.clim.${cEXP}
#   cp const.clim.${cEXP} ../Const.Clim     

   cd ..

     
#fi
  
  

if [[ ! -d prep ]] 
then 
mkdir prep
fi

rm prep/*
cd prep

cYYYY=`echo $cDATE | cut -c1-4`
cMM=`echo $cDATE | cut -c5-6`
cDD=`echo $cDATE | cut -c7-8`


### decide which clim file you need
ANA_DATE=$cDATE
let cTIME=10#${cRR}+10#$cHH
while [ $cTIME -ge 0024 ]
do
  ANA_DATE=`$DECDATE ${ANA_DATE} +1`
  let cTIME=10#$cTIME-10#24
done
ANA_MONTH=`echo ${ANA_DATE} | cut -c5-6`



#    cp ../$cBASE+$cHH ICMSHE927INIT


    #--------------------------- add surface field
    cp ${CLIM_40km}${ANA_MONTH} GLOB
    cp $NAMRFA fort.4
    ln -s ../$cBASE+$cHH LBC
    /home/julieb/software/FAreplace/FAreplace
    mv LBC ICMSHE927INIT
    #----------------------------------------------------------   


cp ${CLIM_40km}${ANA_MONTH} Const.Clim
cp ${CLIM_04km}${ANA_MONTH} const.clim.${cEXP}

cp ${CLIM_04km}${ANA_MONTH} ../const.clim.${cEXP}.${cHH}
#cp ${CLIM_ANDY}_${ANA_MONTH} ../const.clim.ANDY.${cHH}

### and now we actually run ALADIN:
  echo 'echo MONITOR: $* >&2' >monitor.needs
  chmod +x monitor.needs
  
  cat $NAM927  | grep -v '^!' | sed  -e s/!.*// \
                                   -e s/{domain}/${cEXP}/ \
                                   -e s/{nbproc}/${NPROC}/ > fort.4
source ${ENVDIR}/ENV_ALADIN

# Bring executable binary
ln -sf $MASTER ./master

ls -al
#  ln -s ${ALADIN_EXEC} ALADIN

#  mpirun -np ${NPROC} ALADIN -eE927 -vmeteo -c001 -maladin -t1800. -ft0 -aeul
#   mpiexec_mpt omplace ./master -eE927 -vmeteo -c001 -maladin -t1800. -ft0 -aeul > log.out 2>log.err
    mpiexec_mpt -np ${NPROC} ./master -eE927 -vmeteo -c001 -maladin -t1800. -ft0 -aeul > log.out 2>log.err

   #------------ add surface field -------------------------
    cp ../SURFVAR.${YEAR}${MONTH}${COMPT_DAY}${cCPLNR} SRFX
    cp $NAMRFA2 fort.4
    cp PFE927${cEXP}+0000 LBC2
    /home/julieb/software/FAreplace/FAreplace
    #--------------------------------------------------------

  mv LBC2 ../ELSCF${cEXP}ALBC${cCPLNR}
  cd ..
 
 

}

#-------------------------------------------------------- coupling files --------------------------

function get_coupling
{
set -x

COUPDATE=$1
COUPRUN=$2
COUPEXP=$3

NEXTDATE=`/home/julieb/bin/decdate $COUPDATE +$DAYINCREMENT`

COUPYEAR=`echo $NEXTDATE | cut -c1-4`
COUPMONTH=`echo $NEXTDATE | cut -c5-6`
COUPDAY=`echo $NEXTDATE | cut -c7-8`


let NCOUP=10#${RUNLENGTH_04km}/3+10#1

#++++++++++++++++++++++++ typeset -Z3 NCOUP ++++++++++++++
if [[ $NCOUP -le 9 ]]
then
NCOUP=00${NCOUP}
else
NCOUP=0${NCOUP}
fi
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CPLNR=0

RUN_DATE=$COUPDATE

let CTIME=$COUPRUN


#++++++++++++++++++++++++ typeset -Z2 CTIME ++++++++++++++
if [[ $CTIME -le 9 ]]
then
CTIME=0${CTIME}
fi
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#++++++++++++++++++++++++ typeset -Z3 CPLNR ++++++++++++++
if [[ $CPLNR -le 9 ]]
then
CPLNR=00${CPLNR}
else
CPLNR=0${CPLNR}
fi
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#scp ${REMOTE}:$COUPLING/$COUPYEAR/${COUPYEAR}${COUPMONTH}${COUPDAY}.tgz .

scp ${REMOTE}:$COUPLING/$COUPYEAR/${COUPYEAR}${COUPMONTH}${COUPDAY}.tar .
tar -xf ${COUPYEAR}${COUPMONTH}${COUPDAY}.tar
rm -f GPFANDY* AROMOUT_.*
rm -f ${COUPYEAR}${COUPMONTH}${COUPDAY}.tar

while [ $CPLNR != $NCOUP ]
do

  e927 ${COUPDATE} ${RUNSTART_40km} $CTIME ${CPLNR} ICMSHBE20 ${COUPEXP}

  let CPLNR=10#$CPLNR+1
  let CTIME=10#$CTIME+3

#++++++++++++++++++++++++ typeset -Z2 CTIME ++++++++++++++
  if [[ $CTIME -le 9 ]]
  then
  CTIME=0${CTIME}
  fi

#++++++++++++++++++++++++ typeset -Z3 CPLNR ++++++++++++++
  if [[ $CPLNR -le 9 ]]
  then
  CPLNR=00${CPLNR}
  else
  CPLNR=0${CPLNR}
  fi  
done

rm -f BC*

}


#++++++++++++++++++++++++++++++++++++++++++++++++++ Forecast +++++++++++++++++++++++++++++

DATE={startdate}

#. $ENV


if [[ ! -d $WORKDIR/$DATE ]]
then
mkdir -p $WORKDIR/$DATE
fi

rm -f $WORKDIR/$DATE/*
cd $WORKDIR/$DATE


pwd 
ls

YYYY=`echo $DATE | cut -c1-4`
MM=`echo $DATE | cut -c5-6`
DD=`echo $DATE | cut -c7-8`



### first we get the coupling files from the archive
 
 get_coupling $DATE ${RUNSTART_04km} $EXP

 rm -f ICMSHBE40+*

### read climate value cencentration 
 
cp $NAMCLIM/GHG_RCP45.dat .

awk '{if ($1 == "'$YYYY'") {printf($0);}}' GHG_RCP45.dat > RCP45_$YYYY.dat
file=RCP45_$YYYY.dat

old_IFS=$IFS
IFS=$'\n'
lines=($(cat $file))
IFS=$old_IFS
RCCO2=`echo ${lines[0])} | cut -c6-13`
RCCH4=`echo ${lines[0])} | cut -c15-23`
RCN2O=`echo ${lines[0])} | cut -c25-32`
RCCFC11=`echo ${lines[0])} | cut -c34-41`
RCCFC12=`echo ${lines[0])} | cut -c43-50` 
RIO=`echo ${lines[0])} | cut -c52-60`

#### and now we actually run ALADIN:
  echo 'echo MONITOR: $* >&2' >monitor.needs
  chmod +x monitor.needs

  ln -sf ELSCF${EXP}ALBC000 ICMSH${EXP}INIT

  cp $NAMSFX .

  #### forecast run -------
  
  cat $NAM001  | grep -v '^!' | sed -e "s/!.*//" \
                                   -e "s/{cnmexp}/$EXP/" \
                                   -e "s/{neini}/2/" \
                                   -e "s/{lsprt}/.F./" \
                                   -e "s/{cfpath}/ICMSH/" \
                                   -e "s/{yyyymmdd}/${YYYY}${MM}${DD}/" \
                                   -e "s/{sssss}/$(( ${RUNSTART_04km}*3600 ))"/ \
                                   -e "s/{rcco2}/${RCCO2}e-06/" \
                                   -e "s/{rcch4}/${RCCH4}e-09/" \
                                   -e "s/{rcn2o}/${RCN2O}e-09/" \
                                   -e "s/{rccfc11}/${RCCFC11}e-12/" \
                                   -e "s/{rccfc12}/${RCCFC12}e-12/" \
                                   -e "s/{rio}/${RIO}/" \
                                   -e "s/{nproc}/${NPROC}/" > fort.4  


source ${ENVDIR}/ENV_ALADIN

# Bring executable binary
ln -sf $MASTER ./master

ls -al
#  ln -s ${ALADIN_EXEC} ALADIN
#  ls -al

#  mpirun -np ${NPROC} ALADIN -e$EXP -vmeteo -c001 -maladin -t$TSTEP -fh${RUNLENGTH_04km}
   mpiexec_mpt -np ${NPROC} ./master -e$EXP -vmeteo -c001 -maladin -t$TSTEP -fh${RUNLENGTH_04km} > log.out 2>log.err

#Move CLSTEMPERATURE from output file to fullpos file

for HOUR in {11..36}
do

  mv PFBE04zzzz+00${HOUR} pfBE04zzzz+00${HOUR}
  cp $NAMFACLS fort.4
  cp pfBE04zzzz+00${HOUR} pfBE04zzzz
  cp ICMSHBE04+00${HOUR} ICMSHBE04
  /home/julieb/software/FAreplace/FAreplace
  mv pfBE04zzzz pfBE04zzzz+00${HOUR}

done

#### Save output to the archive

  NEXTDATE=`/home/julieb/bin/decdate $DATE +$DAYINCREMENT`
  NEXTDATE2=`/home/julieb/bin/decdate $DATE +2`


  YYYY=`echo $NEXTDATE | cut -c1-4`
  MM=`echo $NEXTDATE | cut -c5-6`
  DD=`echo $NEXTDATE | cut -c7-8`

  YYYY2=`echo $NEXTDATE2 | cut -c1-4`
  MM2=`echo $NEXTDATE2 | cut -c5-6`
  DD2=`echo $NEXTDATE2 | cut -c7-8`


  ARCHIVE2=$SAVEDIR/$YYYY2
#  ARCHIVEANDY=$SAVEDIRANDY/$YYYY

  tar -cf $YYYY2$MM2$DD2.tar  AROMOUT_.0024.lfi AROMOUT_.0024.lfi
  ssh $REMOTE " mkdir -p -m 775 $ARCHIVE2"

  scp $YYYY2$MM2$DD2.tar $REMOTE:$ARCHIVE2



  if [ $NEXTDATE -le $STOPDATE ] 
  then
   ksh $ERADIR/script/kick_10km_FS_RCP45_future_2020 $NEXTDATE $STOPDATE $YEAR $DAYINCREMENT 
  fi 
 

  #YYYY=`echo $DATE | cut -c1-4`
  #MM=`echo $DATE | cut -c5-6`
  #DD=`echo $DATE | cut -c7-8`
  #cd $WORKDIR
 # rm -rf $WORKDIR/$DATE 


  





