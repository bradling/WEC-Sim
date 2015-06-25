function [] = PlotStateSpacePreprocess(Inputmatfile)
%Inputmatfile must be a string input
load(Inputmatfile)
%%
if simu.hydrocoupling == 1
    kk = simu.numWecBodies;
else
    kk = 1;
end
%% Impulse Response Function
close all
replystart = input('Plot Impulse Response Function? [1 - `Yes`/2 - `No`] \n');
if isempty(replystart)
    replystart = input('Please enter 1 for `Yes` or 2 for `No`? \n');
    if isempty(replystart)
        replystart = 2;
    end
end
if replystart == 1
    bodyplot = 1;
    while bodyplot ~= 0
        clc
        bodyplot = input(['Which body should be plotted? [1 - to - ',num2str(simu.numWecBodies),' or 0 to exit] \n']);
        if isempty(bodyplot)
            bodyplot = input('Please enter 1 for `Yes` or 2 for `No`? \n');
            if isempty(bodyplot)
                bodyplot = 0;
                break
            end
        elseif bodyplot == 0
            break
        end
        for pp = bodyplot;%1:simu.numWecBodies
            close all
            for oo = 1:kk
                figure()
                qq = 1;
                for ii = 1:6
                    for jj = 1+(6*(oo-1)):6*oo
                        subplot(6,6,qq)
                        plot(simu.dt*[0:length(body(pp).hydroForce.irkb(:,ii,jj))-1],body(pp).hydroForce.irkb(:,ii,jj),...
                            simu.dt*[0:length(body(pp).hydroForce.irkbss(:,ii,jj))-1],body(pp).hydroForce.irkbss(:,ii,jj),'-.')
                        grid on;
                        if kk == 1
                            ylabel(['K_{r-',num2str(ii+(6*(pp-1))),num2str(jj+(6*(pp-1))),'}'])
                        else
                            ylabel(['K_{r-',num2str(ii+(6*(pp-1))),num2str(jj),'}'])
                        end
                        xlabel('Time [s]');xlim([0 10])
                        if ii == 6 && jj == 6*oo
                            legend('IFT',simu.ssReal)
                        end
                        qq = qq+1;
                    end
                end
                [ax4,h3]=suplabel(body(pp).name  ,'t');
                %[ax2,h2]=suplabel('Impulse Response Function','y');
                set(h3,'FontSize',20)%set(h2,'FontSize',20);
            end
        end
    end
end
%% Wave Damping
replystart = input('Plot Wave Damping? [1 - `Yes`/2 - `No`] \n');
if isempty(replystart)
    replystart = input('Please enter 1 for `Yes` or 2 for `No`? \n');
    if isempty(replystart)
        replystart = 2;
    end
end
if replystart == 1
    bodyplot = 1;
    while bodyplot ~= 0
        clc
        bodyplot = input(['Which body should be plotted? [1 - to - ',num2str(simu.numWecBodies),' or 0 to exit] \n']);
        if isempty(bodyplot)
            bodyplot = input('Please enter 1 for `Yes` or 2 for `No`? \n');
            if isempty(bodyplot)
                bodyplot = 0;
                break
            end
        elseif bodyplot == 0
            break
        end
        for pp = bodyplot
            for oo = 1:kk
                figure()
                qq = 1;
                for ii = 1:6
                    for jj = 1+(6*(oo-1)):6*oo
                        subplot(6,6,qq)
                        plot(body(pp).hydro.data.frequency,reshape(body(pp).hydro.data.fDamping(ii,jj,:),1,length(body(pp).hydro.data.period)),...
                            body(pp).hydro.data.frequency,reshape(body(pp).hydro.data.fDampingest(ii,jj,:),1,length(body(pp).hydro.data.period)),'+')
                        grid on;
                        if kk ==1
                            ylabel(['\lambda_{',num2str(ii+(6*(pp-1))),num2str(jj+(6*(pp-1))),'}'])
                        else
                            ylabel(['\lambda_{',num2str(ii+(6*(pp-1))),num2str(jj),'}'])
                        end
                        xlabel('Angular Frequency [rad/s]');xlim([0 6])
                        if ii == 6 && jj== 6*oo
                            legend('\lambda (\sigma)',['\lambda_{est} (\sigma) ',simu.ssReal])
                        end
                        qq = qq+1;
                    end
                end
                [ax4,h3]=suplabel(body(pp).name  ,'t');
                %[ax2,h2]=suplabel('Wave Damping','y');
                set(h3,'FontSize',20);%set(h2,'FontSize',20);
            end
        end
    end
end
%% Added Mass
close all
replystart = input('Plot Added Mass? [1 - `Yes`/2 - `No`] \n');
if isempty(replystart)
    replystart = input('Please enter 1 for `Yes` or 2 for `No`? \n');
    if isempty(replystart)
        replystart = 2;
    end
end
if replystart == 1
    bodyplot = 1;
    while bodyplot ~= 0
        clc
        bodyplot = input(['Which body should be plotted? [1 - to - ',num2str(simu.numWecBodies),' or 0 to exit] \n']);
        if isempty(bodyplot)
            bodyplot = input('Please enter 1 for `Yes` or 2 for `No`? \n');
            if isempty(bodyplot)
                bodyplot = 0;
                break
            end
        elseif bodyplot == 0
            break
        end
        for pp = bodyplot
            for oo = 1:kk
                figure()
                qq = 1;
                for ii = 1:6
                    for jj = 1+(6*(oo-1)):6*oo
                        subplot(6,6,qq)
                        plot(body(pp).hydro.data.frequency,reshape(body(pp).hydro.data.fAddedMass(ii,jj,:),1,length(body(pp).hydro.data.period)),...
                            body(pp).hydro.data.frequency,reshape(body(pp).hydro.data.fAddedMassest(ii,jj,:),1,length(body(pp).hydro.data.period)),'+',...
                            body(pp).hydro.data.frequency,body(pp).hydro.data.fAddedMassInf(ii,jj,:)*ones(size(body(pp).hydro.data.frequency)),'--')
                        grid on;
                        if kk == 1
                            ylabel(['\mu_{',num2str(ii+(6*(pp-1))),num2str(jj+(6*(pp-1))),'}'])
                        else
                            ylabel(['\mu_{',num2str(ii+(6*(pp-1))),num2str(jj),'}'])
                        end
                        xlabel('Angular Frequency [rad/s]');xlim([0 6])
                        if ii == 6 && jj == 6*oo
                            legend('\mu (\sigma)',['\mu_{est} (\sigma) ',simu.ssReal],'\mu (\infty)')
                        end
                        qq = qq+1;
                    end
                end
                [ax4,h3]=suplabel(body(pp).name  ,'t');
                %[ax2,h2]=suplabel('Added Mass','y');
                set(h3,'FontSize',20);%set(h2,'FontSize',20);
            end
        end
    end
end