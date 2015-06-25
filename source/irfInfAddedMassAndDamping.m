%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2014 the National Renewable Energy Laboratory and Sandia Corporation
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bodyTemp = irfInfAddedMassAndDamping(bodyTemp,simu,kk,bodyind)

WFQSt=min(bodyTemp.hydro.data.frequency);
WFQEd=max(bodyTemp.hydro.data.frequency);
df  = (WFQEd-WFQSt)/(simu.numFreq-1);
w = WFQSt:df:WFQEd;

% fAddedMass=zeros(simu.numFreq,6,6);
% fDamping  =zeros(simu.numFreq,6,6);
if simu.convCalc == 0 || simu.convCalc == 1 %Checking to see if impulse response function needs to be calculated
    for j = 1:simu.numFreq
        for ii=1:6
            for jj=1:6*kk
                %                 tmp = reshape(bodyTemp.hydro.data.fAddedMass(ii,jj,:),1,length(bodyTemp.hydro.data.period));
                %                 fAddedMass(j,ii,jj) = interp1(bodyTemp.hydro.data.frequency,tmp,w(j),'linear');
                
                tmp = reshape(bodyTemp.hydro.data.fDamping  (ii,jj,:),1,length(bodyTemp.hydro.data.period));
                fDamping  (j,ii,jj) = interp1(bodyTemp.hydro.data.frequency,tmp,w(j),'linear');
                
            end; clear tmp;
        end
    end
    
    % bodyTemp.hydroForce.irka=zeros(simu.CIkt+1,6,6);
    bodyTemp.hydroForce.fDampingest=zeros(6,6*kk,length(bodyTemp.hydro.data.period));
    bodyTemp.hydroForce.irkb=zeros(simu.CIkt+1,6,6*kk);
    for kt=1:simu.CIkt+1;
        t = simu.dt*(kt-1);
        for ii=1:6
            for jj=1:6*kk
                %             tmp = w(:).*(fAddedMass(:,ii,jj)-bodyTemp.hydro.data.fAddedMassZero(ii,jj)).*sin(w(:)*t);
                %             bodyTemp.hydroForce.irka(kt,ii,jj) =-2./pi*trapz(w,tmp);
                tmp=fDamping(:,ii,jj).*cos(w(:)*t);
                bodyTemp.hydroForce.irkb(kt,ii,jj) = 2./pi*trapz(w,tmp);
            end
        end; clear tmp;
    end
