clear; clc

nFiles = 4;
dataFolder = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests';

% load files
for n = 1 : nFiles
    %tests(n) = ZTools.newTest();
    tests(n) = ZTools.loadTest();
    %tests(n) = ZTools.createTest(dataFolder);
end
%%
for n = 1 : nFiles
    test = tests(n);
    
[tblCam, headerCam] = ZTools.readCSV( [dataFolder test.csvFile] );
[tblPlate, headerPlate] = ZTools.readLVM( [dataFolder test.lvmFile] );

%camTableClean = ZTools.removeNaN( tblCam );
camTableClean = tblCam;
camTableClean{:,:} = ZTools.fillGaps( tblCam{:,:}, 3 );

[tblCamSync, tblPlateSync, t, f, t0] = ZTools.synchronizeTables( camTableClean, headerCam.t0, headerCam.fs, tblPlate, headerPlate.t0, headerPlate.fs );

[Pplate,Qplate] = ZTools.extractBody( tblCamSync, headerCam, test.plateAlias );
[Pshin,Qshin] = ZTools.extractBody( tblCamSync, headerCam, test.rShinAlias );
[Pfoot,Qfoot] = ZTools.extractBody( tblCamSync, headerCam, test.rFootAlias    );
Pplate = Pplate + quatrotate( quatinv(Qplate), -[test.plateCentroidX test.plateCentroidY test.plateCentroidZ] );

[z1, z2, z3, z4, x12, x34, y14, y23] = ZTools.parsePlateTable( tblPlateSync );

rows = sqrt(sum((Pfoot - Pplate).^2,2)) < 0.3 ...
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
[~, indexInit] = findpeaks( -saw, 'MinPeakWidth', round(0.3*300) );
[~, indexEnd] = findpeaks( saw, 'MinPeakWidth', round(0.3*300) );

figure; subplot(211); plot( nn, z, nn(indexInit), 100, 'x' )
subplot(212); plot( nn, saw, nn(indexInit), saw(indexInit), 'x' )

offset = zeros(size(indexInit));

