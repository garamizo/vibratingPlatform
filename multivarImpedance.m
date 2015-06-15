% clc;
% clear;
% load ta;% load the vectors ang_dp  ang_ie tdp and  tie, the rest should work
Fs=360;

%%
font=24;    %all fonts of the plots
lim_x=15;   % limit of x axis for view
nfft=2^10
n_win=0.5*nfft
n_ovrlp=0.25*nfft

p_p_dp=ang_dp;
p_p_ie=ang_ie;
fz_p_dp=tdp;
fz_p_ie=tie;
%%


n=999;  
str1='.-b';str2='.-r'; str3='-b';
KTA=1;KFD=0;
Kabot_TA=[0 0; 0 0];
Khuman_TA=[0 0;0 0];

R1=[3.5714 -5.2632;3.5714 5.2632];
Kabot_FD=R1*Kabot_TA*R1';
Khuman_FD=R1*Khuman_TA*R1';


[T_aa_1_1,F_aa_1_1] = tfestimate(ang_dp,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_2,F_aa_1_2] = cpsd(ang_dp,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_3,F_aa_1_3] = cpsd(ang_ie,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_4,F_aa_1_4] = cpsd(ang_ie,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_5,F_aa_1_5] = cpsd(ang_dp,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_1_6,F_aa_1_6] = mscohere(ang_dp,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
T_aa_11=T_aa_1_1.*(1.-(P_aa_1_2.*P_aa_1_3)./(P_aa_1_4.*P_aa_1_5))./(1.-C_aa_1_6);
F_aa_11=F_aa_1_1;
for i=1:length(F_aa_11)
    Z_aa_11(i)=(T_aa_11(i))-(Khuman_TA(1,1)*KTA+Khuman_FD(1,1)*KFD);
end
figure(n);subplot(2,2,1,'XScale','log');hold on;plot(F_aa_11,20*log10(abs(Z_aa_11)),str1); 
phaz_aa_11=angle(Z_aa_11);
phaz_aa_11=unwrap(phaz_aa_11);
phaz_aa_11=180/pi*phaz_aa_11+0/1;
figure(n);subplot(2,2,3,'XScale','log');hold on;plot(F_aa_11,phaz_aa_11,str1);



[T_a_1_1,F_a_1_1] = tfestimate(p_p_dp,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_1_2,F_a_1_2] = cpsd(p_p_dp,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_1_3,F_a_1_3] = cpsd(p_p_ie,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_1_4,F_a_1_4] = cpsd(p_p_ie,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_1_5,F_a_1_5] = cpsd(p_p_dp,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_a_1_6,F_a_1_6] = mscohere(p_p_dp,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
T_a_11=T_a_1_1.*(1.-(P_a_1_2.*P_a_1_3)./(P_a_1_4.*P_a_1_5))./(1.-C_a_1_6);
F_a_11=F_a_1_1;
for i=1:length(F_a_11)
    Z_a_11(i)=T_a_11(i)-(Kabot_TA(1,1)*KTA+Kabot_FD(1,1)*KFD);
end
figure(n);subplot(2,2,1,'XScale','log');hold on;
plot(F_a_11,20*log10(abs(Z_a_11)),str2); 
phaz_a_11=angle(Z_a_11);
pZ11=phaz_a_11;
phaz_a_11=unwrap(phaz_a_11);
phaz_a_11=180/pi*phaz_a_11+0/1;
figure(n);subplot(2,2,3,'XScale','log');hold on;plot(F_a_11,phaz_a_11,str2);
Z11=Z_aa_11-Z_a_11;
figure(n);subplot(2,2,1,'XScale','log','fontsize',14);hold on;
plot(F_a_11,20*log10(abs(Z11)),str3,'LineWidth',2);grid on
ylabel('magnitude (dB)');title('Z_1_1(f)');grid on;box on;
xlim([0.878 lim_x])
legend('Abot+Ankle','Abot','Ankle')
phaz11=angle(Z11);
phaz11=180/pi*phaz11+0/1;
figure(n);hold on
subplot(2,2,3,'XScale','log','fontsize',14);hold on;
plot(F_a_11,phaz11,str3,'LineWidth',2);
ylabel('phase (degree)');xlabel('Hz');grid on;box on;
xlim([0.878 lim_x])



[P_aa_1_7,F_aa_1_7] = cpsd(ang_dp,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_8,F_aa_1_8] = cpsd(ang_ie,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_9,F_aa_1_9] = cpsd(ang_ie,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_10,F_aa_1_10] = cpsd(ang_dp,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_11,F_aa_1_11] = cpsd(ang_ie,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_12,F_aa_1_12] = cpsd(ang_dp,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_13,F_aa_1_13] = cpsd(tdp,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_1_14,F_aa_1_14] = mscohere(ang_ie,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_1_15,F_aa_1_15] = mscohere(ang_ie,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
C_aa_11=real((abs(P_aa_1_7.*P_aa_1_8-P_aa_1_9.*P_aa_1_10).^2)./(P_aa_1_11.*P_aa_1_11.*P_aa_1_12.*P_aa_1_13)./(1.-C_aa_1_14)./(1.-C_aa_1_15));
figure(n+2);subplot(2,2,1,'XScale','log','fontsize',14);hold on;
plot(F_a_11,C_aa_11,str3,'LineWidth',2);grid on;box on;
xlabel('Hz');title('Z_1_1 Coherence');

[P_aa_1_17,F_aa_1_17] = cpsd(p_p_dp,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_18,F_aa_1_18] = cpsd(p_p_ie,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_19,F_aa_1_19] = cpsd(p_p_ie,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_20,F_aa_1_20] = cpsd(p_p_dp,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_21,F_aa_1_21] = cpsd(p_p_ie,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_22,F_aa_1_22] = cpsd(p_p_dp,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_1_23,F_aa_1_23] = cpsd(fz_p_dp,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_1_24,F_aa_1_24] = mscohere(p_p_ie,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_1_25,F_aa_1_25] = mscohere(p_p_ie,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);

C_a_11=real((abs(P_aa_1_17.*P_aa_1_18-P_aa_1_19.*P_aa_1_20).^2)./(P_aa_1_21.*P_aa_1_21.*P_aa_1_22.*P_aa_1_23)./(1.-C_aa_1_24)./(1.-C_aa_1_25));
figure(n+2);subplot(2,2,1);hold on;
plot(F_a_11,C_a_11,str2);
grid on;box on;
xlabel('Hz');title('Z_1_1 Coherence');
legend('Abot+Ankle','Abot','Ankle')
xlim([0.878 lim_x])
ylim([0 1])
[T_aa_2_1,F_aa_2_1] = tfestimate(ang_ie,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_2,F_aa_2_2] = cpsd(ang_ie,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_3,F_aa_2_3] = cpsd(ang_dp,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_4,F_aa_2_4] = cpsd(ang_dp,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_5,F_aa_2_5] = cpsd(ang_ie,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_2_6,F_aa_2_6] = mscohere(ang_dp,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
T_aa_22=T_aa_2_1.*(1.-(P_aa_2_2.*P_aa_2_3)./(P_aa_2_4.*P_aa_2_5))./(1.-C_aa_2_6);
F_aa_22=F_aa_2_1;
for i=1:length(F_aa_22)
    Z_aa_22(i)=T_aa_22(i)-(Khuman_TA(2,2)*KTA+Khuman_FD(2,2)*KFD);
end
figure(n);subplot(2,2,2,'XScale','log');hold on;plot(F_aa_22,20*log10(abs(Z_aa_22)),str1); 
phaz_aa_22=angle(Z_aa_22);
phaz_aa_22=unwrap(phaz_aa_22);
phaz_aa_22=180/pi*phaz_aa_22+0/1;
figure(n);subplot(2,2,4,'XScale','log');hold on;plot(F_aa_22,phaz_aa_22,str1);

[T_a_2_1,F_a_2_1] = tfestimate(p_p_ie,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_2_2,F_a_2_2] = cpsd(p_p_ie,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_2_3,F_a_2_3] = cpsd(p_p_dp,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_2_4,F_a_2_4] = cpsd(p_p_dp,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_2_5,F_a_2_5] = cpsd(p_p_ie,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_a_2_6,F_a_2_6] = mscohere(p_p_dp,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
T_a_22=T_a_2_1.*(1.-(P_a_2_2.*P_a_2_3)./(P_a_2_4.*P_a_2_5))./(1.-C_a_2_6);
F_a_22=F_a_2_1;
for i=1:length(F_a_22)
    Z_a_22(i)=T_a_22(i)-(Kabot_TA(2,2)*KTA+Kabot_FD(2,2)*KFD);
end
figure(n);subplot(2,2,2,'XScale','log');hold on;plot(F_a_22,20*log10(abs(Z_a_22)),str2); 
phaz_a_22=angle(Z_a_22);
phaz_a_22=unwrap(phaz_a_22);
phaz_a_22=180/pi*phaz_a_22+0/1;
figure(n);subplot(2,2,4,'XScale','log');hold on;plot(F_a_22,phaz_a_22,str2);

Z22=Z_aa_22-Z_a_22;
figure(n);subplot(2,2,2,'XScale','log','fontsize',14);hold on;
plot(F_a_22,20*log10(abs(Z22)),str3,'LineWidth',2);
ylabel('magnitude (dB)');title('Z_2_2(f)');grid on;box on;
xlim([.7 30])
legend('Abot+Ankle','Abot','Ankle')
phaz22=angle(Z22);
phaz22=180/pi*phaz22+0/1;
figure(n);subplot(2,2,4,'XScale','log','fontsize',14);hold on;
plot(F_a_22,phaz22,str3,'LineWidth',2);
ylabel('phase (degree)');xlabel('Hz');grid on;box on;
xlim([.7 30])
[P_aa_2_7,F_aa_2_7] = cpsd(ang_ie,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_8,F_aa_2_8] = cpsd(ang_dp,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_9,F_aa_2_9] = cpsd(ang_dp,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_10,F_aa_2_10] = cpsd(ang_ie,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_11,F_aa_2_11] = cpsd(ang_dp,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_12,F_aa_2_12] = cpsd(ang_ie,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_13,F_aa_2_13] = cpsd(tie,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_2_14,F_aa_2_14] = mscohere(ang_dp,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_2_15,F_aa_2_15] = mscohere(ang_dp,tie,hamming(n_win),n_ovrlp,nfft,Fs);

C_aa_22=real((abs(P_aa_2_7.*P_aa_2_8-P_aa_2_9.*P_aa_2_10).^2)./(P_aa_2_11.*P_aa_2_11.*P_aa_2_12.*P_aa_2_13)./(1.-C_aa_2_14)./(1.-C_aa_2_15));
figure(n+2);subplot(2,2,4,'XScale','log','fontsize',14);hold on;
plot(F_a_22,C_aa_22,str3,'LineWidth',2);grid on;box on;
xlabel('Hz');title('Z_2_2 Coherence');
[P_aa_2_17,F_aa_2_17] = cpsd(p_p_ie,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_18,F_aa_2_18] = cpsd(p_p_dp,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_19,F_aa_2_19] = cpsd(p_p_dp,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_20,F_aa_2_20] = cpsd(p_p_ie,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_21,F_aa_2_21] = cpsd(p_p_dp,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_22,F_aa_2_22] = cpsd(p_p_ie,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_2_23,F_aa_2_23] = cpsd(fz_p_ie,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_2_24,F_aa_2_24] = mscohere(p_p_dp,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_2_25,F_aa_2_25] = mscohere(p_p_dp,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);

C_a_22=real((abs(P_aa_2_17.*P_aa_2_18-P_aa_2_19.*P_aa_2_20).^2)./(P_aa_2_21.*P_aa_2_21.*P_aa_2_22.*P_aa_2_23)./(1.-C_aa_2_24)./(1.-C_aa_2_25));
figure(n+2);subplot(2,2,4);hold on;
plot(F_a_22,C_a_22,str2);grid on;box on;
xlabel('Hz');title('Z_2_2 Coherence');
legend('Abot+Ankle','Abot','Ankle')
xlim([0.878 lim_x])
ylim([0 1])
[T_aa_3_1,F_aa_3_1] = tfestimate(ang_ie,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_2,F_aa_3_2] = cpsd(ang_ie,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_3,F_aa_3_3] = cpsd(ang_dp,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_4,F_aa_3_4] = cpsd(ang_dp,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_5,F_aa_3_5] = cpsd(ang_ie,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_3_6,F_aa_3_6] = mscohere(ang_dp,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
T_aa_12=T_aa_3_1.*(1.-(P_aa_3_2.*P_aa_3_3)./(P_aa_3_4.*P_aa_3_5))./(1.-C_aa_3_6);
F_aa_12=F_aa_3_1;
for i=1:length(F_aa_12)
    Z_aa_12(i)=T_aa_12(i)-(Khuman_TA(1,2)*KTA+Khuman_FD(1,2)*KFD);
end
figure(n+1);subplot(2,2,1,'XScale','log','fontsize',14);hold on;plot(F_aa_12,20*log10(abs(Z_aa_12)),str1); 
phaz_aa_12=angle(Z_aa_12);
phaz_aa_12=unwrap(phaz_aa_12);
phaz_aa_12=180/pi*phaz_aa_12-180/1;
figure(n+1);subplot(2,2,3,'XScale','log','fontsize',14);hold on;plot(F_aa_12,phaz_aa_12,str1);

[T_a_3_1,F_a_3_1] = tfestimate(p_p_ie,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_3_2,F_a_3_2] = cpsd(p_p_ie,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_3_3,F_a_3_3] = cpsd(p_p_dp,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_3_4,F_a_3_4] = cpsd(p_p_dp,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_3_5,F_a_3_5] = cpsd(p_p_ie,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_a_3_6,F_a_3_6] = mscohere(p_p_dp,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
T_a_12=T_a_3_1.*(1.-(P_a_3_2.*P_a_3_3)./(P_a_3_4.*P_a_3_5))./(1.-C_a_3_6);
F_a_12=F_a_3_1;
for i=1:length(F_a_12)
    Z_a_12(i)=T_a_12(i)-(Kabot_TA(1,2)*KTA+Kabot_FD(1,2)*KFD);
end
phaz_a_12=angle(Z_a_12);
phaz_a_12=180/pi*phaz_a_12+0/1;
Z12=Z_aa_12-Z_a_12;

figure(n+1);subplot(2,2,1,'XScale','log','fontsize',14);hold on;
ylabel('magnitude (dB)');title('Z_1_2(f)','fontsize',14);grid on;box on;
xlim([.7 30])
phaz12=angle(Z12);
phaz12=180/pi*phaz12+0/1;
figure(n+1);subplot(2,2,3,'XScale','log','fontsize',14);hold on;
ylabel('phase (degree)');xlabel('Hz');grid on;box on;
xlim([.7 30])

[P_aa_3_7,F_aa_3_7] = cpsd(ang_ie,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_8,F_aa_3_8] = cpsd(ang_dp,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_9,F_aa_3_9] = cpsd(ang_dp,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_10,F_aa_3_10] = cpsd(ang_ie,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_11,F_aa_3_11] = cpsd(ang_dp,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_12,F_aa_3_12] = cpsd(ang_ie,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_13,F_aa_3_13] = cpsd(tdp,tdp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_3_14,F_aa_3_14] = mscohere(ang_dp,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_3_15,F_aa_3_15] = mscohere(ang_dp,tdp,hamming(n_win),n_ovrlp,nfft,Fs);

C_aa_12=real((abs(P_aa_3_7.*P_aa_3_8-P_aa_3_9.*P_aa_3_10).^2)./(P_aa_3_11.*P_aa_3_11.*P_aa_3_12.*P_aa_3_13)./(1.-C_aa_3_14)./(1.-C_aa_3_15));
figure(n+2);subplot(2,2,2,'XScale','log','fontsize',14);hold on;
plot(F_a_12,C_aa_12,str3,'LineWidth',2);grid on;box on;
xlabel('Hz');title('Z_1_2 Coherence');

[P_aa_3_17,F_aa_3_17] = cpsd(p_p_ie,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_18,F_aa_3_18] = cpsd(p_p_dp,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_19,F_aa_3_19] = cpsd(p_p_dp,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_20,F_aa_3_20] = cpsd(p_p_ie,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_21,F_aa_3_21] = cpsd(p_p_dp,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_22,F_aa_3_22] = cpsd(p_p_ie,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_3_23,F_aa_3_23] = cpsd(fz_p_dp,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_3_24,F_aa_3_24] = mscohere(p_p_dp,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_3_25,F_aa_3_25] = mscohere(p_p_dp,fz_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);

C_a_12=real((abs(P_aa_3_17.*P_aa_3_18-P_aa_3_19.*P_aa_3_20).^2)./(P_aa_3_21.*P_aa_3_21.*P_aa_3_22.*P_aa_3_23)./(1.-C_aa_3_24)./(1.-C_aa_3_25));
xlabel('Hz');title('Z_1_2 Coherence');
xlim([0.878 lim_x])
ylim([0 1])
[T_aa_4_1,F_aa_4_1] = tfestimate(ang_dp,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_2,F_aa_4_2] = cpsd(ang_dp,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_3,F_aa_4_3] = cpsd(ang_ie,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_4,F_aa_4_4] = cpsd(ang_ie,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_5,F_aa_4_5] = cpsd(ang_dp,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_4_6,F_aa_4_6] = mscohere(ang_dp,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
T_aa_21=T_aa_4_1.*(1.-(P_aa_4_2.*P_aa_4_3)./(P_aa_4_4.*P_aa_4_5))./(1.-C_aa_4_6);
F_aa_21=F_aa_4_1;
for i=1:length(F_aa_21)
    Z_aa_21(i)=T_aa_21(i)-(Khuman_TA(2,1)*KTA+Khuman_FD(2,1)*KFD);
end
figure(n+1);subplot(2,2,2,'XScale','log','fontsize',14);hold on;plot(F_aa_21,20*log10(abs(Z_aa_21)),str1); 
phaz_aa_21=angle(Z_aa_21);
phaz_aa_21=unwrap(phaz_aa_21);
phaz_aa_21=180/pi*phaz_aa_21-180/1;
figure(n+1);subplot(2,2,4,'XScale','log','fontsize',14);hold on;plot(F_aa_21,phaz_aa_21,str1);

[T_a_4_1,F_a_4_1] = tfestimate(p_p_dp,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_4_2,F_a_4_2] = cpsd(p_p_dp,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_4_3,F_a_4_3] = cpsd(p_p_ie,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_4_4,F_a_4_4] = cpsd(p_p_ie,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_a_4_5,F_a_4_5] = cpsd(p_p_dp,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_a_4_6,F_a_4_6] = mscohere(p_p_dp,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
T_a_21=T_a_4_1.*(1.-(P_a_4_2.*P_a_4_3)./(P_a_4_4.*P_a_4_5))./(1.-C_a_4_6);
F_a_21=F_a_4_1;
for i=1:length(F_a_21)
    Z_a_21(i)=T_a_21(i)-(Kabot_TA(2,1)*KTA+Kabot_FD(2,1)*KFD);
end
 phaz_a_21=angle(Z_a_21);
phaz_a_21=180/pi*phaz_a_21+0/1;

Z21=Z_aa_21-Z_a_21;
figure(n+1);subplot(2,2,2,'XScale','log','fontsize',14);hold on;
ylabel('magnitude (dB)');title('Z_2_1(f)');grid on;box on;
xlim([.7 30])
phaz21=angle(Z21);
phaz21=180/pi*phaz21+0/1;
figure(n+1);subplot(2,2,4,'XScale','log','fontsize',14);hold on;
ylabel('phase (degree)');xlabel('Hz');grid on;box on;
xlim([.7 30])
[P_aa_4_7,F_aa_4_7] = cpsd(ang_dp,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_8,F_aa_4_8] = cpsd(ang_ie,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_9,F_aa_4_9] = cpsd(ang_ie,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_10,F_aa_4_10] = cpsd(ang_dp,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_11,F_aa_4_11] = cpsd(ang_ie,ang_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_12,F_aa_4_12] = cpsd(ang_dp,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_13,F_aa_4_13] = cpsd(tie,tie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_4_14,F_aa_4_14] = mscohere(ang_ie,ang_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_4_15,F_aa_4_15] = mscohere(ang_ie,tie,hamming(n_win),n_ovrlp,nfft,Fs);

C_aa_21=real((abs(P_aa_4_7.*P_aa_4_8-P_aa_4_9.*P_aa_4_10).^2)./(P_aa_4_11.*P_aa_4_11.*P_aa_4_12.*P_aa_4_13)./(1.-C_aa_4_14)./(1.-C_aa_4_15));
figure(n+2);subplot(2,2,3,'XScale','log','fontsize',14);hold on;
plot(F_a_21,C_aa_21,str3,'LineWidth',2);grid on;box on;
xlabel('Hz');title('Z_2_1 Coherence');

[P_aa_4_17,F_aa_4_17] = cpsd(p_p_dp,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_18,F_aa_4_18] = cpsd(p_p_ie,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_19,F_aa_4_19] = cpsd(p_p_ie,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_20,F_aa_4_20] = cpsd(p_p_dp,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_21,F_aa_4_21] = cpsd(p_p_ie,p_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_22,F_aa_4_22] = cpsd(p_p_dp,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[P_aa_4_23,F_aa_4_23] = cpsd(fz_p_ie,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_4_24,F_aa_4_24] = mscohere(p_p_ie,p_p_dp,hamming(n_win),n_ovrlp,nfft,Fs);
[C_aa_4_25,F_aa_4_25] = mscohere(p_p_ie,fz_p_ie,hamming(n_win),n_ovrlp,nfft,Fs);

C_a_21=real((abs(P_aa_4_17.*P_aa_4_18-P_aa_4_19.*P_aa_4_20).^2)./(P_aa_4_21.*P_aa_4_21.*P_aa_4_22.*P_aa_4_23)./(1.-C_aa_4_24)./(1.-C_aa_4_25));
xlabel('Hz');title('Z_2_1 Coherence');
xlim([0.878 lim_x])
ylim([0 1])