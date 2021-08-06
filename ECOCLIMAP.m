%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Created by HHL to replace the land use/land cover in default ECOCLIMAP %%
%%  -- 20 April 2019                                                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

bnrdir = 'I:/HHL';

%% Domain

Lat_North= 60;
Lat_South= 32; 

Lon_West=  40;
Lon_East=  90;

%compute boundaries of area of interest
BoundNo=floor((90.0-Lat_North)*120);
BoundSo=floor((90.0-Lat_South)*120);
BoundWe=floor((180.0+Lon_West)*120);
BoundEa=floor((180.0+Lon_East)*120);


file1 = sprintf('%s\\ECOCLIMAP_v2.dir',bnrdir);
fid=fopen(file1,'r');
Orig=fread(fid,[120*360 120*180],'uint8');
fclose(fid);
Orig11 = Orig(BoundWe:BoundEa,BoundNo:BoundSo);

% Load the XIEGLUC
file_lucc = 'I:/HHL/CA_LULC/.tif';
lucc = imread(file_lucc);
lucc_1 = lucc';
lucc_T = lucc_1;

[m n]=size(lucc_T);

lucc_new = Orig11;
% Replace the land cover
for i = 1:m
    for j = 1:n
      Orig11(i,j)=lucc_1(i,j);
    end
end

figure; image(lucc_new','cdatamapping','scaled'); colorbar('v')

% output the result to check 
R = georasterref('RasterInterpretation','cells');
R.RasterSize= [n m]; %lat lon
R.LatitudeLimits = [Lat_South Lat_North];
R.LongitudeLimits= [Lon_West Lon_East];

R.ColumnsStartFrom='north';
R.RowsStartFrom='west';
outpath = 'J:\HHL\ECOCLIMAP\Output';
filename = sprintf('%s\\CA_LUCC_1970s_output',outpath);
geotiffwrite(filename,lucc_new',R)


%% write out the new land cover

Orig(BoundWe:BoundEa,BoundNo:BoundSo) = Orig11;

outbnr = 'J:\HHL\ECOCLIMAP\Output';
file_out=sprintf('%s\\ECOCLIMAP_1970s.dir',outbnr);
fid=fopen(file_out,'wb');
fwrite(fid,Orig,'uint8');
fclose(fid);
