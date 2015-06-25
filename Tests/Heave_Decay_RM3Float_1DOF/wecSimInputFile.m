% Simulation Data
simu.startTime=0;
simu.endTime=400;
simu.dt = 0.1;
simu.mode='normal';%'normal','accelerator','rapid-accelerator'
simu.explorer='on';
simu.simMechanicsFile = 'Heave_Decay_RM3Float_1DOF.slx';

% Wave Information
waves.type = 'noWave';
waves.noWaveHydrodynamicCoeffT = 8;

% Body Data
body(1) = bodyClass('Float');
body(1).hydroDataType = 'wamit';
body(1).hydroDataLocation = 'wamit/buoywamit.out';
body(1).mass = 'wamitDisplacement';
body(1).cg = 'wamit';
body(1).momOfInertia = [20907301 21306090.66 37085481.11];
body(1).geometry = 'geometry/float.stl';
body(1).initLinDisp=[0 0 2];

% Joint and Constraint Parameters
constraint(1).name='constraint1';

