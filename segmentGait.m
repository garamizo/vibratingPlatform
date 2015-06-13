clear; clc

nFiles = 4;

% load files
for n = 1 : nFiles
    %tests(n) = ZTools.newTest();
    tests(n) = ZTools.loadTest();
end
%%
for n = 1 : nFiles
    test = tests(n);
    
[tblCam, headerCam] = ZTools.readCSV( test.csvFile );
[tblPlate, headerPlate] = ZTools.readLVM( test.lvmFile );

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

saw = detrend(cumsum(z));
[~, indexInit] = findpeaks( -saw, 'MinPeakWidth', round(0.3*300) );
[~, indexEnd] = findpeaks( saw, 'MinPeakWidth', round(0.3*300) );

stanceSize = 2*round( mean( indexEnd-indexInit )/2 ); % number of samples per stance
stanceInit = round( (indexEnd+indexInit)/2 ) - stanceSize/2; % index of beginning of stance
stanceNumber = length( stanceInit ); % number of gaits cycles

offsetSamples = 100;
slackSamples = 50;
stanceSizeOff = stanceSize + offsetSamples + slackSamples;
stanceInitOff = stanceInit - offsetSamples/2;

rows = bsxfun( @plus, 1:stanceSizeOff, stanceInitOff )'; % during stances

