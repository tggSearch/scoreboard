# ScoreBoard Pro

专业计分板应用，支持多种游戏类型的计分功能。

## 功能特性

- 支持多种游戏类型：篮球、足球、网球、羽毛球、乒乓球、排球、德州扑克、UNO、桥牌、麻将、斗地主等
- 多语言支持（中文/英文）
- 历史记录管理
- 语音播报功能
- 自定义计分规则

## 开发工具

### 翻译文件清理脚本

为了避免翻译文件中的重复key导致的编译错误，我们提供了自动清理脚本：

```bash
# 方法1：使用shell脚本（推荐）
./scripts/clean_translations.sh

# 方法2：直接运行Dart脚本
dart scripts/remove_duplicate_keys.dart
```

**使用场景：**
- 当添加新的翻译key时，可能会意外产生重复
- 运行 `flutter analyze` 时出现 "Two keys in a constant map literal can't be equal" 错误
- 编译时出现 "Constant evaluation error" 错误

**脚本功能：**
- 自动检测并移除 `lib/core/translations/en_us.dart` 中的重复key
- 自动检测并移除 `lib/core/translations/zh_cn.dart` 中的重复key
- 保留第一次出现的key，移除后续重复的key
- 保持文件格式和注释不变

**使用步骤：**
1. 在项目根目录运行清理脚本
2. 脚本会自动处理翻译文件
3. 运行 `flutter analyze` 验证结果
4. 如果还有错误，重复步骤1-3

## 项目结构

```
score_board_pro/
├── lib/
│   ├── business/           # 业务逻辑
│   │   ├── game_utils/     # 游戏工具
│   │   ├── score_tracker/  # 计分追踪
│   │   └── user_profile/   # 用户资料
│   ├── core/              # 核心功能
│   │   ├── base/          # 基础类
│   │   ├── controllers/   # 控制器
│   │   ├── data/          # 数据模型
│   │   ├── network/       # 网络请求
│   │   ├── routes/        # 路由配置
│   │   ├── translations/  # 翻译文件
│   │   └── utils/         # 工具类
│   ├── pages/             # 页面
│   └── main.dart          # 入口文件
├── scripts/               # 脚本文件
│   ├── clean_translations.sh      # 翻译清理脚本
│   └── remove_duplicate_keys.dart # 重复key清理脚本
└── pubspec.yaml           # 项目配置
```

## 开发指南

### 添加新翻译

1. 在 `lib/core/translations/en_us.dart` 中添加英文翻译
2. 在 `lib/core/translations/zh_cn.dart` 中添加中文翻译
3. 运行清理脚本确保没有重复key
4. 在代码中使用 `'key_name'.tr` 来获取翻译

### 运行项目

```bash
# 安装依赖
flutter pub get

# 运行项目
flutter run

# 代码分析
flutter analyze

# 清理翻译文件（如有需要）
./scripts/clean_translations.sh
```

## 技术栈

- Flutter 3.x
- GetX (状态管理)
- Dart 3.x

## 许可证

MIT License
