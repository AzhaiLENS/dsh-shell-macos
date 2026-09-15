# 架构详解（DeepSeek Harness macOS Shell）

> 全部实现都在单文件 `Sources/main.swift`（2059 行）。本文按「启动 → 网页 → 交互」三条线拆解，每条都给出源码行号，便于对照阅读。

## 0. 分层视图

```
┌ 应用层 ────────────────────────────────────────────────┐
│ AppController        :1595  窗口/菜单/快捷键/生命周期   │
│ ToolbarView          :1329  顶栏（标题+导航按钮，无地址栏）│
│ MenuAnimationDelegate:1556  菜单动画                    │
└───────────────┬───────────────────────────────────────┘
                │ 持有
┌ 视图层 ───────▼───────────────────────────────────────┐
│ WebContainer         :945   NSView + WKWebView + 委托  │
│  ├ 注入脚本 ×2（.atDocumentStart）                     │
│  ├ 查找栏 / 进度条 / 状态标签 / 加载遮罩               │
│  └ 下载、新窗口、上传面板、导航策略                    │
└───────────────┬───────────────────────────────────────┘
                │ 加载 http://127.0.0.1:<port>?token=…
┌ 进程层 ───────▼───────────────────────────────────────┐
│ DshProcess           :709   子进程 + stdout/stderr 解析 │
│ 端口与残留治理       :566-698                          │
└───────────────────────────────────────────────────────┘
                │ spawn
          DSH CLI（上游，不含在本仓库）
```

## 1. 常量与全局

| 名称 | 行号 | 值/作用 |
|---|---|---|
| `kDshPath` | `:13` | `/opt/homebrew/bin/dsh` —— 子进程可执行文件，硬编码，可自行修改 |
| `kPreferredPorts` | `:14` | `[47615, 47616, 47617, 47618, 47619]` 首选端口段 |
| `kStartupTimeout` | `:15` | `60.0` 秒 —— 启动总超时 |
| `kHealthCheckInterval` | `:16` | `0.3` 秒 —— 就绪轮询间隔 |
| `kDownloadsSubdir` | `:17` | `"DeepSeek Harness"` —— 下载子目录名 |
| `kLocalizationScript` | `:21-358` | 界面中文化注入脚本（字典约 160 条 + `MutationObserver` 增量翻译） |
| `kFileUploadScript` | `:361-563` | 上传限制解除脚本（类型白名单、粘贴、拖拽） |

## 2. 进程层：`DshProcess`

| 方法 | 行号 | 行为 |
|---|---|---|
| `start(statusUpdate:)` | `:723` | 选端口 → `Process()` 启动 `dsh web --no-open --port <port>`；`env["PATH"]` 前置 Homebrew 路径；`currentDirectoryURL = NSHomeDirectory()`；stdout/stderr 各接 `Pipe`；挂 `terminationHandler` |
| `startReadingStdout()` | `:788` | `DispatchSource.makeReadSource` 逐行读，交给 `parseLine` |
| `startReadingStderr()` | `:811` | 逐行读 stderr，进环形缓冲（`recentStderr`）供诊断 |
| `parseLine(_:)` | `:865` | 正则 `https?://[^\s"'\)<>\\]+` 抓首个 URL → `tokenURL` |
| `waitReady(completion:)` | `:881` | 定时轮询（0.3s / 上限 60s），拿到 `tokenURL` 后 `probe` |
| `probe(url:completion:)` | `:908` | `URLSession` 请求，HTTP 2xx → 就绪 |
| `diagnose(_:)` | `:838` | 识别已知报错（如 `duplicate loader entry id: <id>`）并给出可操作建议 |
| `formattedDiagnostics()` | `:922` | 汇总最近 stderr，用于弹窗提示 |
| `terminate()` | `:930` | 先 `terminate()`（SIGTERM），超时后强制结束；最多等 3 秒 |

**端口与残留治理**（`：566-698`）

