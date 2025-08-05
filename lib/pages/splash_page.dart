import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/routes/app_routes.dart';
import 'dart:math' as math;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  late AnimationController _particleController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _loadingRotationAnimation;
  late Animation<double> _particleAnimation;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    // 初始化粒子
    _initParticles();
    
    // 初始化动画控制器
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // 设置动画
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    ));
    
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
    
    _loadingRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
    
    // 启动动画序列
    _startAnimationSequence();
  }

  void _initParticles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: random.nextDouble() * 400,
        y: random.nextDouble() * 800,
        size: random.nextDouble() * 4 + 2,
        speed: random.nextDouble() * 2 + 1,
        angle: random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  void _startAnimationSequence() async {
    // 1. 启动粒子动画
    _particleController.forward();
    
    // 2. 启动Logo动画
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // 3. 延迟后启动文字动画
    await Future.delayed(const Duration(milliseconds: 1000));
    _textController.forward();
    
    // 4. 延迟后启动加载动画
    await Future.delayed(const Duration(milliseconds: 800));
    _loadingController.repeat();
    
    // 5. 延迟后跳转到主页面
    await Future.delayed(const Duration(milliseconds: 2500));
    _navigateToMain();
  }

  void _navigateToMain() {
    Get.offAllNamed(AppRoutes.mainTab);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF66BB6A),
              Color(0xFF81C784),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 粒子背景
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    animation: _particleAnimation.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            
            // 主要内容
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Logo区域
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Opacity(
                          opacity: _logoOpacityAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 25,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sports_score,
                              color: Colors.white,
                              size: 70,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // 应用名称
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'app_name_pro'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'app_description'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // 加载动画
                  AnimatedBuilder(
                    animation: _loadingController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _loadingRotationAnimation.value * 2 * math.pi,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(21),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // 加载文字
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: Text(
                          'loading'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  // 底部版本信息
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double angle;
  
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;
  
  ParticlePainter({
    required this.particles,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      final x = particle.x + math.cos(particle.angle) * particle.speed * animation * 50;
      final y = particle.y + math.sin(particle.angle) * particle.speed * animation * 50;
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 - animation * 0.5),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 