#!/bin/bash
#PBS -S /bin/bash
#PBS -l walltime=00:30:00
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -o /home/heheuili/pgd.log
#PBS -N PGD
#
#


set -x

ulimit -s unlimited

ECOCLIMAP=/home/heheuili/ECOCLIMAP
mkdir /scratch-a/heheuili/PGD_Aral_Caspian/2015_10km
cd /scratch-a/heheuili/PGD_Aral_Caspian/2015_10km


#
#
#    " copie des bases de donnees "
#
cp $ECOCLIMAP/clay_fao.dir      clay_fao.dir
cp $ECOCLIMAP/clay_fao.hdr      clay_fao.hdr
cp $ECOCLIMAP/sand_fao.dir      sand_fao.dir
cp $ECOCLIMAP/sand_fao.hdr      sand_fao.hdr
#
cp $ECOCLIMAP/future.dir         ecoclimap.dir
#cp $ECOCLIMAP/ecoclimap_v1_XJ1.dir           ecoclimap.dir
cp $ECOCLIMAP/ECOCLIMAP_I_GLOBAL.hdr     ecoclimap.hdr
cp $ECOCLIMAP/gtopo30.dir           gtopo30.dir
cp $ECOCLIMAP/gtopo30.hdr           gtopo30.hdr
#
#    " copie de la namelist"
##NDLUX here with NIMAX
cat << FIN > OPTIONS.nam
&NAM_IO_OFFLINE
CSURF_FILETYPE=  'LFI'
CPGDFILE='PGD_2015_2L_10km_emap_future'
/
&NAM_PGD_GRID
CGRID = 'CONF PROJ '
/
&NAM_CONF_PROJ
XLAT0=44,
XLON0=56,
XRPK=0.6946583704589973,
XBETA=0.00,               
/
&NAM_CONF_PROJ_GRID
XLONCEN=56,
XLATCEN=44,
NIMAX=200,   
NJMAX=200,
XDX=10000.,
XDY=10000.,
/
&NAM_FRAC
LECOCLIMAP=.TRUE.
/
&NAM_PGD_ARRANGE_COVER
LTOWN_TO_ROCK=.FALSE.
/
&NAM_COVER
YCOVER='ecoclimap',
YFILETYPE='DIRECT'
/
&NAM_ZS
YZS='gtopo30',
YFILETYPE='DIRECT'
/
&NAM_PGD_SCHEMES
CTOWN='TEB'
/
&NAM_WATFLEX
/
&NAM_ISBA
YCLAY='clay_fao',
YCLAYFILETYPE='DIRECT',
YSAND='sand_fao',
YSANDFILETYPE='DIRECT',
CISBA='2-L',
/
FIN
#
#    " copie de l'executable "
#
ln -s /home/hamdi/aladin/pack/cy36/bin/PGD.peng2 pgd.exe

#
./pgd.exe
#
ls -l
#
cat *LISTING*
#
#cp PGD* /home/hamdi/ALARO-0/PGD/pgdfile
#cp class_cover_data.tex /home/hamdi/ALARO-0/PGD/pgdfile   
#
