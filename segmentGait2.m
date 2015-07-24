%% Time Varying Impedance

clear; clc
initTime = tic;
%% Loading file

experiment.run = ZTools.loadTestFolder( uigetdir );
experiment.plateAlias = 'Rigid Body 1';
experiment.rShinAlias = 'Rigid Body 2';
experiment.rFootAlias = 'Rigid Body 3';
experiment.platePositionOffset = -[250-12.5 0 -150+12.5]*1e-3 - [-122.7/3 0 272/3]*1e-3; % from centroid to center, cam RF

%% Concatenate runs

for n = 1 : length( experiment.run )
    run = experiment.run( n );

    run.dataMotionClean = ZTools.fillGaps( run.dataMotion, 2 );

    [Pplate,Qplate] = ZTools.extractBody( run.dataMotionClean, run.csvHeader, experiment.plateAlias );
    [Pshin,Qshin] = ZTools.extractBody( run.dataMotionClean, run.csvHeader, experiment.rShinAlias );
    [Pfoot,Qfoot] = ZTools.extractBody( run.dataMotionClean, run.csvHeader, experiment.rFootAlias );
    Pplate = Pplate + quatrotate( quatinv(Qplate), experiment.platePositionOffset );

    [z1, z2, z3, z4, x12, x34, y14, y23] = ZTools.parsePlateTable( run.dataForce );

    t = ( 0 : size( run.dataMotion, 1 ) - 1 )' / run.fs;
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
    angles = vec .* repmat(theta, [1 3]); % rotation components
    
    % Get torque using cross product
    a = 0.21;
    b = 0.10905;
    az0 = 41e-3 + 7e-3;

    % forces on sensors, W RF
    R =  [1 0 0; 0 0 1; 0 1 0]';
    F1 = quatrotate( quatinv(Qplate), [x12/2 y14/2 z1]*R );
    F2 = quatrotate( quatinv(Qplate), [x12/2 y23/2 z2]*R );
    F3 = quatrotate( quatinv(Qplate), [x34/2 y23/2 z3]*R );
    F4 = quatrotate( quatinv(Qplate), [x34/2 y14/2 z4]*R );

    r1 = quatrotate( quatinv(Qplate), [a -az0 b] ) + Pplate - Pankle;
    r2 = quatrotate( quatinv(Qplate), [-a -az0 b] ) + Pplate - Pankle;
    r3 = quatrotate( quatinv(Qplate), [-a -az0 -b] ) + Pplate - Pankle;
    r4 = quatrotate( quatinv(Qplate), [a -az0 -b] ) + Pplate - Pankle;

    % torque in the foot RF
    torques = quatrotate( Qfoot, cross( r1, F1 ) + cross( r2, F2 ) + cross( r3, F3 ) + cross( r4, F4 ) );

    z = z1 + z2 + z3 + z4;
    
    runs(n) = struct( 'torques', torques, 'angles', angles, 'normal', z );
end

angles = [];
torques = [];
normals = [];
for n = 1 : length( experiment.run )
    angles = [angles; runs(n).angles];
    torques = [torques; runs(n).torques];
    normals = [normals; runs(n).normal];
end

%% Segmenting

lookAhead = 120;
lookAheadSlack = lookAhead + 20;

nn = 1 : length(normals);
saw = detrend(cumsum(normals));
[~, indexInit] = findpeaks( -saw, 'MinPeakWidth', round(0.4*300) );
[~, indexEnd] = findpeaks( saw, 'MinPeakWidth', round(0.4*300) );

figure; subplot(211); plot( nn, normals, nn(indexInit), normals(indexInit), 'o', nn(indexEnd), normals(indexEnd), 'x' )
subplot(212); plot( nn, saw, nn(indexInit), saw(indexInit), 'o', nn(indexEnd), saw(indexEnd), 'x' )

stanceSize = 2*round( max( indexEnd-indexInit )/2 ); % number of samples per stance
stanceInit = indexInit; % index of beginning of stance
stanceNumber = length( stanceInit ); % number of gaits cycles

stanceRealSize = indexEnd-indexInit;

