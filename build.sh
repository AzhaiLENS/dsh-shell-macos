#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  DeepSeek Harness macOS Shell — 构建脚本
#  用法: ./build.sh [--sign]
#    --sign   额外做一次 ad-hoc 签名（codesign -s -），便于本机运行
#
#  说明: 本脚本在本项目作者的机器上**未做过端到端验证**（该机 Xcode 许可
#        未接受，swiftc 被系统拦截）。请在你自己环境执行并以实际结果为准。
# ---------------------------------------------------------------------------
set -euo pipefail

APP_NAME="DeepSeek Harness"
EXEC_NAME="DeepSeekHarness"
BUNDLE_ID="com.local.deepseek-harness"
VERSION="0.4.10"
MIN_MACOS="11.0"
SRC="Sources/main.swift"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"

echo "==> 检查工具链"
if ! command -v swiftc >/dev/null 2>&1; then
  echo "错误: 未找到 swiftc。" >&2
  echo "      请安装 Xcode 或 Command Line Tools，并执行: sudo xcodebuild -license accept" >&2
  exit 1
fi

echo "==> 编译 $SRC"
mkdir -p "$BUILD_DIR"
swiftc -O "$SRC" -o "$BUILD_DIR/$EXEC_NAME" \
  -framework Cocoa -framework WebKit -framework AVFoundation

echo "==> 组装 $APP_DIR"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
mv "$BUILD_DIR/$EXEC_NAME" "$APP_DIR/Contents/MacOS/$EXEC_NAME"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key><string>$APP_NAME</string>
	<key>CFBundleDisplayName</key><string>$APP_NAME</string>
	<key>CFBundleExecutable</key><string>$EXEC_NAME</string>
	<key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
	<key>CFBundlePackageType</key><string>APPL</string>
	<key>CFBundleShortVersionString</key><string>$VERSION</string>
	<key>CFBundleVersion</key><string>$VERSION</string>
	<key>LSMinimumSystemVersion</key><string>$MIN_MACOS</string>
	<key>NSHighResolutionCapable</key><true/>
	<key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
PLIST

if [[ "${1:-}" == "--sign" ]]; then
  echo "==> ad-hoc 签名"
  codesign --force --deep --sign - "$APP_DIR" || {
    echo "提示: 签名失败（可能需要 Xcode 许可或开发者证书），可跳过本步骤。" >&2
  }
fi

echo "==> 完成: $APP_DIR"
echo "    运行: open \"$APP_DIR\""
echo "    若被 Gatekeeper 拦下: 右键 →「打开」，或执行"
echo "      xattr -dr com.apple.quarantine \"$APP_DIR\""
echo
echo "    前置条件: 本机已安装 DSH CLI，且位于 /opt/homebrew/bin/dsh"
echo "              （路径为源码常量 kDshPath，Sources/main.swift:13，可自行修改）"
