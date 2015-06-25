%% WEC-Sim State Space Preprocessing
clc;close all;
%% Initiate the simulation class and specify input file name
simu = simulationClass;clc
disp('Running State Space Realization Preprocessing File')
%% Read input file
evalc([simu.inputFile]);
switch simu.ssReal %check to see if frequency or time domain realization is desired
    case 'FD'
    disp('-Frequency Domain Realization')   
    case 'TD'
    disp('-Time Domain Realization')
end
switch simu.hydrocoupling %check to see if hydrodynamic coupling is desired
    case 0
    disp('-Hydrodynamic Coupling not Included')   
    case 1
    disp('-Hydrodynamic Coupling Included')
end
%%
clear pto;clear constraint;clear waves;
%% Load SimMecahnics file and caluclate the number of bodies
simu.loadSimMechModel(simu.simMechanicsFile);
simu.numWecBodies = length(body(1,:));
%% Set hydrodynamic data, body mass, and body cg for each body in the simulation
for i = 1:simu.numWecBodies
    if simu.hydroDataWamit == 0 % this is a hack to deal with simulations that use mutiple WAMIT runs with one body in each run
        body(i).setHydroData(i,simu);
    else
        body(i).setHydroData(1,simu);
    end
    body(i).setMass(simu);
    body(i).setCg;
    body(i).setMomOfInertia;
    %body(i).setGeom;
end
%% Check WAMIT data
checkBem(body)
%%
if simu.hydrocoupling == 1
    kk = simu.numWecBodies;
else
    kk = 1;
