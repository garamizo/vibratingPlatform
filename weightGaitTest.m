dataFolder = 'C:\Users\rastgaar\Google Drive\HIRoLab - Ruffus\VibratingPlatform\GaitTests';

test.type = 'weight';
test.rShinAlias = 'Rigid Body 1';
test.rFootAlias = 'Rigid Body 2';
test.lShinAlias = 'Rigid Body 3';
test.lFootAlias = 'Rigid Body 4';
test.plateCentroidX = -0.15;
test.plateCentroidY = 0;
test.plateCentroidZ = .25;
test.comments = '';
test.csvFile = '\june29\Take 2015-06-29 05.04.29 PM.csv';
test.lvmFile = '\june29\raw_1.lvm';
test.subjectKey = 3;

%%

[tblCam, headerCam] = ZTools.readCSV( [dataFolder test.csvFile] );
[tblPlate, headerPlate] = ZTools.readLVM( [dataFolder test.lvmFile] );

camTableClean = ZTools.fillGaps( tblCam, 3 );

[tblCamSync, tblPlateSync, t, f, t0] = ZTools.synchronizeTables( camTableClean, headerCam.t0, headerCam.fs, tblPlate, headerPlate.t0, headerPlate.fs );

[PshinR,QshinR] = ZTools.extractBody( tblCamSync, headerCam, test.rShinAlias );
[PshinL,QshinL] = ZTools.extractBody( tblCamSync, headerCam, test.lShinAlias );

[PfootR,QfootR] = ZTools.extractBody( tblCamSync, headerCam, test.rFootAlias );
[PfootL,QfootL] = ZTools.extractBody( tblCamSync, headerCam, test.lFootAlias );

[z1, z2, z3, z4, x12, x34, y14, y23] = ZTools.parsePlateTable( tblPlateSync );


%%
rowsR = sqrt(sum(PfootR.^2,2)) < 0.3 ...
    & ( t > t(end)/10 & t < t(end)*9/10 ) ...
    & ~any(isnan([QfootR QshinR PfootR PshinR]),2);

rowsL = sqrt(sum(PfootL.^2,2)) < 1 ...
    & ( t > t(end)/10 & t < t(end)*9/10 ) ...
    & ~any(isnan([QfootL QshinL PfootL PshinL]),2);
%rows = t > t(1)+3 & t < t(end)-3;

[rsR, rfR] = ZTools.calculateJointPosition( PshinR(rowsR,:), QshinR(rowsR,:), PfootR(rowsR,:), QfootR(rowsR,:) );
[rsL, rfL] = ZTools.calculateJointPosition( PshinL(rowsL,:), QshinL(rowsL,:), PfootL(rowsL,:), QfootL(rowsL,:) );

PankleR = (PfootR + quatrotate(quatinv(QfootR), rfR') + PshinR + quatrotate(quatinv(QshinR), rsR')) / 2;
PankleL = (PfootL + quatrotate(quatinv(QfootL), rfL') + PshinL + quatrotate(quatinv(QshinL), rsL')) / 2;

q12 = quatmultiply( quatinv(QshinR), QfootR ); 
theta = 2* acos( q12(:,1) );
vec = q12(:,2:4) ./ repmat(sin(theta/2), [1 3]);
anglesR = vec .* repmat(theta, [1 3]); % rotation components

q12 = quatmultiply( quatinv(QshinL), QfootL ); 
theta = 2* acos( q12(:,1) );
vec = q12(:,2:4) ./ repmat(sin(theta/2), [1 3]);
anglesL = vec .* repmat(theta, [1 3]); % rotation components

% forces on sensors, W RF
RCK = [-1 0 0; 0 0 -1; 0 -1 0];
F1 = [x12/2 y14/2 z1] * RCK';
F2 = [x12/2 y23/2 z2] * RCK';
F3 = [x34/2 y23/2 z3] * RCK';
F4 = [x34/2 y14/2 z4] * RCK';

    a = 0.21;
    b = 0.10905;
    az0 = 41e-3 + 7e-3;

r1 = repmat( [a -b az0]* RCK' + [-15e-3 0 25e-3], [size(F1,1) 1] );
r2 = repmat( [-a b az0]* RCK' + [-15e-3 0 25e-3], [size(F1,1) 1] );
r3 = repmat( [-a -b az0]* RCK' + [-15e-3 0 25e-3], [size(F1,1) 1] );
r4 = repmat( [a b az0]* RCK' + [-15e-3 0 25e-3], [size(F1,1) 1] );

% torque in the foot RF
torques = quatrotate( QfootR, cross( r1, F1 ) + cross( r2, F2 ) + cross( r3, F3 ) + cross( r4, F4 ) );

z = z1 + z2 + z3 + z4;

%%
nn = 1 : length(z);
saw = detrend(cumsum(z));
[~, indexInit] = findpeaks( -saw, 'MinPeakWidth', round(0.4*300) );
[~, indexEnd] = findpeaks( saw, 'MinPeakWidth', round(0.4*300) );

figure; subplot(211); plot( nn, z, nn(indexInit), z(indexInit), 'o', nn(indexEnd), z(indexEnd), 'x' )
subplot(212); plot( nn, saw, nn(indexInit), saw(indexInit), 'o', nn(indexEnd), saw(indexEnd), 'x' )

%%
angles = anglesR;

offset = zeros(size(indexInit));
goodSteps = ones(size(indexInit)) > 0;

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

    % Fine tune sync
    y2 = squeeze(torquesSeg(:,3,:));
    y1 = mean( y2(:,goodSteps), 2 );

    nmax = 10;
    delay = -nmax : 1 : nmax;
    rms = zeros( size(delay) );
    nn = (1 : length(y1))';
    rows = nn > nmax & nn < length(nn)-nmax;

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
    
    offset = offset + offsetInc;
end

disp( [num2str(sum(~goodSteps)) ' steps removed from ' num2str(stanceNumber)])

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
plot(squeeze( anglesFull(:,1,goodSteps) ), 'b' )
hold on
plot(squeeze( anglesFull(:,1,~goodSteps) ), 'r' )

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

