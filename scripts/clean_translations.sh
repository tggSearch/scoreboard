#!/bin/bash

# 翻译文件清理脚本
# 自动去除 en_us.dart 和 zh_cn.dart 中的重复key

echo "🔧 开始清理翻译文件..."

# 检查是否在正确的目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

# 检查Dart脚本是否存在
if [ ! -f "scripts/remove_duplicate_keys.dart" ]; then
    echo "❌ 找不到清理脚本: scripts/remove_duplicate_keys.dart"
    exit 1
fi

# 运行Dart脚本
echo "📝 运行清理脚本..."
dart scripts/remove_duplicate_keys.dart

# 检查是否成功
if [ $? -eq 0 ]; then
    echo "✅ 翻译文件清理完成！"
    echo "📋 现在可以运行 'flutter analyze' 检查结果"
else
    echo "❌ 清理过程中出现错误"
    exit 1
fi 