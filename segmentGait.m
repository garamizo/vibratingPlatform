rows = any( isnan( [angles torques] ), 2 );

anglesInt = angles;
%anglesInt(rows,:) = interp1( t(~rows), angles(~rows,:), t(rows), 'nearest' );

torquesInt = angles;
%torquesInt(rows,:) = interp1( t(~rows), torques(~rows,:), t(rows), 'nearest' );

%plot( [ anglesInt angles] )

%%
saw = detrend(cumsum(z1+z2+z3+z4));
[~, indexInit] = findpeaks( -saw, 'MinPeakWidth', round(0.3*300) );
[~, indexEnd] = findpeaks( saw, 'MinPeakWidth', round(0.3*300) );

stanceSize = 2*round( mean( indexEnd-indexInit )/2 ); % number of samples per stance
stanceInit = round( (indexEnd+indexInit)/2 ) - stanceSize/2; % index of beginning of stance
stanceNumber = length( stanceInit ); % number of gaits cycles

rows = bsxfun( @plus, 1:stanceSize, stanceInit )'; % during stances

% reshape to 3D matrix
anglesCrop = reshape( anglesInt(rows,:)', [3 stanceSize stanceNumber] );
torquesCrop = reshape( torquesInt(rows,:)', [3 stanceSize stanceNumber] );

% remove average
anglesSeg = bsxfun( @plus, anglesCrop, -mean(anglesCrop,2) );
torquesSeg = bsxfun( @plus, torquesCrop, -mean(torquesCrop,2) );

% remove bad gaits
anglesMean = nanmean(anglesSeg,3);
torquesMean = nanmean(torquesSeg,3);
anglesStd = nanstd(anglesSeg,0,3);
torquesStd = nanstd(torquesSeg,0,3);

rows = bsxfun( @plus, abs(bsxfun( @plus, anglesSeg, -anglesMean )), -anglesStd ) < 0;
plot(rows)

figure;
subplot(311); plot( squeeze( anglesSeg(1,:,:) ) )
subplot(312); plot( squeeze( anglesSeg(2,:,:) ) )
subplot(313); plot( squeeze( anglesSeg(3,:,:) ) )

figure;
subplot(311); plot( squeeze( torquesSeg(1,:,:) ) )
subplot(312); plot( squeeze( torquesSeg(2,:,:) ) )
subplot(313); plot( squeeze( torquesSeg(3,:,:) ) )

