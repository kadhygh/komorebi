# Komorebi Manage 命令测试脚本

Write-Host "=== Komorebi Manage 命令测试 ===" -ForegroundColor Green
Write-Host ""

# 1. 检查白名单模式状态
Write-Host "1. 检查白名单模式状态:" -ForegroundColor Cyan
$whitelistMode = komorebic state | ConvertFrom-Json | Select-Object -ExpandProperty whitelist_mode
Write-Host "   白名单模式: $whitelistMode" -ForegroundColor Yellow
Write-Host ""

# 2. 检查当前被管理的窗口
Write-Host "2. 当前被管理的窗口:" -ForegroundColor Cyan
komorebic visible-windows
Write-Host ""

# 3. 获取当前窗口信息
Write-Host "3. 当前 PowerShell 进程信息:" -ForegroundColor Cyan
$psProcess = Get-Process -Id $PID
Write-Host "   进程名: $($psProcess.ProcessName)" -ForegroundColor Yellow
Write-Host "   窗口标题: $($psProcess.MainWindowTitle)" -ForegroundColor Yellow
Write-Host "   窗口句柄: $($psProcess.MainWindowHandle)" -ForegroundColor Yellow
Write-Host ""

# 4. 尝试管理当前窗口
Write-Host "4. 执行 manage 命令..." -ForegroundColor Cyan
komorebic manage
Write-Host "   命令已执行" -ForegroundColor Yellow
Write-Host ""

# 5. 等待处理
Write-Host "5. 等待 3 秒..." -ForegroundColor Cyan
Start-Sleep -Seconds 3
Write-Host ""

# 6. 再次检查被管理的窗口
Write-Host "6. 执行 manage 后的窗口状态:" -ForegroundColor Cyan
komorebic visible-windows
Write-Host ""

# 7. 检查 PowerShell 是否在白名单中
Write-Host "7. 检查 PowerShell 是否在白名单规则中:" -ForegroundColor Cyan
$state = komorebic state | ConvertFrom-Json
if ($state.PSObject.Properties.Name -contains "manage_identifiers") {
    $manageRules = $state.manage_identifiers
    Write-Host "   白名单规则数量: $($manageRules.Count)" -ForegroundColor Yellow

    $psRule = $manageRules | Where-Object { $_.id -like "*powershell*" -or $_.id -like "*pwsh*" }
    if ($psRule) {
        Write-Host "   PowerShell 在白名单中: 是" -ForegroundColor Green
        Write-Host "   规则: $($psRule | ConvertTo-Json)" -ForegroundColor Yellow
    } else {
        Write-Host "   PowerShell 在白名单中: 否" -ForegroundColor Red
    }
} else {
    Write-Host "   无法获取白名单规则" -ForegroundColor Red
}
Write-Host ""

# 8. 建议
Write-Host "=== 建议 ===" -ForegroundColor Green
Write-Host "如果 PowerShell 窗口没有被管理，可能的原因:" -ForegroundColor Yellow
Write-Host "1. PowerShell 窗口可能不符合管理条件（没有标题栏等）" -ForegroundColor White
Write-Host "2. 需要先将 PowerShell 添加到白名单:" -ForegroundColor White
Write-Host "   komorebic manage-rule exe powershell.exe" -ForegroundColor Cyan
Write-Host "   或" -ForegroundColor White
Write-Host "   komorebic manage-rule exe pwsh.exe" -ForegroundColor Cyan
Write-Host "3. 然后重启 PowerShell 窗口" -ForegroundColor White
Write-Host ""

Write-Host "=== 测试完成 ===" -ForegroundColor Green