for iter = 1 : 10
    
    stanceSize = 2*round( mean( indexEnd-indexInit )/2 ); % number of samples per stance
    stanceInit = round( (indexEnd+indexInit)/2 ) - stanceSize/2 + round(offset/2); % index of beginning of stance
    stanceNumber = length( stanceInit ); % number of gaits cycles

    rows = bsxfun( @plus, 1:stanceSize, stanceInit )'; % during stances

    % reshape to 3D matrix
    anglesSeg = permute( reshape( angles(rows,:)', [3 stanceSize stanceNumber] ), [2 1 3] );
    torquesSeg = permute( reshape( torques(rows,:)', [3 stanceSize stanceNumber] ), [2 1 3] );

    % Do not remove average

    % remove bad gaits
    anglesMean = nanmean( anglesSeg, 3);
    torquesMean = nanmean(torquesSeg, 3);
    anglesStd = nanstd(anglesSeg, 0, 3);
    torquesStd = nanstd(torquesSeg, 0, 3);

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
    sum(goodSteps)/length(goodSteps)

%     figure;
%     subplot(221); shadedErrorBar( [], squeeze(nanmean(anglesSeg(:,3,:),3))', 1*nanstd(anglesSeg(:,3,:),[],3)', 'b', 1 )
%     hold on; shadedErrorBar( [], squeeze(nanmean(anglesSeg(:,3,goodSteps),3))', 1*nanstd(anglesSeg(:,3,goodSteps),[],3)', 'r', 1 )
%     subplot(222); shadedErrorBar( [], squeeze(nanmean(anglesSeg(:,1,:),3))', 1*nanstd(anglesSeg(:,1,:),[],3)', 'b', 1 )
%     hold on; shadedErrorBar( [], squeeze(nanmean(anglesSeg(:,1,goodSteps),3))', 1*nanstd(anglesSeg(:,1,goodSteps),[],3)', 'r', 1 )
%     subplot(223); shadedErrorBar( [], squeeze(nanmean(torquesSeg(:,3,:),3))', 1*nanstd(torquesSeg(:,3,:),[],3)', 'b', 1 )
%     hold on; shadedErrorBar( [], squeeze(nanmean(torquesSeg(:,3,goodSteps),3))', 1*nanstd(torquesSeg(:,3,goodSteps),[],3)', 'r', 1 )
%     subplot(224); shadedErrorBar( [], squeeze(nanmean(torquesSeg(:,1,:),3))', 1*nanstd(torquesSeg(:,1,:),[],3)', 'b', 1 )
%     hold on; shadedErrorBar( [], squeeze(nanmean(torquesSeg(:,1,goodSteps),3))', 1*nanstd(torquesSeg(:,1,goodSteps),[],3)', 'r', 1 )

    % Fine tune sync
    y2 = squeeze(torquesSeg(:,3,:));
    y1 = mean( y2(:,goodSteps), 2 );

    nmax = 10;
    delay = -nmax : 1 : nmax;
    rms = zeros( size(delay) );
    nn = (1 : length(y1))';
    rows = nn > nmax & nn < length(nn)-nmax;

    tic
    clear y3 delayCalc anglesSyncDP anglesSyncIE torquesSyncDP torquesSyncIE
    offsetInc = zeros(size(offset));
    for channel = 1 : size( y2, 2 ) 
        yy = y2(:,channel);
        for n = 1 : length( delay )
            rms(n) = sqrt( sum( (y1(rows) - yy( circshift(rows, delay(n)) )).^2  ));
        end
        [~,iOpt] = min( rms );
        offsetInc(channel) = delay(iOpt);
    end
    toc
    
    offset = offset + offsetInc;
    [ sum(abs(offsetInc)) squeeze(sum(anglesStd,1)) squeeze(sum(torquesStd,1)) ]
end

%%
offset = 100;
rows = bsxfun( @plus, -offset:-1, stanceInit )'; % during stances
anglesAdd = permute( reshape( angles(rows,:)', [3 offset stanceNumber] ), [2 1 3] );
torquesAdd = permute( reshape( torques(rows,:)', [3 offset stanceNumber] ), [2 1 3] );

anglesFull = [anglesAdd; anglesSeg];
torquesFull = [torquesAdd; torquesSeg];

anglesSegDP = squeeze( anglesFull(:,3,goodSteps) )';
torquesSegDP = squeeze( torquesFull(:,3,goodSteps) )';
anglesSegIE = squeeze( anglesFull(:,1,goodSteps) )';
torquesSegIE = squeeze( torquesFull(:,1,goodSteps) )';

figure;
plot(torquesSegDP' )

%%

figure;
subplot(221); shadedErrorBar( [], nanmean(anglesSegDP)', 1*nanstd(anglesSegDP,[],1)', 'b', 1 )
subplot(223); shadedErrorBar( [], nanmean(anglesSegIE)', 1*nanstd(anglesSegIE,[],1)', 'r', 1 )
subplot(222); shadedErrorBar( [], nanmean(torquesSegDP)', 1*nanstd(torquesSegDP,[],1)', 'b', 1 )
subplot(224); shadedErrorBar( [], nanmean(torquesSegIE)', 1*nanstd(torquesSegIE,[],1)', 'r', 1 )

figure;
subplot(211);
shadedErrorBar( [], nanmean(anglesSegDP)', 1*nanstd(anglesSegDP,[],1)', 'b', 1 )
hold on; shadedErrorBar( [], nanmean(anglesSegIE)', 1*nanstd(anglesSegIE,[],1)', 'r', 1 )
title('Angle')
subplot(212); shadedErrorBar( [], nanmean(torquesSegDP)', 1*nanstd(torquesSegDP,[],1)', 'b', 1 )
hold on; shadedErrorBar( [], nanmean(torquesSegIE)', 1*nanstd(torquesSegIE,[],1)', 'r', 1 )
title('Torque')


