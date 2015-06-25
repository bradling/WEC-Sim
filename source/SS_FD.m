function [Ass,Bss,Css,Dss,lam_est,mu_est,Krlti,status] = SS_FD(freq,lambda,mu,muinf,ssMax,R2Thresh,Kr,dt)
%%
%Inputs:
%freq - wave angular frequencies, [rad/s], must be in ascending order
%lambda - wave damping, order with corresponding frequency
%mu - added mass, order with corresponding frequency
%muinf - added mass calculated at infinite frequency,
%ssMax - maximum order of the state space realization
%R2Thresh - R2 threshold that must be met either by the R2 value for either by lambda or mu
%Kr - Impulse response function as calculated by user
%dt - time step used for the sampling frequency of the impulse response function
%Outputs:
%Ass - time-invariant state matrix
%Bss - time-invariant input matrix
%Css - time-invariant output matrix
%Dss - time-invariant feedthrough matrix
%lam_est - state space approximation of lambda
%mu_est - state space approximation of mu
%Krlti - Impusle response function as cacluated from state space approximation
%status - status of the realization, 0 - zero hydrodynamic coefficients
%                                    1 - state space realization meets R2 threshold
%                                    2 - state space realization does not
%                                        meet R2 threshold and at ssMax limit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
freqsize = size(freq);
lambdasize = size(lambda);
musize = size(mu);
if freqsize(1) == 1;freq = freq';end
if lambdasize(1) == 1;lambda = lambda';end
if musize(1) == 1;mu = mu';end
Krlti = zeros(length(Kr),1); %Initialize zero matrix for the impulse response function from state space approximation
%%
Kw = lambda + complex(0,freq).*(mu-muinf); %Calculate frequency response data
R2BL =(lambda-mean(lambda)*ones(size(lambda)))'*(lambda-mean(lambda)*ones(size(lambda)));%Calculate mean reference values for R2 calculation for wave damping
R2BA =(mu-mean(mu)*ones(size(mu)))'*(mu-mean(mu)*ones(size(mu)));%Calculate mean reference values for R2 calculation for added mass
%%  
ss = 2; %Initial state space order
while ss <= ssMax
    if sum(diff(Kr))==0 %Check to see if imported hydrodynamic data is 0
        Ass = 0; Bss = 0;
        Css = 0; Dss = 0;
        Krlti = Kr; status = 0;
        lam_est = zeros(size(lambda)); mu_est = zeros(size(mu));
        break
    end
Scale=max(abs(Kw)); %Find maximum magnitude of frequency response
Kws = Kw/Scale; %Scale frequency response
Kws0 =Kws./complex(0,freq); %Divide the frequency response by i\sigma
ord_num = ss-2;ord_den=ss; %Set the order of the numerator and denominator
%%
Weight = ones(size(freq)); %Initialize weighting function
for k=1:30
    [Num,Den]=invfreqs(Kws0,freq,ord_num,ord_den,Weight); %Perform non-linear least squares
    for m=1:length(freq);
    Weight(m)=1/abs(polyval(Den,complex(0,freq(m))))^2; %Update weighting function
    end
end
%%
r=roots(Den); %caculate roots of denominator
for k=1:length(r)
        if  real(r(k)) > 0,
            r(k) = -r(k); %if the root has positive real component, flip its sign
        end
end
DenR=poly(r); %reconstruct denominator after flipping positive roots
%%
NumA=[Num 0]; %add order to numerator
Fresp_hat_est=freqs(NumA*Scale,DenR,freq); %calculate the frequency response of transfer function
[SSA,SSB,SSC,SSD] = tf2ss(NumA*Scale,DenR); %cacluate equivalent state space form of transfer function
%%
lam_est = real(Fresp_hat_est); %extract the wave damping component from the frequency response
mu_est = imag(Fresp_hat_est)./freq+muinf*ones(size(freq)); %extract the added mass component from the frequency response
%%
R2TL = (lambda-lam_est)'*(lambda-lam_est); %Calculate 2 norm of the difference between know and estimated values for wave damping
R2B = 1 - R2TL/R2BL; %Calculate the R2 value for wave damping
R2TA = (mu-mu_est)'*(mu-mu_est); %Calculate 2 norm of the difference between know and estimated values for added mass
R2A = 1 - R2TA/R2BA; %Calculate the R2 value for added mass
%%
if  (R2B<R2Thresh) && (R2A<R2Thresh), %Check to see if threshold for either wave damping or added mass is met
    if ss == ssMax %Check to see if limit on the state space order has been reached
        Ass = SSA;        Bss = SSB;
        Css = SSC;        Dss = SSD;
        %%
        for jj = 1:length(Kr)
        Krlti(jj,1) = SSC*expm(SSA*dt*(jj-1))*SSB; %Calculate impulse response function from state space approximation
        end
        status = 2; %Set status
        break
    end
else
%%
        Ass = SSA;        Bss = SSB;
        Css = SSC;        Dss = SSD;
        for jj = 1:length(Kr)
        Krlti(jj,1) = SSC*expm(SSA*dt*(jj-1))*SSB; %Calculate impulse response function from state space approximation
        end
        status = 1; %Set status
end
ss=ss+1; %Increase state space order
end
