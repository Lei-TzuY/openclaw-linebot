# ==========================================
# 測試東海大學 THU LLM (vibe / Inkling) 連線腳本
# ==========================================
param(
    [string]$ApiKey = $env:THU_API_KEY
)

if (-not $ApiKey) {
    Write-Host "[WARN] 未偵測到環境變數 THU_API_KEY，請手動輸入金鑰：" -ForegroundColor Yellow
    $ApiKey = Read-Host "THU API Key"
}

$headers = @{
    Authorization = "Bearer $ApiKey"
    "Content-Type" = "application/json; charset=utf-8"
}

$bodyObj = @{
    model = "vibe"
    messages = @(
        @{ role = "user"; content = "測試，請簡短回答OK" }
    )
    max_tokens = 30
}

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes(($bodyObj | ConvertTo-Json))

try {
    Write-Host "正在連線 https://api.ithu.tw/v1/chat/completions (model: vibe)..."
    $res = Invoke-RestMethod -Uri "https://api.ithu.tw/v1/chat/completions" -Headers $headers -Method Post -Body $bodyBytes
    Write-Host "[SUCCESS] 模型回覆: $($res.choices[0].message.content)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] 呼叫失敗: $($_.Exception.Message)" -ForegroundColor Red
}
