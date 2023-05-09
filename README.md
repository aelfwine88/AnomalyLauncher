# AnomalyLauncher
Anomaly Affinity Launcher by Eriol (2023)


Purpose of this launcher is to start Anomaly with a CPU affinity where CPU 0 is excluded.
This can ensure that the X-Ray Monolith engine does not use the most occupied core while the game is running.

Available options:

   -MO2_Exe "PathToMO2Executable"        Configures ModOrganizer.exe location
   
   -MO2_Profile MO2Profile               Configures ModOrganizer profile to use (eg: DX11-AVX)
   
   -Anomaly_Delay 5                      Configures delay in seconds before affinity applied
   
   -AskProfile                           Asks for profile regardless of configuration file
   
   -IgnoreConfig                         Ignore usage of launcher configuration file completely
   
   -Help                                 This help summary
