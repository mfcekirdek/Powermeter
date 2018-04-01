# Powermeter
Powermeter is a basic powershell based backdoor/post exploit tool. Main functionalities are shown below. You can check the video at the bottom of the page.
Note: It is highly recommended to watch the video at 1080p due to low quality. It will be fixed soon :=)

In main module:

Powermeter>show options

Options
=============

	 Command                			 Description
	 -------                			 -----------
	 get sysinfo            			 Get system information about victim machine
	 get username           			 Get username of victim machine
	 set FLPORT=<port>      			 Set file transfer port
	 rshell                 			 Open reverse shell module
	 start keylogger        			 Start keylogger thread
	 show jobs              			 Show all active threads
	 stop job -keylogger    			 Stop keylogger thread and download captured keystrokes from file port
	 stop job -reverseShell 			 Stop reverse shell session and thread
	 stop job -sendFile     			 Stop file downloading thread
	 stop job -receiveFile  			 Stop file uploading thread
	 stop job -all          			 Stop all active threads
	 screencap -screen      			 Capture screenshot of victim machine [WHOLE SCREEN] and download it
	 screencap -activeWindow			 Capture screenshot of victim machine [ACTIVE WINDOW] and download it
	 download <fileFromVictim>			 Download a file from victim machine.[<fileFromVictim>: An absolute file path in victim machine that the attacker downloads]
	 upload <fileToVictim>  			 Upload a file to victim machine.[<fileToVictim>: An absolute file path in victim machine to store file uploaded by attacker]
	 exit                   			 Exit the program
	 Important: File transfer port should be opened in attacker's side to achieve download,uploading files.

In reverse shell module:

Powermeter>reverse_shell>show options

Options
=============

	 Command                			 Description
	 -------                			 -----------
	 set LHOST=<IPv4>       			 Set local IP address
	 set LPORT=<port>       			 Set local port address
	 run                    			 Start reverse shell
	 back                   			 Exit from reverse shell module


A quick demo video
=============

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/0D49nX_bD_8/0.jpg)](https://www.youtube.com/watch?v=0D49nX_bD_8)

