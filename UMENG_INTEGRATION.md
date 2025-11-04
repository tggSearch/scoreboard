# 友盟统计集成说明

## 概述
本项目已成功集成友盟统计SDK (fl_umeng)，用于统计DAU（日活跃用户）等数据。

## 配置信息

### Android配置
- **AppKey**: `6909af0a8560e34872debbf6`
- **Channel**: `default`
- **配置文件**: `android/app/src/main/AndroidManifest.xml`

### iOS配置
- **AppKey**: `6909afb48560e34872debc5e`
- **Channel**: `App Store`
- **配置文件**: `ios/Runner/Info.plist`

## 已实现功能

### 1. 自动统计
应用启动后，友盟SDK会自动统计以下数据：
- **DAU（日活跃用户）**
- **应用启动次数**
- **应用使用时长**
- **设备信息**
- **系统版本**

### 2. 初始化
在 `lib/main.dart` 中已完成初始化，应用启动时自动执行。

```dart
await _initUmeng();
```

### 3. 工具类使用
在 `lib/core/utils/analytics_utils.dart` 中提供了便捷的工具类方法：

#### 页面统计
```dart
import 'package:score_board/core/utils/analytics_utils.dart';

// 页面开始
await AnalyticsUtils.onPageStart('HomePage');

// 页面结束
await AnalyticsUtils.onPageEnd('HomePage');
```

#### 自定义事件统计（可选）
```dart
// 简单事件
await AnalyticsUtils.onEvent('ButtonClick');

// 带参数的事件
await AnalyticsUtils.onEvent('ScoreUpdate', parameters: {
  'gameType': 'basketball',
  'score': 100,
});
```

#### 错误上报（可选，仅Android）
```dart
await AnalyticsUtils.reportError('发生了一个错误');
```

## 查看统计数据

1. 登录友盟官网：https://www.umeng.com/
2. 进入"统计分析"模块
3. 选择对应的应用（使用AppKey识别）
4. 查看各项统计数据：
   - 实时概况
   - 日活跃用户（DAU）
   - 新增用户
   - 启动次数
   - 使用时长
   - 自定义事件（如果有使用）

## 注意事项

1. **日志开关**：
   - 当前日志已开启（`setLogEnabled(true)`）
   - 生产环境建议关闭日志，在 `lib/main.dart` 中修改：
   ```dart
   await FlUMeng().setLogEnabled(false);
   ```

2. **数据延迟**：
   - 友盟统计数据有一定延迟（通常1-2小时）
   - 实时数据可能不完全准确

3. **网络权限**：
   - Android和iOS已配置网络权限
   - 确保应用有网络连接

4. **隐私合规**：
   - 确保在隐私政策中说明使用了友盟统计
   - 遵守各地区的数据隐私法规

## 依赖版本

- **fl_umeng**: ^2.0.0（当前安装版本：2.6.0）

## 更多功能

如需使用更多统计功能，请参考：
- [fl_umeng官方文档](https://pub.dev/packages/fl_umeng)
- [友盟官方文档](https://developer.umeng.com/docs/147377/detail/209950)

## 常见问题

### Q: 数据没有上报？
A: 
1. 检查网络连接
2. 检查AppKey是否正确配置
3. 查看控制台日志是否有错误信息
4. 等待1-2小时后在友盟后台查看

### Q: 如何在页面中自动统计？
A: 可以在GetX页面的生命周期方法中添加统计：
```dart
class YourPage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    AnalyticsUtils.onPageStart('YourPageName');
  }

  @override
  void dispose() {
    AnalyticsUtils.onPageEnd('YourPageName');
    super.dispose();
  }
}
```

### Q: iOS真机测试时数据不上报？
A: 确保：
1. Info.plist中AppKey配置正确
2. 网络权限已配置
3. 等待足够的时间让数据同步

