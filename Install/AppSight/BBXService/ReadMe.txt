================================================================================
Installing AppSight for the first time
================================================================================

For the purposes of this ReadMe, the zip file will be upzipped to the D: Drive.
This can actually be ANY DRIVE that has lots of free space (Gigabytes) and
should typically NOT be the System Drive!

1) Unzip this file to 		: D:\
   This will create the tree 	: D:\BBXService

2) Run 				: D:\BBXService\BBxSVC_Installer\SilentInstall.cmd
   This installs the Black Box Service


================================================================================
Tracing with AppSight
================================================================================

3) To Start AppSight, run	: D:\BBXService\CMD\BBxService_Start.cmd

4) To Stop AppSight and generate a log

	Run			: D:\BBXService\CMD\BBxService_Stop.cmd

        This waits until the BBxService process has ended.
        When this script returns, it is safe to copy the generated ASL File.

        This script first issues a Stop on the Service, and waits.
        If the service is busy writing a large ASL file, 
        the Service Control Stop will timeout.
        However, this script will then wait for the Process End Event.

        Note: It can take anywhere from a minute to 20 minutes or more to generate
        the ASL file.
        

5) Transfer ASL file
        Transfer the most recent ASL file that is
	Located here 		: D:\BBXService\ASL\

================================================================================
Recreating a Problem and Tracing with AppSight
================================================================================

6) To generate a trace while recreating a problem, you should follow a slightly
   modified procedure. You will want to:
   
   Stop AppSight, and save the current session files to an ASL.

	Run			: D:\BBXService\CMD\BBxService_Stop.cmd

   Clear out the session files, so only the problem recreation is included
   in the soon to be generated ASL file. The data in the session files 
   being purged was just saved off by the above BBxService_Stop command.

	Run			: D:\BBXService\CMD\BBxService_Purge_Sessions.cmd

   Start AppSight with a heavier troubleshouting profile.

	Run			: D:\BBXService\CMD\BBxService_Start_WST.cmd

	This WST version runs the heavier Web Server Throubleshooting profile,
        instead of the Web Server Optimized profile.

   *** Recreate the Problem Here ***

   Stop AppSight, and save the current session files to an ASL.

	Run			: D:\BBXService\CMD\BBxService_Stop.cmd

   Transfer ASL file to MetraTech Support for Analysis.
        Transfer the most recent ASL file that is
	Located here 		: D:\BBXService\ASL\


================================================================================
Other Operational Considerations
================================================================================

7) While the AppSight Black Box Service is actively tracing, sessions files are 
   being written to a folder under the System TEMP Environment variable path.

   To see the active session folders,
	Run			: D:\BBXService\CMD\BBxService_List_Sessions.cmd

   The profiles included are configured to generate a max of around 20 sessions of
   about 20 MB each. When tracing starts, a new session folder is created. 
   After 20 MB of trace data has been logged, a new session folder will be created.
   If the max number of sessions folders has been reached, the oldest session folder 
   will be automatically deleted (rolled off). Thus, these profiles, in general, 
   will preserve the last 400+ MB of trace data. 

   Certain events, like process crashes, create specially named session folders
   that are NOT counted against the max. So, it is possible that more than 400 MB
   will be used. If a generated ASL file is significantly larger than 400 MB, you
   should purge the session files. This should only be done once BBxService_Stop.cmd 
   has ended normally, and thus you have a valid ASL with the session data.

   To purge the session files,

	Run			: D:\BBXService\CMD\BBxService_Purge_Sessions.cmd

   On most systems, the System TEMP folder is on the C: Drive. You can use the 
   BBxService_List_Sessions.cmd to display the location of the session folders.

   *** MAKE SURE YOU HAVE AT LEAST 1 GB OF FREE DISK SPACE ON THIS DRIVE ***

   Note: An ASL file is like a zip file containing a copy of the session folders.
   The ASL folder should be on a drive with plenty of space. If the ASL folder is
   on the same drive as the session files, you will need TWICE the free space.
   
   