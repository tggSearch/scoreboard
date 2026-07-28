pipeline {
    agent any  // 使用任意可用节点（iOS 构建需要 macOS）

    parameters {
        choice(
            name: 'BUILD_TARGET',
            choices: ['all', 'android', 'ios', 'apk', 'aab'],
            description: '选择构建目标平台'
        )
        booleanParam(
            name: 'CLEAN_BUILD',
            defaultValue: true,
            description: '是否清理构建缓存'
        )
        choice(
            name: 'BUILD_MODE',
            choices: ['release', 'profile', 'debug'],
            description: '构建模式'
        )
        string(
            name: 'VERSION_OVERRIDE',
            defaultValue: '',
            description: '版本号覆盖（留空使用 pubspec.yaml 中的版本）'
        )
        booleanParam(
            name: 'UPLOAD_TO_STORE',
            defaultValue: false,
            description: '构建后上传 (iOS->App Store, AAB->Google Play, APK->腾讯云COS)'
        )
        choice(
            name: 'GOOGLE_PLAY_TRACK',
            choices: ['internal', 'alpha', 'beta', 'production'],
            description: 'Google Play 发布轨道'
        )
    }

    environment {
        // Flutter 环境 - 使用系统已安装的 Flutter
        FLUTTER_HOME = "${env.FLUTTER_HOME ?: '/Users/dan/Desktop/code/flutter'}"
        
        // Android 环境
        ANDROID_HOME = "${env.ANDROID_HOME ?: '/Users/dan/Library/Android/sdk'}"
        ANDROID_SDK_ROOT = "${ANDROID_HOME}"
        // Gradle / sdkmanager（Jenkins 守护进程默认不带 JAVA_HOME）
        JAVA_HOME = "${env.JAVA_HOME ?: '/Applications/Android Studio 2.app/Contents/jbr/Contents/Home'}"
        
        // Ruby/Gem 环境（用于 CocoaPods）
        GEM_HOME = "${env.HOME}/.gem"
        
        // 字符编码设置 - CocoaPods 和 Ruby 需要 UTF-8
        LANG = "en_US.UTF-8"
        LC_ALL = "en_US.UTF-8"
        
        // 网络配置 - 使用代理直连 pub.dev（不使用镜像避免 TLS 错误）
        HTTP_PROXY = "http://127.0.0.1:7897"
        HTTPS_PROXY = "http://127.0.0.1:7897"
        http_proxy = "http://127.0.0.1:7897"
        https_proxy = "http://127.0.0.1:7897"
        ALL_PROXY = "socks5://127.0.0.1:7897"
        NO_PROXY = "localhost,127.0.0.1"
        
        // 应用信息
        APP_NAME = 'scoreBoard'
        BUNDLE_ID = 'com.qualrb.scoreBoardPro'
        TEAM_ID = '483V3ZF35S'
        IOS_PROVISIONING_PROFILE = 'scoreboard'
        
        // 证书目录（敏感密钥放在节点 ${CERT_DIR}/jenkins_secrets.env）
        CERT_DIR = "${env.CERT_DIR ?: '/Users/dan/Documents/cert'}"
        IOS_PROVISIONING_PROFILE_PATH = "${env.IOS_PROVISIONING_PROFILE_PATH ?: "${WORKSPACE}/certs/scoreboard.mobileprovision"}"
        JENKINS_SECRETS_FILE = "${env.JENKINS_SECRETS_FILE ?: "${CERT_DIR}/jenkins_secrets.env"}"
        
        // iOS App Store Connect API 配置（从 Jenkins 环境变量或 secrets 文件读取）
        IOS_API_KEY_ID = "${env.IOS_API_KEY_ID ?: ''}"
        IOS_API_ISSUER_ID = "${env.IOS_API_ISSUER_ID ?: ''}"
        IOS_API_KEY_PATH = "${env.IOS_API_KEY_PATH ?: "${CERT_DIR}/4GN8P39YH9.p8"}"
        
        // Android Google Play API 配置
        ANDROID_SERVICE_ACCOUNT_JSON = "${env.ANDROID_SERVICE_ACCOUNT_JSON ?: "${CERT_DIR}/tudan.json"}"
        
        // 腾讯云 COS 配置 (APK 上传)
        TENCENT_SECRET_ID = "${env.TENCENT_SECRET_ID ?: ''}"
        TENCENT_SECRET_KEY = "${env.TENCENT_SECRET_KEY ?: ''}"
        COS_BUCKET = "${env.COS_BUCKET ?: 'apk-1251046496'}"
        COS_BUCKET_PATH = "${env.COS_BUCKET_PATH ?: 'apk'}"
        COS_REGION = "${env.COS_REGION ?: 'ap-guangzhou'}"
    }

    options {
        timeout(time: 60, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: scm.branches,
                    extensions: [
                        [$class: 'CloneOption', 
                         shallow: false,
                         noTags: false,
                         reference: '',
                         timeout: 30],
                        [$class: 'CheckoutOption', timeout: 30],
                        [$class: 'CleanBeforeCheckout', deleteUntrackedNestedRepositories: false]
                    ],
                    userRemoteConfigs: scm.userRemoteConfigs
                ])
                script {
                    // 获取版本信息
                    def version = sh(
                        script: """
                            export PATH="/opt/homebrew/bin:/usr/local/bin:\$FLUTTER_HOME/bin:\$PATH"
                            grep 'version:' pubspec.yaml | head -1 | awk '{print \$2}'
                        """,
                        returnStdout: true
                    ).trim()
                    
                    if (params.VERSION_OVERRIDE?.trim()) {
                        version = params.VERSION_OVERRIDE.trim()
                    }
                    
                    env.APP_VERSION = version
                    currentBuild.displayName = "#${BUILD_NUMBER} - v${version} (${params.BUILD_TARGET})"
                }
                echo "构建版本: ${env.APP_VERSION}"
            }
        }

        stage('Setup Flutter') {
            steps {
                script {
                    // 检查 Flutter 和 CocoaPods 环境
                    sh '''
                        # 设置 PATH - 在脚本中设置避免 Jenkins PATH 变量冲突
                        export PATH="/opt/homebrew/bin:/usr/local/bin:$FLUTTER_HOME/bin:$HOME/.rbenv/shims:$HOME/.rvm/bin:$HOME/.gem/bin:$PATH"
                        
                        echo "===================================="
                        echo "检查构建环境..."
                        echo "===================================="
                        echo ""
                        
                        echo "当前 PATH:"
                        echo "$PATH"
                        echo ""
                        
                        echo "--- 代理检查 ---"
                        echo "HTTP_PROXY: $HTTP_PROXY"
                        echo "HTTPS_PROXY: $HTTPS_PROXY"
                        echo ""
                        echo "测试代理连接..."
                        if curl -I --proxy $HTTP_PROXY --connect-timeout 5 https://www.google.com 2>/dev/null | head -1; then
                            echo "✓ 代理连接成功"
                        else
                            echo "✗ 警告: 代理连接失败，可能影响 pub.dev 访问"
                            echo "尝试直接连接 pub.dev (不使用代理)..."
                            if curl -I --connect-timeout 5 https://pub.dev 2>/dev/null | head -1; then
                                echo "✓ 可以直接访问 pub.dev"
                            else
                                echo "✗ 无法访问 pub.dev，构建可能失败"
                            fi
                        fi
                        echo ""
                        
                        echo "--- Flutter 检查 ---"
                        echo "FLUTTER_HOME: $FLUTTER_HOME"
                        
                        if [ -f "$FLUTTER_HOME/bin/flutter" ]; then
                            echo "✓ Flutter SDK 已找到: $FLUTTER_HOME"
                        elif command -v flutter &> /dev/null; then
                            echo "✓ Flutter 已在 PATH 中: $(which flutter)"
                        else
                            echo "✗ 错误: Flutter 未安装!"
                            echo "请在 Jenkins 节点上安装 Flutter:"
                            echo "  git clone https://github.com/flutter/flutter.git ~/development/flutter"
                            echo "  或设置 FLUTTER_HOME 环境变量指向已安装的 Flutter"
                            exit 1
                        fi
                        
                        flutter --version
                        echo ""
                        
                        echo "--- CocoaPods 检查 ---"
                        if command -v pod &> /dev/null; then
                            echo "✓ CocoaPods 已找到: $(which pod)"
                            echo "✓ CocoaPods 版本: $(pod --version)"
                        else
                            echo "✗ 警告: CocoaPods 未在 PATH 中找到"
                            echo "尝试在常见位置查找..."
                            
                            if [ -f "/opt/homebrew/bin/pod" ]; then
                                echo "✓ 找到: /opt/homebrew/bin/pod"
                                export PATH="/opt/homebrew/bin:$PATH"
                            elif [ -f "/usr/local/bin/pod" ]; then
                                echo "✓ 找到: /usr/local/bin/pod"
                                export PATH="/usr/local/bin:$PATH"
                            else
                                echo "✗ CocoaPods 未安装"
                                echo "如需构建 iOS，请安装 CocoaPods:"
                                echo "  brew install cocoapods"
                            fi
                        fi
                        echo ""
                        
                        echo "--- Android SDK 检查 ---"
                        if [ -d "$ANDROID_HOME" ]; then
                            echo "✓ Android SDK: $ANDROID_HOME"
                        else
                            echo "✗ 警告: ANDROID_HOME 未设置或目录不存在"
                        fi
                        echo ""
                        
                        echo "===================================="
                        echo "环境检查完成"
                        echo "===================================="
                    '''
                }
            }
        }

        stage('Clean') {
            when {
                expression { params.CLEAN_BUILD }
            }
            steps {
                sh '''
                    export PATH="/opt/homebrew/bin:/usr/local/bin:$FLUTTER_HOME/bin:$HOME/.rbenv/shims:$HOME/.rvm/bin:$PATH"
                    echo "Git HEAD: $(git rev-parse HEAD 2>/dev/null || echo unknown)"
                    flutter clean
                    rm -rf output build android/.gradle android/app/build
                '''
            }
        }

        stage('Get Dependencies') {
            steps {
                sh '''
                    export PATH="/opt/homebrew/bin:/usr/local/bin:$FLUTTER_HOME/bin:$HOME/.rbenv/shims:$HOME/.rvm/bin:$PATH"
                    flutter pub get
                '''
            }
        }

        stage('Prepare Output') {
            steps {
                sh 'mkdir -p output'
            }
        }

        stage('Prepare Android Signing') {
            when {
                expression { 
                    params.BUILD_TARGET in ['all', 'android', 'apk', 'aab'] 
                }
            }
            steps {
                sh '''
                    export PATH="/opt/homebrew/bin:/usr/local/bin:$FLUTTER_HOME/bin:$HOME/.rbenv/shims:$HOME/.rvm/bin:$PATH"
                    if [ -f "${JENKINS_SECRETS_FILE}" ]; then
                        set -a
                        # shellcheck source=/dev/null
                        source "${JENKINS_SECRETS_FILE}"
                        set +a
                        echo "已加载 ${JENKINS_SECRETS_FILE}"
                    fi
                    ./jenkins_build.sh --prepare-android-signing
                '''
            }
        }

        stage('Build Android APK') {
            when {
                expression { 
                    params.BUILD_TARGET in ['all', 'android', 'apk'] 
                }
            }
            steps {
                script {
                    def versionArg = ''
                    if (params.VERSION_OVERRIDE?.trim()) {
                        versionArg = "-v ${params.VERSION_OVERRIDE.trim()}"
                    }
                    def cleanArg = params.CLEAN_BUILD ? '-c' : ''
                    sh """
                        export PATH="/opt/homebrew/bin:/usr/local/bin:\$FLUTTER_HOME/bin:\$HOME/.rbenv/shims:\$HOME/.rvm/bin:\$PATH"
                        echo "Building from commit: \$(git rev-parse --short HEAD)"
                        ./jenkins_build.sh -t apk -m ${params.BUILD_MODE} ${versionArg} ${cleanArg}
                    """
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'output/*.apk', fingerprint: true
                }
            }
        }

        stage('Build Android AAB') {
            when {
                expression { 
                    params.BUILD_TARGET in ['all', 'android', 'aab'] 
                }
            }
            steps {
                script {
                    def versionArg = ''
                    if (params.VERSION_OVERRIDE?.trim()) {
                        versionArg = "-v ${params.VERSION_OVERRIDE.trim()}"
                    }
                    def cleanArg = params.CLEAN_BUILD ? '-c' : ''
                    sh """
                        export PATH="/opt/homebrew/bin:/usr/local/bin:\$FLUTTER_HOME/bin:\$HOME/.rbenv/shims:\$HOME/.rvm/bin:\$PATH"
                        ./jenkins_build.sh -t aab -m ${params.BUILD_MODE} ${versionArg} ${cleanArg}
                    """
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: "output/${APP_NAME}-*.aab", fingerprint: true
                }
            }
        }

        stage('Build iOS') {
            when {
                expression { 
                    params.BUILD_TARGET in ['all', 'ios'] 
                }
            }
            stages {
                stage('Check iOS Signing') {
                    steps {
                        script {
                            // 检查手动签名配置
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$FLUTTER_HOME/bin:$HOME/.rbenv/shims:$HOME/.rvm/bin:$PATH"
                                echo "检查可用的签名身份..."
                                security find-identity -v -p codesigning || true
                                
                                echo "检查已安装的描述文件..."
                                ls -la ~/Library/MobileDevice/Provisioning\\ Profiles/ 2>/dev/null || echo "描述文件目录为空或不存在"
                            '''
                        }
                    }
                }

                stage('Prepare iOS Signing') {
                    steps {
                        sh '''
                            export PATH="/opt/homebrew/bin:/usr/local/bin:$FLUTTER_HOME/bin:$HOME/.rbenv/shims:$HOME/.rvm/bin:$PATH"
                            export BUNDLE_ID=com.qualrb.scoreBoardPro
                            export IOS_PROVISIONING_PROFILE=scoreboard
                            ./jenkins_ios_signing_setup.sh
                        '''
                    }
                }

                stage('Install CocoaPods') {
                    steps {
                        dir('ios') {
                            sh '''
                                # 设置 UTF-8 编码 - CocoaPods 要求
                                export LANG=en_US.UTF-8
                                export LC_ALL=en_US.UTF-8
                                
                                echo "安装 CocoaPods 依赖..."
                                
                                # 确保 pod 在 PATH 中
                                if ! command -v pod &> /dev/null; then
                                    echo "在常见位置查找 CocoaPods..."
                                    if [ -f "/opt/homebrew/bin/pod" ]; then
                                        export PATH="/opt/homebrew/bin:$PATH"
                                    elif [ -f "/usr/local/bin/pod" ]; then
                                        export PATH="/usr/local/bin:$PATH"
                                    else
                                        echo "错误: CocoaPods 未找到，无法构建 iOS"
                                        exit 1
                                    fi
                                fi
                                
                                echo "使用 CocoaPods: $(which pod)"
                                echo "版本: $(pod --version)"
                                echo ""
                                
                                # 执行 pod install
                                pod install --repo-update || pod install
                            '''
                        }
                    }
                }

                stage('Build IPA') {
                    steps {
                        script {
                            def versionSource = params.VERSION_OVERRIDE?.trim() ?: env.APP_VERSION
                            def versionParts = versionSource.split('\\+')
                            def versionName = versionParts[0]
                            def versionCode = versionParts.size() > 1 ? versionParts[1] : BUILD_NUMBER
                            def buildArgs = "--${params.BUILD_MODE} --build-name=${versionName} --build-number=${versionCode}"
                            
                            sh """
                                export PATH="/opt/homebrew/bin:/usr/local/bin:\$FLUTTER_HOME/bin:\$HOME/.rbenv/shims:\$HOME/.rvm/bin:\$PATH"
                                flutter build ipa ${buildArgs} --export-options-plist=ios/ExportOptions.plist
                                
                                # 复制 IPA 到输出目录
                                IPA_PATH=\$(find build/ios/ipa -name "*.ipa" -type f | head -1)
                                if [ -n "\$IPA_PATH" ]; then
                                    cp "\$IPA_PATH" output/${APP_NAME}-${env.APP_VERSION}.ipa
                                fi
                            """
                        }
                    }
                    post {
                        success {
                            archiveArtifacts artifacts: "output/${APP_NAME}-*.ipa", fingerprint: true
                        }
                    }
                }
            }
        }

        stage('Generate Build Report') {
            steps {
                script {
                    def reportContent = """
==============================================
Score Board - 构建报告
==============================================

构建信息:
  - 构建号: ${BUILD_NUMBER}
  - 版本: ${env.APP_VERSION}
  - 目标平台: ${params.BUILD_TARGET}
  - 构建模式: ${params.BUILD_MODE}
  - 分支: ${env.GIT_BRANCH ?: 'N/A'}
  - 提交: ${env.GIT_COMMIT?.take(8) ?: 'N/A'}

输出文件:
"""
                    writeFile file: 'output/build-report.txt', text: reportContent
                    
                    sh '''
                        echo "" >> output/build-report.txt
                        ls -lh output/ >> output/build-report.txt || true
                        echo "" >> output/build-report.txt
                        echo "=============================================="  >> output/build-report.txt
                        cat output/build-report.txt
                    '''
                }
            }
        }

        stage('Upload to App Store') {
            when {
                expression { 
                    params.UPLOAD_TO_STORE && params.BUILD_TARGET in ['all', 'ios'] 
                }
            }
            steps {
                sh """
                    export PATH="/opt/homebrew/bin:/usr/local/bin:\$FLUTTER_HOME/bin:\$HOME/.rbenv/shims:\$HOME/.rvm/bin:\$PATH"
                    ./jenkins_build.sh -t ios --upload-only
                """
            }
        }

        stage('Upload to Google Play') {
            when {
                expression { 
                    params.UPLOAD_TO_STORE && params.BUILD_TARGET in ['all', 'android', 'aab'] 
                }
            }
            steps {
                script {
                    echo "上传 AAB 到 Google Play Store..."
                    echo "发布轨道: ${params.GOOGLE_PLAY_TRACK}"
                    
                    sh """
                        export PATH="/opt/homebrew/bin:/usr/local/bin:\$FLUTTER_HOME/bin:\$PATH"
                        ./jenkins_build.sh -t aab --upload-only --track ${params.GOOGLE_PLAY_TRACK}
                    """
                }
            }
        }

        stage('Upload APK to Tencent COS') {
            when {
                expression { 
                    params.UPLOAD_TO_STORE && params.BUILD_TARGET in ['all', 'android', 'apk'] 
                }
            }
            steps {
                script {
                    echo "上传 APK 到腾讯云 COS..."
                    
                    // 检查并安装 coscmd
                    sh '''
                        echo "检查腾讯云 COS 上传依赖..."
                        
                        if ! command -v coscmd &> /dev/null; then
                            echo "coscmd 未安装，正在自动安装..."
                            pip3 install --user --break-system-packages coscmd
                            export PATH="$HOME/.local/bin:$HOME/Library/Python/3.9/bin:$HOME/Library/Python/3.10/bin:$HOME/Library/Python/3.11/bin:$PATH"
                            echo "coscmd 安装完成"
                        else
                            echo "coscmd 已就绪"
                        fi
                    '''
                    
                    // 配置并上传（清除代理设置，腾讯云走直连）
                    sh """
                        # 添加 Python bin 到 PATH
                        export PATH="\$HOME/.local/bin:\$HOME/Library/Python/3.9/bin:\$HOME/Library/Python/3.10/bin:\$HOME/Library/Python/3.11/bin:\$PATH"
                        
                        # 清除代理设置 - 腾讯云是国内服务，不需要走代理
                        unset HTTP_PROXY
                        unset HTTPS_PROXY
                        unset http_proxy
                        unset https_proxy
                        unset ALL_PROXY
                        unset all_proxy
                        echo "已清除代理设置，腾讯云 COS 将使用直连"
                        
                        if [ -f "${JENKINS_SECRETS_FILE}" ]; then
                            set -a
                            source "${JENKINS_SECRETS_FILE}"
                            set +a
                        fi
                        
                        if [ -z "\${TENCENT_SECRET_ID:-}" ] || [ -z "\${TENCENT_SECRET_KEY:-}" ]; then
                            echo "错误: 未配置 TENCENT_SECRET_ID / TENCENT_SECRET_KEY"
                            echo "请在 Jenkins 环境变量或 ${JENKINS_SECRETS_FILE} 中设置"
                            exit 1
                        fi
                        
                        # 配置 coscmd
                        coscmd config \\
                            -a ${TENCENT_SECRET_ID} \\
                            -s ${TENCENT_SECRET_KEY} \\
                            -b ${COS_BUCKET} \\
                            -r ${COS_REGION}
                        
                        # 上传 arm64 主包（排除 armeabi-v7a 备用包）
                        APK_FILE=\$(find output -name "*.apk" ! -name "*armeabi-v7a*" -type f | head -1)
                        if [ -n "\$APK_FILE" ]; then
                            APK_NAME=\$(basename "\$APK_FILE")
                            echo "上传文件: \$APK_FILE"
                            echo "目标路径: /${COS_BUCKET_PATH}/\$APK_NAME"
                            
                            coscmd upload "\$APK_FILE" "/${COS_BUCKET_PATH}/\$APK_NAME"
                            
                            DOWNLOAD_URL="https://${COS_BUCKET}.cos.${COS_REGION}.myqcloud.com/${COS_BUCKET_PATH}/\$APK_NAME"
                            echo "上传成功!"
                            echo "下载链接: \$DOWNLOAD_URL"
                            echo "\$DOWNLOAD_URL" > output/apk_download_url.txt
                        else
                            echo "未找到 APK 文件"
                            exit 1
                        fi
                    """
                }
            }
        }
    }

    post {
        always {
            // 清理工作空间中的临时文件
            sh '''
                rm -rf build/ios/archive || true
                rm -rf build/app/intermediates || true
            '''
        }
        
        success {
            echo '构建成功!'
            archiveArtifacts artifacts: 'output/**/*', fingerprint: true
            
            // 可选：发送通知
            script {
                if (env.SLACK_WEBHOOK_URL) {
                    slackSend(
                        color: 'good',
                        message: "构建成功: ${currentBuild.displayName}\n版本: ${env.APP_VERSION}\n${BUILD_URL}"
                    )
                }
            }
        }
        
        failure {
            echo '构建失败!'
            
            // 可选：发送失败通知
            script {
                if (env.SLACK_WEBHOOK_URL) {
                    slackSend(
                        color: 'danger',
                        message: "构建失败: ${currentBuild.displayName}\n${BUILD_URL}"
                    )
                }
            }
        }
        
    }
}