% reshape to 3D matrix
anglesCrop = permute( reshape( angles(rows,:)', [3 stanceSizeOff stanceNumber] ), [2 1 3] );
torquesCrop = permute( reshape( torques(rows,:)', [3 stanceSizeOff stanceNumber] ), [2 1 3] );

% remove average
rowsTight = slackSamples/2+offsetSamples : size(anglesCrop,1)-slackSamples/2;
anglesSeg = bsxfun( @plus, anglesCrop, -mean(anglesCrop(rowsTight,:,:),1) );
torquesSeg = bsxfun( @plus, torquesCrop, -mean(torquesCrop(rowsTight,:,:),1) );

% remove bad gaits
anglesMean = nanmean(anglesSeg(rowsTight,:,:),3);
torquesMean = nanmean(torquesSeg(rowsTight,:,:),3);
anglesStd = nanstd(anglesSeg(rowsTight,:,:),0,3);
torquesStd = nanstd(torquesSeg(rowsTight,:,:),0,3);

%
stdNumberAngles = 2;
percentageThresAngles = 0.7;

anglesDev = abs( anglesSeg(rowsTight,:,:) - repmat(anglesMean,[1 1 stanceNumber]) );

tmp = anglesDev(:,[1 3],:) < repmat( stdNumberAngles*anglesStd(:,[1 3]), [1 1 stanceNumber] );
goodStepsAngles = squeeze( all( sum( tmp, 1 ) / stanceNumber > percentageThresAngles, 2 ) );

%
stdNumberTorques = 2;
percentageThresTorques = 0.7;

torquesDev = abs( torquesSeg(rowsTight,:,:) - repmat(torquesMean,[1 1 stanceNumber]) );

tmp = torquesDev(:,[1 3],:) < repmat( stdNumberTorques*torquesStd(:,[1 3]), [1 1 stanceNumber] );
goodStepsTorques = squeeze( all( sum( tmp, 1 ) / stanceNumber > percentageThresTorques, 2 ) );

goodSteps = goodStepsAngles & goodStepsTorques;



sum(goodSteps)/length(goodSteps)

% figure;
% subplot(211); shadedErrorBar( [], squeeze(nanmean(anglesSeg(:,3,~goodSteps),3))', 2*nanstd(anglesSeg(:,3,~goodSteps),[],3)', 'b', 1 )
% hold on; shadedErrorBar( [], squeeze(nanmean(anglesSeg(:,3,goodSteps),3))', 2*nanstd(anglesSeg(:,3,goodSteps),[],3)', 'r', 1 )
% subplot(212); shadedErrorBar( [], squeeze(nanmean(anglesSeg(:,1,~goodSteps),3))', 2*nanstd(anglesSeg(:,1,~goodSteps),[],3)', 'b', 1 )
% hold on; shadedErrorBar( [], squeeze(nanmean(anglesSeg(:,1,goodSteps),3))', 2*nanstd(anglesSeg(:,1,goodSteps),[],3)', 'r', 1 )
% 
% figure;
% subplot(311); plot( squeeze( anglesSeg(:,1,~goodSteps) ) )
% subplot(312); plot( squeeze( anglesSeg(:,2,~goodSteps) ) )
% subplot(313); plot( squeeze( anglesSeg(:,3,~goodSteps) ) )
% 
% figure;
% subplot(311); plot( squeeze( torquesSeg(:,1,~goodSteps) ) )
% subplot(312); plot( squeeze( torquesSeg(:,2,~goodSteps) ) )
% subplot(313); plot( squeeze( torquesSeg(:,3,~goodSteps) ) )
% 
% anglesSeries = timeseries( anglesSeg );
% torquesSeries = timeseries( torquesSeg );
% aStd = std( anglesSeries );
% aMean = mean( anglesSeries );
% tStd = std( torquesSeries );
% tMean = mean( torquesSeries );
% 
% figure;
% subplot(311); shadedErrorBar( [], aMean(:,1), 2*aStd(:,1), 'b' )
% subplot(312); shadedErrorBar( [], aMean(:,2), 2*aStd(:,2), 'r' )
% subplot(313); shadedErrorBar( [], aMean(:,3), 2*aStd(:,3), 'y' )
% 
% figure;
% subplot(311); shadedErrorBar( [], tMean(:,1), 2*tStd(:,1), 'b' )
% subplot(312); shadedErrorBar( [], tMean(:,2), 2*tStd(:,2), 'r' )
% subplot(313); shadedErrorBar( [], tMean(:,3), 2*tStd(:,3), 'y' )
% 
% figure;
% subplot(311); plot( squeeze( anglesSeg(:,1,:) ) )
% subplot(312); plot( squeeze( anglesSeg(:,2,:) ) )
% subplot(313); plot( squeeze( anglesSeg(:,3,:) ) )
% 
% figure;
% subplot(311); plot( squeeze( torquesSeg(:,1,:) ) )
% subplot(312); plot( squeeze( torquesSeg(:,2,:) ) )
% subplot(313); plot( squeeze( torquesSeg(:,3,:) ) )

anglesSegDP = squeeze( anglesSeg(:,3,goodSteps) )';
torquesSegDP = squeeze( torquesSeg(:,3,goodSteps) )';
anglesSegIE = squeeze( anglesSeg(:,1,goodSteps) )';
torquesSegIE = squeeze( torquesSeg(:,1,goodSteps) )';

%%

y2 = torquesSegDP;
y1 = mean( torquesSegDP, 1 );

nmax = 25;
delay = -nmax : 1 : nmax;
rms = zeros( size(delay) );
nn = (1 : length(y1))';
rows = nn > 100+nmax & nn < length(nn)-nmax;
rowsSave = nmax : length(y1)-nmax;

tic
clear y3 delayCalc anglesSyncDP anglesSyncIE torquesSyncDP torquesSyncIE
for channel = 1 : size( y2, 1 ) 
    yy = y2(channel,:);
    for n = 1 : length( delay )
        rms(n) = sqrt( sum( (y1(rows) - yy( circshift(rows, delay(n)) )).^2  ));
    end
    [~,iOpt] = min( rms );
    delayCalc(channel) = delay(iOpt);
    y3(:,channel) = yy( delay(iOpt)+rowsSave);
    
    anglesSyncDP(channel,:) = anglesSegDP(channel,delay(iOpt)+rowsSave);
    anglesSyncIE(channel,:) = anglesSegIE(channel,delay(iOpt)+rowsSave);
    torquesSyncDP(channel,:) = torquesSegDP(channel,delay(iOpt)+rowsSave);
    torquesSyncIE(channel,:) = torquesSegIE(channel,delay(iOpt)+rowsSave);
end
toc

figure;
subplot(211); shadedErrorBar( [], mean(torquesSegDP(:,rowsSave)',2), 2*std(torquesSegDP(:,rowsSave)',[],2), 'b', 1 )
hold on; shadedErrorBar( [], mean(torquesSyncDP(:,:)',2), 2*std(torquesSyncDP(:,:)',[],2), '--r', 1 )
subplot(212); shadedErrorBar( [], mean(torquesSegIE(:,rowsSave)',2), 2*std(torquesSegIE(:,rowsSave)',[],2), 'b' )
hold on; shadedErrorBar( [], mean(torquesSyncIE(:,:)',2), 2*std(torquesSyncIE(:,:)',[],2), '--r', 1 )

figure;
subplot(211); shadedErrorBar( [], mean(anglesSegDP(:,rowsSave)',2), 2*std(anglesSegDP(:,rowsSave)',[],2), 'b', 1 )
hold on; shadedErrorBar( [], mean(anglesSyncDP',2), 2*std(anglesSyncDP',[],2), '--r', 1 )
subplot(212); shadedErrorBar( [], mean(anglesSegIE(:,rowsSave)',2), 2*std(anglesSegIE(:,rowsSave)',[],2), 'b', 1 )
hold on; shadedErrorBar( [], mean(anglesSyncIE',2), 2*std(anglesSyncIE',[],2), '--r', 1 )
