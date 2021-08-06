#!/bin/bash
#PBS -l walltime=2:00:00
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -o /home/heheuili/CMIP5/RCP/log/RCP45.50km.A5.FS.{startdate}.log
#PBS -N LU.{startdate}
#
#

umask 022

set -x

STARTDATE={startdate}
STOPDATE={stopdate}
YEAR={year}
DAYINCREMENT={interval}

RUNSTART=12
NPROC=$NCPUS
TSTEP=900.
RUNLENGTH=60

#DAYINCREMENT={interval}


REMOTE=gloin


COUPLING=/mnt/HDS_ALD_TEAM/ALD_TEAM/heheuili/CMIP5_RCP45/LBC50_LU2050
#COUPLING=/mnt/EQL_FORBIO/FORBIO/CHIMERE/CMIP5/RCP45/coupling_20km
EXP=BE20
ERADIR=/home/heheuili/CMIP5/RCP


NAM001=$ERADIR/namelist/name.fc36.surfex.ALR.CUF.ANDY
NAMRFA=$ERADIR/namelist/nam.FAreplace.surf.20
NAMCLIM=$ERADIR/namelist/climnam
#NAMFACLS=$ERADIR/namelist/nam.CLSTEMPreplace.surf

NAMSFX=$ERADIR/namelist/EXSEG1.nam


CLIM_20km=/scratch-a/heheuili/CLIM/CLIM50km/ca_cordex_clim50_

#CLIM_ANDY=/home/julieb/CLIMATE_ALARO_SURFEX/clim/clim_andy/be40c_g1

WORKDIR=/scratch-b/heheuili/CMIP5/RCP45/FS50km_LU2050

#SAVEDIR=/mnt/EQL_FORBIO/FORBIO/CHIMERE/CMIP5/RCP45/FS20km
SAVEDIR=/mnt/HDS_ALD_TEAM/ALD_TEAM/heheuili/CMIP5_RCP45/FS50_LU2050

#SAVEDIRANDY=/mnt/EQL_MASC/MASC/CMIP5/HIST/20km/CHIMERE

#MASTER=/home/daand/aladin/rootpack/36t1_op2bf1.01.INTEL1503.x/bin/MASTER
MASTER=/home/ald_team/Aladin/rootpack/36t1_op2bf1.01.INTEL1503.x/bin/MASTER
# Base directory
ENVDIR=/home/daand/aladin/runs/ref38t1/

DECDATE=$HOME/bin/decdate

LFIREPLACESST=$ERADIR/namelist/LFIreplaceSST.R


#-------------------------------------------------------- coupling files --------------------------

