<div align="center">
  <img src="icons.icon/Assets/AppIcon.png" width="120" alt="应用卸载器图标" />
  <h1 align="center">应用卸载器</h1>
  <p align="center">基于 SwiftUI 的 macOS 应用卸载工具 — 干净、安全、省心。</p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/平台-macOS%2013+-blue?logo=apple&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?logo=swift" alt="Swift" />
  <img src="https://img.shields.io/badge/许可证-MIT-green" alt="License" />
</p>

---

## 简介

**应用卸载器** 是一款原生 macOS 应用，帮助您彻底删除不需要的应用程序及其关联文件。与简单地将应用拖入废纸篓不同，卸载器还会查找并清理散落在系统中的残留文件 — 偏好设置、缓存、应用支持数据、日志等 — 确保不留痕迹。

## 功能特性

- **全面扫描** — 扫描 `/Applications`、`~/Applications`、系统工具以及用户目录中的应用。
- **智能分类** — 应用按*应用*、*工具*、*用户*和*系统*分组，方便浏览。
- **搜索筛选** — 按名称实时搜索，快速定位应用。
- **详细信息** — 查看应用图标、版本、大小、Bundle ID 和安装路径。
- **深度清理** — 扫描 `~/Library` 和 `/Library` 目录中的关联文件，包括：
  - 偏好设置文件 (`.plist`)
  - 缓存
  - 应用支持数据
  - 保存的应用状态
  - 日志
  - 容器
  - HTTP 存储
  - 群组容器
  - WebKit 数据库
- **安全卸载** — 先将应用移入废纸篓，再清理关联文件，实时显示进度。
- **系统应用保护** — 系统应用有明确标识，无法被卸载。
- **原生 SwiftUI 界面** — 流畅动画、侧边栏导航、深色模式支持、现代 macOS 设计。

## 系统要求

- macOS 13 (Ventura) 或更高版本
- Xcode 15+（从源码构建时需要）

## 安装方法

### 从源码构建

```bash
# 克隆仓库
git clone https://github.com/yourusername/uninstaller.git
cd uninstaller/Uninstaller

# 构建并生成 app bundle
make app

# 或直接运行
make run
```

构建完成后，`.app` 包位于 `build/Uninstaller.app`。将其拖入 `Applications` 文件夹，或直接运行。

### 使用 Xcode 构建

```bash
make xcode
```

然后打开生成的 Xcode 项目进行构建。

## 使用方法

1. 启动应用卸载器 — 它会自动扫描所有已安装的应用。
2. 在侧边栏按分类浏览应用，或使用搜索栏查找。
3. 点击应用查看其详细信息和关联文件。
4. 点击**卸载**移除应用及其关联文件。
5. 确认操作 — 应用会被移入废纸篓，残留文件也会被清理。

## 项目结构

```
Uninstaller/
├── Sources/Uninstaller/
│   ├── UninstallerApp.swift        # 应用入口 & 启动画面
│   ├── ContentView.swift           # 主界面（三栏布局）
│   ├── Models/
│   │   ├── MacApp.swift            # 应用数据模型及分类
│   │   └── AssociatedFile.swift    # 关联文件模型及分类
│   ├── Services/
│   │   ├── AppScanner.swift        # 扫描已安装应用
│   │   └── UninstallService.swift  # 处理卸载及文件清理
│   ├── ViewModels/
│   │   └── AppListViewModel.swift  # 应用列表状态管理
│   └── Views/
│       ├── SidebarView.swift       # 分类侧边栏
│       ├── AppListView.swift       # 应用列表面板（卡片式）
│       ├── AppDetailView.swift     # 选中应用的详情面板
│       ├── WelcomeView.swift       # 空状态欢迎页面
│       ├── UninstallConfirmationView.swift  # 卸载确认弹窗
│       └── UninstallProgressView.swift      # 进度 & 完成视图
├── icons.icon/                     # 应用图标资源
├── gen_icon.swift                  # 图标生成脚本
├── Info.plist                      # 包元信息
├── Makefile                        # 构建自动化
├── Package.swift                   # SwiftPM 清单
├── README.md                       # 英文说明文档
├── README.zh-CN.md                 # 中文说明文档
└── LICENSE                         # MIT 许可证
```

## 许可证

本项目基于 MIT 许可证开源。详见 [LICENSE](LICENSE) 文件。
