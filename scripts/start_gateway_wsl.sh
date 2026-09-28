#!/usr/bin/env bash
# ==========================================
# 重啟 WSL 內的 OpenClaw Gateway 服務
# ==========================================

echo "正在重啟 OpenClaw Gateway 服務..."
systemctl --user restart openclaw-gateway.service

echo "檢查服務狀態："
systemctl --user status openclaw-gateway.service --no-pager