function get_coupling
{
set -x

COUPDATE=$1
COUPRUN=$2
COUPEXP=$3

let NCOUP=10#${RUNLENGTH}/6+10#1


COUPYEAR=`echo $COUPDATE | cut -c1-4`
COUPMONTH=`echo $COUPDATE | cut -c5-6`
COUPDAY=`echo $COUPDATE | cut -c7-8`


PREVDATE=`/home/julieb/bin/decdate $COUPDATE -0`
pYYYY=`echo $PREVDATE | cut -c1-4`
pMM=`echo $PREVDATE | cut -c5-6`
pDD=`echo $PREVDATE | cut -c7-8`



# --- Spring -------

  YEARS=$YEAR
  MONTHS='03'
  INITDAYS='01'
  LCOLD=0

for YEAR in $YEARS
  do   
  for MONTH in $MONTHS 
     do  
     for DAY in $INITDAYS
         do
         if [ $COUPDAY = $DAY -a $COUPMONTH = $MONTH -a $COUPYEAR = $YEAR ]  
            then
            LCOLD=1
         fi      
         done 
     done   
done   


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

scp $REMOTE:$COUPLING/$COUPYEAR/${COUPEXP}_${COUPDATE}.tar .
tar -xvf ${COUPEXP}_${COUPDATE}.tar

if [[ $LCOLD = 0 ]] 
      then
      scp $REMOTE:$SAVEDIR/$pYYYY/$pYYYY$pMM$pDD.tar $pYYYY$pMM$pDD.tar
      tar -xvf $pYYYY$pMM$pDD.tar
      mv AROMOUT_.0024.lfi TEST.lfi

      scp $REMOTE:$COUPLING/$COUPYEAR/INIT_SURF.${COUPYEAR}${COUPMONTH}${COUPDAY}00.lfi SST.lfi
     
      R CMD BATCH $LFIREPLACESST     

      rm -f AROMOUT_.*.lfi pfBE04zzzz+* pfBE40BE04+* $pYYYY$pMM$pDD.tgz GPFANDY* 
    
      rm -f ICMSHBE20+*
fi

if [[ $LCOLD = 1 ]] 
      then
      scp $REMOTE:$COUPLING/$COUPYEAR/INIT_SURF.${COUPDATE}${COUPRUN}.lfi TEST.lfi
fi

while [ $CPLNR != $NCOUP ]
do

   ANA_DATE=$COUPDATE
    let cTIME=10#$COUPRUN

   while [ $cTIME -ge 0024 ]
   do
     ANA_DATE=`$DECDATE ${ANA_DATE} +1`
     let cTIME=10#$cTIME-10#24
   done
   ANA_MONTH=`echo ${ANA_DATE} | cut -c5-6`


  if [[ $CPLNR -le 1 ]]
     then
     cp ${CLIM_20km}${ANA_MONTH} const.clim.BE20
     cp ${CLIM_20km}${ANA_MONTH} Const.Clim
  fi 


   cp ${CLIM_20km}${ANA_MONTH} Const.Clim.$CPLNR
  
#   cp ${CLIM_ANDY}_${ANA_MONTH} const.clim.ANDY.$CPLNR

   cp ${CLIM_20km}${ANA_MONTH} BE20
   cp $NAMRFA fort.4
   cp BC_${COUPDATE}_${COUPRUN} LBC
#   /home/hamdi/aladin/pack/test/bin/FAREPLACE
   mv LBC ELSCF${EXP}ALBC${CPLNR}

 
  let CPLNR=10#$CPLNR+1
#++++++++++++++++++++++++ typeset -Z3 CPLNR ++++++++++++++
  if [[ $CPLNR -le 9 ]]
  then
  CPLNR=00${CPLNR}
  else
  CPLNR=0${CPLNR}
  fi  
  

  if [ $COUPRUN == 18 ] 
  then
    rm -f BC_* 
    COUPRUN=00
    COUPDATE=`$DECDATE $COUPDATE +1`
    COUPYEAR=`echo $COUPDATE | cut -c1-4`

    scp $REMOTE:$COUPLING/$COUPYEAR/${COUPEXP}_${COUPDATE}.tar .
    tar -xvf ${COUPEXP}_${COUPDATE}.tar
    else
    let COUPRUN=10#$COUPRUN+6

#++++++++++++++++++++++++ typeset -Z2 COUPRUN ++++++++++++++
    if [[ $COUPRUN -le 9 ]]
     then
     COUPRUN=0${COUPRUN}
    fi


  fi

done
rm -f BC*

}

#++++++++++++++++++++++++++++++++++++++++++++++++++ Forecast +++++++++++++++++++++++++++++

DATE={startdate}

. $ENV


YYYY=`echo $DATE | cut -c1-4`
MM=`echo $DATE | cut -c5-6`
DD=`echo $DATE | cut -c7-8`


if [[ ! -d $WORKDIR/$YYYY/$MM/$DD/r$RUNSTART ]]
then
mkdir -p $WORKDIR/$YYYY/$MM/$DD/r$RUNSTART
fi

