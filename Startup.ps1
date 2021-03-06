Param($WASPPath)

Function AdminElavated()
{

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   Write-Host "Script is getting executed in Administrator rights..."
   # We are running "as Administrator" - so change the title and background color to indicate this
   #$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.WindowTitle = "Admin (Elevated)"
   $Host.UI.RawUI.BackgroundColor = "Blue"
   #Clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   #Exit
   }

# Run your code that needs to be elevated here
#Write-Host -NoNewLine "Press any key to continue..."
#$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

add-type -AssemblyName System.Windows.Forms

Function CopyWASPtoModules()
{  
    $modules = "C:\Windows\system32\WindowsPowerShell\v1.0\Modules"
    $folderName = "WASP"
    $modulesPath = "{0}\{1}" -f $modules, $folderName

    New-Item -ItemType directory -Path $modulesPath -Force
    Copy-Item $WASPPath $modulesPath -Force
}

Function AutoNavigationCall()
{
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
    Start-Sleep -m 100
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    
    Import-Module WASP

    #start C:\Windows\System32\dcomcnfg.exe
    #Start-Process 'C:\Windows\System32\dcomcnfg.exe' -Wait -PassThru
    Start-Process -FilePath 'C:\Windows\System32\dcomcnfg.exe' -Wait -passthru;

    $waitTimer = 3
    Start-Sleep -seconds $waitTimer
    Select-Window -ProcessName mmc | Set-WindowActive | Set-WindowPosition -Height 500 -Width 600 -Left 750
    
    Start-Sleep -seconds $waitTimer

    [System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
    Start-Sleep -seconds $waitTimer
    [System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
    Start-Sleep -seconds $waitTimer
    [System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
    Start-Sleep -seconds $waitTimer
    [System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
    Start-Sleep -seconds $waitTimer
    [System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
    Start-Sleep -seconds $waitTimer
    [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
    Start-Sleep -seconds $waitTimer
    [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
    Start-Sleep -seconds $waitTimer
    [System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
    Start-Sleep -seconds $waitTimer
    [System.Windows.Forms.SendKeys]::SendWait("{F5}")
    Start-Sleep -seconds $waitTimer
    [System.Windows.Forms.SendKeys]::SendWait("{F5}")
    Start-Sleep -seconds $waitTimer
    [System.Windows.Forms.SendKeys]::SendWait("{F5}")
}

AdminElavated

CopyWASPtoModules

Start-Sleep -Seconds 5

AutoNavigationCall