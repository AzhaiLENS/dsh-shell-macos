# DeepSeek Harness macOS Shell（DSH 套壳 App）

> 给 [DeepSeek Harness](https://github.com/deepseek-ai/dsh) 的 **macOS 原生套壳应用**：把 DSH 的本地 Web 界面包进一个原生窗口里，自带中文化、文件上传补丁、完整浏览器级菜单与下载管理。
>
> **本仓库只包含这个"壳"（前端 App）本身** —— 不含 DSH 后端、不含任何插件、不含任何凭据或私人配置。

- 语言/框架：**Swift + AppKit(Cocoa) + WebKit(WKWebView)**，单文件源码 `Sources/main.swift`（2059 行）
- 目标平台：**macOS 11.0+（Apple Silicon / Intel 均可编译）**，**仅 macOS**
- 构建方式：`swiftc` 直接编译单文件 + 组装 `.app`（无 Xcode 工程、无第三方依赖）

---

## 一、适用平台：为什么只有 macOS

| 项 | 值 | 依据 |
|---|---|---|
| 最低系统 | **macOS 11.0** | `LSMinimumSystemVersion = 11.0`（已装机 bundle 的 `Info.plist`） |
| 运行平台 | **仅 macOS** | 源码 `import Cocoa` / `import WebKit`（`Sources/main.swift:1-3`），窗口层直接使用 `NSWindow`/`NSView`（`:1595`）、网页容器使用 `WKWebView`（`:945`）；Windows/Linux 无 AppKit 与 WKWebView，**无法运行** |
| 架构 | 单文件 `.swift`，无平台相关汇编或私有 API；源码层面与 CPU 架构无关（已装机二进制为 arm64） | `file` 结果：`Mach-O 64-bit executable arm64` |

> **关于技术栈的一点澄清**：本项目的技术栈是 **Swift + AppKit + WebKit(WKWebView)**，"WebKit" 指的是 macOS 系统自带的网页渲染框架，不是跨平台 UI 工具包——这也是它只能跑在 macOS 上的根本原因。（早期口述里提到的名字不准确，此处以源码与二进制链接库为准。）

**二进制实证**（对已装机 App 的 `otool` 等价解析，Load Commands）：

```
AppKit.framework / WebKit.framework / Foundation / CoreGraphics / QuartzCore / CFNetwork
libswiftCore.dylib / libswiftDispatch.dylib …   ← Swift 运行时，非 Electron / 非 Tauri
```

---

## 二、架构总览

一句话：**启动一个 `dsh` 子进程 → 从它的 stdout 里抓出本地 Web URL → 用 `WKWebView` 加载该 URL → 通过注入脚本改造页面 → 用原生菜单/工具栏补齐浏览器级体验。**

```
┌──────────────────────────────────────────────────────────────────────┐
│  DeepSeekHarness.app   （本仓库，纯前端壳层）                          │
│                                                                      │
│  main (Sources/main.swift:2053)                                      │
│     └─ NSApplication + AppController(NSApplicationDelegate)          │
│                                                                      │
│  AppController (:1595)   窗口 1280×820、中文菜单、快捷键、生命周期      │
│     ├─ ToolbarView (:1329)          标题 + 后退/前进/刷新（无地址栏）   │
│     └─ WebContainer (:945)          NSView 容器，内嵌 WKWebView        │
│           ├─ WKUserScript ×2  (注入时机 .atDocumentStart)              │
│           │    ├─ kLocalizationScript (:21)   界面中文化（160 条词条）  │
│           │    └─ kFileUploadScript   (:361)  解除上传类型限制/粘贴/拖拽│
│           ├─ WKNavigationDelegate / WKUIDelegate / WKDownloadDelegate │
│           └─ KVO 观察 title/url/progress/loading/canGoBack/Forward     │
│                                                                      │
│  DshProcess (:709)   子进程管理 + 端口治理 + 就绪探测 + 故障诊断        │
│     └─ 启动 /opt/homebrew/bin/dsh web --no-open --port <port>          │
└──────────────────────────────────────────────────────────────────────┘
                               │  spawn（子进程）
                               ▼
        DSH CLI（后端，**不在本仓库**）→ 本地 HTTP 服务（默认端口段 47615-47619）
```

### 启动时序

```
1. NSApplication 启动 → AppController 建窗口、装菜单、起加载遮罩      (:1603 起 · applicationDidFinishLaunching)
2. DshProcess.start()                                              (:723)
   · findFreePort()  依次试 47615→47619，全占用则返回失败           (:690)
   · Process() 启动 `/opt/homebrew/bin/dsh web --no-open --port <port>`
   · env.PATH 前置 /opt/homebrew/bin…；工作目录 = 用户主目录
   · stdout/stderr 各挂 Pipe + DispatchSourceRead（非阻塞逐行读）
3. parseLine() 用正则从 stdout 抓首个 http(s) URL → tokenURL        (:865)
   （DSH 会打印带本地访问令牌的 URL，令牌只存在于内存，不落盘）
4. waitReady() 定时器 0.3s 轮询、总超时 60s                          (:881)
   · probe() 发 URLSession 请求，HTTP 2xx 即视为就绪                 (:908)
5. WebContainer 加载 tokenURL（绕过本地缓存、15s 超时）              (:1082)
6. 两个注入脚本在文档开始前生效 → 页面被中文化 + 上传限制解除
7. 用户关闭窗口 → applicationWillTerminate → dsh?.terminate() 收拾子进程（:2023）
```

### 组件清单

| 组件 | 位置 | 职责 |
|---|---|---|
| `DshProcess` | `:709-943` | 起停 `dsh` 子进程；端口选择与抢占回收；stdout/stderr 逐行解析；就绪探测；故障诊断文案 |
| 端口/残留治理 | `:566-698` | `isPortFree`(`:566`)、`listeners`(`:609`, lsof)、`fullCommand`/`parentPid`(`:617`/`:622`)、`looksLikeOurDsh`(`:632`)、`isOrphanedProcess`(`:642`)、`terminateProcess`(`:653`, 先 TERM 后 KILL)、`reclaimPortFromStaleDsh`(`:672`)、`findFreePort`(`:690`) |
| `WebContainer` | `:945-1327` | `WKWebView` 容器：配置注入脚本、非持久化数据仓、自定义 UA、KVO 状态、查找栏、下载委托、新窗口策略、⌘W 转发 |
| `ToolbarView` | `:1329-1554` | 顶栏：标题 + 后退/前进/刷新（**刻意不做地址栏**）；含「在默认浏览器打开/复制 URL/打印/导出 PDF」等菜单项 |
| `MenuAnimationDelegate` | `:1556-1593` | 菜单淡入 + 位移的动画委托（`NSMenuDelegate`） |
| `AppController` | `:1595-2051` | 窗口与生命周期、全套中文菜单与快捷键、偏好设置、新建会话、帮助跳转 |
| 入口 | `:2053-2059` | 纯代码 `NSApplication.setActivationPolicy(.regular)` + `app.run()`（无 storyboard/XIB） |

### 几个值得说明的设计决策

- **不做地址栏**：这是一个"应用"而不是浏览器，地址栏只会带来误导与钓鱼风险；需要外部访问时用菜单显式「在默认浏览器中打开」（`:1441`）。
- **非持久化网页数据仓**：`cfg.websiteDataStore = .nonPersistent()`（`:980`），Cookie/缓存不落盘，退出即清 —— 隐私友好，也避免残留会话状态。
- **自定义 UA**：`DeepSeekHarness/0.4 macOS App`（`:988`），便于页面侧识别来源。
- **⌘W 转发而非关窗**：`performKeyEquivalent` 拦截 ⌘W/Ctrl+W 交给页面处理（`:1009`、`:1021`），让 DSH 页面内部的会话标签有机会自行关闭，避免误关整个应用。
- **端口占用自愈**：上一个 DSH 进程若变成孤儿进程占着端口，`reclaimPortFromStaleDsh` 会核对命令行特征后回收（`:672`），不会乱杀别人的进程。
- **中文化用注入而非改后端**：`kLocalizationScript` 用「字典 + `MutationObserver`」替换页面文案（`:21` 起，约 160 条词条，含 DOM 变化后的增量翻译），后端零改动，升级 DSH 也不会冲突（代价是页面文案大改时字典需要跟进）。
- **上传限制在客户端解除**：`kFileUploadScript`（`:361`）打补丁解除文件类型限制、支持粘贴与拖拽上传。

---

## 三、功能特性

- **一键启动**：双击即拉起本地 DSH 服务并加载界面，不用再开终端敲 `dsh web`。
- **界面中文化**：命令面板、菜单、按钮、提示等约 160 条词条自动汉化，DOM 动态变化也持续生效。
- **文件上传无限制**：解除页面默认的文件类型限制，支持选择、粘贴、拖拽。
- **浏览器级体验**：后退/前进（含触控板手势）、刷新/强制刷新、停止、缩放（⌘0/⌘+/⌘-）、全屏、页面内查找（⌘F / ⌘G）、打印（⌘P）、导出 PDF。
- **下载管理**：走 `WKDownload`，自动落到 `~/Downloads/DeepSeek Harness/`（`:1254`）；完成/失败均有提示。
- **外部浏览器接力**：默认浏览器 / Safari / Chrome / Firefox 一键打开当前页（`:1441`、`:1454`-`:1468`）。
- **窗口状态记忆**：`setFrameAutosaveName("DeepSeekHarnessMainWindow")`（`:1634`）。
- **故障诊断**：子进程退出、端口全占用、DSH 已知报错（如 `duplicate loader entry id`）都会给出中文提示与建议（`:838`、`:922`）。

---

## 四、构建与运行

### 前置条件

1. **macOS 11.0+**，安装 **Xcode 或 Xcode Command Line Tools**（提供 `swiftc`；首次可能需要 `sudo xcodebuild -license accept`）。
2. 本机已安装 **DSH CLI**，且可执行文件位于 **`/opt/homebrew/bin/dsh`**（源码常量 `kDshPath`，`Sources/main.swift:13`，路径不同请自行修改）。
   > 本仓库**不包含也不需要** DSH 的源码或插件；套壳只负责把它跑起来并显示它的界面。

### 一键构建

```bash
./build.sh
```

脚本会：编译 `Sources/main.swift` → 组装 `build/DeepSeek Harness.app`（含自动生成的 `Info.plist`）→ 可选 ad-hoc 签名。

手动等价命令：

```bash
swiftc -O Sources/main.swift -o DeepSeekHarness \
  -framework Cocoa -framework WebKit -framework AVFoundation
```

### 运行

```bash
open "build/DeepSeek Harness.app"
```

首次打开若被 Gatekeeper 拦下（未签名），右键 → 打开，或执行：

```bash
xattr -dr com.apple.quarantine "build/DeepSeek Harness.app"
```

> **诚实声明**：本仓库的构建脚本**未在作者机器上端到端验证**（该机的 Xcode 许可未接受，`swiftc` 被系统拦截）。源码本身来自一个**正在正常使用**的已装机 App（二进制比源码晚 4 分钟构建），但**请以你本机的编译结果为准**；如遇编译问题欢迎提 Issue。

---

## 五、目录结构

```
.
├── Sources/
│   └── main.swift          # 全部实现（2059 行，单文件）
├── docs/
│   └── ARCHITECTURE.md     # 逐组件架构详解（含行号索引）
├── build.sh                # 编译 + 组装 .app
├── LICENSE                 # MIT
├── .gitignore
└── README.md
```

---

## 六、本仓库**不包含**什么（重要）

| 不包含 | 说明 |
|---|---|
| **DSH 后端 / Harness 本体** | 那是上游项目（[deepseek-ai/dsh](https://github.com/deepseek-ai/dsh)），本仓库只有壳 |
| **任何插件** | 不含插件市场、编排插件、UI 插件等一切插件代码或产物 |
| **任何凭据 / 密钥 / Cookie** | 源码中不存在 API Key、令牌、Cookie、私钥、邮箱、绝对用户路径（已用 14 类模式全量扫描，零命中） |
| **个人配置** | 不含 `~/.dsh`、profile、会话记录、插件清单等 |
| **应用图标与截图** | 为避免第三方商标与素材版权问题，未附带 `.icns` 与截图；`build.sh` 会生成无图标的 App |

---

## 七、隐私与安全

- **只连本机**：套壳自身不向任何远端发起请求；唯一网络行为是对 `127.0.0.1:<port>` 的就绪探测与页面加载（`:908`、`:1082`）。访问外部链接一律交给系统默认浏览器（用户显式操作）。
- **不持久化网页数据**：`.nonPersistent()`（`:980`）—— Cookie、LocalStorage、缓存不落盘。
- **令牌只在内存**：DSH 打印的本地 URL 内含访问令牌，套壳仅把它保存在内存变量中用于加载（`:716`、`:873`），不写入磁盘、不打印到日志（日志只记录 URL 的捕获事实）。
- **子进程随窗口退出**：`applicationWillTerminate` 会终止 `dsh` 子进程（`:2023`），不留后台孤儿。
- **启动失败诊断**：只读取自己子进程的 stdout/stderr（`:788`、`:811`），不读取其它进程的隐私数据。

---

## 八、兼容性与限制

1. **DSH 版本耦合**：中文化脚本按页面**现有英文文案**做字典替换；DSH 界面文案大改时，部分条目会失效（功能不受影响，只是回退成英文）。
2. **端口约定**：优先 47615-47619，全部占用则启动失败并提示（`:690`、`:727`）。若你习惯固定端口，改 `kPreferredPorts` 即可。
3. **CLI 路径硬编码**：`/opt/homebrew/bin/dsh`（Apple Silicon Homebrew 默认位置）；Intel Mac 或自定义安装位置请改 `kDshPath`（`:13`）。
4. **单文件架构**：便于阅读与二次修改，但不利于大型协作；本项目有意保持"一个文件看得完"。
5. **未做公证签名**：`build.sh` 只做 ad-hoc 签名（可选），分发给他人的话需自备开发者证书。

---

## License

[MIT](LICENSE) —— 随便用、随便改，保留版权声明即可。

> DeepSeek Harness 本身遵循其上游仓库的许可；本仓库只包含套壳壳层代码，与其无隶属关系。
