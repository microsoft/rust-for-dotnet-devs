<#
MIT License

Copyright (c) 2019 Atif Aziz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

[CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'Install')]
param(
    [Parameter(ParameterSetName = 'Install')]
    [string]$RequirementsFile,
    [Parameter(ParameterSetName = 'Install')]
    [switch]$SkipProxyScripts,
    [Parameter(ParameterSetName = 'Install')]
    [Parameter(ParameterSetName = 'Uninstall')]
    [string]$BasePath = './.python',
    [Parameter(ParameterSetName = 'Install')]
    [switch]$ExpandPycZip,

    [Parameter(ParameterSetName = 'Uninstall', Mandatory = $true)]
    [switch]$Uninstall,

    [Parameter(ParameterSetName = 'Update', Mandatory = $true)]
    [switch]$Update,

    [Parameter(ParameterSetName = 'List-Versions', Mandatory = $true)]
    [switch]$ListVersions,
    [Parameter(ParameterSetName = 'List-Versions')]
    [switch]$IncludePreRelease,

    [Parameter(ParameterSetName = 'Show-Version', Mandatory = $true)]
    [switch]$Version,

    [Parameter(ParameterSetName = 'Finish-SelfInstall', Mandatory = $true)]
    [switch]$FinishSelfInstall,

    [Parameter(ParameterSetName = 'Finish-Update', Mandatory = $true)]
    [switch]$FinishUpdate,
    [Parameter(ParameterSetName = 'Finish-Update', Mandatory = $true)]
    [string]$CallerPath)

$ErrorActionPreference = 'Stop'

$thisVersion = '1.4.0'

function Remove-CommonLeadingWhiteSpace([string]$s) {
    [regex]::Replace($s, "(?m:^ {$(([regex]::Matches($s, '(?m:^ +)') | Select-Object -ExpandProperty Length | Measure-Object -Minimum).Minimum)})", '') -split '`r?`n'
}

function Get-PieUrl([uri]$url)
{
    if (!$url.IsAbsoluteUri)
    {
        $baseUrl = "https://raw.githubusercontent.com/atifaziz/pie.ps/master"
        if ($env:PIE_DEV_URL) {
            $baseUrl = $env:PIE_DEV_URL.TrimEnd('/')
        }
        "$baseUrl/" + $url.OriginalString.TrimStart('/')
    }
    else
    {
        $url
    }
}

function Write-Batch([string]$path, [string]$content)
{
    Set-Content $path (Remove-CommonLeadingWhiteSpace $content).Trim() -Encoding ascii
}

function Write-PythonBatch
{
    Write-Batch python.cmd '
        @echo off
        setlocal
        set PATH=%~dp0.python;%~dp0.python\Scripts;%PATH%
        python.exe -s -E %*'
}

$cachedVersions = $null

function Get-PythonVersions
{
    if (!$script:cachedVersions)
    {
        $script:cachedVersions =
            Invoke-RestMethod (Get-PieUrl pyver.csv) |
                ConvertFrom-Csv |
                Select-Object @{ L = 'Version'      ; E = { $_.version        } },
                              @{ L = 'VersionPrefix'; E = { $_.version_prefix } },
                              @{ L = 'VersionSuffix'; E = { $_.version_suffix } },
                              @{ L = 'Architecture' ; E = { $_.architecture   } },
                              @{ L = 'Url'          ; E = { $_.url            } }
    }
    $script:cachedVersions
}

function Uninstall
{
    'python', 'pip' |
        % { "$_.cmd" } |
        ? { Test-Path -PathType Leaf $_ } |
        Remove-Item
    Remove-Item -Recurse -Force $basePath
}

