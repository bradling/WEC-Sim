%% Run the WEC-Sim RM3 Test Case for 3DOF w/o PTO
% This script will run the RM3 in WEC-Sim for regular waves with Hs=2.5[m] 
% and Tp=8[s]. The RM3 WEC models has 2 bodies, restricted to surge, heave 
% and pitch motion, and has PTO damping=0[kN-s/m]. This script compares 
% results from the latest WEC-Sim run, to a previous compile of WEC-Sim, 
% ANSYS-AQWA and DNV-GL's WaveDyn. 
% 
%% Load Data and Run Simulation
% Run Simulation
wecSim;

% Load Data
load('Response_org.mat');

% Post-Process Data
Tshift=0;

B1.WEC_Sim_new.time=output.bodies(1).time-Tshift;
Hshift1=output.bodies(1).position(1,3);
B1.WEC_Sim_new.heave=output.bodies(1).position(:,3)-Hshift1;
B1.WEC_Sim_new.pitch=(output.bodies(1).position(:,5))*180/pi;

B2.WEC_Sim_new.time=output.bodies(2).time-Tshift;
Hshift2=output.bodies(2).position(1,3);
B2.WEC_Sim_new.heave=output.bodies(2).position(:,3)-Hshift2;
B2.WEC_Sim_new.pitch=(output.bodies(2).position(:,5))*180/pi;

Rel.WEC_Sim_new.time=B1.WEC_Sim_new.time;
Rel.WEC_Sim_new.heave=B1.WEC_Sim_new.heave-B2.WEC_Sim_new.heave;

clear h Tshift Hshift1 Hshift2 ans
save(['.' filesep 'output' filesep 'Response.mat'])

%% Quantify Maximum Difference Between Saved and Current WEC-Sim Runs
[B1_H_max,B1_H_I]=max(abs(B1.WEC_Sim_org.heave-B1.WEC_Sim_new.heave));
[B2_H_max,B2_H_I]=max(abs(B2.WEC_Sim_org.heave-B2.WEC_Sim_new.heave));
[Rel_H_max,Rel_H_I]=max(abs(Rel.WEC_Sim_org.heave-Rel.WEC_Sim_new.heave));
[B1_P_max,B1_P_I]=max(abs(B1.WEC_Sim_org.pitch-B1.WEC_Sim_new.pitch));

fprintf(['\nBody1_Heave Max Diff = ' num2str(B1_H_max) ...
    ' m at time = ' num2str(B1.WEC_Sim_org.time(B1_H_I)) 's\n'])
fprintf(['Body2_Heave Max Diff = ' num2str(B2_H_max) ...
    ' m at time = ' num2str(B2.WEC_Sim_org.time(B2_H_I)) 's\n'])
fprintf(['Relative_Heave Max Diff = ' num2str(Rel_H_max) ...
    ' m at time = ' num2str(Rel.WEC_Sim_org.time(Rel_H_I)) 's\n'])
fprintf(['Body1_Pitch Max Diff = ' num2str(B1_P_max) ...
    ' m at time = ' num2str(B1.WEC_Sim_org.time(B1_P_I)) 's\n'])


%% Plot Heave Comparison
h=figure('units','normalized','outerposition',[0 0 1 1]);
%First row = All simulations, all times
%Second row = All simulations, t=350-400s
%Third row = Original and New WEC-Sim runs only, t=350-400s

%First Column: Body 1 Heave
subplot(3,3,1)
plot(B1.OrcaFlex.time,B1.OrcaFlex.heave,'b-',...
    B1.WEC_Sim_org.time,B1.WEC_Sim_org.heave,'r-',...
    B1.WEC_Sim_new.time,B1.WEC_Sim_new.heave,'k-')
xlabel('time(s)')
ylabel('Heave(m)')
title('Float 3DOF Heave noPTO T=8s H=2.5m')
str1=['Max Diff = ' num2str(B1_H_max) ' m'];
str2=['at time = ' num2str(B1.WEC_Sim_org.time(B1_H_I)) 's'];
a=text(10,1.7,str1);set(a,'FontSize',12)
a=text(10,1.4,str2);set(a,'FontSize',12)
xlim([0 400])
ylim([-2 2])

subplot(3,3,4)
plot(B1.OrcaFlex.time(find(B1.OrcaFlex.time==350):end),...
    B1.OrcaFlex.heave(find(B1.OrcaFlex.time==350):end),'b-',...
    B1.WEC_Sim_org.time(find(B1.WEC_Sim_org.time==350):end),...
    B1.WEC_Sim_org.heave(find(B1.WEC_Sim_org.time==350):end),'r-',...
    B1.WEC_Sim_new.time(find(B1.WEC_Sim_new.time==350):end),...
    B1.WEC_Sim_new.heave(find(B1.WEC_Sim_new.time==350):end),'k-')
