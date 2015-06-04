%% IE pulse, with springs, higher amplitude (2.5/5)
comments = 'IE pulse, with springs, higher amplitude';

csvFile = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\june2\Take 2015-06-02 11.52.56 AM.csv';
lvmFile = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\june2\raw.lvm';

plateIndex = 47;
rSheenIndex = 3;
rFootIndex = 25;

offsetPlate = -HiRoLab.centroid4Markers;

test1 = struct( 'csvFile', csvFile, 'lvmFile', lvmFile, 'plateIndex', plateIndex, ...
    'rSheenIndex', rSheenIndex, 'rFootIndex', rFootIndex, 'comments', comments, ...
    'offsetPlate', offsetPlate );

%% IE pulse, with springs, higher amplitude (2.5/5)
comments = 'IE pulse, with springs, higher amplitude';

csvFile = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\june2\Take 2015-06-02 12.10.29 AM.csv';
lvmFile = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\june2\raw_1.lvm';

plateIndex = 47;
rSheenIndex = 3;
rFootIndex = 25;

offsetPlate = -HiRoLab.centroid4Markers;

test1 = struct( 'csvFile', csvFile, 'lvmFile', lvmFile, 'plateIndex', plateIndex, ...
    'rSheenIndex', rSheenIndex, 'rFootIndex', rFootIndex, 'comments', comments, ...
    'offsetPlate', offsetPlate );

%%
%% IE pulse, with springs, higher amplitude (2.5/5)
comments = 'IE pulse, with springs, higher amplitude';

csvFile = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\may18\Take 2015-05-18 03.10.10 PM.csv';
lvmFile = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\may18\raw_8.lvm';

plateIndex = 3;
rSheenIndex = 10;
rFootIndex = 3;

offsetPlate = -HiRoLab.centroid3Markers;

test1 = struct( 'csvFile', csvFile, 'lvmFile', lvmFile, 'plateIndex', plateIndex, ...
    'rSheenIndex', rSheenIndex, 'rFootIndex', rFootIndex, 'comments', comments, ...
    'offsetPlate', offsetPlate );

