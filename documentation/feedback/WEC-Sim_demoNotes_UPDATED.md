# WEC-Sim notes
RG Coe 04/23/2014
Kelley 5/26/14

* add set moment of inertia method using WAMIT


COMPLETED* not a fan of using the same file names (e.g., wecModel.slx, wecSimInputFile.m) for all models


* using WEC-Sim is straightforward, as long as you understand the workflow (i.e., setting up the system in Simulink and then defining its parameters in the input file); I see this as the least intuitive part of set-up


COMPLETED* irregular waves do not work?


COMPLETED* is there a lower limit on the simulation length? (tried to run irregular waves at dt = 0.001s for 40s w/ Hs = 2.5m and Tp = 8s; see below for error)


* might be nice to have 'wamit' setting methods to report result (e.g., "Setting CG of "Plate" to 0 0 -1").

* more error checking

	* do you have multiple bodies in the Simulink model with the same name (body(1))?

COMPLETED* percent complete goes above 100%


COMPLETED* output forces (by category)

* force in the joints?

? * can specify joint locations in two places? (mask or input file)?


COMPLETED* use Thor Fossen's MSS Toolbox