function Install
{
    if (Test-Path -PathType Leaf pyver.txt)
    {
        $requiredVersion, $versionDownloadUrl = (Get-Content pyver.txt -TotalCount 1) -split '@'
        Write-Verbose "Required Python version is $requiredVersion."
        if ($versionDownloadUrl -and ($versionDownloadUrl -notmatch '^https?://')) {
            throw "Invalid version download URL (must be a URI using the HTTP or HTTPS scheme): $versionDownloadUrl"
        }
    }

    $python = Join-Path $basePath python.exe
    if (Test-Path -PathType Leaf $python)
    {
        $pythonVersionString = (& $python -V | Out-String).Trim()
        Write-Verbose $pythonVersionString
        $installedVersion = ($pythonVersionString -split ' ', 3)[1]
    }

    if ($installedVersion -and $requiredVersion -and ($installedVersion -ne $requiredVersion))
    {
        Write-Warning "Installed version $installedVersion does not match required version $requiredVersion. Installed version will be removed."
        $uninstall = $true
    }

    if (!(Test-Path -PathType Container $basePath) -or $uninstall)
    {
        $zipPath = Join-Path $env:TEMP python.zip
        if ($versionDownloadUrl)
        {
            $pythonDownloadUrl = $versionDownloadUrl
        }
        else
        {
            if (!$requiredVersion)
            {
                Write-Warning 'There is no "pyver.txt" specifying the Python version to install. The latest version will be installed.'
                $versionStats =
                    Get-PythonVersions |
                        ? { !$_.VersionSuffix } |
                        Select-Object -ExpandProperty Version |
                        % { [version]$_ } |
                        Measure-Object -Maximum
                if (!$versionStats.Count) {
                    throw "There is no Python version available to install."
                }
                $requiredVersion = $versionStats.Maximum
                Write-Verbose "The latest Python version that will be installed is $requiredVersion."
            }
            $archs = @{ AMD64 = 'amd64'; x86 = 'win32' }
            $arch = $archs[$env:PROCESSOR_ARCHITECTURE]
            [uri]$pythonDownloadUrl = Get-PythonVersions |
                ? { ($_.Version -eq $requiredVersion) -and ($_.Architecture -eq $arch) } |
                Select-Object -ExpandProperty Url
            if (!$pythonDownloadUrl) {
                throw "Download URL for Python $requiredVersion ($arch) is unknown."
            }
        }
        [uri]$pythonDownloadUrl = $pythonDownloadUrl
        $zipName = $pythonDownloadUrl.Segments | Select-Object -Last 1
        if ($zipName -like '*.zip')
        {
            $cachedZipPath = Join-Path ./.pythons $zipName
            Write-Verbose "Looking for `"$cachedZipPath`" in local cache..."
            if (Test-Path -PathType Leaf $cachedZipPath)
            {
                Write-Verbose "...found and using cached version instead downloading."
                $zipPath = $cachedZipPath
                $pythonDownloadUrl = $null
            }
            else
            {
                Write-Verbose "...not found."
            }
        }
        if ($pythonDownloadUrl) {
            Invoke-WebRequest $pythonDownloadUrl -OutFile $zipPath
        }
        if ($uninstall) {
            Uninstall
        }
        Expand-Archive $zipPath -DestinationPath $basePath
        $installed = $true
    }

    Remove-Item (Join-Path $basePath *.pth),
                (Join-Path $basePath *._pth)

    if ($installed)
    {
        $pythonVersionString = (& $python -V | Out-String).Trim()
        Write-Verbose $pythonVersionString
        $installedVersion = ($pythonVersionString -split ' ', 3)[1]

        if ($installedVersion -and $requiredVersion -and ($installedVersion -ne $requiredVersion)) {
            throw "Downloaded version $installedVersion does not match required version $requiredVersion. Installation impossible."
        }

        if (!$expandPycZip)
        {
            # Following hack is needed by to make "python setup.py egg_info" work
            # with the embedded distribution. For more, See:
            # https://stackoverflow.com/a/44432707/6682

            Get-ChildItem -File -Filter python*.zip $basePath |
                ? { $_.Name -match 'python[0-9]+\.zip' } |
                % {
                    Move-Item $_.FullName $env:TEMP -Force
                    Expand-Archive (Join-Path $env:TEMP $_.Name) -DestinationPath (Join-Path $basePath $_.Name)
                }
        }
    }

    if (!$skipProxyScripts)
    {
        Write-PythonBatch
        Write-Batch pip.cmd '@call "%~dp0python" -m pip %*'
    }

    [string]$pipVersion = & $python -s -E -m pip --version
    if ($LASTEXITCODE)
    {
        Invoke-WebRequest https://bootstrap.pypa.io/get-pip.py `
            -OutFile (Join-Path $basePath get-pip.py)

        Push-Location $basePath
        try {
            .\python get-pip.py
        }
        finally {
            Pop-Location
        }

        if ($LASTEXITCODE) {
            throw "Installation of pip failed (exit code = $LASTEXITCODE)."
        }

    }
    else
    {
        Write-Verbose $pipVersion
    }

    $requirementsFiles = [string[]]@()

    if ($requirementsFile)
    {
        $requirementsFiles = [string[]]$requirementsFile
    }
    elseif (Test-Path -PathType Leaf requirements-files.txt)
    {
        $requirementsFiles =
            Get-Content requirements-files.txt |
                % { $_.Trim() } |
                ? { $_.Length -gt 0 -and $_ -notmatch '^#' }
    }
    elseif (Test-Path -PathType Leaf requirements.txt)
    {
        $requirementsFiles = [string[]]'requirements.txt'
    }

    if ($requirementsFiles)
    {
        $requirementsFiles |
            % {
                Write-Verbose "Installing requirements from ""$_""..."
                & $python -s -E -m pip install -r $_ --no-warn-script-location
                if ($LASTEXITCODE) {
                    throw "Installation of requirements (from ""$_"") failed (exit code = $LASTEXITCODE)."
                }
            }
    }
}

function Get-UpdatePath { Join-Path $env:TEMP pie.ps1 }

function Update
{
    $temp = Get-UpdatePath
    Invoke-WebRequest (Get-PieUrl pie.ps1) -OutFile $temp
    & $temp -FinishUpdate -CallerPath $PSCommandPath
}

function Finish-Update
{
    Move-Item (Get-UpdatePath) $callerPath -Force

    Push-Location (Split-Path -Parent $callerPath)

    try
    {
        if (Test-Path -PathType Leaf $basePath)
        {
            Remove-Item (Join-Path $basePath *.pth),
            (Join-Path $basePath *._pth)
        }

        Write-PythonBatch
    }
    finally
    {
        Pop-Location
    }

    Write-Output 'Pie updated successfully.'
}

function List-Versions
{
    $versions = Get-PythonVersions
    if (!$includePreRelease) {
        $versions = $versions | ? { !$_.VersionSuffix }
    }
    $versions | Select-Object -ExpandProperty Version -Unique
}

function Finish-SelfInstall
{
    Write-Output 'Pie installed successfully.'
}

function Show-Version
{
    Write-Output $thisVersion
}

$oldPythonHome = $env:PYTHONHOME
if ($oldPythonHome) {
    $env:PYTHONHOME = $null
    Write-Verbose "PYTHONHOME (`"$oldPythonHome`") has been undefined to avoid interference."
}

try
{
    & $PSCmdlet.ParameterSetName
}
finally
{
    if ($oldPythonHome) {
        $env:PYTHONHOME = $oldPythonHome
        Write-Verbose "PYTHONHOME has been restored to `"$env:PYTHONHOME`"."
    }
}
