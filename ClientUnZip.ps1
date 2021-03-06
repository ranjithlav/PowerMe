Param($clientZipFileName, $conversionClientAppFolder, $svcName, $CoversionProfilingClientEXE, $serverIP, $outputFolder, $clientFolder, $serverFolder, $totalRequest, $parallelBatch)


Function GetPath() 
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    $executionPath = Split-Path $Invocation.MyCommand.Path
    return $executionPath
}

$Global:parentFolderPath = GetPath #Get script execution path
$Global:clientConfigPath = ""
$Global:clientPath = ""

Function ClientUnZip
{   
    $zipfilename = "{0}\{1}" -f  $Global:parentFolderPath, $clientZipFileName
    
    $fileName = split-path $zipfilename -Leaf
    If($fileName.Contains("."))
    {
        $fileNameSplit = $fileName.split(".")
        $fileNameWithoutExt = $fileNameSplit[$fileNameSplit.Count - 2] #Get filename without extension
    }
    $folderName = $fileNameWithoutExt
    $parentPath = Split-Path $zipfilename -Parent #Get parent path from .zip file path  
    $destination = "{0}\{1}" -f  $parentPath, $folderName
    
    $Global:clientConfigPath = "{0}\{1}\{2}.config" -f $destination, $conversionClientAppFolder, $CoversionProfilingClientEXE
    $Global:clientPath = "{0}\{1}" -f $destination, $conversionClientAppFolder
    
    $clientOutput = "{0}\{1}" -f $Global:clientPath, $outputFolder
    $clientLog = "{0}\{1}" -f $Global:clientPath, $clientFolder
    $serverLog = "{0}\{1}" -f $Global:clientPath, $serverFolder
    
    Remove-Item -Path $destination -Recurse -Force -ErrorAction SilentlyContinue #Remove folder, if already exists
    New-Item -ItemType directory -Path $destination -Force -ErrorAction SilentlyContinue
    
	If(Test-Path($zipfilename))
	{	
        Write-Host "Extracting: $zipfilename to $destination"
		$shellApplication = new-object -com shell.application
		$zipPackage = $shellApplication.NameSpace($zipfilename)
		$destinationFolder = $shellApplication.NameSpace($destination)
        Write-Host "`nExtracting & moving files... Please wait..."
		$destinationFolder.MoveHere($zipPackage.Items(), 0x14)
                
        $movedPath = "{0}\{1}" -f $destination, $folderName                
        DIR $movedPath | MV -dest $destination
        
        Remove-Item $zipfilename -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $movedPath -Recurse -Force -ErrorAction SilentlyContinue
        
        New-Item -ItemType directory -Path $clientOutput -Force -ErrorAction SilentlyContinue
        New-Item -ItemType directory -Path $clientLog -Force -ErrorAction SilentlyContinue
        New-Item -ItemType directory -Path $serverLog -Force -ErrorAction SilentlyContinue
        
        Write-Host "`nExtraction done..."
	}
    Else
    {
        Write-Host "$zipfilename doesn't exists."
    }  
}

Function UpdateConversionClientConfig()
{   
    Param ($totalRequestCount, $parallelBatchCount)
    
    $ServiceBaseURL = "http://{0}/{1}.svc" -f $serverIP, $svcName
        
    $totalRequestCount = [string]$totalRequest
    $parallelBatchCount = [string]$parallelBatch
       
    If(Test-path $Global:clientConfigPath)
    {
        [xml]$conversionClientConfig = Get-Content $Global:clientConfigPath
                
        Write-Host "Updating Config file..."
        foreach($keys in $conversionClientConfig.configuration.appSettings.add | Where-Object {$_.Key -match "BaseFolderPath" -or $_.Key -match "TotalRequestCount" -or $_.Key -match "parallelBatchCount" -or $_.Key -match "ServiceBase"  -or $_.Key -match "ServerProfilerLogFolder"  -or $_.Key -match "ClientProfilerLogFolder"}) 
        {
            If($keys.Key -eq "BaseFolderPath")
            {
                $keys.Value = $Global:clientPath         
            }
            ElseIf($keys.Key -eq "TotalRequestCount")
            {
                $keys.Value = $totalRequestCount   
            }
            ElseIf($keys.Key -eq "parallelBatchCount")
            {
                $keys.Value = $parallelBatchCount
            }
            ElseIf($keys.Key -eq "ServiceBase")
            {
                $ServiceBaseURL = $ServiceBaseURL -replace '\s',''
                $keys.Value = $ServiceBaseURL         
            }
            ElseIf($keys.Key -eq "ServerProfilerLogFolder")
            {
                $keys.Value = $serverFolder         
            }
            ElseIf($keys.Key -eq "ClientProfilerLogFolder")
            {
                $keys.Value = $clientFolder
            }
        }
        $conversionClientConfig.Save($Global:clientConfigPath)
        Write-Host "`nDone..."
    }
    Else
    {
        Write-Host "File: '$Global:clientConfigPath' not available..."
    }
}

ClientUnZip
UpdateConversionClientConfig 

Start-Sleep -Seconds 3