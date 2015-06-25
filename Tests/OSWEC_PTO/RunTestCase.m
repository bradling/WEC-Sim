%% Run the WEC-Sim OSWEC Test Case for 1DOF w/o PTO
% This script will run OSWEC in WEC-Sim for regular waves with Hs=2.5[m] 
% and Tp=8[s]. The OSWEC model has 2 bodies, restricted to pitch motion 
% only, and has PTO damping=0[kN-s/m]. This script compares results from 
% the latest WEC-Sim run, to a previous compile of WEC-Sim.
% 
%% Run Simulation
wecSim;

% Load Data
load('Response_org.mat');

% Post-Process Data
B1.WEC_Sim_org.time=Response_org(1).time;
B1.WEC_Sim_org.pitch=Response_org(1).position(:,5)-...
    Response_org(1).position(1,5);

B1.WEC_Sim_new.time=output.bodies(1).time;
B1.WEC_Sim_new.pitch=(output.bodies(1).position(:,5));%*180/pi;

clear body_org joint_org Power_org Response_org simu_org waves_org
save(['.' filesep 'output' filesep 'Response.mat'])

%% Quantify Maximum Difference Between Saved and Current WEC-Sim Runs
[B1_P_max,B1_P_I]=max(abs(B1.WEC_Sim_org.pitch-B1.WEC_Sim_new.pitch));

fprintf(['Body1_Pitch Max Diff = ' num2str(B1_P_max) ...
    ' m at time = ' num2str(B1.WEC_Sim_org.time(B1_P_I)) 's\n'])

%% Plot Pitch Comparison
h=figure('units','normalized','outerposition',[0 0 1 1]);

m=plot(B1.WEC_Sim_org.time,B1.WEC_Sim_org.pitch,'r-',...
    B1.WEC_Sim_new.time,B1.WEC_Sim_new.pitch,'k-');
xlabel('time(s)')
ylabel('Pitch(deg)')
title('Float 3DOF Pitch noPTO T=8s H=2.5m')
str1=['Max Diff = ' num2str(B1_P_max) ' m'];
str2=['at time = ' num2str(B1.WEC_Sim_org.time(B1_P_I)) 's'];
a=text(5,1.2,str1);set(a,'FontSize',16)
a=text(5,0.9,str2);set(a,'FontSize',16)
a=get(m(1),'LineWidth')+1;
set(m(1),'LineWidth',a);
xlim([0 400])
ylim([-1.5 1.5])
l=legend('WEC-Sim org','WEC-Sim New');

saveas(h,['.' filesep 'output' filesep 'test_pitch'],'fig')

%%
clear B1 h str1 str2 a l m B1_P_max B1_P_I