xlabel('time(s)')
ylabel('Heave(m)')
xlim([350 400])
ylim([-2 2])

subplot(3,3,7)
m=plot(B1.WEC_Sim_org.time(find(B1.WEC_Sim_org.time==350):end),...
    B1.WEC_Sim_org.heave(find(B1.WEC_Sim_org.time==350):end),'r-',...
    B1.WEC_Sim_new.time(find(B1.WEC_Sim_new.time==350):end),...
    B1.WEC_Sim_new.heave(find(B1.WEC_Sim_new.time==350):end),'k-');
a=get(m(1),'LineWidth')+1;
set(m(1),'LineWidth',a)
xlabel('time(s)')
ylabel('Heave(m)')
xlim([350 400])
ylim([-2 2])

%Second Column: Body 2 Heave
subplot(3,3,2)
plot(B2.WEC_Sim_org.time,B2.WEC_Sim_org.heave,'r-',...
    B2.OrcaFlex.time,B2.OrcaFlex.heave,'b-',...
    B2.WEC_Sim_org.time,B2.WEC_Sim_org.heave,'r-',...
    B2.WEC_Sim_new.time,B2.WEC_Sim_new.heave,'k-')
xlabel('time(s)')
ylabel('Heave(m)')
title('Spar/Plate 3DOF Heave noPTO')
str1=['Max Diff = ' num2str(B2_H_max) ' m'];
str2=['at time = ' num2str(B2.WEC_Sim_org.time(B2_H_I)) 's'];
a=text(10,0.18,str1);set(a,'FontSize',12)
a=text(10,0.15,str2);set(a,'FontSize',12)
xlim([0 400])
ylim([-0.2 0.2])

subplot(3,3,5)
plot(B2.WEC_Sim_org.time(find(B2.WEC_Sim_org.time==350):end),...
    B2.WEC_Sim_org.heave(find(B2.WEC_Sim_org.time==350):end),'r-',...
    B2.OrcaFlex.time(find(B2.OrcaFlex.time==350):end),...
    B2.OrcaFlex.heave(find(B2.OrcaFlex.time==350):end),'b-',...
    B2.WEC_Sim_org.time(find(B2.WEC_Sim_org.time==350):end),...
    B2.WEC_Sim_org.heave(find(B2.WEC_Sim_org.time==350):end),'r-',...
    B2.WEC_Sim_new.time(find(B2.WEC_Sim_new.time==350):end),...
    B2.WEC_Sim_new.heave(find(B2.WEC_Sim_new.time==350):end),'k-')
xlabel('time(s)')
ylabel('Heave(m)')
xlim([350 400])
ylim([-0.2 0.2])

subplot(3,3,8)
m=plot(B2.WEC_Sim_org.time(find(B2.WEC_Sim_org.time==350):end),...
    B2.WEC_Sim_org.heave(find(B2.WEC_Sim_org.time==350):end),'r-',...
    B2.WEC_Sim_new.time(find(B2.WEC_Sim_new.time==350):end),...
    B2.WEC_Sim_new.heave(find(B2.WEC_Sim_new.time==350):end),'k-');
a=get(m(1),'LineWidth')+1;
set(m(1),'LineWidth',a)
xlabel('time(s)')
ylabel('Heave(m)')
xlim([350 400])
ylim([-0.2 0.2])

%Third Column: Relative Heave
subplot(3,3,3)
plot(Rel.OrcaFlex.time,Rel.OrcaFlex.heave,'b-',...
    Rel.WEC_Sim_org.time,Rel.WEC_Sim_org.heave,'r-',...
    Rel.WEC_Sim_new.time,Rel.WEC_Sim_new.heave,'k-')
xlabel('time(s)')
ylabel('Heave(m)')
title('Relative Motion 3DOF Heave noPTO')
l=legend('OrcaFlex','WEC-Sim org','WEC-Sim New');
set(l,'Position',[0.90 0.90 0.07 0.07],'Units','normalized',...
    'FontSize',12);
str1=['Max Diff = ' num2str(Rel_H_max) ' m'];
str2=['at time = ' num2str(Rel.WEC_Sim_org.time(Rel_H_I)) 's'];
a=text(10,1.7,str1);set(a,'FontSize',12)
a=text(10,1.4,str2);set(a,'FontSize',12)
xlim([0 400])
ylim([-2 2])

