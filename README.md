# OpenClaw LINE Bot (THU LLM Edition) 🦞

基於 [OpenClaw](https://github.com/openclaw/openclaw) 打造的個人隨身 LINE 智慧助理，後端接入東海大學「咚咚妞」高階 AI 運算叢集之 **Inkling (vibe)** 多模態推理模型（跑在 4x NVIDIA Blackwell B200 GPU 上的開源頂級模型）。

---

## 🌟 系統架構

```
[ LINE 用戶 ]
      │ (HTTPS Webhook)
      ▼
[ Cloudflare Tunnel (cloudflared) ]
      │ (安全穿透到內網)
      ▼
[ OpenClaw Gateway (WSL2 / Linux) ] ◄── [ 角色與對話規範 (SOUL.md, IDENTITY.md) ]
      │ (OpenAI 相容協議)
      ▼
[ 東海大學 AI 運算叢集 (api.ithu.tw) ]
      └─ 模型: vibe (Thinking Machines Lab Inkling MoE 模型 / 4x NVIDIA B200)
```

---

## 📁 專案目錄結構

```text
openclaw-linebot/
├── .gitignore                      # 嚴格過濾所有機密 Key、Token 與個人對話記錄
├── README.md                       # 本說明文檔
├── config/
│   └── openclaw.json.example       # OpenClaw 去敏感化設定範本 (LINE + THU Provider)
├── workspace/                      # 助理心智與個人認知設定檔
│   ├── IDENTITY.md                 # 助理名稱、形象與 Emoji 設定
│   ├── SOUL.md                     # 說話準則（嚴禁報系統後台檔案、親切繁中對話）
│   └── USER.md                     # 使用者個人偏好與稱呼設定
└── scripts/
    ├── start_gateway_wsl.sh        # WSL 服務快速重啟指令
    └── test_model.ps1              # THU LLM API 連線測試腳本
```

---

## 🚀 快速上手與部署

### 1. 前置準備
* **LINE Developers Console**：建立 Messaging API Channel，取得 `Channel Secret` 與 `Channel Access Token`。
* **東海大學 LLM API**：至 [THU LLM 平台](https://llmapi.service.thu.edu.tw/) 取得 API Key（`sk-...`）。
* **環境**：Windows 11 + WSL2 (Ubuntu) + Node.js 22+。

### 2. 設定 OpenClaw 設定檔
將 `config/openclaw.json.example` 複製至主機的 `~/.openclaw/openclaw.json`，並填入真實的憑證：
```json
"models": {
  "providers": {
    "thu": {
      "baseUrl": "https://api.ithu.tw/v1",
      "apiKey": "YOUR_ACTUAL_THU_API_KEY",
      "models": [
        { "id": "vibe", "name": "THU vibe (Inkling)" }
      ]
    }
  }
},
"agents": {
  "defaults": {
    "model": {
      "primary": "thu/vibe"
    }
  }
},
"channels": {
  "line": {
    "enabled": true,
    "channelSecret": "YOUR_ACTUAL_CHANNEL_SECRET",
    "channelAccessToken": "YOUR_ACTUAL_CHANNEL_ACCESS_TOKEN"
  }
}
```

### 3. 配置助理人設 (Prompts)
將 `workspace/` 中的 `IDENTITY.md`、`SOUL.md` 與 `USER.md` 複製至工作區路徑（如 `~/.openclaw/workspace/`）：
* `IDENTITY.md`：設定助理名稱與 Emoji（預設：OpenClaw 智慧助理 小爪 🦞）。
* `USER.md`：設定助理對您的稱呼（例如：子毅）。
* `SOUL.md`：內含「防系統碎念規範」，保證機器人像正常人一樣簡潔親切對話，絕不報內部檔案路徑與狀態。

### 4. 啟動與連線
在 WSL2 中啟動或重啟 OpenClaw Gateway 服務：
```bash
bash scripts/start_gateway_wsl.sh
```

---

## 🛠️ 常見問題排查 (FAQ)

### Q1: LINE 發送訊息回覆 `⚠️ Something went wrong...`？
1. **檢查 API Key 是否到期**：執行 `scripts/test_model.ps1` 測試金鑰是否過期（401 Unauthorized）。
2. **檢查模型端點名稱**：確認使用的是 `vibe` 或 `vibecode`，舊別名（如 `gpt-oss-120b` 或 `nemotron-3-ultra`）已被伺服器端禁用（403 Forbidden）。

### Q2: 機器人說一堆檔案名稱、bytes 大小、yield/abort 等外星話？
* 請在 LINE 對話室輸入 **`/new`** 重置對話 Session。
* 確認 `SOUL.md` 已正確配置防自言自語守則。

---

## 🔒 資安守則
本儲存庫嚴格禁止提交任何實際的 API Key、LINE Secret、Cloudflare Tunnel Token 或個人對話紀錄。所有敏感檔案均已列入 `.gitignore`。
