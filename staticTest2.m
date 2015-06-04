%% Static test of DP angle impedace
% Possible problems: no shear force, initial angle wasn't 0, preload

%% test 1
ang1 = -atan( [[70.99 70.87 70.87 68.31 68.21 68.27] - 70.91] / 250 );
tor1 = 26.797*0.453592*9.81*[ 0 0 0 .24 .24 .24 ];

mdl1 = fitlm( ang1, tor1 )

mdl1.plot
xlabel('angle [rad]'); ylabel('torque [N*m]')
title(['Dorsi-Plantar. Stiffness = ' num2str( mdl1.Coefficients.Estimate(2) ) ' N*m/rad'])

%% test 2
% foot moved slighly
ang2 = -atan( [[70.25 70.18 70.23 68.55 68.51 68.54] - 70.2200] / 250 );
tor2 = 26.797*0.453592*9.81*[ 0 0 0 .1275 .1275 .1275 ];

mdl2 = fitlm( ang2, tor2 )

mdl2.plot
xlabel('angle [rad]'); ylabel('torque [N*m]')
title(['Dorsi-Plantar. Stiffness = ' num2str( mdl2.Coefficients.Estimate(2) ) ' N*m/rad'])

%% test 3
% increased pre-load
ang3 = -atan( ([85.56 85.40 85.45 82.93 82.73 82.70 84.25 83.92 84.14 85 84.55 84.47] - 85.4700) / 250 );
tor3 = 26.797*0.453592*9.81*[ 0 0 0 .242 .242 .242 .153 .153 .153 .089 .089 .089 ];

mdl3 = fitlm( ang3, tor3 )

mdl3.plot
xlabel('angle [rad]'); ylabel('torque [N*m]')
title(['Dorsi-Plantar. Stiffness = ' num2str( mdl3.Coefficients.Estimate(2) ) ' N*m/rad'])

%% test4

csvPath = 'C:\Users\rastgaar\Desktop\may8\Take 2015-05-08 03.12.11 PM.csv';
%csvPath = 'C:\Users\rastgaar\Desktop\may8\Take 2015-05-08 03.40.52 PM.csv';

col.frame = 1;
col.time = 2;
col.plate = 27;
col.rSheen = 3;
col.rFoot = 27;

fid = fopen(csvPath);
tline = fgets(fid);
tmp = strsplit( tline, ',' );
date2 = tmp{10};
dateMask = [0 0 0 60*60 60 1];
tCam0 = datevec(date2, 'yyyy-mm-dd HH.MM.SS.FFF PM') * dateMask';
fclose(fid);

pos = [4 5 6];
qua = [3 0 1 2];
eul = [0 1 2];
pose = [3 4 5];

camTable = readtable(csvPath, 'HeaderLines', 6);

rows = 1 : size(camTable,1);

time = camTable{rows,col.time};
[Pplate, Qplate] = deal( camTable{rows,pos+col.plate}, camTable{rows,qua+col.plate} );
[Psheen, Qsheen] = deal( camTable{rows,pos+col.rSheen}, camTable{rows,qua+col.rSheen} );
[Pfoot, Qfoot] = deal( camTable{rows,pos+col.rFoot}, camTable{rows,qua+col.rFoot} );

A = 0.472156000000000 / 2;
B = 0.270108000000000 / 2;
Pplate = Pplate - quatrotate( quatinv(Qplate), [A/3 0 -B/3] );

[r1,r2,r3] = quat2angle( Qplate, 'YZX' );
r2 = -r2;

reselect = false;
if reselect
    region = {'zero', 'close', 'mid', 'far'};
    figure; plot( (r2)*180/pi )
    rect = [];
    for n = 1 : 4
        title(['Mark ' region{n}])
        rect(n,:) = getrect();
    end
    close
else
    rect = 1e4 * [ ...
   0.001152073732719  -0.000013436268068   0.163594470046083   0.000015177398160
   0.508064516129032   0.000006340341656   0.195852534562212   0.000011957950066
   1.206221198156682   0.000013699080158   0.216589861751152   0.000018856767411
   2.185483870967742   0.000042214191853   0.301843317972350   0.000020236530880 ];
end

