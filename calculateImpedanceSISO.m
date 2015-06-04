%% Create new experimental file entry
%test = HiRoLab.newTest();

%% Load file
%test = HiRoLab.loadTest();

%% Pre-process the raw data
[tblCam, t0Cam, fCam] = HiRoLab.readCSV( test.csvFile );
[tblPlate, t0Plate, fPlate] = HiRoLab.readLVM( test.lvmFile );

camTableClean = HiRoLab.removeNaN( tblCam );

[tblCamSync, tblPlateSync, t, f, t0] = HiRoLab.synchronizeTables( camTableClean, t0Cam, fCam, tblPlate, t0Plate, fPlate );

[Pplate, Qplate, Psheen, Qsheen, Pfoot, Qfoot] = HiRoLab.parseCamTable( tblCamSync, test );
[z1, z2, z3, z4, x12, x34, y14, y23] = HiRoLab.parsePlateTable( tblPlateSync );

rows = abs(Pfoot(:,1) - Pplate(:,1)) < 2 & ( t > t(1)+3 & t < t(end)-3 )';
%rows = t > t(1)+3 & t < t(end)-3;

[rs, rf] = HiRoLab.calculateJointPosition( Psheen(rows,:), Qsheen(rows,:), Pfoot(rows,:), Qfoot(rows,:) );
Pankle = (Pfoot + quatrotate(quatinv(Qfoot), rf') + Psheen + quatrotate(quatinv(Qsheen), rs')) / 2;

%% Verify cam data integrity on Simulink
[rx1, ry1, rz1] = quat2angle(Qplate, 'XYZ');
[rx2, ry2, rz2] = quat2angle(Qsheen, 'XYZ');
[rx3, ry3, rz3] = quat2angle(Qfoot, 'XYZ');

dataIn.time = t;
dataIn.signals.dimensions = 21;
dataIn.signals.values = [ Pplate Psheen Pfoot rad2deg([rx1, ry1, rz1, rx2, ry2, rz2, rx3, ry3, rz3]) Pankle ];

%{
sim( 'simImpedanceExperiment.slx' )
%}

%% Check FFT
%{
HiRoLab.plotFFT( t, Qfoot(:,1) );
%}

%% Get ankle angle using quaternion components
% Foot rotation is respect to shin
q12 = quatmultiply( quatinv(Qsheen), Qfoot ); 
theta = 2* acos( q12(:,1) );
vec = q12(:,2:4) ./ repmat(sin(theta/2), [1 3]);
angs = vec .* repmat(theta, [1 3]); % rotation components

%% Get torque using cross product
a = 0.21;
b = 0.10905;
az0 = 41e-3 + 7e-3;

% forces on sensors, W RF
F1 = quatrotate( quatinv(Qplate), -[x12/2 -z1 y14/2] );
F2 = quatrotate( quatinv(Qplate), -[x12/2 -z2 y23/2] );
F3 = quatrotate( quatinv(Qplate), -[x34/2 -z3 y23/2] );
F4 = quatrotate( quatinv(Qplate), -[x34/2 -z4 y14/2] );

% ankle to sensor position, W RF
% r1 = quatrotate( quatinv(Qplate), [a -az0 -b] ) + Pplate - Pankle;
% r2 = quatrotate( quatinv(Qplate), [-a -az0 -b] ) + Pplate - Pankle;
% r3 = quatrotate( quatinv(Qplate), [-a -az0 b] ) + Pplate - Pankle;
% r4 = quatrotate( quatinv(Qplate), [a -az0 b] ) + Pplate - Pankle;

r1 = quatrotate( quatinv(Qplate), [a -az0 b] ) + Pplate - Pankle;
r2 = quatrotate( quatinv(Qplate), [-a -az0 b] ) + Pplate - Pankle;
r3 = quatrotate( quatinv(Qplate), [-a -az0 -b] ) + Pplate - Pankle;
r4 = quatrotate( quatinv(Qplate), [a -az0 -b] ) + Pplate - Pankle;

% torque in the foot RF
torqueF = quatrotate( Qfoot, cross( r1, F1 ) + cross( r2, F2 ) + cross( r3, F3 ) + cross( r4, F4 ) );

%% Calculate impedance

% ========================================================
rows = t > 3 & t < t(end)-3;

torques = torqueF;
angles = angs;

ang_DP = detrend(angles(rows,3));
torque_DP = detrend(torques(rows,3));

ang_IE = detrend(angles(rows,1));
torque_IE = detrend(torques(rows,1));

ang_ML = detrend(angles(rows,2));
torque_ML = detrend(torques(rows,2));

% load the vectors ang_dp  ang_ie tdp and  tie, the rest should work
ang_dp = ang_DP;
ang_ie = ang_IE;
tdp = torque_DP;
tie = torque_IE;

%{

figure; subplot(311); h = plotyy(t(rows), ang_IE, t(rows), torque_IE);
subplot(312); h = plotyy(t(rows), ang_ML, t(rows), torque_ML); 
subplot(313); h = plotyy(t(rows), ang_DP, t(rows), torque_DP);

%}
% ========================================================

font=24;    %all fonts of the plots
lim_x = 30;   % limit of x axis for view
Fs = f;
nfft = 2^10;
n_win=0.5*nfft;
n_ovrlp=0.25*nfft;

%mag
[Z_DP,f_DP] = tfestimate(ang_DP,torque_DP,hamming(n_win),n_ovrlp,nfft,Fs);
coh_DP = mscohere(ang_DP,torque_DP,hamming(n_win),n_ovrlp,nfft,Fs);

[Z_IE,f_IE] = tfestimate(ang_IE,torque_IE,hamming(n_win),n_ovrlp,nfft,Fs);
coh_IE = mscohere(ang_IE,torque_IE,hamming(n_win),n_ovrlp,nfft,Fs);

% hold on
figure

subplot(311)
semilogx(f_DP, 20*log10(abs([Z_IE Z_DP])));grid on; hold on
ylabel('magnitude (dB)'); grid on; box on; xlabel('Hz'); xlim([.87 lim_x]); ylim([20 70]);
legend('IE', 'DP')

subplot(312)
semilogx(f_DP,rad2deg(angle([Z_IE Z_DP]))); hold on
ylabel('phase (degree)'); grid on; box on; xlabel('Hz'); xlim([.87 lim_x]); ylim([-45 180]);
legend('IE', 'DP')

subplot(313)
semilogx(f_DP,[coh_IE coh_DP]); hold on
grid on; box on; xlabel('Hz'); ylabel('Coherence'); xlim([.87 lim_x]); ylim([0 1]);
legend('IE', 'DP')

