clear; clc


dataFolder = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests\';
% dataFolder = '/home/garamizo/Downloads/';
% dataFolder = 'C:\Users\rastgaar\Desktop\';

nFiles = 4;

% load files
for n = 1 : nFiles
    tests(n) = ZTools.loadTest();
    %tests(n) = ZTools.createTest(dataFolder);
end
%%
for n = 1 : nFiles
    test = tests(n);
    
[tblCam, headerCam] = ZTools.readCSV( [dataFolder test.csvFile] );
[tblPlate, headerPlate] = ZTools.readLVM( [dataFolder test.lvmFile] );

camTableClean = ZTools.fillGaps( tblCam, 3 );

[tblCamSync, tblPlateSync, t, f, t0] = ZTools.synchronizeTables( camTableClean, headerCam.t0, headerCam.fs, tblPlate, headerPlate.t0, headerPlate.fs );

[Pplate,Qplate] = ZTools.extractBody( tblCamSync, headerCam, test.plateAlias );
[Pshin,Qshin] = ZTools.extractBody( tblCamSync, headerCam, test.rShinAlias );
[Pfoot,Qfoot] = ZTools.extractBody( tblCamSync, headerCam, test.rFootAlias );
Pplate = Pplate + quatrotate( quatinv(Qplate), -[test.plateCentroidX test.plateCentroidY test.plateCentroidZ] );

[z1, z2, z3, z4, x12, x34, y14, y23] = ZTools.parsePlateTable( tblPlateSync );

rows = sqrt(sum((Pfoot - Pplate).^2,2)) < 1 ...
    & ( t > t(end)/10 & t < t(end)*9/10 ) ...
    & ~any(isnan([Qfoot Qshin Pfoot Pshin]),2);
%rows = t > t(1)+3 & t < t(end)-3;

[rs, rf] = ZTools.calculateJointPosition( Pshin(rows,:), Qshin(rows,:), Pfoot(rows,:), Qfoot(rows,:) );
Pankle = (Pfoot + quatrotate(quatinv(Qfoot), rf') + Pshin + quatrotate(quatinv(Qshin), rs')) / 2;

    % Get ankle angle using quaternion components
    % Foot rotation is respect to shin
    q12 = quatmultiply( quatinv(Qshin), Qfoot ); 
    theta = 2* acos( q12(:,1) );
    vec = q12(:,2:4) ./ repmat(sin(theta/2), [1 3]);
    tests(n).angles = vec .* repmat(theta, [1 3]); % rotation components
    
    % Get torque using cross product
    a = 0.21;
    b = 0.10905;
    az0 = 41e-3 + 7e-3;

    % forces on sensors, W RF
    F1 = quatrotate( quatinv(Qplate), -[x12/2 -z1 y14/2] );
    F2 = quatrotate( quatinv(Qplate), -[x12/2 -z2 y23/2] );
    F3 = quatrotate( quatinv(Qplate), -[x34/2 -z3 y23/2] );
    F4 = quatrotate( quatinv(Qplate), -[x34/2 -z4 y14/2] );

    r1 = quatrotate( quatinv(Qplate), [a -az0 b] ) + Pplate - Pankle;
    r2 = quatrotate( quatinv(Qplate), [-a -az0 b] ) + Pplate - Pankle;
    r3 = quatrotate( quatinv(Qplate), [-a -az0 -b] ) + Pplate - Pankle;
    r4 = quatrotate( quatinv(Qplate), [a -az0 -b] ) + Pplate - Pankle;

    % torque in the foot RF
    tests(n).torques = quatrotate( Qfoot, cross( r1, F1 ) + cross( r2, F2 ) + cross( r3, F3 ) + cross( r4, F4 ) );

    tests(n).z = z1 + z2 + z3 + z4;
    
    tests(n).Qfoot = Qfoot;
end

angles = [];
torques = [];
z = [];
for n = 1 : nFiles
    angles = [angles; tests(n).angles];
    torques = [torques; tests(n).torques];
    z = [z; tests(n).z];
end

%%

nn = 1 : length(z);
saw = detrend(cumsum(z));
[~, indexInit] = findpeaks( -saw, 'MinPeakWidth', round(0.4*300) );
[~, indexEnd] = findpeaks( saw, 'MinPeakWidth', round(0.4*300) );

figure; subplot(211); plot( nn, z, nn(indexInit), z(indexInit), 'o', nn(indexEnd), z(indexEnd), 'x' )
subplot(212); plot( nn, saw, nn(indexInit), saw(indexInit), 'o', nn(indexEnd), saw(indexEnd), 'x' )

gaitRealSize = indexEnd-indexInit;

%%

shiftOn = false;
borderSlack = 20; % maximum shift offset

offset = zeros(size(indexInit));
goodSteps = ones(size(indexInit)) > 0;

