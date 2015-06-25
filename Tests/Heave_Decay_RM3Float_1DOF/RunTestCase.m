%% Run the WEC-Sim Test Case for Heave Decay
% This script will run the RM3 float response to a heave decay test, and
% compare its results to the analytical solution using WAMIT coefficients.
%
%% Run Simulation
wecSim;

% Post-Process Data
Tshift=0;
B1.WEC_Sim_new.time=output.bodies(1).time-Tshift;
Hshift1=output.bodies(1).position(1,3)-2;
B1.WEC_Sim_new.heave=output.bodies(1).position(:,3)-Hshift1;

clear h Tshift Hshift1 ans
save(['.' filesep 'output' filesep 'Response.mat'])

%% Analytical Solution

Xinit=2; 
Vinit=0;
m=2178788; %mass + added mass
c=5.7519e+05; %radiation damping
k=2.8049e+06; %linear hydro restoring coeff

alpha=c/(2*m);
omega=sqrt(4*k*m-c^2)/(2*m);

t=0:0.1:400;

a=c/m;
b=k/m;
B=Xinit;
A=B*(alpha/omega);
x1=exp(-a.*t/2);
x2a=A*sin(0.5*sqrt(4*b-a^2).*t);
x2b=B*cos(0.5*sqrt(4*b-a^2).*t);
x=x1.*(x2a+x2b);

%Differences
[diff,ind]=max(abs(x'-B1.WEC_Sim_new.heave));

%% Plot Heave Comparisons

h=figure('units','normalized','outerposition',[0 0 1 1]);
plot(B1.WEC_Sim_new.time,B1.WEC_Sim_new.heave,'k-',....
    t,x,'r--')
str1=['Max Diff = ' num2str(diff) ' m'];
str2=['at time = ' num2str(t(ind)) 's'];
a=text(10,1.5,str1);set(a,'FontSize',12)
a=text(10,1.2,str2);set(a,'FontSize',12)
xlabel('time(s)')
ylabel('Heave(m)')
title('Float Heave Decay')
legend('WEC-Sim','Analytical')
xlim([0 200])
ylim([-2 2])

%%
clear h str1 str2 x x2b x2a x1 t A B omega alpha a b m c k Xinit Vinit ...
    Hshift1 Tshift B1 diff ind tout