rows = bsxfun( @plus, -lookAheadSlack:stanceSize-1, stanceInit )'; % during stances
anglesSeg = permute( reshape( angles(rows,:)', [3 stanceSize+lookAheadSlack stanceNumber] ), [2 1 3] );
torquesSeg = permute( reshape( torques(rows,:)', [3 stanceSize+lookAheadSlack stanceNumber] ), [2 1 3] );

anglesSegDP = squeeze( anglesSeg(:,3,:) )';
torquesSegDP = squeeze( torquesSeg(:,3,:) )';
anglesSegIE = squeeze( anglesSeg(:,1,:) )';
torquesSegIE = squeeze( torquesSeg(:,1,:) )';

%% Time Scaling

anglesScaledDP = zeros( stanceNumber, round(mean(stanceRealSize))+lookAhead );
torquesScaledDP = zeros( stanceNumber, round(mean(stanceRealSize))+lookAhead );
anglesScaledIE = zeros( stanceNumber, round(mean(stanceRealSize))+lookAhead );
torquesScaledIE = zeros( stanceNumber, round(mean(stanceRealSize))+lookAhead );

for n = 1 : stanceNumber
    tmp = resample( anglesSegDP(n,lookAheadSlack+1:lookAheadSlack+stanceRealSize(n)), round(mean(stanceRealSize)), stanceRealSize(n) );
    tmp2 = resample( anglesSegDP(n,1:lookAheadSlack+1), round(mean(stanceRealSize)), stanceRealSize(n) );
    anglesScaledDP(n,:) = [ tmp2(end-lookAhead:end-1) tmp ];
    
    tmp = resample( torquesSegDP(n,lookAheadSlack+1:lookAheadSlack+stanceRealSize(n)), round(mean(stanceRealSize)), stanceRealSize(n) );
    tmp2 = resample( torquesSegDP(n,1:lookAheadSlack+1), round(mean(stanceRealSize)), stanceRealSize(n) );
    torquesScaledDP(n,:) = [ tmp2(end-lookAhead:end-1) tmp ];
    
    tmp = resample( anglesSegIE(n,lookAheadSlack+1:lookAheadSlack+stanceRealSize(n)), round(mean(stanceRealSize)), stanceRealSize(n) );
    tmp2 = resample( anglesSegIE(n,1:lookAheadSlack+1), round(mean(stanceRealSize)), stanceRealSize(n) );
    anglesScaledIE(n,:) = [ tmp2(end-lookAhead:end-1) tmp ];
    
    tmp = resample( torquesSegIE(n,lookAheadSlack+1:lookAheadSlack+stanceRealSize(n)), round(mean(stanceRealSize)), stanceRealSize(n) );
    tmp2 = resample( torquesSegIE(n,1:lookAheadSlack+1), round(mean(stanceRealSize)), stanceRealSize(n) );
    torquesScaledIE(n,:) = [ tmp2(end-lookAhead:end-1) tmp ];
end

missingSamples = squeeze( sum( isnan( anglesScaledDP ), 2 ) );
figure; hist( missingSamples ); title( 'Frequency of Missing Samples' )
goodSteps = missingSamples == 0;
sum( goodSteps )

figure;
subplot(211);
shadedErrorBar( [], nanmean(anglesScaledDP)', 1*nanstd(anglesScaledDP,[],1)', 'b', 1 )
hold on; shadedErrorBar( [], nanmean(anglesScaledIE)', 1*nanstd(anglesScaledIE,[],1)', 'r', 1 )
title('Angle')
subplot(212); shadedErrorBar( [], nanmean(torquesScaledDP)', 1*nanstd(torquesScaledDP,[],1)', 'b', 1 )
hold on; shadedErrorBar( [], nanmean(torquesScaledIE)', 1*nanstd(torquesScaledIE,[],1)', 'r', 1 )
title('Torque')

figure;
subplot(221); plot( anglesScaledDP' )
subplot(222); plot( anglesScaledIE' )
subplot(223); plot( torquesScaledDP' )
subplot(224); plot( torquesScaledIE' )

toc( initTime )