- `isPortFree(_:)` `:566` —— BSD socket `bind` 探测。
- `listeners(on:)` `:609` —— 调 `/usr/sbin/lsof -nP -iTCP:<port> -sTCP:LISTEN -t` 取占用 PID。
- `fullCommand(of:)` `:617` / `parentPid(of:)` `:622` —— 调 `/bin/ps` 取命令行与父进程，用于**特征判定**。
- `looksLikeOurDsh(_:port:)` `:632` —— 命令行同时含 `dsh` 与端口号才算"我们的"。
- `isOrphanedProcess(_:)` `:642` —— 父进程命令行含 `dsh` 视为仍在管，否则视为孤儿。
- `terminateProcess(_:grace:)` `:653` —— SIGTERM → 3s 宽限 → SIGKILL（再 1.5s）。
- `reclaimPortFromStaleDsh(_:)` `:672` —— 只回收"像我们的 dsh"的进程，避免误杀。
- `findFreePort()` `:690` —— 先试 `kPreferredPorts`，再退化为系统分配。

## 3. 视图层：`WebContainer`（`:945-1327`）

### 3.1 初始化（`:968`）

```swift
let cfg = WKWebViewConfiguration()
let userContent = WKUserContentController()
userContent.addUserScript(WKUserScript(source: kLocalizationScript, injectionTime: .atDocumentStart, forMainFrameOnly: true))   // :971-972
userContent.addUserScript(WKUserScript(source: kFileUploadScript,   injectionTime: .atDocumentStart, forMainFrameOnly: true))   // :973-974
cfg.preferences.javaScriptCanOpenWindowsAutomatically = true                                                                     // :976
cfg.websiteDataStore = .nonPersistent()        // 不落盘，隐私友好                                                               // :980
webView.customUserAgent = "DeepSeekHarness/0.4 macOS App"                                                                        // :988
```

同时开启：导航手势 `allowsBackForwardNavigationGestures`（`:987`）、缩放 `allowsMagnification`（`:988`）、KVO 观察（`setupKVO` `:1043`）观察 `title/url/estimatedProgress/loading/canGoBack/canGoForward`。

### 3.2 键盘与导航

| 方法 | 行号 | 行为 |
|---|---|---|
| `performKeyEquivalent(with:)` | `:1009` | 拦截 ⌘W / Ctrl+W，不关窗 |
| `forwardCloseKeyToWeb(cmd:ctrl:)` | `:1021` | 把关闭键转发给页面（让 DSH 内部标签自己处理） |
| 加载入口 | `:1079-1082` | 记录 `tokenURL`，`URLRequest(cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)` |
| `decidePolicyFor navigationAction` | `:1314` | 导航策略（外链等场景处理） |
| `createWebViewWith …` | `:1156` | `window.open` / `target=_blank` → 复用当前 WebView 承载，不开新窗口 |
| `runOpenPanelWith …` | `:1166` | 网页文件选择 → 弹 `NSOpenPanel`（`:1167`） |
| `decidePolicyFor navigationResponse` | `:1233` | 命中下载条件的响应转 `WKDownload`（`:1246`） |
| `download(_:decideDestinationUsing:…)` | `:1251` | 目标目录 `~/Downloads/DeepSeek Harness/`（`:1254`） |
| `downloadDidFinish` / `download(_:didFailWithError:…)` | `:1268` / `:1292` | 完成/失败提示 |

### 3.3 页面内查找栏

查找栏由 `WebContainer` 内的 `findBar`/`findField`（`:948-949`）构成，⌘F 唤出（`showFindBar` `:1914`）、⌘G 下一个（菜单 `:1818`），高亮通过 `find(_:configuration:)` 系列 API 完成。

## 4. 应用层：`AppController`（`:1595-2051`）