end
%%
if simu.convCalc == 1 %check to see if state space realization is desired
fprintf('\nConvolution to State-Space Approximation: \n')
fprintf(['\t -',simu.ssReal,' Realization (TD - Time Domain, FD - Frequency Domain) \n'])
if simu.hydrocoupling == 1
fprintf(['\t -Hydrodynamic Coupling Included \n'])
else
fprintf(['\t -Hydrodynamic Coupling Not Included \n'])
end
fprintf(['\t -R2 Threshold: ',num2str(simu.R2Thresh),' \n'])
fprintf(['\t\tBody ',num2str(bodyind),' \n'])
fprintf(['\t\tForce Direction, Body Motion\n'])
for ii = 1:6
    for jj = 1:6*kk
        fprintf(['\t\t\t',num2str(ii),',',num2str(jj),'\n'])
    switch simu.ssReal %check to see if frequency or time domain realization is desired
        case 'FD'
        [Ass,Bss,Css,Dss,lam_est,mu_est,Krest,status] = SS_FD(bodyTemp.hydro.data.frequency,...
            reshape(bodyTemp.hydro.data.fDamping(ii,jj,:),1,length(bodyTemp.hydro.data.period)),...
            reshape(bodyTemp.hydro.data.fAddedMass(ii,jj,:),1,length(bodyTemp.hydro.data.period)),...
            bodyTemp.hydro.data.fAddedMassZero(ii,jj),simu.ssMax,simu.R2Thresh,bodyTemp.hydroForce.irkb(:,ii,jj),simu.dt); %Run frequency domain realization
        bodyTemp.hydro.data.fDampingest(ii,jj,:) = lam_est;
        bodyTemp.hydro.data.fAddedMassest(ii,jj,:) = mu_est;
        case 'TD'
        [Ass,Bss,Css,Dss,Krest,status] = SS_TD(bodyTemp.hydroForce.irkb(:,ii,jj),simu.ssMax,simu.R2Thresh,simu.dt); %Run time domain realization
        [NumTD,DenTD] = ss2tf(Ass,Bss,Css,0); %Convert state space to transfer function
        [Kw,freq] = FreqResp(NumTD,DenTD,bodyTemp.hydro.data.frequency); %Calculate frequency response of state space system
        bodyTemp.hydro.data.fDampingest(ii,jj,:) = real(Kw);
        bodyTemp.hydro.data.fAddedMassest(ii,jj,:) = imag(Kw)./bodyTemp.hydro.data.frequency + ones(size(bodyTemp.hydro.data.frequency))*bodyTemp.hydro.data.fAddedMassZero(ii,jj);
    end
    bodyTemp.hydroForce.ssRad(ii,jj).A = Ass;
    bodyTemp.hydroForce.ssRad(ii,jj).B = Bss;
    bodyTemp.hydroForce.ssRad(ii,jj).C = Css;
    bodyTemp.hydroForce.ssRad(ii,jj).D = Dss;
    bodyTemp.hydroForce.irkbss(:,ii,jj) = Krest;
    bodyTemp.hydroForce.ssRadconv(ii,jj) = status;
    
    if ii == 1 && jj == 1 % Begin construction of combined state, input, and output matrices
    Af = bodyTemp.hydroForce.ssRad(ii,jj).A;
    Bf = bodyTemp.hydroForce.ssRad(ii,jj).B;
    Cf = bodyTemp.hydroForce.ssRad(ii,jj).C;
    else
    Af(length(Af)+1:length(Af)+length(bodyTemp.hydroForce.ssRad(ii,jj).A),...
       length(Af)+1:length(Af)+length(bodyTemp.hydroForce.ssRad(ii,jj).A)) = bodyTemp.hydroForce.ssRad(ii,jj).A;
    Bf(length(Bf)+1:length(Bf)+length(bodyTemp.hydroForce.ssRad(ii,jj).B),jj) = bodyTemp.hydroForce.ssRad(ii,jj).B;
    Cf(ii,length(Cf)+1:length(Cf)+length(bodyTemp.hydroForce.ssRad(ii,jj).C)) = bodyTemp.hydroForce.ssRad(ii,jj).C;
    end
    end
end
    bodyTemp.hydroForce.ssRadf.A = Af;
    bodyTemp.hydroForce.ssRadf.B = Bf;
    bodyTemp.hydroForce.ssRadf.C = Cf;
    bodyTemp.hydroForce.ssRadf.D = zeros(6,6*kk);
elseif simu.convCalc == 2
    load(simu.ssImport)
    bodyTemp.hydroForce.ssRadf.A = radSS(bodyind).A;
    bodyTemp.hydroForce.ssRadf.B = radSS(bodyind).B;
    bodyTemp.hydroForce.ssRadf.C = radSS(bodyind).C;
    bodyTemp.hydroForce.ssRadf.D = radSS(bodyind).D;
    clear(simu.ssImport)
    bodyTemp.hydroForce.irkb=zeros(simu.CIkt+1,6,6*kk);
else
    bodyTemp.hydroForce.ssRadf.A = zeros(6*kk,6*kk);
    bodyTemp.hydroForce.ssRadf.B = zeros(6*kk,6*kk);
    bodyTemp.hydroForce.ssRadf.C = zeros(6,6*kk);
    bodyTemp.hydroForce.ssRadf.D = zeros(6,6*kk);
end
    bodyTemp.hydroForce.fAddedMass=bodyTemp.hydro.data.fAddedMassZero; %If WAMIT is solved using period .fAddedMass Zero, if solved with frequency .fAddedMassInfinity
    bodyTemp.hydroForce.fDamping=zeros(6,6*kk);

end