width = round( min( rect(:,3) ) );
ang4 = [];
for n = 1 : 4
    rows = round(rect(n,1)) : round(rect(n,1)+width-1);
    ang4 = [ ang4 r2(rows)' ];
end

tor4 = reshape( repmat( 26.797*0.453592*9.81*[ 0 .089 .153 .242 ], [width 1] ), [4*width 1] )';

mdl4 = fitlm( ang4, tor4, 'RobustOpts','on')
mdl4.plot
xlabel('angle [rad]'); ylabel('torque [N*m]')
title(['Dorsi-Plantar. Stiffness = ' num2str( mdl4.Coefficients.Estimate(2) ) ' N*m/rad'])

%% test5

clear
csvPath = 'C:\Users\rastgaar\Desktop\may12\Take 2015-05-12 12.15.01 AM.csv';
%csvPath = 'C:\Users\rastgaar\Desktop\may8\Take 2015-05-08 03.40.52 PM.csv';

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 19;
col.rFoot = 3;

fid = fopen(csvPath);
tline = fgets(fid);
tmp = strsplit( tline, ',' );
date2 = tmp{10};
dateMask = [0 0 0 60*60 60 1];
tCam0 = datevec(date2, 'yyyy-mm-dd HH.MM.SS.FFF PM') * dateMask';
fclose(fid);

% noon singularity
tCam0 = tCam0 + 12*60*60;

pos = [4 5 6];
qua = [3 0 1 2];
eul = [0 1 2];
pose = [3 4 5];

camTable = readtable(csvPath, 'HeaderLines', 6);

rows = 1 : size(camTable,1);

time = camTable{rows,col.time};
[Pplate, Qplate] = deal( camTable{rows,pos+col.plate}, camTable{rows,qua+col.plate} );
[Psheen, Qsheen] = deal( camTable{rows,pos+col.rSheen}, camTable{rows,qua+col.rSheen} );
[Pfoot, Qfoot] = deal( camTable{rows,pos+col.rFoot}, camTable{rows,qua+col.rFoot} );

A = 0.472156000000000 / 2;
B = 0.270108000000000 / 2;
Pplate = Pplate - quatrotate( quatinv(Qplate), [A/3 0 -B/3] );

[r1,r2,r3] = quat2angle( Qplate, 'YZX' );
r2 = r2;

reselect = false;
if reselect
    region = {'zero', 'close', 'mid', 'far'};
    figure; plot( (r2)*180/pi )
    rect = [];
    for n = 1 : 4
        title(['Mark ' region{n}])
        rect(n,:) = getrect();
    end
    close
else
    rect = 1e4 * [ ...
   0.003456221198157   0.000040880420499   0.069124423963134   0.000012063074901
   0.331105990783410   0.000029763469120   0.331797235023042   0.000018922470434
   0.859216589861752   0.000029053876478   0.139631336405530   0.000012536136662
   1.491013824884793  -0.000023455978975   0.069124423963133   0.000009934296978 ];
end

width = round( min( rect(:,3) ) );
ang4 = [];
for n = 1 : 4
    rows = round(rect(n,1)) : round(rect(n,1)+width-1);
    ang4 = [ ang4 r2(rows)' ];
end

tor4 = reshape( repmat( 26.797*0.453592*9.81*[ 0 0.068 0.13 0.2 ], [width 1] ), [4*width 1] )';

mdl4 = fitlm( ang4, tor4, 'RobustOpts','on')
mdl4.plot
xlabel('angle [rad]'); ylabel('torque [N*m]')
title(['Dorsi-Plantar. Stiffness = ' num2str( mdl4.Coefficients.Estimate(2) ) ' N*m/rad'])

%% test 6

clear
csvPath = 'C:\Users\rastgaar\Desktop\may12\Take 2015-05-12 01.43.16 PM.csv';
%csvPath = 'C:\Users\rastgaar\Desktop\may8\Take 2015-05-08 03.40.52 PM.csv';

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;

fid = fopen(csvPath);
tline = fgets(fid);
tmp = strsplit( tline, ',' );
date2 = tmp{10};
dateMask = [0 0 0 60*60 60 1];
tCam0 = datevec(date2, 'yyyy-mm-dd HH.MM.SS.FFF PM') * dateMask';
fclose(fid);

% noon singularity
%tCam0 = tCam0 + 12*60*60;

pos = [4 5 6];
qua = [3 0 1 2];
eul = [0 1 2];
pose = [3 4 5];

camTable = readtable(csvPath, 'HeaderLines', 6);

rows = 1 : size(camTable,1);

time = camTable{rows,col.time};
[Pplate, Qplate] = deal( camTable{rows,pos+col.plate}, camTable{rows,qua+col.plate} );
[Psheen, Qsheen] = deal( camTable{rows,pos+col.rSheen}, camTable{rows,qua+col.rSheen} );
[Pfoot, Qfoot] = deal( camTable{rows,pos+col.rFoot}, camTable{rows,qua+col.rFoot} );

A = 0.472156000000000 / 2;
B = 0.270108000000000 / 2;
Pplate = Pplate - quatrotate( quatinv(Qplate), [A/3 0 -B/3] );

[r1,r2,r3] = quat2angle( Qplate, 'YZX' );
r2 = r2;

reselect = false;
if reselect
    region = {'zero', 'close', 'mid', 'far'};
    figure; plot( (r2)*180/pi )
    rect = [];
    for n = 1 : 4
        title(['Mark ' region{n}])
        rect(n,:) = getrect();
    end
    close
else
    rect = 1e4 * [ ...
   0.010944700460830  -0.000155716162943   0.063364055299539   0.000022076215506
   0.399193548387097  -0.000165177398160   0.114055299539171   0.000011038107753
   0.824308755760369  -0.000197503285151   0.125576036866360   0.000031537450723
   1.227534562211981  -0.000239290407359   0.131336405529954   0.000029172141919 ];

end

width = round( min( rect(:,3) ) );
ang4 = [];
for n = 1 : 4
    rows = round(rect(n,1)) : round(rect(n,1)+width-1);
    ang4 = [ ang4 r2(rows)' ];
end

tor4 = reshape( repmat( 26.797*0.453592*9.81*[ 0 0.068 0.13 0.2 ], [width 1] ), [4*width 1] )';

N = size( tor4, 2 );
ang4( round(N/4) : round(N/2) ) = [];
tor4( round(N/4) : round(N/2) ) = [];

mdl4 = fitlm( ang4, tor4, 'RobustOpts','on')
mdl4.plot
xlabel('angle [rad]'); ylabel('torque [N*m]')
title(['Dorsi-Plantar. Stiffness = ' num2str( mdl4.Coefficients.Estimate(2) ) ' N*m/rad'])

%% test IE

clear
csvPath = 'C:\Users\rastgaar\Desktop\may13\Take 2015-05-13 01.05.45 PM.csv';
%csvPath = 'C:\Users\rastgaar\Desktop\may8\Take 2015-05-08 03.40.52 PM.csv';

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;

fid = fopen(csvPath);
tline = fgets(fid);
tmp = strsplit( tline, ',' );
date2 = tmp{10};
dateMask = [0 0 0 60*60 60 1];
tCam0 = datevec(date2, 'yyyy-mm-dd HH.MM.SS.FFF PM') * dateMask';
fclose(fid);

% noon singularity
%tCam0 = tCam0 + 12*60*60;

pos = [4 5 6];
qua = [3 0 1 2];
eul = [0 1 2];
pose = [3 4 5];

camTable = readtable(csvPath, 'HeaderLines', 6);

rows = 1 : size(camTable,1);

time = camTable{rows,col.time};
[Pplate, Qplate] = deal( camTable{rows,pos+col.plate}, camTable{rows,qua+col.plate} );
[Psheen, Qsheen] = deal( camTable{rows,pos+col.rSheen}, camTable{rows,qua+col.rSheen} );
[Pfoot, Qfoot] = deal( camTable{rows,pos+col.rFoot}, camTable{rows,qua+col.rFoot} );

A = 0.472156000000000 / 2;
B = 0.270108000000000 / 2;
Pplate = Pplate - quatrotate( quatinv(Qplate), [A/3 0 -B/3] );

[r1,r2,r3] = quat2angle( Qplate, 'YZX' );
r3 = r3;

clear r1 r2

reselect = true;
region = {'zero', 'far+', 'far-'};
% region = {'zero', 'far+', 'far-'};
% region = {'zero', 'far+'};
% region = {'zero', 'close+', 'close-'};
if reselect
    figure; plot( (r3)*180/pi )
    rect = [];
    for n = 1 : size(region,2)
        title(['Mark ' region{n}])
        rect(n,:) = getrect();
    end
    close
else
    rect = 1e4 * [ ...
   0.032398316970547   0.000167611336032   0.041234221598878   0.000012955465587
   0.615568022440393   0.000192226720648   0.107994389901823   0.000015870445344
   1.153576437587658   0.000119676113360   0.098176718092567   0.000018137651822 ];

end

width = round( min( rect(:,3) ) );
ang4 = [];
for n = 1 : size(region,2)
    rows = round(rect(n,1)) : round(rect(n,1)+width-1);
    ang4 = [ ang4 r3(rows)' ];
end

%tor4 = reshape( repmat( 25*0.453592*9.81*[ 0 14.5 6 -5.5 -13 ]/100, [width 1] ), [size(region,2)*width 1] )';
%tor4 = reshape( repmat( 26.797*0.453592*9.81*[ 0 14.5 -13 ]/100, [width 1] ), [size(region,2)*width 1] )';
%tor4 = reshape( repmat( 26.797*0.453592*9.81*[ 0 14.5 ]/100, [width 1] ), [size(region,2)*width 1] )';
tor4 = reshape( repmat( 12.0742*0.453592*9.81*[ 0 14 -14]/100, [width 1] ), [size(region,2)*width 1] )';

% N = size( tor4, 2 );
% ang4( round(N/4) : round(N/2) ) = [];
% tor4( round(N/4) : round(N/2) ) = [];

mdl4 = fitlm( ang4, tor4, 'RobustOpts','on')
figure; mdl4.plot
xlabel('angle [rad]'); ylabel('torque [N*m]')
title(['Inversion-Eversion. Stiffness = ' num2str( mdl4.Coefficients.Estimate(2) ) ' N*m/rad'])