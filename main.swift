import Cocoa
import WebKit
import AVFoundation

// ============================================================================
//  DeepSeek Harness 本地启动器
//  套壳 WKWebView App · 完全汉化 · 浏览器功能对齐
//  v0.4.0
// ============================================================================

// MARK: - 常量

let kDshPath = "/opt/homebrew/bin/dsh"
let kPreferredPorts: [UInt16] = [47615, 47616, 47617, 47618, 47619]
let kStartupTimeout: TimeInterval = 60.0
let kHealthCheckInterval: TimeInterval = 0.3
let kDownloadsSubdir = "DeepSeek Harness"

// MARK: - JS 注入：汉化 dsh Web 界面常见英文

let kLocalizationScript: String = """
(function() {
    'use strict';
    if (window.__dshLocalizerInstalled) return;
    window.__dshLocalizerInstalled = true;

    const dict = {
        // 命令面板
        'compact': '压缩历史',
        'Compact older conversation history': '压缩较早的对话历史',
        'export': '导出',
        'Download this Session log as a ZIP archive': '将此会话日志以 ZIP 归档下载',
        'feedback': '反馈',
        'record feedback about this session': '记录关于本次会话的反馈',
        'goal': '目标',
        'set or view the goal for a long-running task': '设置或查看长期任务目标',
        'permission': '权限',
        'Switch the permission preset (sandbox mode + approval policy)': '切换权限预设（沙盒模式 + 审批策略）',
        'plan': '计划',
        'Enter or leave plan mode': '进入或退出计划模式',
        'model': '模型',
        'Switch the model used in this conversation': '切换本会话使用的模型',
        'help': '帮助',
        'Show help information': '显示帮助信息',
        'clear': '清空',
        'Clear the current conversation': '清空当前对话',
        'rename': '重命名',
        'Rename this session': '重命名本会话',
        'fork': '分叉',
        'Fork this session from a specific message': '从指定消息分叉本会话',
        'undo': '撤销',
        'Undo the last action': '撤销上一步操作',
        'redo': '重做',
        'Redo the last undone action': '重做上一步撤销',
        // 通用
        'Session': '会话',
        'Sessions': '会话列表',
        'New Session': '新会话',
        'New chat': '新对话',
        'Standard': '标准',
        'Standard mode': '标准模式',
        'Full Control': '完全控制',
        'Full Control mode': '完全控制模式',
        'Plan Mode': '计划模式',
        'Bypass Permissions': '跳过审批',
        'Workspace': '工作区',
        'Chat': '对话',
        'Trace': '轨迹',
        'Settings': '设置',
        'Send a message or task...': '发消息或做任务...',
        'Type a command': '输入指令',
        'Stop': '停止',
        'Generating': '生成中',
        'Thinking': '思考中',
        'Tool calls': '工具调用',
        'Attachments': '附件',
        'Drop files here': '将文件拖到此处',
        'No conversations yet': '暂无对话',
        'Start a new conversation': '开始新对话',
        'Loading...': '加载中...',
        'Error': '错误',
        'Retry': '重试',
        'Cancel': '取消',
        'Confirm': '确认',
        'Save': '保存',
        'Delete': '删除',
        'Rename': '重命名',
        'Copy': '复制',
        'Paste': '粘贴',
        'Cut': '剪切',
        'Select All': '全选',
        'Reload': '刷新',
        'Refresh': '刷新',
        'Back': '后退',
        'Forward': '前进',
        'Open in Browser': '在浏览器中打开',
        'Approve': '批准',
        'Reject': '拒绝',
        'Deny': '拒绝',
        'Allow once': '仅本次允许',
        'Allow always': '始终允许',
        'Apply': '应用',
        'Reset': '重置',
        'Continue': '继续',
        'Yes': '是',
        'No': '否',
        'OK': '确定',
        'Welcome': '欢迎',
        'Get started': '开始使用',
        'Documentation': '文档',
        'Examples': '示例',
        'New folder': '新建文件夹',
        'Upload': '上传',
        'Download': '下载',
        'Today': '今天',
        'Yesterday': '昨天',
        'Last 7 days': '最近 7 天',
        'Last 30 days': '最近 30 天',
        'Older': '更早',
        'Pinned': '已置顶',
        'All': '全部',
        'Search': '搜索',
        'Search sessions...': '搜索会话...',
        'Type to search...': '输入关键词搜索...',
        'Send': '发送',
        'Edit message': '编辑消息',
        'Copy message': '复制消息',
        'Copy code': '复制代码',
        'Regenerate': '重新生成',
        'Stop generating': '停止生成',
        'Show in folder': '在访达中显示',
        'Token count': '令牌数',
        'tokens': '令牌',
        'Prompt': '提示词',
        'Completion': '补全',
        'Context': '上下文',
        'Tools': '工具',
        'Skills': '技能',
        'Plugins': '插件',
        'Marketplace': '市场',
        'Custom': '自定义',
        'Built-in': '内置',
        'Enable': '启用',
        'Disable': '禁用',
        'Enabled': '已启用',
        'Disabled': '已禁用',
        'On': '开',
        'Off': '关',
        'Default': '默认',
        'Theme': '主题',
        'Light': '浅色',
        'Dark': '深色',
        'Auto': '自动',
        'System': '跟随系统',
        'Language': '语言',
        'About': '关于',
        'Version': '版本',
        'Quit': '退出',
        'Preferences': '偏好设置',
        'Account': '账户',
        'Sign in': '登录',
        'Sign out': '退出登录',
        'Sign up': '注册',
        'API Keys': 'API 密钥',
        'Models': '模型',
        'Provider': '服务商',
        'Providers': '服务商',
        'Endpoint': '接口地址',
        'Base URL': '基础 URL',
        'API Key': 'API 密钥',
        'Add provider': '添加服务商',
        'Add model': '添加模型',
        'Test connection': '测试连接',
        'Connection successful': '连接成功',
        'Connection failed': '连接失败',
        'Invalid API key': 'API 密钥无效',
        'Rate limit exceeded': '请求频率超限',
        'Server error': '服务器错误',
        'Network error': '网络错误',
        // 图片上传提示
        'Only PNG, JPG, WebP, GIF image formats are supported': '已支持任意文件类型',
        'Only supports PNG, JPG, WebP, GIF format images': '已支持任意文件类型',
        'PNG, JPG, WebP, GIF': '任意文件',
        'Image files only': '任意文件',
        'Drop image here': '拖放文件到此处',
        'Paste image here': '粘贴文件到此处',
        'Upload image': '上传文件',
        'Upload file': '上传文件',
        'Attach image': '附加文件',
        'Attach file': '附加文件'
    };

    function applyDict(text) {
        if (!text) return null;
        const trimmed = text.trim();
        if (dict[trimmed] !== undefined) return dict[trimmed];
        // 预构建的小写 Map，O(1) 兜底查找（避免流式时 O(n) 扫描卡顿）
        if (!dictLowerBuilt) {
            for (const k in dict) dictLower[k.toLowerCase()] = dict[k];
            dictLowerBuilt = true;
        }
        const v = dictLower[trimmed.toLowerCase()];
        return v !== undefined ? v : null;
    }
    const dictLower = {};
    let dictLowerBuilt = false;

    function hasCJK(t) {
        return /[\\u4e00-\\u9fff\\u3040-\\u309f\\u30a0-\\u30ff\\uac00-\\ud7af]/.test(t);
    }

    // 是否位于可编辑区域（输入框/textarea/contenteditable）——这些是用户输入，绝不翻译
    function isEditable(node) {
        let el = node.nodeType === 1 ? node : node.parentElement;
        while (el && el.nodeType === 1) {
            if (el.isContentEditable) return true;
            const tag = el.tagName;
            if (tag === 'TEXTAREA' || tag === 'INPUT' || tag === 'SELECT') return true;
            el = el.parentElement;
        }
        return false;
    }

    // 标记已翻译过的元素，避免重复扫描
    const MARK = 'data-dsh-tx';
    function isMarked(el) { return el.nodeType !== 1 || el.hasAttribute(MARK); }
    function mark(el) { if (el.nodeType === 1) el.setAttribute(MARK, '1'); }

    // 翻译单个文本节点：只做简短英文 UI 文本，避免翻译聊天内容
    function translateTextNode(node) {
        if (!node || node.nodeType !== 3) return;
        if (isEditable(node)) return;             // 用户输入区绝不碰
        const text = node.textContent || '';
        const trimmed = text.trim();
        if (!trimmed) return;
        if (trimmed.length > 160) return;         // 太长：可能是消息内容
        if (hasCJK(text)) return;                 // 含中文：已是中文或为动态内容
        const t = applyDict(trimmed);
        if (t !== null) node.textContent = t;
    }

    // 翻译元素：属性 + 所有直接文本子节点（不递归进入子元素）
    function translateElement(el) {
        if (isMarked(el)) return;
        if (isEditable(el)) { mark(el); return; } // 可编辑区域整块跳过
        if (el.placeholder) {
            const t = applyDict(el.placeholder);
            if (t !== null) el.placeholder = t;
        }
        if (el.title) {
            const t = applyDict(el.title);
            if (t !== null) el.title = t;
        }
        if (el.alt) {
            const t = applyDict(el.alt);
            if (t !== null) el.alt = t;
        }
        const aria = el.getAttribute && el.getAttribute('aria-label');
        if (aria) {
            const t = applyDict(aria);
            if (t !== null) el.setAttribute('aria-label', t);
        }
        // 翻译所有直接文本子节点
        for (const child of el.childNodes) {
            if (child.nodeType === 3) translateTextNode(child);
        }
        mark(el);
    }

    // 对未知 shadow root 做浅层翻译
    function processRoot(root) {
        if (!root) return;
        const tw = document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT);
        let n;
        while ((n = tw.nextNode())) translateElement(n);
    }

    // rAF 批量处理：元素与文本节点分开队列，只翻译新增节点，避免重复遍历兄弟节点
    const pendingElements = new Set();
    const pendingTexts = new Set();
    let scheduled = false;
    function flush() {
        scheduled = false;
        const els = Array.from(pendingElements);
        pendingElements.clear();
        const texts = Array.from(pendingTexts);
        pendingTexts.clear();
        for (const el of els) if (el.nodeType === 1) translateElement(el);
        for (const tn of texts) translateTextNode(tn);
    }
    function schedule() {
        if (scheduled) return;
        scheduled = true;
        (window.requestAnimationFrame || function(cb){ setTimeout(cb,16); })(flush);
    }

    const obs = new MutationObserver((muts) => {
        for (const m of muts) {
            for (const n of m.addedNodes) {
                if (n.nodeType === 1) {
                    pendingElements.add(n);
                    if (n.shadowRoot) processRoot(n.shadowRoot);
                } else if (n.nodeType === 3) {
                    pendingTexts.add(n);   // 只翻译这个新增文本节点本身
                }
            }
            if (m.type === 'characterData' && m.target.nodeType === 3) {
                pendingTexts.add(m.target);
            }
            if (m.type === 'attributes' && m.target.nodeType === 1) {
                pendingElements.add(m.target);
            }
        }
        if (pendingElements.size > 0 || pendingTexts.size > 0) schedule();
    });

    function start() {
        // 初始全量：直接走 TreeWalker，比递归 walkChildren 快得多
        const root = document.body || document.documentElement;
        processRoot(root);
        obs.observe(root, {
            childList: true,
            subtree: true,
            characterData: true,
            attributes: true,
            attributeFilter: ['placeholder', 'title', 'alt', 'aria-label', 'value']
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', start);
    } else {
        start();
    }

    // 字体兜底：保证中英文混排渲染清晰
    // 注意：脚本以 atDocumentStart 注入，此时 document.head / documentElement
    // 可能尚未创建；直接 appendChild 会抛 "null is not an object" 并中断整个脚本
    // （导致汉化与文件上传补丁的后续逻辑不再执行），故改为安全重试。
    const FONT_CSS = `
        :root, html, body, button, input, textarea, select, [class*="font"] {
            font-family: -apple-system, "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", "Helvetica Neue", Arial, sans-serif !important;
        }
    `;
    function applyFontStyle() {
        const root = document.head || document.documentElement;
        if (!root) {
            (window.requestAnimationFrame || function (cb) { setTimeout(cb, 16); })(applyFontStyle);
            return;
        }
        const style = document.createElement('style');
        style.textContent = FONT_CSS;
        root.appendChild(style);
    }
    applyFontStyle();
})();
"""

