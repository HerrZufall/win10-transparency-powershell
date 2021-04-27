Write-Host "
  
    Make Windows transparent
    :( Does not work on Explorer-Windows so far... 
    :( and Admin-Windows for sure... XD
    
  "

#### Settings
# Opacity value between 0 and 255 - 0 will be fully transparent and unusable. DON'T!
$opacity = 240
# Transparency will be set in a loop every ... seconds.
$StepsInSeconds = 1
# These will be set to not transparent.
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
    Write-Host [ $_.ProcessName ] $_.MainWindowTitle
    $windowLong = $user32::GetWindowLong($process.MainWindowHandle, -20)
    $user32::SetWindowLong($_.MainWindowHandle, -20, ($windowLong -bor 0x80000)) | Out-Null
    $user32::SetLayeredWindowAttributes($process.MainWindowHandle, 0, $opacity, 0x02) | Out-Null
  }
}


While ('yes' -eq 'yes') { 
 
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

Write-Host "

Transparancy set. (Every $StepsInSeconds seconds)"
Start-Sleep -s $StepsInSeconds
}