for iter = 1 : 10
    
    stanceSize = 2*round( max( indexEnd-indexInit )/2 ) + 2*borderSlack; % number of samples per stance
    stanceInit = indexInit - borderSlack + offset; % index of beginning of stance
    stanceNumber = length( stanceInit ); % number of gaits cycles

    rows = bsxfun( @plus, 1:stanceSize, stanceInit )'; % during stances

    % reshape to 3D matrix
    anglesSeg = permute( reshape( angles(rows,:)', [3 stanceSize stanceNumber] ), [2 1 3] );
    torquesSeg = permute( reshape( torques(rows,:)', [3 stanceSize stanceNumber] ), [2 1 3] );

    % remove bad gaits
    anglesMean = nanmean( anglesSeg(:,:,goodSteps), 3);
    torquesMean = nanmean(torquesSeg(:,:,goodSteps), 3);
    anglesStd = nanstd(anglesSeg(:,:,goodSteps), 0, 3);
    torquesStd = nanstd(torquesSeg(:,:,goodSteps), 0, 3);

    % good angles
    stdNumberAngles = 1.5;
    percentageThresAngles = 0.9;
    anglesDev = abs( anglesSeg - repmat(anglesMean,[1 1 stanceNumber]) );
    tmp = anglesDev(:,[1 3],:) < repmat( stdNumberAngles*anglesStd(:,[1 3]), [1 1 stanceNumber] );
    goodStepsAngles = squeeze( all( sum( tmp, 1 ) / stanceNumber > percentageThresAngles, 2 ) );

    % good torques
    stdNumberTorques = 1.5;
    percentageThresTorques = 0.9;
    torquesDev = abs( torquesSeg - repmat(torquesMean,[1 1 stanceNumber]) );
    tmp = torquesDev(:,[1 3],:) < repmat( stdNumberTorques*torquesStd(:,[1 3]), [1 1 stanceNumber] );
    goodStepsTorques = squeeze( all( sum( tmp, 1 ) / stanceNumber > percentageThresTorques, 2 ) );

    goodSteps = goodStepsAngles & goodStepsTorques;
    %goodSteps = ones( size(goodSteps) ) > 0;

    % Fine tune sync
    refCurve = squeeze( mean( torquesSeg(:,3,:), 2 ) );

    delay = -borderSlack : 1 : borderSlack;
    rms = zeros( size(delay) );
    nn = (1 : length(refCurve))';
    rows = nn > borderSlack & nn < length(nn)-borderSlack;

    clear y3 delayCalc anglesSyncDP anglesSyncIE torquesSyncDP torquesSyncIE
    offsetInc = zeros(size(offset));
    for channel = 1 : size( refCurve, 2 ) 
        %yy = refCurve(:,channel);
        for n = 1 : length( delay )
            rms(n) = sqrt( sum( (mean(refCurve(rows,goodSteps),2) - refCurve( circshift(rows, delay(n)),channel )).^2  ));
        end
        [~,iOpt] = min( rms );
        offsetInc(channel) = delay(iOpt);
    end
    
    if shiftOn
        offset = offset + offsetInc;
    end
end

disp( [num2str(sum(~goodSteps)) ' steps removed from ' num2str(stanceNumber)])

%%
lookAhead = 100;

rows = bsxfun( @plus, -lookAhead:-1, stanceInit )'; % during stances
anglesAdd = permute( reshape( angles(rows,:)', [3 lookAhead stanceNumber] ), [2 1 3] );
torquesAdd = permute( reshape( torques(rows,:)', [3 lookAhead stanceNumber] ), [2 1 3] );

anglesFull = [anglesAdd; anglesSeg];
torquesFull = [torquesAdd; torquesSeg];

anglesSegDP = squeeze( anglesFull(:,3,:) )';
torquesSegDP = squeeze( torquesFull(:,3,:) )';
anglesSegIE = squeeze( anglesFull(:,1,:) )';
torquesSegIE = squeeze( torquesFull(:,1,:) )';

figure;
plot(squeeze( anglesFull(:,1,goodSteps) ), 'b' )
hold on
plot(squeeze( anglesFull(:,1,~goodSteps) ), 'r' )



%%

% figure;
% subplot(221); shadedErrorBar( [], nanmean(anglesSegDP)', 1*nanstd(anglesSegDP,[],1)', 'b', 1 )
% subplot(223); shadedErrorBar( [], nanmean(anglesSegIE)', 1*nanstd(anglesSegIE,[],1)', 'r', 1 )
% subplot(222); shadedErrorBar( [], nanmean(torquesSegDP)', 1*nanstd(torquesSegDP,[],1)', 'b', 1 )
% subplot(224); shadedErrorBar( [], nanmean(torquesSegIE)', 1*nanstd(torquesSegIE,[],1)', 'r', 1 )

figure;
subplot(211);
shadedErrorBar( [], nanmean(anglesSegDP)', 1*nanstd(anglesSegDP,[],1)', 'b', 1 )
hold on; shadedErrorBar( [], nanmean(anglesSegIE)', 1*nanstd(anglesSegIE,[],1)', 'r', 1 )
title('Angle')
subplot(212); shadedErrorBar( [], nanmean(torquesSegDP)', 1*nanstd(torquesSegDP,[],1)', 'b', 1 )
hold on; shadedErrorBar( [], nanmean(torquesSegIE)', 1*nanstd(torquesSegIE,[],1)', 'r', 1 )
title('Torque')