// MARK: - JS 注入：解除文件类型限制，支持任意文件上传/粘贴/拖拽

let kFileUploadScript: String = """
(function() {
    'use strict';
    if (window.__dshFileUploadPatched) return;
    window.__dshFileUploadPatched = true;
    const log = (msg) => console.log('[DSH.FileUploadPatch]', msg);

    // 1. 强制所有 file input 接受任意文件
    function patchInputs() {
        document.querySelectorAll('input[type="file"]').forEach(input => {
            input.setAttribute('accept', '*/*');
        });
    }

    // 2. 覆盖 HTMLInputElement.prototype.accept
    try {
        Object.defineProperty(HTMLInputElement.prototype, 'accept', {
            get() { return '*/*'; },
            set(v) { this.setAttribute('accept', '*/*'); },
            configurable: true
        });
    } catch (e) { log('accept patch failed', e); }

    // 3. 强制 File.type 返回 image/png，绕过 dsh 前端图片校验
    try {
        const origType = Object.getOwnPropertyDescriptor(File.prototype, 'type');
        if (origType && origType.get) {
            const origGet = origType.get;
            Object.defineProperty(File.prototype, 'type', {
                get() {
                    const real = origGet.call(this);
                    if (real && (real.startsWith('image/') || real.startsWith('video/'))) return real;
                    // 非图片/视频全部伪装成 png，让只检查 image/* 的前端放行
                    return 'image/png';
                },
                configurable: true
            });
        }
    } catch (e) { log('File.type patch failed', e); }

    // 4. 包装 File：读取 name/type 时伪装成图片，真实对象上传时仍用原文件
    function wrapFile(file) {
        if (!file || file.__wrapped) return file;
        const fakeName = file.name.replace(/\\.[^.]+$/, '.png');
        return new Proxy(file, {
            get(target, prop) {
                if (prop === 'type') return 'image/png';
                if (prop === 'name') return fakeName;
                if (prop === '__wrapped') return true;
                const val = target[prop];
                return typeof val === 'function' ? val.bind(target) : val;
            }
        });
    }

    function wrapFileList(list) {
        if (!list || list.__wrapped) return list;
        return new Proxy(list, {
            get(target, prop) {
                if (prop === 'length') return target.length;
                if (prop === '__wrapped') return true;
                if (typeof prop === 'symbol' || isNaN(Number(prop))) {
                    const val = target[prop];
                    return typeof val === 'function' ? val.bind(target) : val;
                }
                const file = target[Number(prop)];
                return file ? wrapFile(file) : file;
            }
        });
    }

    // 5. 包装 DataTransfer.files / items，让 dsh 读取时拿到伪装文件
    try {
        ['files', 'items'].forEach(key => {
            const desc = Object.getOwnPropertyDescriptor(DataTransfer.prototype, key);
            if (!desc || !desc.get) return;
            const origGet = desc.get;
            Object.defineProperty(DataTransfer.prototype, key, {
                get() {
                    const val = origGet.call(this);
                    if (key === 'files') return wrapFileList(val);
                    if (key === 'items') {
                        return new Proxy(val, {
                            get(t, p) {
                                if (p === 'length') return t.length;
                                if (typeof p === 'symbol') return t[p];
                                const idx = Number(p);
                                if (!isNaN(idx)) {
                                    const item = t[idx];
                                    if (!item) return item;
                                    return new Proxy(item, {
                                        get(it, ip) {
                                            if (ip === 'getAsFile') {
                                                return () => {
                                                    const f = it.getAsFile();
                                                    return f ? wrapFile(f) : f;
                                                };
                                            }
                                            if (ip === 'type') return 'image/png';
                                            const v = it[ip];
                                            return typeof v === 'function' ? v.bind(it) : v;
                                        }
                                    });
                                }
                                const v = t[p];
                                return typeof v === 'function' ? v.bind(t) : v;
                            }
                        });
                    }
                    return val;
                },
                configurable: true
            });
        });
    } catch (e) { log('DataTransfer patch failed', e); }

    // 6. 拖拽：设置 dropEffect，让 drop zone 保持激活
    ['dragenter', 'dragover', 'dragleave'].forEach(name => {
        document.addEventListener(name, (e) => {
            const dt = e.dataTransfer;
            if (!dt) return;
            dt.dropEffect = 'copy';
            if (e.type === 'dragover') e.preventDefault();
        }, true);
    });

    document.addEventListener('drop', (e) => {
        const dt = e.dataTransfer;
        if (!dt || !dt.files || dt.files.length === 0) return;
        log('drop files: ' + dt.files.length + ' target=' + (e.target && e.target.tagName));
    }, true);

    // 7. 粘贴放行
    document.addEventListener('paste', (e) => {
        const dt = e.clipboardData;
        if (dt && dt.files && dt.files.length > 0) {
            log('paste files: ' + dt.files.length);
        }
    }, true);

    // 8. 用 MutationObserver 隐藏「仅支持图片」提示
    // 注意：只 hide 不 remove，避免破坏 React 管理的 DOM 树导致页面崩溃/卡顿
    function isTooltipLike(el) {
        const role = el.getAttribute && el.getAttribute('role');
        if (role === 'tooltip') return true;
        const cls = (typeof el.className === 'string' ? el.className : '') || '';
        if (/tooltip|hint|error|toast|banner/i.test(cls)) return true;
        // 无子元素的叶子节点 + 短文本，最可能是 tooltip 本身
        if (el.childElementCount === 0 && (el.textContent || '').length < 120) return true;
        return false;
    }
    function hideBadTooltip(el) {
        if (el.nodeType !== 1) return;
        if (!isTooltipLike(el)) return;
        const text = (el.textContent || '').toLowerCase();
        if (text.includes('仅支持') && (text.includes('png') || text.includes('jpg') || text.includes('webp') || text.includes('gif'))) {
            el.style.display = 'none';
            el.style.visibility = 'hidden';
            el.style.pointerEvents = 'none';
            el.setAttribute('aria-hidden', 'true');
        }
    }
    const tooltipObs = new MutationObserver((muts) => {
        for (const m of muts) {
            for (const n of m.addedNodes) {
                if (n.nodeType !== 1) continue;
                hideBadTooltip(n);
                // 也检查其直接子元素里有没有小的 tooltip
                if (n.children) {
                    for (const c of n.children) hideBadTooltip(c);
                }
            }
        }
    });

    // 9. 监听动态插入的 file input，自动 patch accept
    const inputObs = new MutationObserver((muts) => {
        let needPatch = false;
        for (const m of muts) {
            for (const n of m.addedNodes) {
                if (n.nodeType === 1) {
                    if (n.tagName === 'INPUT' && n.type === 'file') needPatch = true;
                    if (n.querySelector && n.querySelector('input[type="file"]')) needPatch = true;
                }
            }
        }
        if (needPatch) patchInputs();
    });

    function init() {
        patchInputs();
        tooltipObs.observe(document.body || document.documentElement, { childList: true, subtree: true });
        inputObs.observe(document.body || document.documentElement, { childList: true, subtree: true });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
"""

