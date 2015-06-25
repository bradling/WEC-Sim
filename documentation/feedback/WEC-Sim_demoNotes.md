# WEC-Sim notes
RG Coe 04/23/2014

* add set moment of inertia method using WAMIT

* not a fan of using the same file names (e.g., wecModel.slx, wecSimInputFile.m) for all models

	* makes it hard to look at what you did "last time"

	* makes it hard (or impossible to copy between models)

	* easy to accidentally overwrite things

* using WEC-Sim is straightforward, as long as you understand the workflow (i.e., setting up the system in Simulink and then defining its parameters in the input file); I see this as the least intuitive part of set-up


COMPLETED* irregular waves do not work?

* is there a lower limit on the simulation length? (tried to run irregular waves at dt = 0.001s for 40s w/ Hs = 2.5m and Tp = 8s; see below for error)

	WEC-Sim: An open-source code for simulating waveenergy converters
	Version: alpha

	Initializing the Siumulation Class...
	Initializing the Body Class... 
		Reading wamit data for body 1...   
	Offsetting STL geometry by the center of gravity from WAMIT...
	Initializing the Body Class... 
		Reading wamit data for body 2...   
	Offsetting STL geometry by the center of gravity from WAMIT...
	Initializing the Wave Class...
	Wave environment: 
	 	irregular waves
		Significant Wave Height Hs=  2.5000 m 
	 	Peak Wave Period Tp=  8.0000 sec
	Attempted to access waveAmpTime(40002); index out of bounds because
	numel(waveAmpTime)=40001.

	Error in wavesIrreg (line 35)
	           waveAmpTime(i) = waveAmpTime(i) +
	           tmp*real(exp(sqrt(-1)*(frequency(j)*t + waves.phaseRand(j))));

	Error in waveSim (line 12)
	        [waves.waveAmpTime,waves.A,waves.w]=wavesIrreg(waves,simu);

	Error in waveSetup (line 8)
	waves = waveSim(waves,body,simu);

	Error in wecSimInputFile (line 37)
	[waves,body] = waveSetup('irregular',2.5,8,body,simu);


* might be nice to have 'wamit' setting methods to report result (e.g., "Setting CG of "Plate" to 0 0 -1").

* more error checking

	* do you have multiple bodies in the Simulink model with the same name (body(1))?

COMPLETED* percent complete goes above 100%

* output forces (by category)

* force in the joints?

* can specify join locations in two places? (mask or input file)?

* use Thor Fossen's MSS Toolbox