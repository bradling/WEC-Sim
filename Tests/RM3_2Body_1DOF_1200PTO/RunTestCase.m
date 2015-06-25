%% Run the WEC-Sim RM3 Test Case for 1DOF w/PTO
% This script will run the RM3 in WEC-Sim for regular waves with Hs=2.5[m] 
% and Tp=8[s]. The RM3 WEC models has 2 bodies, restricted to heave motion
% only, and has PTO damping=1200[kN-s/m]. This script compares results from
% the latest WEC-Sim run, to a previous compile of WEC-Sim, ANSYS-AQWA and 
% DNV-GL's WaveDyn. For more info reference Ruehl OMAE 2014.
% 
%% Load Data and Run Simulation
% Run Simulation
wecSim;

% Load Previous WEC-Sim Data
load('Response_org.mat')

% Post-Process Data
Tshift=-2;

B1.WEC_Sim_new.time=output.bodies(1).time-Tshift;
Hshift1=output.bodies(1).position(1,3);
B1.WEC_Sim_new.heave=output.bodies(1).position(:,3)-Hshift1;

B2.WEC_Sim_new.time=output.bodies(2).time-Tshift;
Hshift2=output.bodies(2).position(1,3);
B2.WEC_Sim_new.heave=output.bodies(2).position(:,3)-Hshift2;

Rel.WEC_Sim_new.time=B1.WEC_Sim_new.time;
Rel.WEC_Sim_new.heave=B1.WEC_Sim_new.heave-B2.WEC_Sim_new.heave;

clear h Tshift Hshift1 Hshift2 ans
save(['.' filesep 'output' filesep 'Response.mat'])

%% Quantify Maximum Difference Between Saved and Current WEC-Sim Runs
[B1_H_max,B1_H_I]=max(abs(B1.WEC_Sim_org.heave-B1.WEC_Sim_new.heave));
[B2_H_max,B2_H_I]=max(abs(B2.WEC_Sim_org.heave-B2.WEC_Sim_new.heave));
[Rel_H_max,Rel_H_I]=max(abs(Rel.WEC_Sim_org.heave-Rel.WEC_Sim_new.heave));

fprintf(['\nBody1_Heave Max Diff = ' num2str(B1_H_max) ...
    ' m at time = ' num2str(B1.WEC_Sim_org.time(B1_H_I)) 's\n'])
fprintf(['Body2_Heave Max Diff = ' num2str(B2_H_max) ...
    ' m at time = ' num2str(B2.WEC_Sim_org.time(B2_H_I)) 's\n'])
fprintf(['Relative_Heave Max Diff = ' num2str(Rel_H_max) ...
    ' m at time = ' num2str(Rel.WEC_Sim_org.time(Rel_H_I)) 's\n'])

%% Plot Heave Comparisons
h=figure('units','normalized','outerposition',[0 0 1 1]);
%First row = All simulations, all times
%Second row = All simulations, t=350-400s
%Third row = Original and New WEC-Sim runs only, t=350-400s

%First Column: Body 1 Heave
subplot(3,3,1)
plot(B1.WaveDyn.time,B1.WaveDyn.heave,'b-',...
    B1.AQWA.time,B1.AQWA.heave,'g-',...
    B1.WEC_Sim_org.time,B1.WEC_Sim_org.heave,'r-',...
    B1.WEC_Sim_new.time,B1.WEC_Sim_new.heave,'k-')
xlabel('time(s)')
ylabel('Heave(m)')
title('Float 1DOF 1200PTO')
str1=['Max Diff = ' num2str(B1_H_max) ' m'];
str2=['at time = ' num2str(B1.WEC_Sim_org.time(B1_H_I)) 's'];
a=text(10,1.5,str1);set(a,'FontSize',12)
a=text(10,1.2,str2);set(a,'FontSize',12)
xlim([0 400])
ylim([-2 2])

subplot(3,3,4)
plot(B1.WaveDyn.time(find(B1.WaveDyn.time>350, 1 ):end),...
    B1.WaveDyn.heave(find(B1.WaveDyn.time>350, 1 ):end),'b-',...
    B1.AQWA.time(find(B1.AQWA.time==350):end),...
    B1.AQWA.heave(find(B1.AQWA.time==350):end),'g-',...
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
    B2.WaveDyn.time,B2.WaveDyn.heave,'b-',...
    B2.AQWA.time,B2.AQWA.heave,'g-',...
    B2.WEC_Sim_org.time,B2.WEC_Sim_org.heave,'r-',...
    B2.WEC_Sim_new.time,B2.WEC_Sim_new.heave,'k-')
xlabel('time(s)')
ylabel('Heave(m)')
title('Spar/Plate 1DOF 1200PTO')
str1=['Max Diff = ' num2str(B2_H_max) ' m'];
str2=['at time = ' num2str(B1.WEC_Sim_org.time(B2_H_I)) 's'];
a=text(10,0.18,str1);set(a,'FontSize',12)
a=text(10,0.15,str2);set(a,'FontSize',12)
xlim([0 400])
ylim([-0.2 0.2])

subplot(3,3,5)
plot(B2.WaveDyn.time(find(B2.WaveDyn.time>350, 1 ):end),...
    B2.WaveDyn.heave(find(B2.WaveDyn.time>350, 1 ):end),'b-',...
    B2.AQWA.time(find(B2.AQWA.time==350):end),...
    B2.AQWA.heave(find(B2.AQWA.time==350):end),'g-',...
    B2.WEC_Sim_org.time(find(B2.WEC_Sim_org.time==350):end),...
    B2.WEC_Sim_org.heave(find(B2.WEC_Sim_new.time==350):end),'r-',...
    B2.WEC_Sim_new.time(find(B2.WEC_Sim_org.time==350):end),...
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
plot(Rel.WaveDyn.time,Rel.WaveDyn.heave,'b-',...
    Rel.AQWA.time,Rel.AQWA.heave,'g-',...
    Rel.WEC_Sim_org.time,Rel.WEC_Sim_org.heave,'r-',...
    Rel.WEC_Sim_new.time,Rel.WEC_Sim_new.heave,'k-')
xlabel('time(s)')
ylabel('Heave(m)')
title('Relative Motion 1DOF 1200PTO')
str1=['Max Diff = ' num2str(Rel_H_max) ' m'];
str2=['at time = ' num2str(Rel.WEC_Sim_org.time(Rel_H_I)) 's'];
a=text(10,1.5,str1);set(a,'FontSize',12)
a=text(10,1.2,str2);set(a,'FontSize',12)
xlim([0 400])
ylim([-2 2])
l=legend('WaveDyn','AQWA','WEC-Sim org','WEC-Sim New');
set(l,'Position',[0.90 0.90 0.07 0.07],'Units','normalized',...
    'FontSize',12);

subplot(3,3,6)
plot(Rel.WaveDyn.time(find(Rel.WaveDyn.time>350, 1 ):end),...
    Rel.WaveDyn.heave(find(Rel.WaveDyn.time>350, 1 ):end),'b-',...
    Rel.AQWA.time(find( Rel.AQWA.time==350):end),...
    Rel.AQWA.heave(find( Rel.AQWA.time==350):end),'g-',...
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

saveas(h,['.' filesep 'output' filesep 'test'],'fig')

%%
clear h l m B1_H_Tolerance B2_H_Tolerance Rel_H_Tolerance str1 str2 ...
    B1_H_max B1_H_I B2_H_max B2_H_I Rel_H_max Rel_H_I pf a B1 B2 Rel 