%% DP pulse, with springs, higher amplitude (2.5/5)
%{
csvPath = 'C:\Users\rastgaar\Desktop\may18\Take 2015-05-18 03.06.19 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\may18\raw_7.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% Random input with springs, higher amplitude (2.5/5)
%{
csvPath = 'C:\Users\rastgaar\Desktop\may18\Take 2015-05-18 03.03.13 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\may18\raw_6.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% Random input, higher amplitude (2.5/5)
%{
csvPath = 'C:\Users\rastgaar\Desktop\may18\Take 2015-05-18 02.39.56 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\may18\raw_5.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% Random input, higher amplitude (2.5/5)
%{
csvPath = 'C:\Users\rastgaar\Desktop\may18\Take 2015-05-18 02.26.22 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\may18\raw_4.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% Pulse-Train DP try 2, higher amplitude (2.5/5)
%{
csvPath = 'C:\Users\rastgaar\Desktop\may18\Take 2015-05-18 02.02.00 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\may18\raw_3.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% Pulse-Train IE try 2, higher amplitude (2.5/5)
%{
csvPath = 'C:\Users\rastgaar\Desktop\may18\Take 2015-05-18 01.58.22 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\may18\raw_2.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% Pulse-Train DP try 1, amplitude 1.5/5
%{
csvPath = 'C:\Users\rastgaar\Desktop\may18\Take 2015-05-18 01.23.52 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\may18\raw_1.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 10;
col.rSheen = 3;
col.rFoot = 10;
%}

%% Manual-Static DP, preload = 430 N
%{
csvPath = 'C:\Users\rastgaar\Desktop\may12\Take 2015-05-12 01.43.16 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\may12\raw_2.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% Manual-Static DP, preload = 430 N
%
comments = 'Manual-Static DP, preload = 430 N';

csvFile = 'C:\Users\rastgaar\Desktop\may12\Take 2015-05-12 12.15.01 AM.csv';
lvmFile = 'C:\Users\rastgaar\Desktop\may12\raw_1.lvm';

plateIndex = 3;
rSheenIndex = 19;
rFootIndex = 3;

offsetPlate = -HiRoLab.centroid3Markers;

test2 = struct( 'csvFile', csvFile, 'lvmFile', lvmFile, 'plateIndex', plateIndex, ...
    'rSheenIndex', rSheenIndex, 'rFootIndex', rFootIndex, 'comments', comments, ...
    'offsetPlate', offsetPlate );
%}

%% Quasi-Static DP, preload = 430 N
%{
csvPath = 'C:\Users\rastgaar\Desktop\may12\Take 2015-05-12 11.58.38 AM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\may12\raw.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 19;
col.rFoot = 3;
%}

%% Static test 8 May
%{
csvPath = 'C:\Users\rastgaar\Desktop\may8\Take 2015-05-08 03.12.11 PM.csv';

col.frame = 1;
col.time = 2;
col.plate = 30;
col.rSheen = 3;
col.rFoot = 30;
%}

%% Evandro 21 April, regular, 155 mm, 24.9* V, suit
%
comments = 'IE pulse, with springs, higher amplitude';

csvFile = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\test21April\Take 2015-04-21 03.53.11 PM(1).csv';
lvmFile = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\test21April\raw_9.lvm';

plateIndex = 150;
rSheenIndex = 122;
rFootIndex = 129;

offsetPlate = -HiRoLab.centroid3Markers;

test1 = struct( 'csvFile', csvFile, 'lvmFile', lvmFile, 'plateIndex', plateIndex, ...
    'rSheenIndex', rSheenIndex, 'rFootIndex', rFootIndex, 'comments', comments, ...
    'offsetPlate', offsetPlate );
%}

%% Evandro 21 April, regular, 155 mm, 24.9* V, markers strongly connect
%{
csvPath = 'C:\Users\rastgaar\Desktop\test21April\Take 2015-04-21 03.39.07 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test21April\raw_7.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% Evandro 21 April, regular, 155 mm, 24.9* V, back against fence
%{
csvPath = 'C:\Users\rastgaar\Desktop\test21April\Take 2015-04-21 03.30.23 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test21April\raw_5.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% Evandro 21 April, regular, 155 mm, 24.9* V, more tape! No support
%{
csvPath = 'C:\Users\rastgaar\Desktop\test21April\Take 2015-04-21 03.18.23 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test21April\raw_4.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% Evandro 21 April, regular, 155 mm, 24.9* V, more tape!
%{
csvPath = 'C:\Users\rastgaar\Desktop\test21April\Take 2015-04-21 03.11.06 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test21April\raw_3.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% Evandro 21 April, regular, 155 mm, 24.9* V, more tape! GOOOD!
%{
csvPath = 'C:\Users\rastgaar\Desktop\test21April\Take 2015-04-21 02.58.38 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test21April\raw_2.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% Evandro 21 April, regular, 155 mm, 24.9* V, more tape!
%{
csvPath = 'C:\Users\rastgaar\Desktop\test21April\Take 2015-04-21 02.37.38 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test21April\raw_1.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% Evandro 8 April, regular, 152.0 mm, 25.25 V, more tape!
%{
csvPath = 'C:\Users\rastgaar\Desktop\test8April\Take 2015-04-08 01.20.44 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test8April\raw_2.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% Evandro 8 April, regular, 152.0 mm, 25.25 V
%{
csvPath = 'C:\Users\rastgaar\Desktop\test8April\Take 2015-04-08 01.06.10 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test8April\raw_1.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% Evandro 8 April, regular, 152.6 mm, 25.25 V
%{
csvPath = 'C:\Users\rastgaar\Desktop\test8April\Take 2015-04-08 12.51.54 AM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test8April\raw.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, regular, 151 mm, 25.27 V
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 06.28.17 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_14.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, regular, 158 mm, 25.27 V
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 06.17.54 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_13.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, regular, 153 mm, 25.27 V
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 06.10.41 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_12.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, regular, 156 mm, 25.27 V
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 06.05.53 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_11.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, 300, medium load
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 05.31.51 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_10.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, 300, medium load.
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 05.20.58 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_9.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, 300, medium load. rotated
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 05.06.29 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_6.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, 300, high load. rotated. non-reset
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 04.31.13 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_3.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, 300, high load. rotated. reset
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 04.33.27 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_4.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, 300, high load
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 04.15.57 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_2.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April, slow
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 03.32.12 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw_1.lvm';

f = 180;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 7 April
%{
csvPath = 'C:\Users\rastgaar\Desktop\test7April\Take 2015-04-07 03.01.04 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test7April\raw.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 6 April, anti-friction
%{
csvPath = 'C:\Users\rastgaar\Desktop\test6April\Take 2015-04-06 12.19.58 AM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test6April\raw.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 3 April, final 2, Euler
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 04.33.38 PM(1).csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_16.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 9;
col.rFoot = 3;
%}

%% mockup 3 April, final 2
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 04.33.38 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_16.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 3 April, final
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 04.33.38 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_16.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% mockup 3 April, final
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 04.29.19 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_15.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 3 April, recalibrated 4 centered
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 04.13.58 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_13.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 3 April, recalibrated 4 centered
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 03.55.14 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_10.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 3 April, recalibrated 4 centered
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 03.49.34 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_8.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 3 April, recalibrated 3
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 03.37.39 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_7.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 3 April, recalibrated 2
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 03.29.41 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_7.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup 3 April, recalibrated
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 02.36.08 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_3.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% mockup 3 April, centered
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 02.17.53 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_2.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% mockup 3 April, mid tension
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 01.53.45 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw_1.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% mockup 3 April, high tension
%{
csvPath = 'C:\Users\rastgaar\Desktop\test3April\Take 2015-04-03 01.46.10 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test3April\raw.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% Evandro 2 April, support
%{
csvPath = 'C:\Users\rastgaar\Desktop\test2April\Take 2015-04-02 03.24.49 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test2April\raw_9.lvm';

f = 360;
fPlate = 7200;


col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% Evandro 20 March
%{
csvPath = 'C:\Users\rastgaar\Desktop\test hope\Take 2015-03-20 01.40.51 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test hope\test.lvm';

f = 300;
fPla = 1500;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 27;
col.rFoot = 47;

%lvTable = readtable(lvFile, 'ReadRowNames', false, 'Delimiter', ',', 'HeaderLines', 22);

% dateMask = [0 0 0 60*60 60 1];
% tPlate0 = datevec('13:40:36.6218311500199214951') * dateMask';
%}

%% Evandro 25 March
%{
csvPath = 'C:\Users\rastgaar\Desktop\testUnited\Take 2015-03-25 01.39.41 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\testUnited\spring_test_withoutspring_25.lvm';

f = 300;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 27;
col.rFoot = 47;

%}

%% Evandro 1 April
%{
csvPath = 'C:\Users\rastgaar\Desktop\test1Aprilb\Take 2015-04-01 05.13.06 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test1Aprilb\raw_5.lvm';

f = 360;
fPlate = 7200;


col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% Evandro 1 April, No support
%{
csvPath = 'C:\Users\rastgaar\Desktop\test1Aprilb\Take 2015-04-01 05.15.09 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test1Aprilb\raw_6.lvm';

f = 360;
fPlate = 7200;


col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 17;
%}

%% mockup Random 2
%{
csvPath = 'C:\Users\rastgaar\Desktop\test1Aprilb\Take 2015-04-01 04.43.53 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test1Aprilb\raw_4.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup Random
%
comments = 'IE pulse, with springs, higher amplitude';

csvFile = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\test1April\Take 2015-04-01 01.45.11 PM.csv';
lvmFile = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\test1April\raw.lvm';

plateIndex = 3;
rSheenIndex = 10;
rFootIndex = 3;

offsetPlate = -HiRoLab.centroid3Markers;

test1 = struct( 'csvFile', csvFile, 'lvmFile', lvmFile, 'plateIndex', plateIndex, ...
    'rSheenIndex', rSheenIndex, 'rFootIndex', rFootIndex, 'comments', comments, ...
    'offsetPlate', offsetPlate );
%}

%% mockup Random rotated 2
%
csvPath = 'C:\Users\rastgaar\Desktop\test1Aprilb\Take 2015-04-01 04.21.01 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test1Aprilb\raw_3.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% mockup Random rotated
%{
csvPath = 'C:\Users\rastgaar\Desktop\test1Aprilb\Take 2015-04-01 03.56.15 PM.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test1Aprilb\raw_1.lvm';

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;
%}

%% Mockup static DP
%{
csvPath = 'C:\Users\rastgaar\Desktop\test1April\dp.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test1April\raw_1.lvm';

tPlate0 = 03.7722908833529187655;
tCam0 = 08.358;
T = 10;

tCamSpan = tCam0 + [0 T-0];

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;


%}

%% Mockup static IE
%{
csvPath = 'C:\Users\rastgaar\Desktop\test1April\ie.csv';
lvFileOriginal = 'C:\Users\rastgaar\Desktop\test1April\raw_2.lvm';

tPlate0 = 10.5041077833530576291;
tCam0 = 16.463;
T = 10;

f = 360;
fPlate = 7200;

col.frame = 1;
col.time = 2;
col.plate = 3;
col.rSheen = 10;
col.rFoot = 3;

%}