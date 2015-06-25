function [Ass,Bss,Css,Dss,Krlti,status] = SS_TD(Kr,ssMax,R2Thresh,dt)
%%
%Inputs:
%Kr - impulse response function
%ssMax - maximum order of the state space realization
%R2Thresh - R2 threshold that must be met either by the R2 value for K_{r}
%dt - time step used for the sampling frequency of the impulse response function
%Outputs:
%Ass - time-invariant state matrix
%Bss - time-invariant input matrix
%Css - time-invariant output matrix
%Dss - time-invariant feedthrough matrix
%Krlti - Impusle response function as cacluated from state space approximation
%status - status of the realization, 0 - zero hydrodynamic coefficients
%                                    1 - state space realization meets R2 threshold
%                                    2 - state space realization does not
%                                        meet R2 threshold and at ssMax limit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Krsize = size(Kr);
if Krsize(1) == 1;Kr = Kr';end
Krlti = zeros(length(Kr),1);  %Initialize zero matrix for the impulse response function from state space approximation
%%
R2BT = (Kr-mean(Kr))'*(Kr-mean(Kr)); %Calculate mean reference values for R2 calculation for impulse response function
ss = 2; %Initial state space order
%%
while ss <= ssMax
%%
if sum(diff(Kr))==0 %Check to see if imported hydrodynamic data is 0
        Ass = 0; Bss = 0;
        Css = 0; Dss = 0;
        Krlti = Kr; status = 0;
        break
end
%%
[a,b,c,d] = impreal(dt*Kr',ss); %Perform Hankel Singular Value Decomposition
%% 
[ac,bc,cc,dc]=bilintrans(a,b,c,d,dt); %Perform bilinear transformation to convert from discrete-to-continuous time system
%%
for jj = 1:length(Kr)
Krlti(jj,1) = cc*expm(ac*dt*(jj-1))*bc; %Calculate impulse response function from state space approximation
end
R2TT = (Kr-Krlti)'*(Kr-Krlti); %Calculate 2 norm of the difference between know and estimated values impulse response function
%%
R2T = 1 - R2TT/R2BT; %Calculate the R2 value for impulse response function
%%
if (R2T<R2Thresh) %Check to see if threshold for the impulse response is meet
     if ss == ssMax %Check to see if limit on the state space order has been reached
        Ass = ac; Bss = bc;
        Css = cc; Dss = dc;
        status = 2;  %Set status
        break
     end
else
    Ass = ac; Bss = bc;
    Css = cc; Dss = dc;
    status = 1;  %Set status
    break
end
ss=ss+1; %Increase state space order
end
end