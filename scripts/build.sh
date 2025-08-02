#!/bin/bash

# FlowMind 构建脚本
# 支持 Android、iOS、Web 平台构建

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  FlowMind 构建脚本${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 检查Flutter环境
check_flutter() {
    print_message "检查Flutter环境..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter未安装或不在PATH中"
        exit 1
    fi
    
    flutter --version
    print_message "Flutter环境检查完成"
}

# 清理项目
clean_project() {
    print_message "清理项目..."
    flutter clean
    print_message "项目清理完成"
}

# 获取依赖
get_dependencies() {
    print_message "获取依赖..."
    flutter pub get
    print_message "依赖获取完成"
}

# 生成代码
generate_code() {
    print_message "生成代码..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    print_message "代码生成完成"
}

# 运行测试
run_tests() {
    print_message "运行测试..."
    flutter test
    print_message "测试完成"
}

# 构建Android APK
build_android_apk() {
    print_message "构建Android APK..."
    
    # 检查Android环境
    if ! command -v adb &> /dev/null; then
        print_warning "Android SDK未安装或不在PATH中，跳过Android构建"
        return
    fi
    
    flutter build apk --release
    print_message "Android APK构建完成: build/app/outputs/flutter-apk/app-release.apk"
}

# 构建Android App Bundle
build_android_bundle() {
    print_message "构建Android App Bundle..."
    
    if ! command -v adb &> /dev/null; then
        print_warning "Android SDK未安装或不在PATH中，跳过Android构建"
        return
    fi
    
    flutter build appbundle --release
    print_message "Android App Bundle构建完成: build/app/outputs/bundle/release/app-release.aab"
}

# 构建iOS
build_ios() {
    print_message "构建iOS..."
    
    # 检查iOS环境
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_warning "iOS构建只能在macOS上进行，跳过iOS构建"
        return
    fi
    
    if ! command -v xcodebuild &> /dev/null; then
        print_warning "Xcode未安装或不在PATH中，跳过iOS构建"
        return
    fi
    
    flutter build ios --release --no-codesign
    print_message "iOS构建完成"
}

# 构建Web
build_web() {
    print_message "构建Web应用..."
    flutter build web --release
    print_message "Web应用构建完成: build/web/"
}

# 构建所有平台
build_all() {
    print_message "构建所有平台..."
    
    build_android_apk
    build_android_bundle
    build_ios
    build_web
    
    print_message "所有平台构建完成"
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  clean         清理项目"
    echo "  deps          获取依赖"
    echo "  generate      生成代码"
    echo "  test          运行测试"
    echo "  android-apk   构建Android APK"
    echo "  android-bundle 构建Android App Bundle"
    echo "  ios           构建iOS"
    echo "  web           构建Web"
    echo "  all           构建所有平台"
    echo "  help          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 clean"
    echo "  $0 deps"
    echo "  $0 android-apk"
    echo "  $0 all"
}

# 主函数
main() {
    print_header
    
    # 检查参数
    if [ $# -eq 0 ]; then
        print_error "请提供构建选项"
        show_help
        exit 1
    fi
    
    # 检查Flutter环境
    check_flutter
    
    # 处理参数
    case "$1" in
        "clean")
            clean_project
            ;;
        "deps")
            get_dependencies
            ;;
        "generate")
            generate_code
            ;;
        "test")
            run_tests
            ;;
        "android-apk")
            clean_project
            get_dependencies
            generate_code
            build_android_apk
            ;;
        "android-bundle")
            clean_project
            get_dependencies
            generate_code
            build_android_bundle
            ;;
        "ios")
            clean_project
            get_dependencies
            generate_code
            build_ios
            ;;
        "web")
            clean_project
            get_dependencies
            generate_code
            build_web
            ;;
        "all")
            clean_project
            get_dependencies
            generate_code
            build_all
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
    
    print_message "构建脚本执行完成"
}

# 执行主函数
main "$@" 