clear; clc

% load files
for n = 1 : 4
    tests(n) = ZTools.newTest();
end

for n = 1 : 4
    test = tests(n);
    
    % Pre-process the raw data
    [tblCam, t0Cam, fCam] = ZTools.readCSV( test.csvFile );
    [tblPlate, t0Plate, fPlate] = ZTools.readLVM( test.lvmFile );

    %camTableClean = ZTools.removeNaN( tblCam );
    camTableClean = tblCam;
    camTableClean{:,:} = ZTools.fillGaps( tblCam{:,:}, 3 );

    [tblCamSync, tblPlateSync, t, f, t0] = ZTools.synchronizeTables( camTableClean, t0Cam, fCam, tblPlate, t0Plate, fPlate );

    [Pplate, Qplate, Psheen, Qsheen, Pfoot, Qfoot] = ZTools.parseCamTable( tblCamSync, test );
    [z1, z2, z3, z4, x12, x34, y14, y23] = ZTools.parsePlateTable( tblPlateSync );

    rows = sqrt(sum((Pfoot - Pplate).^2,2)) < 0.3 ...
        & ( t > t(end)/10 & t < t(end)*9/10 )' ...
        & ~any(isnan([Qfoot Qsheen Pfoot Psheen]),2);
    %rows = t > t(1)+3 & t < t(end)-3;

    [rs, rf] = ZTools.calculateJointPosition( Psheen(rows,:), Qsheen(rows,:), Pfoot(rows,:), Qfoot(rows,:) );
    Pankle = (Pfoot + quatrotate(quatinv(Qfoot), rf') + Psheen + quatrotate(quatinv(Qsheen), rs')) / 2;

    % Get ankle angle using quaternion components
    % Foot rotation is respect to shin
    q12 = quatmultiply( quatinv(Qsheen), Qfoot ); 
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
for n = 1 : 4
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

rows = bsxfun( @plus, 1:stanceSize, stanceInit )'; % during stances

% reshape to 3D matrix
anglesCrop = permute( reshape( angles(rows,:)', [3 stanceSize stanceNumber] ), [2 1 3] );
torquesCrop = permute( reshape( torques(rows,:)', [3 stanceSize stanceNumber] ), [2 1 3] );

% remove average
anglesSeg = bsxfun( @plus, anglesCrop, -mean(anglesCrop,2) );
torquesSeg = bsxfun( @plus, torquesCrop, -mean(torquesCrop,2) );

% remove bad gaits
anglesMean = nanmean(anglesSeg,3);
torquesMean = nanmean(torquesSeg,3);
anglesStd = nanstd(anglesSeg,0,3);
torquesStd = nanstd(torquesSeg,0,3);

rows = sum( any( bsxfun( @plus, abs(bsxfun( @plus, anglesSeg, -anglesMean )), -2*anglesStd ) > 0, 2 ), 1 );

anglesSeries = timeseries( anglesSeg );
torquesSeries = timeseries( torquesSeg );
aStd = std( a );
aMean = mean( a );

figure;
subplot(311); shadedErrorBar( [], aMean(:,1), 2*aStd(:,1), 'b' )
subplot(312); shadedErrorBar( [], aMean(:,2), 2*aStd(:,2), 'r' )
subplot(313); shadedErrorBar( [], aMean(:,3), 2*aStd(:,3), 'y' )


figure;
subplot(311); plot( squeeze( anglesSeg(:,1,:) ) )
subplot(312); plot( squeeze( anglesSeg(:,2,:) ) )
subplot(313); plot( squeeze( anglesSeg(:,3,:) ) )

figure;
subplot(311); plot( squeeze( torquesSeg(:,1,:) ) )
subplot(312); plot( squeeze( torquesSeg(:,2,:) ) )
subplot(313); plot( squeeze( torquesSeg(:,3,:) ) )

