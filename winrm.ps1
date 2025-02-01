<#
  .SYNOPSIS
    Having fun with WinRM Commands
  .DESCRIPTION
    Having fun with WinRM Commands
  .INPUTS
    N/A
  .NOTES
    Author:         Anders Mikkelsen
    Creation Date:  2025-02-01
    GitHub:         https://github.com/amikkelsendk
    Twitter:        @AMikkelsenDK
    
    Tested on:
    - PowerShell 7.4.x

    IMPORTANT !!!!
    Ensure WinRM HTTP && || HTTPS is enabled
    Make sure UAC is disabled or set to "Never Notify" for the target script/util server
#>

$userName       = "<domain\username>"
$userPasswd     = "**********"
$targetComputer = "<hostname or IP>"


## Create Credentials
$credentials = New-Object -TypeName System.Management.Automation.PSCredential( $userName, $( ConvertTo-SecureString -String $userPasswd -AsPlainText -Force ) )


## Run script via WinRM
Invoke-Command -ComputerName localhost -Credential $credentials -ScriptBlock { powershell.exe -File "c:\get_ad.ps1" }


## Run commands via WinRM
Invoke-Command -ComputerName $targetComputer -Credential $credentials -ScriptBlock { hostname }


## Connect via a PSSession
$winrmPort      = "5985"
$sessionName    = "My PSSession"
$sessionOptions = New-PSSessionOption -SkipCACheck
$session        = New-PSSession -ComputerName $targetComputer -Port $winrmPort -Credential $credentials -Name $sessionName -SessionOption $sessionOptions -ErrorAction SilentlyContinue

Get-PSSession

If ( $session ) {
    # Check if directory exists and create if not
    $targetDirectory = "C:\Scripts"
    If ( -not ( Invoke-Command -Session $session -ScriptBlock { Test-Path -path $args[0]  } -ArgumentList $targetDirectory ) ) {
        Invoke-Command -Session $session -ScriptBlock { [void]( New-Item -ItemType Directory -Force -Path $args[0] )  } -ArgumentList $targetDirectory
    }

    # Get target directory content
    $targetDirectory = "C:\Scripts"
    $folders = Invoke-Command -Session $session -ScriptBlock { Get-ChildItem -Path $args[0] -Directory } -ArgumentList $targetDirectory
    $files   = Invoke-Command -Session $session -ScriptBlock { Get-ChildItem -Path $args[0] -File } -ArgumentList $targetDirectory

    # Copy files to target directory
    $targetDirectory    = "C:\Scripts"
    $sourceFiles        = ( "C:\testfile001.txt", "C:\testfile002.txt" )
    If ( Invoke-Command -Session $session -ScriptBlock { Test-Path -path $args[0] } -ArgumentList $targetDirectory ) {
        Copy-Item -Path $sourceFiles -ToSession $session -Destination $targetDirectory -Confirm:$false -Force -ErrorAction SilentlyContinue
    }

    # Create new file in target directory - with content (SIMPLE)
    $targetFile  = "C:\Scripts\001.txt"
    $fileContent = "This is some test content"
    Invoke-Command -Session $session -ScriptBlock { $args[0] | Out-File $args[1] -encoding:utf8 } -ArgumentList $fileContent, $targetFile

    # Create new file in target directory - with content (MULTI-LINE)
    # https://www.asciitable.com/
    $targetFile  = "C:\Scripts\001.ps1"
    $fileContent = @"
        Try {
            Write-Host "TEST"
            Throw "My error"
        }
        Catch {
            Write-Host $([char]36)( $([char]36)_ | Out-String )
        }
"@
    Invoke-Command -Session $session -ScriptBlock { $args[0] | Out-File $args[1] -encoding:utf8 } -ArgumentList $fileContent, $targetFile
    
    # Get target file content
    $targetFile        = "C:\Scripts\001.txt"
    $targetFileContent = Invoke-Command -Session $session -ScriptBlock { Get-Content -Path $args[0] } -ArgumentList $targetFile

    # Delete target file
    $targetFile        = "C:\Scripts\001.txt"
    Invoke-Command -Session $session -ScriptBlock { Remove-Item -Path $args[0] -Confirm:$false } -ArgumentList $targetFile

    # Execute script in target computer
    $targetFile  = "C:\Scripts\001.ps1"
    Invoke-Command -Session $session -ScriptBlock { powershell.exe -File $args[0] } -ArgumentList $targetFile

    # Execute script in target computer and retrieve script exitcode
    $targetFile  = "C:\Scripts\001.ps1"
    $fileContent = @"
        Write-Host "TEST"
        Exit -1
"@
    $argumentList = "-File $targetFile"
    Invoke-Command -Session $session -ScriptBlock { $args[0] | Out-File $args[1] -encoding:utf8 } -ArgumentList $fileContent, $targetFile
    $result = Invoke-Command -Session $session -ScriptBlock { $process = Start-Process powershell.exe -ArgumentList $args[0] -NoNewWindow -PassThru -Wait -ErrorAction Stop; return $process} -ArgumentList $argumentList
    $result.exitcode

    # Execute script in target computer and retrieve script output and exitcode
    $targetFile  = "C:\Scripts\001.ps1"
    $fileContent = @"
        Write-Host "TEST"
        Exit -1
"@
    Invoke-Command -Session $session -ScriptBlock { $args[0] | Out-File $args[1] -encoding:utf8 } -ArgumentList $fileContent, $targetFile
    $argumentList = "-File $targetFile"
    $scriptBlock = {
        # https://stackoverflow.com/questions/8761888/capturing-standard-out-and-error-with-start-process
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "powershell.exe"
        $pinfo.RedirectStandardError = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.UseShellExecute = $false
        $pinfo.Arguments = $args[0]
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        $p.WaitForExit()
        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()
        $return = "" | Select-Object -Property exitCode, stdOut, stdErr
        # Create return custom object
        $return.exitCode = $p.ExitCode
        $return.stdOut   = $stdout
        $return.stdErr   = $stderr
        return $return
    }
    $result = Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $argumentList
    $result.exitCode
    $result.stdOut
    $result.stdErr
}

# Close session
If ( $session ) {
    Remove-PSSession -Session $session -ErrorAction SilentlyContinue
}
