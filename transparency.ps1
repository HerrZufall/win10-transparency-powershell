# Sets Transparency for Windows 10 through Powershell

#### Settings
# Opacity value between 0 and 255 - 0 will be fully transparent and unusable. DON'T!
$opacity = 230
# Transparency will be set in a loop every ... seconds.
$StepsInSeconds = 1
# These will not be transparent.
$notTransparentWindowNames = "youtube|you tube|netflix|vimeo|vlc|video"

function Set-Transparency {
  [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        $process,
        $user32,
        $opacity
  )
  PROCESS {
    Write-Host [ $process.ProcessName ] $process.MainWindowTitle
    $windowLong = $user32::GetWindowLong($process.MainWindowHandle, -20)
    $user32::SetWindowLong($process.MainWindowHandle, -20, ($windowLong -bor 0x80000)) | Out-Null
    $user32::SetLayeredWindowAttributes($process.MainWindowHandle, 0, $opacity, 0x02) | Out-Null
  }
}

function Set-ExplorerTransparency {
  [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        $process,
        $user32,
        $opacity
  )
  PROCESS {
    Write-Host [ $_.Name ] $_.LocationName
    $windowLong = $user32::GetWindowLong($_.HWND, -20)
    $user32::SetWindowLong($_.HWND, -20, ($windowLong -bor 0x80000)) | Out-Null
    $user32::SetLayeredWindowAttributes($_.HWND, 0, $opacity, 0x02) | Out-Null
  }
}



While ('yes' -eq 'yes') { 

  clear
  Write-Host "
  
    Transparency for Windows 10
    (c) Thomas Friedrich Boehme

  "

 
$user32 = Add-Type -Name 'user32' -Namespace 'Win32' -PassThru -MemberDefinition @'

[DllImport("user32.dll")]
public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

[DllImport("user32.dll")]
public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

[DllImport("user32.dll", SetLastError = true)]
public static extern bool SetLayeredWindowAttributes(IntPtr hWnd, uint crKey, int bAlpha, uint dwFlags);
'@

Write-Host "
NOT TRANSPARENT [$notTransparentWindowNames]
---------------"
Get-Process | Where-Object {$_.MainWindowTitle -match $notTransparentWindowNames } | Set-Transparency -user32 $user32 -opacity 255

Write-Host "
TRANSPARENT
-----------"
Get-Process | Where-Object {-not ([string]::IsNullOrEmpty($_.MainWindowTitle)) -and ($_.MainWindowTitle -notMatch $notTransparentWindowNames)} | Set-Transparency -user32 $user32 -opacity $opacity
#ExplorerWindows
$app = New-Object -COM 'Shell.Application'
$app.Windows() | Set-ExplorerTransparency -user32 $user32 -opacity $opacity

Write-Host "

Transparancy set. (Every $StepsInSeconds seconds)"
Start-Sleep -s $StepsInSeconds
}