rm -f $WORKDIR/$YYYY/$MM/$DD/r$RUNSTART/*
cd $WORKDIR/$YYYY/$MM/$DD/r$RUNSTART

pwd 
ls



### first we get the coupling files from the archive
 
 get_coupling $DATE ${RUNSTART} $EXP


### read climate value cencentration 
 
cp $NAMCLIM/GHG_RCP45.dat .

awk '{if ($1 == "'$YYYY'") {printf($0);}}' GHG_RCP45.dat > RCP45_$YYYY.dat
#grep "$YYYY   " GHG_RCP85.dat > RCP85_$YYYY.dat

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


### and now we actually run ALADIN:
  echo 'echo MONITOR: $* >&2' >monitor.needs
  chmod +x monitor.needs

  ln -sf ELSCF${EXP}ALBC000 ICMSH${EXP}INIT

#### forecast run -------

  cp $NAMSFX .

  cat $NAM001  | grep -v '^!' | sed -e "s/!.*//" \
                                   -e "s/{cnmexp}/$EXP/" \
                                   -e "s/{neini}/2/" \
                                   -e "s/{lsprt}/.F./" \
                                   -e "s/{cfpath}/ICMSH/" \
                                   -e "s/{yyyymmdd}/${YYYY}${MM}${DD}/" \
                                   -e "s/{sssss}/$(( ${RUNSTART}*3600 ))"/ \
                                   -e "s/{rcco2}/${RCCO2}e-06/" \
                                   -e "s/{rcch4}/${RCCH4}e-09/" \
                                   -e "s/{rcn2o}/${RCN2O}e-09/" \
                                   -e "s/{rccfc11}/${RCCFC11}e-12/" \
                                   -e "s/{rccfc12}/${RCCFC12}e-12/" \
                                   -e "s/{rio}/${RIO}/" \
                                   -e "s/{nproc}/${NPROC}/" > fort.4  
# set environment
source ${ENVDIR}/ENV_ALADIN

# Bring executable binary
ln -sf $MASTER ./master

ls -al

  mpiexec_mpt -np ${NPROC} ./master -e$EXP -vmeteo -c001 -maladin -t$TSTEP -fh${RUNLENGTH} > log.out 2>log.err

OK=$?
echo run succeeded: $OK

### Save output to the archive

  NEXTDATE=`/home/julieb/bin/decdate $DATE +$DAYINCREMENT`

  YYYY=`echo $NEXTDATE | cut -c1-4`
  MM=`echo $NEXTDATE | cut -c5-6`
  DD=`echo $NEXTDATE | cut -c7-8`
  ARCHIVE=$SAVEDIR/$YYYY
#  ARCHIVEANDY=$SAVEDIRANDY/$YYYY

#  tar -cvf $YYYY$MM$DD.tgz AROMOUT_.0024.lfi ICMSHBE20+*  
  tar -cvf $YYYY$MM$DD.tar AROMOUT_.0018.lfi ICMSHBE20+*
 # tar -cvf $YYYY$MM$DD.tar AROMOUT_.0024.lfi 
  ssh $REMOTE mkdir -p -m 775 $ARCHIVE 
  scp $YYYY$MM$DD.tar $REMOTE:$ARCHIVE/$YYYY$MM$DD.tar

#   mkdir -p -m 775 $ARCHIVE 
#   cp $YYYY$MM$DD.tgz $ARCHIVE/$YYYY$MM$DD.tgz
  tmp=/home/heheuili/CMIP5/LFI/script
  ksh $tmp/kick_LFI_12km_RCP45_future $STARTDATE $NEXTDATE $DAYINCREMENT  

  if [ $NEXTDATE -le $STOPDATE ] 
  then
   ksh $ERADIR/script/kick_RCP45_FS_50km_future_2020 $NEXTDATE $STOPDATE $YEAR $DAYINCREMENT 
#  ksh $ERADIR/script/kick_RCP85_FS_50km $NEXTDATE $STOPDATE $YEAR $DAYINCREMENT

  fi 

  YYYY=`echo $DATE | cut -c1-4`
  MM=`echo $DATE | cut -c5-6`
  DD=`echo $DATE | cut -c7-8`
#  rm -rf $WORKDIR/$DATE 