subplot(3,3,6)
plot(Rel.OrcaFlex.time(find(Rel.OrcaFlex.time==350):end),...
    Rel.OrcaFlex.heave(find(Rel.OrcaFlex.time==350):end),'b-',...
    Rel.WEC_Sim_org.time(find(Rel.WEC_Sim_org.time==350):end),...
    Rel.WEC_Sim_org.heave(find(Rel.WEC_Sim_org.time==350):end),'r-',...
    Rel.WEC_Sim_new.time(find(Rel.WEC_Sim_new.time==350):end),...
    Rel.WEC_Sim_new.heave(find(Rel.WEC_Sim_new.time==350):end),'k-')
xlabel('time(s)')
ylabel('Heave(m)')
xlim([350 400])
ylim([-2 2])

subplot(3,3,9)
m=plot(Rel.WEC_Sim_org.time(find(Rel.WEC_Sim_org.time==350):end),...
    Rel.WEC_Sim_org.heave(find(Rel.WEC_Sim_org.time==350):end),'r-',...
    Rel.WEC_Sim_new.time(find(Rel.WEC_Sim_new.time==350):end),...
    Rel.WEC_Sim_new.heave(find(Rel.WEC_Sim_new.time==350):end),'k-');
a=get(m(1),'LineWidth')+1;
set(m(1),'LineWidth',a)
xlabel('time(s)')
ylabel('Heave(m)')
xlim([350 400])
ylim([-2 2])

saveas(h,['.' filesep 'output' filesep 'test_heave'],'fig')

%% Plot Pitch Comparison
h=figure('units','normalized','outerposition',[0 0 1 1]);
%First row = All simulations, all times
%Second row = All simulations, t=350-400s
%Third row = Original and New WEC-Sim runs only, t=350-400s

subplot(3,1,1)
plot(B1.OrcaFlex.time,B1.OrcaFlex.pitch,'b-',...
    B1.WEC_Sim_org.time,B1.WEC_Sim_org.pitch,'r-',...
    B1.WEC_Sim_new.time,B1.WEC_Sim_new.pitch,'k-')
xlabel('time(s)')
ylabel('Pitch(deg)')
title('Float 3DOF Pitch noPTO T=8s H=2.5m')
str1=['Max Diff = ' num2str(B1_P_max) ' m'];
str2=['at time = ' num2str(B1.WEC_Sim_org.time(B1_P_I)) 's'];
a=text(5,1.2,str1);set(a,'FontSize',16)
a=text(5,0.9,str2);set(a,'FontSize',16)
xlim([0 400])
ylim([-1.5 1.5])
l=legend('OrcaFlex','WEC-Sim org','WEC-Sim New');
set(l,'Position',[0.90 0.90 0.07 0.07],'Units','normalized',...
    'FontSize',12);

subplot(3,1,2)
plot(B1.OrcaFlex.time(find(B1.OrcaFlex.time==350):end),...
    B1.OrcaFlex.pitch(find(B1.OrcaFlex.time==350):end),'b-',...
    B1.WEC_Sim_org.time(find(B1.WEC_Sim_org.time==350):end),...
    B1.WEC_Sim_org.pitch(find(B1.WEC_Sim_org.time==350):end),'r-',...
    B1.WEC_Sim_new.time(find(B1.WEC_Sim_new.time==350):end),...
    B1.WEC_Sim_new.pitch(find(B1.WEC_Sim_new.time==350):end),'k-')
xlabel('time(s)')
ylabel('Pitch(deg)')
xlim([350 400])
ylim([-1.5 1.5])

subplot(3,1,3)
m=plot(B1.WEC_Sim_org.time(find(B1.WEC_Sim_org.time==350):end),...
    B1.WEC_Sim_org.pitch(find(B1.WEC_Sim_org.time==350):end),'r-',...
    B1.WEC_Sim_new.time(find(B1.WEC_Sim_new.time==350):end),...
    B1.WEC_Sim_new.pitch(find(B1.WEC_Sim_new.time==350):end),'k-');
a=get(m(1),'LineWidth')+1;
set(m(1),'LineWidth',a)
xlabel('time(s)')
ylabel('Pitch(deg)')
xlim([350 400])
ylim([-1.5 1.5])

saveas(h,['.' filesep 'output' filesep 'test_pitch'],'fig')

%%
clear h l m str1 str2 ans a B1_H_max B1_H_I B2_H_max B1 B2 Rel ...
    B2_H_I Rel_H_max Rel_H_I B1_P_max B1_P_I