| 关注点 | 行号 | 说明 |
|---|---|---|
| 窗口创建 | `:1624-1634` | `NSWindow` 1280×820；标题 `DeepSeek Harness`；`setFrameAutosaveName("DeepSeekHarnessMainWindow")` 记住尺寸位置 |
| 标题联动 | `:1049` | 跟随网页标题（空则回落为 `DeepSeek Harness`） |
| 主菜单 | `:1754` 起（`setupMenu()`；`animatedSubmenu` `:1758`） | 全中文：应用（关于/偏好设置 ⌘, /隐藏/退出 ⌘Q）、文件（新建会话 ⌘N、在浏览器打开 ⌘O、关闭窗口）、编辑（撤销/重做/剪切/复制/粘贴/粘贴并匹配样式 ⇧⌘V/全选/查找 ⌘F/查找下一个 ⌘G）、显示（重新载入 ⌘R、强制重新载入 ⇧⌘R、停止 ⌘.、实际大小 ⌘0、放大 ⌘+、缩小 ⌘-、全屏幕、显示/隐藏工具栏）、帮助（`:1866-1869`） |
| 页面动作 | `:1430` 起 | 在默认浏览器打开 ⌘O（`:1441`）、复制当前页 URL ⇧⌘C（`:1446`）、Safari/Chrome/Firefox（`:1454-1468`）、打印 ⌘P（`:1525`）、导出 PDF（`:1532`） |
| 新建会话 | `:1879` | ⌘N |
| 偏好设置 | `:2002` | ⌘, |
| 帮助 | `:1869`、`:2010` | 打开上游仓库 `https://github.com/deepseek-ai/dsh` |
| 退出清理 | `:2023-2024` | `applicationWillTerminate` → `dsh?.terminate()`；`:2017` 关掉唯一窗口即退出应用 |
| 入口 | `:2053-2059` | 纯代码：`NSApplication.shared` → `app.delegate = AppController()` → `setActivationPolicy(.regular)` → `app.run()` |

## 5. 菜单动画：`MenuAnimationDelegate`（`:1556-1593`）

`NSMenuDelegate` 实现，菜单展开时对窗口做轻微的 `y` 位移 + 动画（`:1578`、`:1584`），形成"淡入/上浮"观感。所有弹出菜单通过 `animatedSubmenu(_:)` 统一挂载该委托。

## 6. 注入脚本要点

| 脚本 | 行号 | 机制 |
|---|---|---|
| 中文化 | `:21-358` | 用 `dict` 做英文→中文映射；`NodeFilter` 遍历元素与文本节点；用 `data-dsh-tx` 标记避免重复翻译；`MutationObserver` 监听 `childList/characterData/attributes` 做增量翻译；跳过可编辑区域（输入框不受影响） |
| 上传补丁 | `:361-563` | 解除文件类型限制；接管 `<input type=file>`；支持粘贴与拖拽；对动态出现的控件持续打补丁（幂等守卫 `__dshFileUploadPatched`） |

## 7. 线程模型

- UI 与 `WKWebView` 操作全部在主线程（`DispatchQueue.main.async`，如 `:873`、`:886`）。
- 子进程读管道、就绪轮询在全局并发队列（`DispatchQueue.global()`，如 `:791`、`:813`、`:883`），状态经主线程回投。
- `stderr` 缓冲用 `NSLock` 保护（`:720`）。

## 8. 扩展点建议

| 想改什么 | 从哪里下手 |
|---|---|
| 换 DSH 可执行文件路径 | `kDshPath`（`:13`） |
| 换端口段 | `kPreferredPorts`（`:14`） |
| 增加/修正中文化词条 | `kLocalizationScript` 的 `dict`（`:21` 起） |
| 改下载目录 | `download(_:decideDestinationUsing:…)` 内 `kDownloadsSubdir`（`:1254`） |
| 加菜单项 | `AppController` 的 `setupMenu()`（`:1754` 起） + 对应 `@objc func` |
| 换窗口默认尺寸 | `:1624` |
