
function data = userDefinedHydro(matFile, bodyNum)

%% Run File
load(matFile);
data = hydroData(bodyNum);
clear hydroData


%% frequency and period
if isfield(data,'period')==1
    if isfield(data,'frequency')==1
        warning(['Both period and frequency given. Using only the' ...
            'values of ''period''. ''frequency'' will be overwritten.'])
    end
    data.frequency = 2*pi./data.period;
elseif isfield(data,'frequency')==1
    data.period = 2*pi./data.frequency;
else 
    error('Either ''period'' or ''frequency'' must be given.')
end
N = length(data.period);
[rowsp,colsp] = size(data.period);
[rowsf,colsf] = size(data.frequency);
if rowsp~=1 || colsp~=N
    error('''period'' must be a [1xN] vector.')
end
if rowsf~=1 || colsf~=N
    error('''frequency'' must be a [1xN] vector.')
end    
clear rowsp colsp rowsf colsf



%% fExt
if isfield(data.fExt,'Mag') == 0
    if isfield(data.fExt,'Re')==1 && isfield(data.fExt,'Im')==1
        i = sqrt(-1);
        data.fExt.Mag = abs(data.fExt.Re + (data.fExt.Im*i));
    elseif isfield(data.fExt,'Re')==1
        error('''fExt.Im'' must be given.')
    elseif isfield(data.fExt,'Im')==1
        error('''fExt.Re'' must be given.')
    else
        error('''fExt.Re'' and ''fExt.Im'' must be given.')
    end
end
[rowsRe,colsRe] = size(data.fExt.Re);
[rowsIm,colsIm] = size(data.fExt.Im);
[rowsMag,colsMag] = size(data.fExt.Mag);
if rowsRe~=6 || colsRe~=N
    error('''fExt.Re'' must be a [6xN] matrix.')
end
if rowsIm~=6 || colsIm~=N
    error('''fExt.Im'' must be a [6xN] matrix.')
end
if rowsMag~=6 || colsMag~=N
    error('''fExt.Mag'' must be a [6xN] matrix.')
end
clear rowsRe colsRe rowsIm colsIm rowsMag colsMag


%% fAddedMassInf
if isfield(data,'fAddedMassInf') == 0
    data.fAddedMassInf = zeros(6,6);
end
[rowsInf,colsInf] = size(data.fAddedMassInf);
if rowsInf~=6 || colsInf~=6
    warning('''fAddedMassInf'' must be a [6x6] matrix.')
end
clear rowsInf colsInf

%% fAddedMassZero
if isfield(data,'fAddedMassZero') == 0
    error('''fAddedMassZero'' must be given.')
else
    [rowsZero,colsZero] = size(data.fAddedMassZero);
    if rowsZero~=6 || colsZero~=6
        error('''fAddedMassZero'' must be a [6x6] matrix.')
    end
    clear rowsZero colsZero
end


%% waterDepth
if isfield(data,'waterDepth')==0
    error('''waterDepth'' must be given.')
elseif sum(size(data.waterDepth)>1)~=0
    error('''waterDepth'' must be a scalar')
end


%% vol
if isfield(data,'vol')==0
    error('''vol'' must be given.')
elseif sum(size(data.vol)>1)~=0
    error('''vol'' must be a scalar')
end


%% cg
% if isfield(data,'cg') == 0
%     error('''cg'' must be given.')
% else
%     [rowscg,colscg] = size(data.cg);
%     if rowscg~=1 || colscg~=3
%         error('''cg'' must be a [1x3] matrix.')
%     end
%     clear rowscg colscg 
% end


%% linearHyroRestCoef
if isfield(data,'linearHyroRestCoef') == 0
    error('''linearHyroRestCoef'' must be given.')
else
    [rowsK,colsK] = size(data.linearHyroRestCoef);
    if rowsK~=6 || colsK~=6
        error('''linearHyroRestCoef'' must be a [6x6] matrix.')
    end
    clear rowsK colsK
end


%% fDamping
if isfield(data,'fDamping') == 0
    error('''fDamping'' must be given.')
else
    [rowsC,colsC,lenC] = size(data.fDamping);
    if rowsC~=6 || colsC~=6 || lenC~=N
        error('''fDamping'' must be a [6x6xN] matrix.')
    end
    clear rowsC colsC lenC
end


%% waveheading


%% fAddedMass
if isfield(data,'fAddedMass') == 0
    error('''fAddedMass'' must be given.')
else
    [rowsA,colsA,lenA] = size(data.fAddedMass);
    if rowsA~=6 || colsA~=6 || lenA~=N
        error('''fAddedMass'' must be a [6x6xN] matrix.')
    end
    clear rowsA colsA lenA
end


%% raw % need to change. raw.waveDirection is required.
if isfield(data,'raw') == 0
    data.raw=struct;
% else
%     if isstruct(data.raw)==0
%         warning('''raw'' should be a 1x1 structure.')
%     elseif sum(size(data.raw)>1)~=0
%         warning('''raw'' should be a 1x1 structure.')
%     end
end


%%
clear N
end
