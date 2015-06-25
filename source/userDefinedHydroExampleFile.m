

%% Fixed Size
hydroData(i).waterDepth = ; % [1]
%hydroData(i).cg = [,,] ; % [1x3]
hydroData(i).vol = ; % [1]
hydroData(i).linearHyroRestCoef = [,,;,,;,,]; % [6x6]
hydroData(i).fAddedMassZero = [,,;,,;,,]; % [6x6]

%% ???
hydroData(i).waveheading = ; % [?]
hydroData(i).raw.waveDirection = ; % [?]

%% xN
hydroData(i).period = []; % [1xN]
hydroData(i).fDamping = []; % [6x6xN]
hydroData(i).fAddedMass = []; % [6x6xN]
hydroData(i).fExt.Re = []; % [6xN]
hydroData(i).fExt.Im = []; % [6xN]

%% Optional
% raw: [1x1 struct]
% frequency: [1xN]
% hydroData(i).fAddedMassInf = [,,;,,;,,]; % [6x6]