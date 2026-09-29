# OpenClaw LINE Bot (THU LLM Edition) 🦞

基於 [OpenClaw](https://github.com/openclaw/openclaw) 打造的高效能雙身分隨身 LINE 智慧助理，後端接入東海大學「咚咚妞」高階 AI 運算叢集之 **Inkling (vibe)** 多模態推理模型（運行於 4x NVIDIA Blackwell B200 GPU 上）。

---

## 🌟 核心特色與架構

```
[ LINE 用戶 / 家庭群組 / 實驗室群組 ]
                     │ (HTTPS Webhook)
                     ▼
       [ Cloudflare Tunnel (cloudflared) ]
                     │
       ┌─────────────┴─────────────┐
       ▼                           ▼
/line/family                  /line/lab
       ▼                           ▼
[ 家庭小幫手 Agent ]          [ 實驗室小助手 Agent ]
(workspaces_family)          (workspaces_lab)
       └─────────────┬─────────────┘
                     ▼
  [ OpenClaw Gateway (WSL2 / Linux 核心) ]
                     │ (OpenAI 相容協議)
                     ▼
  [ 東海大學 AI 運算叢集 (api.ithu.tw) ]
   └─ 模型: vibe (4x NVIDIA Blackwell B200)
```

### 1. 雙帳號身分分流 (Multi-Agent Routing)
* **小爪 🦞 (家庭小幫手)** (`@304owgol`)：
  - 專屬定位：長輩生活疑難、健康飲食、養生、家常燉湯食譜教學。
  - 對話風格：溫柔親切、充滿耐心、像懂事貼心的晚輩，絕不提及生硬的電腦硬體與代碼術語。
* **小爪 🦞 (實驗室小助手)** (`@946iqolf`)：
  - 專屬定位：研究團隊科研支援、PyTorch 核心實作、深度學習模型解析、Linux / CUDA 疑難排除。
  - 對話風格：專業俐落、直奔重點、結構清晰，直接輸出易讀的高品質代碼與原理推導。

### 2. 行動端 LINE 排版極致優化
* **LaTeX 符號原生化**：LINE 不支援 LaTeX 語法（`$...$`），助理自動改採直觀的 Unicode 數學表示法（如 `X ∈ ℝ^(N × d_model)`、`Softmax(Q K^T / √d_k) V`、`d_k = d_model / h`）。
* **手機窄螢幕抗破版**：停用 Markdown 表格（`| ... |`），全面改採結構化層級列表與步驟式呈現，在手機畫面上整齊易讀。
* **零背景工具報錯**：透過沙盒策略全面關閉 `exec` / `read` / `write` 工具嘗試，杜絕模型在對話中碎念或回傳英文報錯。

---

## 📁 專案目錄結構

```text
openclaw-linebot/
├── .gitignore                      # 嚴格過濾機密 Key、Token 與個人對話記錄
├── README.md                       # 本專案完整技術手冊
├── assets/
│   └── cover.jpg                   # 官方 16:9 專屬封面圖 (RTX 5080 + OpenClaw 概念視覺)
├── config/
│   └── openclaw.json.example       # 雙帳號路由與去敏感化 OpenClaw 設定檔範本
├── workspaces_family/              # 【家庭小幫手】獨立工作區
│   ├── IDENTITY.md                 # 形象、Emoji 與稱呼定位
│   ├── SOUL.md                     # 說話守則（親切家常、排版友善、禁提硬體代碼）
│   └── USER.md                     # 家庭成員習慣與背景資訊
├── workspaces_lab/                 # 【實驗室小助手】獨立工作區
│   ├── IDENTITY.md                 # 形象、Emoji 與稱呼定位
│   ├── SOUL.md                     # 說話守則（技術核心、無 LaTeX/表格、代碼區塊）
│   └── USER.md                     # 實驗室夥伴與專案背景資訊
└── scripts/
    ├── start_gateway_wsl.sh        # WSL 服務快速重啟指令
    └── test_model.ps1              # 東海 LLM API 連線測試腳本
```

---

## 🚀 快速上手與部署

### 1. 前置準備
* **LINE Developers Console**：
  - 建立兩個 Messaging API Channel（分別命名為「家庭小幫手」與「實驗室小助手」）。
  - 分別獲取兩組 `Channel Secret` 與長期 `Channel Access Token`。
* **東海大學 LLM API**：
  - 登入 [THU LLM 平台](https://llmapi.service.thu.edu.tw/) 取得專屬 API Key（`sk-...`）。
* **執行環境**：
  - Windows 11 + WSL2 (Ubuntu) + Node.js 22+。

### 2. 部署 OpenClaw 配置
將 `config/openclaw.json.example` 複製至主機的 `~/.openclaw/openclaw.json`，並填入真實的憑證：
* 配置 `models.providers.thu` 接入東海模型 `vibe`。
* 配置 `channels.line.accounts.family` 與 `channels.line.accounts.lab`，分別指向 Webhook 路徑 `/line/family` 與 `/line/lab`。
* 配置 `bindings` 實現 Webhook 帳號到 Agent 的精準綁定。

### 3. 同步工作區角色設定
將 `workspaces_family/` 與 `workspaces_lab/` 複製至 WSL2：
```bash
cp -r workspaces_family ~/.openclaw/workspace-family
cp -r workspaces_lab ~/.openclaw/workspace-lab
```

### 4. 啟動 Gateway 與 Cloudflare Tunnel
在 WSL2 中透過 systemd 守護進程啟動服務：
```bash
systemctl --user restart openclaw-gateway.service
```
確保 Cloudflare Tunnel 將公開域名轉發至 WSL2 的 `http://127.0.0.1:18789`。

---

## 💡 LINE 官方帳號設定重點（必看避免踩坑）

1. **群組官方帳號數量限制**：
   - **LINE 限制一個群組中只能存在「最多 1 個」官方帳號（Bot）**。
   - 若將家庭小幫手與實驗室小助手同時加入同一群組，LINE 伺服器會強制將兩個機器人同時踢出。
   - 請將家庭小幫手加入家庭群組、實驗室小助手加入實驗室專屬群組。
2. **開啟加入群組權限**：
   - 新建的 LINE 官方帳號預設可能關閉加入群組功能。
   - 請至 [LINE Official Account Manager](https://page.line.biz) ➡️ 設定 ➡️ 帳號設定 ➡️ 開啟「允許帳號加入群組或多人聊天室」。
3. **關閉官方自動回應訊息**：
   - 在 LINE OA Manager ➡️「回應設定」中，將**自動回應訊息**切換為**停用**。
   - 避免每次在群組提問時，官方系統先行回覆「感謝您的訊息，很抱歉本帳號無法個別回覆...」的罐頭訊息。

---

## 🖥️ 本機中控台 (Control UI) 訪問

OpenClaw 內建美觀的 Web 儀表板，可即時查看 Session 對話歷程、Agent 狀態與 Channel 運作：
* **存取位址**：`http://127.0.0.1:18789/#token=<YOUR_GATEWAY_TOKEN>`
* **排查提示**：若 Windows 瀏覽器訪問時出現 `Control UI assets not found`，通常代表 Windows 本機殘留的舊 Node 進程搶佔了 18789 端口。請確保 18789 端口由 WSL2 Gateway 監聽即可。

---

## 🔒 資安守則

本儲存庫嚴格禁止提交任何實際的 API Key、LINE Secret、Cloudflare Tunnel Token 或個人對話紀錄。所有敏感檔案均已列入 `.gitignore`。