// MARK: - 工具函数

func isPortFree(_ port: UInt16) -> Bool {
    let sock = socket(AF_INET, SOCK_STREAM, 0)
    guard sock >= 0 else { return false }
    defer { close(sock) }
    var addr = sockaddr_in()
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_addr.s_addr = inet_addr("127.0.0.1")
    // sin_port 要的是**网络字节序**。
    // 这里原来写的是 `UInt16(bigEndian: port).bigEndian` —— 翻了两次等于没翻，
    // 得到的是主机序，于是 bind 实际去探测的是另一个端口（47615 → 65465），
    // 几乎总是"空闲"，本函数就永远返回 true：
    // 端口被占也发现不了，findFreePort() 也就永远不会回退到 47616。
    addr.sin_port = port.bigEndian
    var sa = sockaddr()
    memcpy(&sa, &addr, MemoryLayout<sockaddr_in>.size)
    let r = withUnsafePointer(to: &sa) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(sock, $0, socklen_t(MemoryLayout<sockaddr>.size)) }
    }
    return r == 0
}

// MARK: - 残留 dsh 回收
//
// 场景：App 被强杀 / 崩溃时，子进程 dsh 会变成孤儿继续占着端口。它自己的 stdout
// 管道随父进程一起没了，token URL 无从得知，等于一个谁都连不上的实例；下次启动
// App 想绑同一个端口就是 EADDRINUSE。
// 这里在启动时主动把这些**自己的**残留回收掉；别人的进程一律不碰。

/// 跑一条命令并抓取标准输出（失败返回空串）。
private func runCapturing(_ path: String, _ args: [String]) -> String {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: path)
    p.arguments = args
    let out = Pipe()
    p.standardOutput = out
    p.standardError = Pipe()
    do { try p.run() } catch { return "" }
    let data = out.fileHandleForReading.readDataToEndOfFile()
    p.waitUntilExit()
    return String(data: data, encoding: .utf8) ?? ""
}