end
%%
for bb = 1:simu.numWecBodies
    WFQSt=min(body(bb).hydro.data.frequency);
    WFQEd=max(body(bb).hydro.data.frequency);
    df  = (WFQEd-WFQSt)/(simu.numFreq-1);
    freq = body(bb).hydro.data.frequency;
    w = WFQSt:df:WFQEd;
    fDamping  =zeros(simu.numFreq,6,6*kk);
    disp(['Body ',num2str(bb)])
    replystart = input('Do you want to manually edit hydro coefficients or automated process? [1 - `Edit`/2 - `Auto`] \n');
    if isempty(replystart)
        replystart = input('Please enter 1 for manually process or 2 for automated process? [1 - `Edit`/2 - `Auto`] \n');
        if isempty(replystart)
            replystart = 2;
        end
    elseif replystart ~= 1 && replystart ~= 2
        replystart = input('Please enter 1 for manually process or 2 for automated process? [1 - `Edit`/2 - `Auto`] \n');
        if isempty(replystart)
            replystart = 2;
        end
    end
    for ii=1:6
        clc
        replystartr = input(['Zero Row ',num2str(ii + 6*(bb-1)),'? [1 - `Yes`/2 - `No`] \n']);
        if isempty(replystartr)
            replystartr = input(['Zero Row ',num2str(ii + 6*(bb-1)),'? [1 - `Yes`/2 - `No`] \n']);
            if isempty(replystartr)
            replystartr  = 2;
            end
        end
        for jj=1:6*kk
            if replystartr == 2
                if replystart == 1
                    iter = 0;
                    tmp = reshape(body(bb).hydro.data.fDamping  (ii,jj,:),1,length(body(bb).hydro.data.period));
                    while iter <1
                        clc
                        iter = 0;
                        close all
                        plot(freq,tmp);xlabel('Angular Frequency [rad/s]');ylabel('Wave Damping, \lambda, [N/(m/s)]');
                        title(['Body ',num2str(bb),':',num2str(ii + 6*(bb-1)),num2str(jj)]);grid on
                        reply = input('Do you want to edit hydrocoefficients? [1 - `Yes`/2 - `No`/3 - Zero Coefficients] \n');
                        if isempty(reply)
                            iter = 99;
                        elseif reply==1
                            disp('Pick Point to Interpolate on Plot:')
                            [xp,yp] = ginput(1);
                            [freqv,freqint] = min(abs(freq-xp));
                            if isempty(freqint)
                                disp('Please Pick Point on Plot')
                                [freqv,freqint] = min(abs(freq-xp));
                            else
                                tmp(freqint) = interp1([freq(freqint-1),freq(freqint+1)],[tmp(freqint-1),tmp(freqint+1)],freq(freqint),'linear');
                            end
                            
                        elseif reply==3
                            tmp = zeros(size(tmp));
                            iter = 99;
                        else
                            iter = 99;
                        end
                    end
                else
                    tmp = reshape(body(bb).hydro.data.fDamping  (ii,jj,:),1,length(body(bb).hydro.data.period));
                end
            else
                tmp = zeros(size(body(bb).hydro.data.period));
            end
            for j = 1:simu.numFreq
                fDamping(j,ii,jj) = interp1(body(bb).hydro.data.frequency,tmp,w(j),'linear');
            end; clear tmp;
        end
    end
    body(bb).hydroForce.fDampingest=zeros(6,6*kk,length(body(bb).hydro.data.period));
    body(bb).hydroForce.irkb=zeros(simu.CIkt+1,6,6*kk);
    for kt=1:simu.CIkt+1;
        t = simu.dt*(kt-1);
        for ii=1:6
            for jj=1:6*kk
                tmp=fDamping(:,ii,jj).*cos(w(:)*t);
                body(bb).hydroForce.irkb(kt,ii,jj) = 2./pi*trapz(w,tmp);
            end
        end; clear tmp;
    end
    disp(['State Space Index for Body ',num2str(bb)])
    for ii = 1:6
        for jj = 1:6*kk
            disp([num2str(ii+ 6*(bb-1)),num2str(jj)])
            switch simu.ssReal %check to see if frequency or time domain realization is desired
                case 'FD'
                    [Ass,Bss,Css,Dss,lam_est,mu_est,Krest,status] = SS_FD(body(bb).hydro.data.frequency,...
                        reshape(body(bb).hydro.data.fDamping(ii,jj,:),1,length(body(bb).hydro.data.period)),...
                        reshape(body(bb).hydro.data.fAddedMass(ii,jj,:),1,length(body(bb).hydro.data.period)),...
                        body(bb).hydro.data.fAddedMassZero(ii,jj),simu.ssMax,simu.R2Thresh,body(bb).hydroForce.irkb(:,ii,jj),simu.dt); %Run frequency domain realization
                    body(bb).hydro.data.fDampingest(ii,jj,:) = lam_est;
                    body(bb).hydro.data.fAddedMassest(ii,jj,:) = mu_est;
                case 'TD'
                    [Ass,Bss,Css,Dss,Krest,status] = SS_TD(body(bb).hydroForce.irkb(:,ii,jj),simu.ssMax,simu.R2Thresh,simu.dt); %Run time domain realization
                    [NumTD,DenTD] = ss2tf(Ass,Bss,Css,0); %Convert state space to transfer function
                    [Kw,freq] = FreqResp(NumTD,DenTD,body(bb).hydro.data.frequency); %Calculate frequency response of state space system
                    body(bb).hydro.data.fDampingest(ii,jj,:) = real(Kw);
                    body(bb).hydro.data.fAddedMassest(ii,jj,:) = imag(Kw)./body(bb).hydro.data.frequency + ones(size(body(bb).hydro.data.frequency))*body(bb).hydro.data.fAddedMassZero(ii,jj);
            end
            body(bb).hydroForce.ssRad(ii,jj).A = Ass;
            body(bb).hydroForce.ssRad(ii,jj).B = Bss;
            body(bb).hydroForce.ssRad(ii,jj).C = Css;
            body(bb).hydroForce.ssRad(ii,jj).D = Dss;
            body(bb).hydroForce.irkbss(:,ii,jj) = Krest;
            body(bb).hydroForce.ssRadconv(ii,jj) = status;
            
            if ii == 1 && jj == 1 % Begin construction of combined state, input, and output matrices
                Af = body(bb).hydroForce.ssRad(ii,jj).A;
                Bf = body(bb).hydroForce.ssRad(ii,jj).B;
                Cf = body(bb).hydroForce.ssRad(ii,jj).C;
            else
                Af(length(Af)+1:length(Af)+length(body(bb).hydroForce.ssRad(ii,jj).A),...
                    length(Af)+1:length(Af)+length(body(bb).hydroForce.ssRad(ii,jj).A)) = body(bb).hydroForce.ssRad(ii,jj).A;
                Bf(length(Bf)+1:length(Bf)+length(body(bb).hydroForce.ssRad(ii,jj).B),jj) = body(bb).hydroForce.ssRad(ii,jj).B;
                Cf(ii,length(Cf)+1:length(Cf)+length(body(bb).hydroForce.ssRad(ii,jj).C)) = body(bb).hydroForce.ssRad(ii,jj).C;
            end
        end
    end
    radSS(bb).A = Af;
    radSS(bb).B = Bf;
    radSS(bb).C = Cf;
    radSS(bb).D = zeros(6,6*kk);
end
%%
save([simu.ssImport],'radSS')
save([simu.ssImport,'_est'],'body','simu')