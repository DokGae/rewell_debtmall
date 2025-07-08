# WSL2 포트 포워딩 스크립트 (Windows PowerShell에서 관리자 권한으로 실행)
$wslIp = (wsl hostname -I).Trim()
$port = 5173

# 기존 규칙 제거
netsh interface portproxy delete v4tov4 listenport=$port listenaddress=0.0.0.0

# 새 포트 포워딩 규칙 추가
netsh interface portproxy add v4tov4 listenport=$port listenaddress=0.0.0.0 connectport=$port connectaddress=$wslIp

# Windows 방화벽 규칙 추가
New-NetFirewallRule -DisplayName "WSL2 Rails Server" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow

Write-Host "포트 포워딩 설정 완료:"
Write-Host "WSL2 IP: $wslIp"
Write-Host "포트: $port"
Write-Host "이제 http://localhost:$port 로 접속 가능합니다."