/// 正在监听该端口的进程 PID。
func listeners(on port: UInt16) -> [pid_t] {
    let out = runCapturing("/usr/sbin/lsof", ["-nP", "-iTCP:\(port)", "-sTCP:LISTEN", "-t"])
    return out.split(separator: "\n").compactMap { line in
        Int32(String(line).trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

/// 进程的完整命令行（已退出 / 拿不到则返回空串）。
func fullCommand(of pid: pid_t) -> String {
    runCapturing("/bin/ps", ["-p", String(pid), "-o", "command="])
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

func parentPid(of pid: pid_t) -> pid_t {
    let out = runCapturing("/bin/ps", ["-p", String(pid), "-o", "ppid="])
        .trimmingCharacters(in: .whitespacesAndNewlines)
    return Int32(out) ?? 0
}

/// 是不是"我们自己那种 dsh"：命令行形如
/// `/opt/homebrew/Cellar/node/x/bin/node /opt/homebrew/bin/dsh web --no-open --port 47615`
/// 要求 `--no-open` 是刻意的 —— 那是本 App 启动 dsh 时独有的参数，
/// 用户自己手敲 `dsh web` 不会带它，这样就不会误伤手动起的实例。
func looksLikeOurDsh(_ command: String, port: UInt16) -> Bool {
    guard !command.isEmpty, command.contains("dsh"), command.contains("web"),
          command.contains("--no-open") else { return false }
    // `--port 47615` 后面必须不是数字，免得 47615 命中 476150 这种巧合。
    guard let regex = try? NSRegularExpression(pattern: "--port\\s+\(port)(\\s|$)") else { return false }
    return regex.firstMatch(in: command, range: NSRange(command.startIndex..., in: command)) != nil
}

/// 它是不是"没人要的"：父进程已不存在，或父进程不是还活着的 App。
/// 这是安全阀 —— **绝不**去动另一个正在运行的 App 实例的 dsh。
func isOrphanedProcess(_ pid: pid_t) -> Bool {
    let parent = parentPid(of: pid)
    if parent <= 1 { return true }              // 已被 launchd 收养 → 上一轮的残留
    let parentCommand = fullCommand(of: parent)
    // 查得到 ppid 但读不到它的命令行（无权限等）→ 保守当作"别人的"，不动。
    if parentCommand.isEmpty { return false }
    return !parentCommand.contains("DeepSeekHarness")
}

/// 先 SIGTERM 给足体面退出的时间，再 SIGKILL。返回是否已确认退出。
@discardableResult
func terminateProcess(_ pid: pid_t, grace: TimeInterval = 3.0) -> Bool {
    if kill(pid, 0) != 0 { return true }
    kill(pid, SIGTERM)
    let deadline = Date().addingTimeInterval(grace)
    while Date() < deadline {
        if kill(pid, 0) != 0 { return true }
        Thread.sleep(forTimeInterval: 0.05)
    }
    kill(pid, SIGKILL)
    let hardDeadline = Date().addingTimeInterval(1.5)
    while Date() < hardDeadline {
        if kill(pid, 0) != 0 { return true }
        Thread.sleep(forTimeInterval: 0.05)
    }
    return kill(pid, 0) != 0
}

/// 端口被占时，若占它的是上一轮遗留的 dsh，就回收掉。
/// 返回 true 表示"这个端口现在能用了"。
func reclaimPortFromStaleDsh(_ port: UInt16) -> Bool {
    for pid in listeners(on: port) {
        let command = fullCommand(of: pid)
        guard looksLikeOurDsh(command, port: port) else { continue }
        guard isOrphanedProcess(pid) else {
            NSLog("端口 \(port) 上的 dsh（pid \(pid)）属于另一个仍在运行的实例，跳过")
            continue
        }
        NSLog("发现上一轮遗留的 dsh（pid \(pid)）占着端口 \(port)，正在回收")
        if terminateProcess(pid) {
            NSLog("已回收端口 \(port)")
            return isPortFree(port)
        }
        NSLog("回收端口 \(port) 失败（pid \(pid) 仍在）")
    }
    return false
}

func findFreePort() -> UInt16 {
    for p in kPreferredPorts {
        if isPortFree(p) { return p }
        // 被占：如果是我们自己的残留就回收掉再用，否则试下一个。
        if reclaimPortFromStaleDsh(p) { return p }
    }
    return 0
}

func localized(_ key: String, comment: String = "") -> String {
    if let path = Bundle.main.path(forResource: "zh-Hans", ofType: "lproj"),
       let bundle = Bundle(path: path) {
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: comment)
    }
    return key
}

// MARK: - 进程管理

final class DshProcess {
    private var process: Process?
    private var stdoutPipe: Pipe?
    private var stderrPipe: Pipe?
    private var stdoutSource: DispatchSourceRead?
    private var stderrSource: DispatchSourceRead?
    private(set) var port: UInt16 = 0
    private(set) var tokenURL: URL?
    private(set) var isReady = false
    private(set) var lastError: String?
    private(set) var recentStderr: [String] = []
    private let stderrLock = NSLock()
    private var statusCallback: ((String) -> Void)?

    func start(statusUpdate: ((String) -> Void)? = nil) -> Bool {
        self.statusCallback = statusUpdate
        let port = findFreePort()
        if port == 0 {
            lastError = "找不到可用端口（47615-47619 全被占用）"
            return false
        }
        self.port = port

        let p = Process()
        p.executableURL = URL(fileURLWithPath: kDshPath)
        p.arguments = ["web", "--no-open", "--port", String(port)]
        var env = ProcessInfo.processInfo.environment
        env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        p.environment = env
        p.currentDirectoryURL = URL(fileURLWithPath: NSHomeDirectory())

        let out = Pipe()
        let err = Pipe()
        p.standardOutput = out
        p.standardError = err
        self.stdoutPipe = out
        self.stderrPipe = err
        self.process = p

        p.terminationHandler = { [weak self] proc in
            DispatchQueue.main.async {
                self?.isReady = false
                if proc.terminationStatus != 0 && proc.terminationReason != .exit {
                    let msg = "dsh 进程意外退出 status=\(proc.terminationStatus)"
                    NSLog(msg)
                    self?.appendStderr(msg)
                }
            }
        }

        do {
            try p.run()
        } catch {
            lastError = "无法启动 dsh：\(error.localizedDescription)"
            return false
        }

        startReadingStdout()
        startReadingStderr()
        return true
    }

    private func appendStderr(_ line: String) {
        stderrLock.lock()
        recentStderr.append(line)
        if recentStderr.count > 20 { recentStderr.removeFirst() }
        stderrLock.unlock()
        // 向 UI 反馈最近一条非空、非警告的信息性日志
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty,
           !trimmed.hasPrefix("(node:"),
           !trimmed.hasPrefix("(Use `"),
           !trimmed.contains("ExperimentalWarning") {
            DispatchQueue.main.async { [weak self] in
                self?.statusCallback?(trimmed)
            }
        }
    }

    private func startReadingStdout() {
        guard let pipe = stdoutPipe else { return }
        let handle = pipe.fileHandleForReading
        let src = DispatchSource.makeReadSource(fileDescriptor: handle.fileDescriptor, queue: .global())
        stdoutSource = src
        var buffer = Data()
        src.setEventHandler { [weak self] in
            let data = handle.availableData
            if data.isEmpty {
                self?.stdoutSource?.cancel()
                return
            }
            buffer.append(data)
            while let r = buffer.range(of: Data([0x0A])) {
                let line = String(data: buffer.subdata(in: 0..<r.lowerBound), encoding: .utf8) ?? ""
                buffer.removeSubrange(0..<r.upperBound)
                self?.parseLine(line)
            }
        }
        src.setCancelHandler { [weak handle] in try? handle?.close() }
        src.resume()
    }

    private func startReadingStderr() {
        guard let pipe = stderrPipe else { return }
        let handle = pipe.fileHandleForReading
        let src = DispatchSource.makeReadSource(fileDescriptor: handle.fileDescriptor, queue: .global())
        stderrSource = src
        var buffer = Data()
        src.setEventHandler { [weak self] in
            let data = handle.availableData
            if data.isEmpty {
                self?.stderrSource?.cancel()
                return
            }
            buffer.append(data)
            while let r = buffer.range(of: Data([0x0A])) {
                let line = String(data: buffer.subdata(in: 0..<r.lowerBound), encoding: .utf8) ?? ""
                buffer.removeSubrange(0..<r.upperBound)
                self?.appendStderr(line)
                // 把关键错误同步到 lastError，便于启动失败后弹窗提示
                if let err = self?.diagnose(line) {
                    DispatchQueue.main.async { self?.lastError = err }
                }
            }
        }
        src.setCancelHandler { [weak handle] in try? handle?.close() }
        src.resume()
    }

    private func diagnose(_ line: String) -> String? {
        let lower = line.lowercased()
        if lower.contains("duplicate loader entry id") {
            let pattern = "duplicate loader entry id: ([^\\s]+)"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let m = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let r = Range(m.range(at: 1), in: line) {
                let id = String(line[r])
                return "插件加载冲突：loader entry id「\(id)」重复。请检查 ~/.dsh/profiles/web/cordis.patch.yml 或插件是否被重复安装。"
            }
            return "插件加载冲突：存在重复的 loader entry id。请检查 cordis.patch.yml 或重复安装的插件。"
        }
        if lower.contains("plugin tree failed to load") {
            return "插件树加载失败：\(line)"
        }
        if lower.contains("cannot find module") || lower.contains("error: cannot resolve") {
            return "插件依赖缺失：\(line)"
        }
        if lower.contains("eaddrinuse") {
            let tried = kPreferredPorts.map { String($0) }.joined(separator: "、")
            return "端口被占用：dsh 绑不上端口（已依次尝试 \(tried)）。"
                + "\n若占用者是上一轮遗留的 dsh，本 App 会自动回收；若仍失败，"
                + "可在终端运行 `lsof -nP -iTCP:47615 -sTCP:LISTEN` 查看占用者。"
        }
        return nil
    }

    private func parseLine(_ line: String) {
        // 提取首个 http(s) URL
        guard let regex = try? NSRegularExpression(pattern: "https?://[^\\s\"'\\)<>\\\\]+") else { return }
        let range = NSRange(line.startIndex..., in: line)
        if let m = regex.firstMatch(in: line, range: range),
           let r = Range(m.range, in: line),
           let url = URL(string: String(line[r])) {
            DispatchQueue.main.async {
                if self.tokenURL == nil {
                    self.tokenURL = url
                    NSLog("捕获 dsh URL: \(url.absoluteString)")
                }
            }
        }
    }

    func waitReady(completion: @escaping (URL?) -> Void) {
        let start = Date()
        let timer = DispatchSource.makeTimerSource(queue: .global())
        timer.schedule(deadline: .now() + kHealthCheckInterval, repeating: kHealthCheckInterval)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if let url = DispatchQueue.main.sync(execute: { self.tokenURL }) {
                self.probe(url: url) { ok in
                    if ok {
                        DispatchQueue.main.async {
                            self.isReady = true
                            timer.cancel()
                            completion(url)
                        }
                    } else if Date().timeIntervalSince(start) > kStartupTimeout {
                        timer.cancel()
                        DispatchQueue.main.async { completion(nil) }
                    }
                }
            } else if Date().timeIntervalSince(start) > kStartupTimeout {
                timer.cancel()
                DispatchQueue.main.async { completion(nil) }
            }
        }
        timer.resume()
    }

    private func probe(url: URL, completion: @escaping (Bool) -> Void) {
        var req = URLRequest(url: url)
        req.timeoutInterval = 2.0
        let cfg = URLSession.shared
        let task = cfg.dataTask(with: req) { _, resp, _ in
            if let h = resp as? HTTPURLResponse, (200..<300).contains(h.statusCode) {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }

    func formattedDiagnostics() -> String {
        stderrLock.lock()
        let lines = recentStderr
        stderrLock.unlock()
        if lines.isEmpty { return "" }
        return "\n\n最近 dsh 日志：\n" + lines.joined(separator: "\n")
    }

    func terminate() {
        guard let p = process, p.isRunning else { return }
        p.terminate()
        let deadline = Date().addingTimeInterval(3.0)
        while p.isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.05)
        }
        if p.isRunning {
            kill(p.processIdentifier, SIGKILL)
        }
    }
}

// MARK: - WebView 容器

final class WebContainer: NSView, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate, NSTextFieldDelegate {

    let webView: WKWebView
    var findBar: NSView?
    var findField: NSTextField?
    var statusLabel: NSTextField?
    var progressView: NSProgressIndicator?
    var backButton: NSButton?
    var forwardButton: NSButton?
    var refreshButton: NSButton?
    var titleLabel: NSTextField?
    var loadingOverlay: NSView?
    var loadingSpinner: NSProgressIndicator?
    var loadingText: NSTextField?

    var tokenURL: URL?
    var titleObservation: NSKeyValueObservation?
    var urlObservation: NSKeyValueObservation?
    var progressObservation: NSKeyValueObservation?
    var loadingObservation: NSKeyValueObservation?
    var backObservation: NSKeyValueObservation?
    var forwardObservation: NSKeyValueObservation?

    override init(frame frameRect: NSRect) {
        let cfg = WKWebViewConfiguration()
        let userContent = WKUserContentController()
        let script = WKUserScript(source: kLocalizationScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContent.addUserScript(script)
        let fileScript = WKUserScript(source: kFileUploadScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContent.addUserScript(fileScript)
        cfg.userContentController = userContent
        cfg.preferences.javaScriptCanOpenWindowsAutomatically = true
        if #available(macOS 11.0, *) {
            cfg.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        cfg.websiteDataStore = .nonPersistent()
        webView = WKWebView(frame: .zero, configuration: cfg)
        super.init(frame: frameRect)
        autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsMagnification = true
        webView.customUserAgent = "DeepSeekHarness/0.4 macOS App"
        if #available(macOS 12.0, *) {
            let prefs = WKWebpagePreferences()
            prefs.allowsContentJavaScript = true
            cfg.defaultWebpagePreferences = prefs
        }
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        setupKVO()
    }

    required init?(coder: NSCoder) { fatalError() }

    // 拦截 ⌘W / Ctrl+W：不关闭整个窗口/退出应用，改为转发给网页内容，
    // 让 dsh 内部的小标签页有机会自行处理（关闭当前会话标签）。
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let flags = event.modifierFlags
        let isCmd = flags.contains(.command)
        let isCtrl = flags.contains(.control)
        let key = event.charactersIgnoringModifiers?.lowercased()
        if key == "w" && (isCmd || isCtrl) {
            forwardCloseKeyToWeb(cmd: isCmd, ctrl: isCtrl)
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    private func forwardCloseKeyToWeb(cmd: Bool, ctrl: Bool) {
        let meta = cmd ? "true" : "false"
        let ctrlStr = ctrl ? "true" : "false"
        let js = """
        (function() {
            var el = document.activeElement || document.body;
            function fire(type) {
                try {
                    el.dispatchEvent(new KeyboardEvent(type, {
                        key: 'w', code: 'KeyW', keyCode: 87, which: 87,
                        metaKey: \(meta), ctrlKey: \(ctrlStr),
                        bubbles: true, cancelable: true
                    }));
                } catch (e) {}
            }
            fire('keydown');
            fire('keyup');
        })();
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    private func setupKVO() {
        titleObservation = webView.observe(\.title, options: [.new]) { [weak self] _, c in
            guard let self = self else { return }
            let outer = c.newValue
            let t: String = (outer ?? nil) ?? ""
            self.titleLabel?.stringValue = t
            self.window?.title = t.isEmpty ? "DeepSeek Harness" : t
        }
        urlObservation = webView.observe(\.url, options: [.new]) { [weak self] _, _ in
            self?.updateNavButtons()
        }
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, c in
            guard let self = self, let p = c.newValue else { return }
            self.progressView?.doubleValue = p * 100
            self.progressView?.isHidden = (p >= 1.0 || p <= 0.0)
        }
        loadingObservation = webView.observe(\.isLoading, options: [.new]) { [weak self] _, c in
            guard let self = self, let loading = c.newValue else { return }
            self.refreshButton?.image = NSImage(systemSymbolName: loading ? "xmark" : "arrow.clockwise", accessibilityDescription: nil)
            self.refreshButton?.toolTip = loading ? "停止" : "刷新"
            self.updateNavButtons()
        }
        backObservation = webView.observe(\.canGoBack, options: [.new]) { [weak self] _, c in
            self?.backButton?.isEnabled = c.newValue ?? false
        }
        forwardObservation = webView.observe(\.canGoForward, options: [.new]) { [weak self] _, c in
            self?.forwardButton?.isEnabled = c.newValue ?? false
        }
    }

    func updateNavButtons() {
        backButton?.isEnabled = webView.canGoBack
        forwardButton?.isEnabled = webView.canGoForward
    }

    func loadURL(_ url: URL) {
        tokenURL = url
        showLoadingOverlay(animated: true)
        loadingSpinner?.startAnimation(nil)
        let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        webView.load(req)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoadingOverlay(animated: true)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideLoadingOverlay(animated: true)
        loadingSpinner?.stopAnimation(nil)
        let alert = NSAlert()
        alert.messageText = "页面加载失败"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "重试")
        alert.addButton(withTitle: "取消")
        if alert.runModal() == .alertFirstButtonReturn {
            if webView.url != nil { webView.reload() }
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // dsh 启动期偶发；忽略 cancel 类
        let ns = error as NSError
        if ns.code == NSURLErrorCancelled { return }
    }

    // 网页内容进程崩溃（内存压力/JS 异常）→ 自动重新加载，避免「对话框卡没」
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        NSLog("网页内容进程终止，自动重新加载…")
        // 回到 token URL 重新加载，而不是 webView.reload()（reload 可能指向已失效的会话）
        if let u = tokenURL {
            showLoadingOverlay(animated: true)
            webView.load(URLRequest(url: u, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15))
        } else if webView.url != nil {
            webView.reload()
        }
    }

    // MARK: - 加载占位淡入淡出

    private func showLoadingOverlay(animated: Bool) {
        guard let overlay = loadingOverlay else { return }
        if animated {
            overlay.alphaValue = 0
            overlay.isHidden = false
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.25
                ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
                overlay.animator().alphaValue = 1
            }
        } else {
            overlay.isHidden = false
        }
    }

    private func hideLoadingOverlay(animated: Bool) {
        guard let overlay = loadingOverlay, !overlay.isHidden else { return }
        if animated {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.22
                ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
                overlay.animator().alphaValue = 0
            }, completionHandler: {
                overlay.isHidden = true
                overlay.alphaValue = 1
            })
        } else {
            overlay.isHidden = true
        }
    }

    // 新窗口链接：在当前窗口打开
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let target = navigationAction.targetFrame, target.isMainFrame {
            webView.load(navigationAction.request)
        } else if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }

    // 文件选择
    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        panel.canChooseDirectories = parameters.allowsDirectories
        panel.canChooseFiles = true
        panel.message = "选择文件"
        if let window = webView.window {
            panel.beginSheetModal(for: window) { response in
                completionHandler(response == .OK ? panel.urls : nil)
            }
        } else {
            completionHandler(panel.runModal() == .OK ? panel.urls : nil)
        }
    }

    // 弹窗
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = webView.title ?? "DeepSeek Harness"
        alert.informativeText = message
        alert.addButton(withTitle: "确定")
        if let window = webView.window {
            alert.beginSheetModal(for: window) { _ in completionHandler() }
        } else {
            alert.runModal()
            completionHandler()
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = webView.title ?? "DeepSeek Harness"
        alert.informativeText = message
        alert.addButton(withTitle: "确定")
        alert.addButton(withTitle: "取消")
        if let window = webView.window {
            alert.beginSheetModal(for: window) { r in completionHandler(r == .alertFirstButtonReturn) }
        } else {
            completionHandler(alert.runModal() == .alertFirstButtonReturn)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = NSAlert()
        alert.messageText = webView.title ?? "DeepSeek Harness"
        alert.informativeText = prompt
        let field = NSTextField(string: defaultText ?? "")
        field.frame = NSRect(x: 0, y: 0, width: 280, height: 24)
        alert.accessoryView = field
        alert.addButton(withTitle: "确定")
        alert.addButton(withTitle: "取消")
        if let window = webView.window {
            alert.beginSheetModal(for: window) { r in
                completionHandler(r == .alertFirstButtonReturn ? field.stringValue : nil)
            }
        } else {
            let r = alert.runModal()
            completionHandler(r == .alertFirstButtonReturn ? field.stringValue : nil)
        }
    }

    // 媒体权限：本机可信
    func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }

    // 下载入口：触发 WKDownload
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let resp = navigationResponse.response as? HTTPURLResponse {
            let disp = resp.value(forHTTPHeaderField: "Content-Disposition") ?? ""
            let isAttachment = disp.lowercased().contains("attachment")
            let isBinary = !navigationResponse.canShowMIMEType || isAttachment
            if isBinary {
                decisionHandler(.download)
                return
            }
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }

    // WKDownloadDelegate
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        let fm = FileManager.default
        let downloads = (try? fm.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)) ?? URL(fileURLWithPath: NSHomeDirectory())
        let dir = downloads.appendingPathComponent(kDownloadsSubdir, isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        var dest = dir.appendingPathComponent(suggestedFilename)
        var n = 1
        while fm.fileExists(atPath: dest.path) {
            let ext = (suggestedFilename as NSString).pathExtension
            let base = (suggestedFilename as NSString).deletingPathExtension
            let newName = ext.isEmpty ? "\(base)-\(n)" : "\(base)-\(n).\(ext)"
            dest = dir.appendingPathComponent(newName)
            n += 1
        }
        completionHandler(dest)
    }

    func downloadDidFinish(_ download: WKDownload) {
        DispatchQueue.main.async {
            self.statusLabel?.stringValue = "下载完成"
        }
        let alert = NSAlert()
        alert.messageText = "下载完成"
        if let url = download.originalRequest?.url {
            alert.informativeText = "已保存到 \(url.lastPathComponent)"
        }
        alert.addButton(withTitle: "在访达中显示")
        alert.addButton(withTitle: "确定")
        if let w = self.webView.window {
            alert.beginSheetModal(for: w) { r in
                if r == .alertFirstButtonReturn {
                    if let dest = self.lastDownloadDest {
                        NSWorkspace.shared.activateFileViewerSelecting([dest])
                    }
                }
            }
        } else {
            alert.runModal()
        }
    }

    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        let alert = NSAlert()
        alert.messageText = "下载失败"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "确定")
        if let w = self.webView.window {
            alert.beginSheetModal(for: w, completionHandler: nil)
        } else {
            alert.runModal()
        }
    }

    private var lastDownloadDest: URL? {
        get {
            if let s = self.statusLabel?.toolTip, let u = URL(string: s) { return u }
            return nil
        }
        set { self.statusLabel?.toolTip = newValue?.absoluteString }
    }

    // 开发者工具
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 拦截外链在系统浏览器打开
        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url,
           let host = url.host, host != "127.0.0.1" && host != "localhost" {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

// MARK: - 工具栏（无地址栏）

final class ToolbarView: NSView {
    let container: WebContainer

    init(container: WebContainer) {
        self.container = container
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        let back = NSButton(image: NSImage(systemSymbolName: "chevron.left", accessibilityDescription: "后退")!, target: self, action: #selector(goBack))
        back.bezelStyle = .texturedRounded
        back.toolTip = "后退 (⌘[)"
        backButton = back

        let forward = NSButton(image: NSImage(systemSymbolName: "chevron.right", accessibilityDescription: "前进")!, target: self, action: #selector(goForward))
        forward.bezelStyle = .texturedRounded
        forward.toolTip = "前进 (⌘])"
        forwardButton = forward

        let refresh = NSButton(image: NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: "刷新")!, target: self, action: #selector(refreshOrStop))
        refresh.bezelStyle = .texturedRounded
        refresh.toolTip = "刷新 (⌘R)"
        refreshButton = refresh

        let openInBrowser = NSPopUpButton(frame: .zero, pullsDown: true)
        openInBrowser.bezelStyle = .texturedRounded
        openInBrowser.image = NSImage(systemSymbolName: "safari", accessibilityDescription: "在浏览器中打开")
        openInBrowser.imagePosition = .imageOnly
        openInBrowser.toolTip = "在系统浏览器中打开当前页 (⌘O)"
        openInBrowser.menu = buildBrowserMenu()
        // pullsDown=true 时自带菜单三角箭头；为了让按钮看起来像普通按钮，用纯图标
        openInBrowser.cell?.isBezeled = true

        let title = NSTextField(labelWithString: "DeepSeek Harness")
        title.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        title.alignment = .center
        title.textColor = .labelColor
        title.lineBreakMode = .byTruncatingTail
        titleLabel = title

        let progress = NSProgressIndicator()
        progress.style = .bar
        progress.isIndeterminate = false
        progress.minValue = 0
        progress.maxValue = 100
        progress.doubleValue = 0
        progress.isHidden = true
        progressView = progress

        let stack = NSStackView(views: [back, forward, refresh, title, openInBrowser])
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .centerY
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        addSubview(progress)
        progress.translatesAutoresizingMaskIntoConstraints = false

        title.setContentHuggingPriority(.defaultLow, for: .horizontal)
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: progress.topAnchor, constant: -4),

            progress.leadingAnchor.constraint(equalTo: leadingAnchor),
            progress.trailingAnchor.constraint(equalTo: trailingAnchor),
            progress.bottomAnchor.constraint(equalTo: bottomAnchor),
            progress.heightAnchor.constraint(equalToConstant: 3)
        ])

        container.backButton = back
        container.forwardButton = forward
        container.refreshButton = refresh
        container.titleLabel = title
        container.progressView = progress
        container.updateNavButtons()
    }

    weak var backButton: NSButton?
    weak var forwardButton: NSButton?
    weak var refreshButton: NSButton?
    weak var titleLabel: NSTextField?
    weak var progressView: NSProgressIndicator?

    @objc func goBack() { container.webView.goBack() }
    @objc func goForward() { container.webView.goForward() }
    @objc func refreshOrStop() {
        let wv = container.webView
        if wv.isLoading { wv.stopLoading() } else { wv.reload() }
    }
    @objc func openInBrowser() {
        if let u = container.webView.url { NSWorkspace.shared.open(u) }
    }

    // MARK: - 浏览器子菜单

    private func buildBrowserMenu() -> NSMenu {
        let menu = NSMenu(title: "浏览器")
        menu.autoenablesItems = false
        menu.delegate = MenuAnimationDelegate.shared

        let defaultBrowser = NSMenuItem(title: "在默认浏览器中打开", action: #selector(openInBrowser), keyEquivalent: "o")
        defaultBrowser.target = self
        defaultBrowser.image = NSImage(systemSymbolName: "safari", accessibilityDescription: nil)
        menu.addItem(defaultBrowser)

        let copyURL = NSMenuItem(title: "复制当前页 URL", action: #selector(copyCurrentURL), keyEquivalent: "c")
        copyURL.target = self
        copyURL.keyEquivalentModifierMask = [.command, .shift]
        copyURL.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: nil)
        menu.addItem(copyURL)

        menu.addItem(NSMenuItem.separator())

        let safari = NSMenuItem(title: "在 Safari 中打开", action: #selector(openInSafari), keyEquivalent: "")
        safari.target = self
        safari.image = NSImage(systemSymbolName: "safari", accessibilityDescription: nil)
        menu.addItem(safari)

        let chrome = NSMenuItem(title: "在 Google Chrome 中打开", action: #selector(openInChrome), keyEquivalent: "")
        chrome.target = self
        chrome.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
        // 仅在已安装 Chrome 时启用
        if NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") == nil {
            chrome.isEnabled = false
        }
        menu.addItem(chrome)

        let firefox = NSMenuItem(title: "在 Firefox 中打开", action: #selector(openInFirefox), keyEquivalent: "")
        firefox.target = self
        firefox.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
        if NSWorkspace.shared.urlForApplication(withBundleIdentifier: "org.mozilla.firefox") == nil {
            firefox.isEnabled = false
        }
        menu.addItem(firefox)

        menu.addItem(NSMenuItem.separator())

        let print = NSMenuItem(title: "打印…", action: #selector(printPage), keyEquivalent: "p")
        print.target = self
        print.image = NSImage(systemSymbolName: "printer", accessibilityDescription: nil)
        menu.addItem(print)

        let export = NSMenuItem(title: "导出为 PDF…", action: #selector(exportPDF), keyEquivalent: "")
        export.target = self
        export.image = NSImage(systemSymbolName: "arrow.down.doc", accessibilityDescription: nil)
        menu.addItem(export)

        return menu
    }

    @objc func copyCurrentURL() {
        if let u = container.webView.url {
            let pb = NSPasteboard.general
            pb.clearContents()
            pb.setString(u.absoluteString, forType: .string)
        }
    }

    @objc func openInSafari() {
        guard let u = container.webView.url else { return }
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") {
            let cfg = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open([u], withApplicationAt: appURL, configuration: cfg, completionHandler: nil)
        } else {
            NSWorkspace.shared.open(u)
        }
    }

    @objc func openInChrome() {
        if let u = container.webView.url,
           let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") {
            let cfg = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open([u], withApplicationAt: appURL, configuration: cfg, completionHandler: nil)
        }
    }

    @objc func openInFirefox() {
        if let u = container.webView.url,
           let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "org.mozilla.firefox") {
            let cfg = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open([u], withApplicationAt: appURL, configuration: cfg, completionHandler: nil)
        }
    }

    @objc func printPage() {
        let op = container.webView.printOperation(with: NSPrintInfo.shared)
        op.showsPrintPanel = true
        op.showsProgressPanel = true
        op.run()
    }

    @objc func exportPDF() {
        guard let u = container.webView.url else { return }
        let save = NSSavePanel()
        save.allowedContentTypes = [.pdf]
        save.nameFieldStringValue = (u.host ?? "page") + ".pdf"
        save.title = "导出为 PDF"
        if let w = container.webView.window {
            save.beginSheetModal(for: w) { [weak self] resp in
                guard let self = self, resp == .OK, let dest = save.url else { return }
                // 复用 print 能力输出 PDF：通过 NSPrintInfo.jobDisposition = .save + savePath
                let info = NSPrintInfo.shared.copy() as! NSPrintInfo
                info.jobDisposition = .save
                info.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = dest
                let op = self.container.webView.printOperation(with: info)
                op.showsPrintPanel = false
                op.showsProgressPanel = false
                op.run()
            }
        }
    }
}

// MARK: - 菜单动画委托（系统级淡入 + 缩放）

final class MenuAnimationDelegate: NSObject, NSMenuDelegate {
    static let shared = MenuAnimationDelegate()

    func menuWillOpen(_ menu: NSMenu) {
        // NSMenu 在 NSPopUpButton 弹出时使用 NSMenuWindow 显示。
        // 系统已经有默认淡入动画（来自 NSMenuManager），但有时
        // 因 Reduce Motion 设置而消失。这里在菜单即将打开时
        // 找到对应的 NSWindow 主动添加一个 0.18s 的轻微缩放+淡入。
        DispatchQueue.main.async { [weak menu] in
            guard let menu = menu else { return }
            self.enhanceMenuAnimation(menu)
        }
    }

    private func enhanceMenuAnimation(_ menu: NSMenu) {
        // 通过遍历 menu.items 强制让视图层级实例化，便于获取关联的 NSWindow
        for item in menu.items { _ = item.view }

        // 找菜单的 NSWindow：NSApp.windows 中最近的、visible 的 menuWindow
        // 私有类 NSMenuWindow 在 Swift 中以 NSMenuWindow 形式暴露为 NSWindow 子类
        for w in NSApp.windows where w.isVisible && w.className.hasPrefix("NSMenu") {
            w.alphaValue = 0
            w.setFrame(w.frame.offsetBy(dx: 0, dy: -4), display: false)
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.18
                ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
                w.animator().alphaValue = 1.0
                let f = w.frame
                w.animator().setFrame(NSRect(x: f.origin.x, y: f.origin.y + 4, width: f.width, height: f.height), display: true)
            }
            break
        }
    }

    func menuDidClose(_ menu: NSMenu) { /* 关闭动画由系统处理 */ }
}

// MARK: - 窗口控制器

final class AppController: NSObject, NSWindowDelegate, NSApplicationDelegate {
    var window: NSWindow!
    var container: WebContainer!
    var dsh: DshProcess!
    var statusItem: NSMenuItem?
    var isQuitting = false
    private var signalSources: [DispatchSourceSignal] = []

    func applicationDidFinishLaunching(_ note: Notification) {
        NSApp.activate(ignoringOtherApps: true)
        setupMenu()
        setupWindow()
        startDsh()
        installSignalHandlers()
    }

    private func installSignalHandlers() {
        let sigs = [SIGTERM, SIGINT, SIGHUP]
        for sig in sigs {
            signal(sig, SIG_IGN)
            let src = DispatchSource.makeSignalSource(signal: sig, queue: .main)
            src.setEventHandler { [weak self] in self?.quit() }
            src.resume()
            signalSources.append(src)
        }
    }

    private func setupWindow() {
        let style: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 820),
                          styleMask: style,
                          backing: .buffered,
                          defer: false)
        window.title = "DeepSeek Harness"
        window.minSize = NSSize(width: 800, height: 540)
        window.titlebarAppearsTransparent = false
        window.appearance = nil
        window.delegate = self
        window.center()
        window.setFrameAutosaveName("DeepSeekHarnessMainWindow")

        let contentView = NSView(frame: window.contentView!.bounds)
        contentView.autoresizingMask = [.width, .height]
        window.contentView = contentView

        container = WebContainer(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)

        let toolbar = ToolbarView(container: container)
        contentView.addSubview(toolbar)

        // 加载占位
        let overlay = NSView()
        overlay.wantsLayer = true
        overlay.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        overlay.translatesAutoresizingMaskIntoConstraints = false
        // 初始为半透明，将用淡入动画登场
        overlay.alphaValue = 0
        let spinner = NSProgressIndicator()
        spinner.style = .spinning
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimation(nil)
        let text = NSTextField(labelWithString: "正在启动 DeepSeek Harness…")
        text.font = NSFont.systemFont(ofSize: 14)
        text.textColor = .secondaryLabelColor
        text.alignment = .center
        text.translatesAutoresizingMaskIntoConstraints = false
        let iconView = NSImageView(image: NSImage(named: NSImage.applicationIconName) ?? NSImage())
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = .scaleProportionallyUpOrDown
        overlay.addSubview(iconView)
        overlay.addSubview(text)
        overlay.addSubview(spinner)
        contentView.addSubview(overlay)
        container.loadingOverlay = overlay
        container.loadingSpinner = spinner
        container.loadingText = text

        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: contentView.topAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 40),

            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            overlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            overlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: overlay.centerYAnchor, constant: -40),
            iconView.widthAnchor.constraint(equalToConstant: 96),
            iconView.heightAnchor.constraint(equalToConstant: 96),

            text.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            text.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            text.widthAnchor.constraint(lessThanOrEqualTo: overlay.widthAnchor, constant: -80),

            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 12)
        ])

        window.makeKeyAndOrderFront(nil)
        // 启动时占位淡入（系统级 ease-out 动画）
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.35
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            overlay.animator().alphaValue = 1
        }
    }

    private func startDsh() {
        dsh = DshProcess()
        guard dsh.start(statusUpdate: { [weak self] status in
            guard let self = self else { return }
            // 过滤过长的日志行，只保留关键信息展示在占位文字上
            let line = status.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.count > 80 {
                self.container?.loadingText?.stringValue = String(line.prefix(80)) + "…"
            } else {
                self.container?.loadingText?.stringValue = line
            }
        }) else {
            showFatalError(dsh.lastError ?? "dsh 启动失败")
            return
        }
        NSLog("dsh 已启动，端口 \(dsh.port)")
        dsh.waitReady { [weak self] url in
            guard let self = self else { return }
            guard let url = url else {
                let detail = self.dsh.lastError ?? "dsh 在 60 秒内未打印可访问的 token URL。"
                let diagnostics = self.dsh.formattedDiagnostics()
                self.showFatalError("\(detail)\(diagnostics)")
                return
            }
            self.container.loadURL(url)
        }
    }

    private func showFatalError(_ msg: String) {
        container?.loadingText?.stringValue = "启动失败"
        container?.loadingSpinner?.stopAnimation(nil)
        let alert = NSAlert()
        alert.messageText = "无法启动 DeepSeek Harness"
        alert.informativeText = msg + "\n\n可尝试在终端运行 `dsh web --no-open` 查看详细报错。"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "退出")
        alert.runModal()
        quit()
    }

    // MARK: - 菜单

    private func setupMenu() {
        let menubar = NSMenu()

        // 给 menubar 的所有 submenu 注入系统级淡入动画
        func animatedSubmenu(_ title: String) -> NSMenu {
            let m = NSMenu(title: title)
            m.delegate = MenuAnimationDelegate.shared
            return m
        }

        // 应用菜单
        let appMenuItem = NSMenuItem()
        let appMenu = animatedSubmenu("DeepSeek Harness")
        appMenu.title = "DeepSeek Harness"
        appMenu.addItem(withTitle: "关于 DeepSeek Harness", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "偏好设置…", action: #selector(showPreferences), keyEquivalent: ",")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "服务", action: nil, keyEquivalent: "")
        let servicesItem = appMenu.items.last!
        let servicesMenu = NSMenu()
        servicesItem.submenu = servicesMenu
        NSApp.servicesMenu = servicesMenu
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "隐藏 DeepSeek Harness", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        let hideOthers = NSMenuItem(title: "隐藏其他", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        appMenu.addItem(hideOthers)
        appMenu.addItem(withTitle: "显示全部", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "退出 DeepSeek Harness", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        menubar.addItem(appMenuItem)

        // 文件菜单
        let fileMenuItem = NSMenuItem()
        let fileMenu = animatedSubmenu("文件")
        fileMenu.addItem(withTitle: "新建会话", action: #selector(newSession), keyEquivalent: "n")
        let open = NSMenuItem(title: "在浏览器中打开", action: #selector(openInBrowserMenu), keyEquivalent: "o")
        fileMenu.addItem(open)
        fileMenu.addItem(NSMenuItem.separator())
        let close = NSMenuItem(title: "关闭窗口", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "")
        fileMenu.addItem(close)
        fileMenuItem.submenu = fileMenu
        menubar.addItem(fileMenuItem)

        // 编辑菜单（必填，否则 ⌘C/⌘V 失效）
        let editMenuItem = NSMenuItem()
        let editMenu = animatedSubmenu("编辑")
        editMenu.addItem(withTitle: "撤销", action: Selector(("undo:")), keyEquivalent: "z")
        let redo = NSMenuItem(title: "重做", action: Selector(("redo:")), keyEquivalent: "z")
        redo.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(redo)
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "剪切", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "复制", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "粘贴", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        let pastePlain = NSMenuItem(title: "粘贴并匹配样式", action: Selector(("pasteAsPlainText:")), keyEquivalent: "v")
        pastePlain.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(pastePlain)
        editMenu.addItem(withTitle: "全选", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenu.addItem(NSMenuItem.separator())
        let findItem = NSMenuItem(title: "查找…", action: #selector(showFindBar), keyEquivalent: "f")
        editMenu.addItem(findItem)
        let findNext = NSMenuItem(title: "查找下一个", action: #selector(findNext), keyEquivalent: "g")
        editMenu.addItem(findNext)
        let findPrev = NSMenuItem(title: "查找上一个", action: #selector(findPrev), keyEquivalent: "g")
        findPrev.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(findPrev)
        editMenuItem.submenu = editMenu
        menubar.addItem(editMenuItem)

        // 视图菜单
        let viewMenuItem = NSMenuItem()
        let viewMenu = animatedSubmenu("视图")
        viewMenu.addItem(withTitle: "重新载入", action: #selector(reload), keyEquivalent: "r")
        viewMenu.addItem(withTitle: "强制重新载入", action: #selector(forceReload), keyEquivalent: "r")
        if let last = viewMenu.items.last { last.keyEquivalentModifierMask = [.command, .shift] }
        viewMenu.addItem(withTitle: "停止", action: #selector(stop), keyEquivalent: ".")
        viewMenu.addItem(NSMenuItem.separator())
        viewMenu.addItem(withTitle: "实际大小", action: #selector(actualSize), keyEquivalent: "0")
        viewMenu.addItem(withTitle: "放大", action: #selector(zoomIn), keyEquivalent: "+")
        viewMenu.addItem(withTitle: "缩小", action: #selector(zoomOut), keyEquivalent: "-")
        viewMenu.addItem(NSMenuItem.separator())
        viewMenu.addItem(withTitle: "进入全屏幕", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
        if let last = viewMenu.items.last { last.keyEquivalentModifierMask = [.command, .control] }
        viewMenu.addItem(NSMenuItem.separator())
        let toggleToolbar = NSMenuItem(title: "隐藏工具栏", action: #selector(toggleToolbar), keyEquivalent: "l")
        viewMenu.addItem(toggleToolbar)
        viewMenuItem.submenu = viewMenu
        menubar.addItem(viewMenuItem)

        // 前往菜单
        let goMenuItem = NSMenuItem()
        let goMenu = animatedSubmenu("前往")
        goMenu.addItem(withTitle: "后退", action: #selector(goBackMenu), keyEquivalent: "[")
        goMenu.addItem(withTitle: "前进", action: #selector(goForwardMenu), keyEquivalent: "]")
        goMenu.addItem(NSMenuItem.separator())
        goMenu.addItem(withTitle: "返回主页", action: #selector(goHome), keyEquivalent: "H")
        if let last = goMenu.items.last { last.keyEquivalentModifierMask = [.command, .shift] }
        goMenuItem.submenu = goMenu
        menubar.addItem(goMenuItem)

        // 窗口菜单
        let windowMenuItem = NSMenuItem()
        let windowMenu = animatedSubmenu("窗口")
        windowMenu.addItem(withTitle: "最小化", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "全部前置", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "")
        windowMenuItem.submenu = windowMenu
        menubar.addItem(windowMenuItem)
        NSApp.windowsMenu = windowMenu

        // 帮助菜单
        let helpMenuItem = NSMenuItem()
        let helpMenu = animatedSubmenu("帮助")
        helpMenu.addItem(withTitle: "DeepSeek Harness 帮助", action: #selector(openHelp), keyEquivalent: "?")
        helpMenuItem.submenu = helpMenu
        menubar.addItem(helpMenuItem)
        NSApp.helpMenu = helpMenu

        NSApp.mainMenu = menubar
    }

    // MARK: - 菜单动作

    @objc func newSession() {
        if let url = container?.tokenURL {
            var comp = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if var c = comp {
                c.queryItems = (c.queryItems ?? []).filter { $0.name != "token" }
                if let home = c.url {
                    container?.webView.load(URLRequest(url: home))
                }
            }
        }
    }

    @objc func openInBrowserMenu() {
        if let u = container?.webView.url { NSWorkspace.shared.open(u) }
    }

    @objc func reload() { container?.webView.reload() }

    @objc func forceReload() {
        if let u = container?.webView.url {
            container?.webView.load(URLRequest(url: u, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15))
        }
    }

    @objc func stop() { container?.webView.stopLoading() }

    @objc func actualSize() { container?.webView.pageZoom = 1.0 }
    @objc func zoomIn() { container?.webView.pageZoom = min(container.webView.pageZoom + 0.1, 3.0) }
    @objc func zoomOut() { container?.webView.pageZoom = max(container.webView.pageZoom - 0.1, 0.5) }

    @objc func goBackMenu() { container?.webView.goBack() }
    @objc func goForwardMenu() { container?.webView.goForward() }
    @objc func goHome() { newSession() }

    var findBarVisible = false
    @objc func showFindBar() {
        guard let container = container else { return }
        if container.findBar == nil { buildFindBar() }
        guard let bar = container.findBar else { return }
        if !findBarVisible {
            bar.isHidden = false
            findBarVisible = true
        }
        container.webView.window?.makeFirstResponder(container.findField)
    }
    @objc func hideFindBar() {
        if let bar = container?.findBar { bar.isHidden = true }
        findBarVisible = false
        container?.webView.evaluateJavaScript("window.getSelection().removeAllRanges()", completionHandler: nil)
    }
    @objc func findNext() { performFind(backwards: false) }
    @objc func findPrev() { performFind(backwards: true) }
    private func performFind(backwards: Bool) {
        guard let text = container?.findField?.stringValue, !text.isEmpty else { return }
        let dir = backwards ? "true" : "false"
        let js = "window.find('\(text.replacingOccurrences(of: "'", with: "\\'"))', false, \(dir), true)"
        container?.webView.evaluateJavaScript(js, completionHandler: nil)
    }

    func buildFindBar() {
        guard let container = container, let win = container.webView.window else { return }
        let bar = NSView()
        bar.wantsLayer = true
        bar.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        bar.translatesAutoresizingMaskIntoConstraints = false

        let field = NSTextField()
        field.placeholderString = "在页面中查找"
        field.bezelStyle = .roundedBezel
        field.delegate = self
        field.target = self
        field.action = #selector(findNext)
        field.translatesAutoresizingMaskIntoConstraints = false

        let next = NSButton(image: NSImage(systemSymbolName: "chevron.down", accessibilityDescription: "下一个")!, target: self, action: #selector(findNext))
        next.bezelStyle = .texturedRounded
        let prev = NSButton(image: NSImage(systemSymbolName: "chevron.up", accessibilityDescription: "上一个")!, target: self, action: #selector(findPrev))
        prev.bezelStyle = .texturedRounded
        let done = NSButton(image: NSImage(systemSymbolName: "xmark", accessibilityDescription: "关闭")!, target: self, action: #selector(hideFindBar))
        done.bezelStyle = .texturedRounded

        bar.addSubview(field)
        bar.addSubview(prev)
        bar.addSubview(next)
        bar.addSubview(done)

        win.contentView?.addSubview(bar)
        let anchorView = win.contentView?.subviews.first(where: { $0 !== bar && $0 is NSView })
        let topAnchor = anchorView?.bottomAnchor ?? win.contentView!.topAnchor
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            bar.leadingAnchor.constraint(equalTo: win.contentView!.trailingAnchor, constant: -360),
            bar.trailingAnchor.constraint(equalTo: win.contentView!.trailingAnchor, constant: -8),
            bar.heightAnchor.constraint(equalToConstant: 36),

            field.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 8),
            field.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            field.widthAnchor.constraint(equalToConstant: 220),

            prev.leadingAnchor.constraint(equalTo: field.trailingAnchor, constant: 8),
            prev.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            next.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: 4),
            next.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            done.leadingAnchor.constraint(equalTo: next.trailingAnchor, constant: 4),
            done.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -8),
            done.centerYAnchor.constraint(equalTo: bar.centerYAnchor)
        ])
        bar.isHidden = true
        container.findBar = bar
        container.findField = field
    }

    var toolbarVisible = true
    @objc func toggleToolbar() {
        toolbarVisible.toggle()
        let toolbar = window.contentView?.subviews.first(where: { $0 is ToolbarView }) as? ToolbarView
        toolbar?.isHidden = !toolbarVisible
        // 同步菜单标题
        if let m = NSApp.mainMenu?.item(withTitle: "视图")?.submenu?.item(withTitle: toolbarVisible ? "隐藏工具栏" : "显示工具栏") {
            m.title = toolbarVisible ? "隐藏工具栏" : "显示工具栏"
        }
    }

    @objc func showPreferences() {
        let alert = NSAlert()
        alert.messageText = "偏好设置"
        alert.informativeText = "偏好设置面板开发中。当前为最轻量套壳，地址栏已移除，全部依赖 dsh Web UI 自带设置。"
        alert.runModal()
    }

    @objc func openHelp() {
        if let u = URL(string: "https://github.com/deepseek-ai/dsh") {
            NSWorkspace.shared.open(u)
        }
    }

    // MARK: - NSApplicationDelegate

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { window?.makeKeyAndOrderFront(nil) }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        dsh?.terminate()
    }

    func windowShouldZoom(_ window: NSWindow, toFrame newFrame: NSRect) -> Bool { true }

    // MARK: - 退出

    func quit() {
        if isQuitting { return }
        isQuitting = true
        dsh?.terminate()
        NSApp.terminate(nil)
    }
}

extension AppController: NSTextFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            if NSEvent.modifierFlags.contains(.shift) { findPrev() } else { findNext() }
            return true
        }
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            hideFindBar()
            return true
        }
        return false
    }
}

// MARK: - 入口

let app = NSApplication.shared
let delegate = AppController()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
