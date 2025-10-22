import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: ShootingGame()));
}

class ShootingGame extends FlameGame with TapDetector, KeyboardEvents {
  late Player player;
  late Timer enemySpawner;
  int score = 0;
  late TextComponent scoreText;

  @override
  Future<void> onLoad() async {
    // Add player
    player = Player();
    add(player);

    // Add score display
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(style: TextStyle(color: Colors.white, fontSize: 24)),
    );
    add(scoreText);

    // Set up enemy spawner
    enemySpawner = Timer(2, onTick: () {
      add(Enemy());
    }, repeat: true);
    enemySpawner.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    enemySpawner.update(dt);

    // Check for collisions
    children.whereType<Bullet>().forEach((bullet) {
      children.whereType<Enemy>().forEach((enemy) {
        if (bullet.position.distanceTo(enemy.position) < 20) {
          bullet.removeFromParent();
          enemy.removeFromParent();
          score += 10;
          scoreText.text = 'Score: $score';
        }
      });
    });

    // Check if enemies hit player
    children.whereType<Enemy>().forEach((enemy) {
      if (enemy.position.distanceTo(player.position) < 30) {
        // Game over
        pauseEngine();
        add(TextComponent(
          text: 'Game Over! Final Score: $score',
          position: Vector2(size.x / 2 - 100, size.y / 2),
          textRenderer: TextPaint(style: TextStyle(color: Colors.red, fontSize: 32)),
        ));
      }
    });
  }

  @override
  void onTapDown(TapDownInfo info) {
    // Shoot bullet when tapped
    final bullet = Bullet(player.position);
    add(bullet);
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Handle keyboard input for player movement
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) {
      player.moveLeft();
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) {
      player.moveRight();
    }
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      final bullet = Bullet(player.position);
      add(bullet);
    }
    return KeyEventResult.handled;
  }
}

class Player extends PositionComponent {
  static const double speed = 200;

  @override
  void onLoad() {
    size = Vector2(50, 50);
    position = Vector2(200, 500);
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.blue));
  }

  void moveLeft() {
    position.x -= speed * 0.016; // Approximate dt
    position.x = position.x.clamp(0, 400 - size.x);
  }

  void moveRight() {
    position.x += speed * 0.016;
    position.x = position.x.clamp(0, 400 - size.x);
  }
}

class Enemy extends PositionComponent {
  static const double speed = 100;

  @override
  void onLoad() {
    size = Vector2(40, 40);
    position = Vector2((400 - size.x) * (DateTime.now().millisecondsSinceEpoch % 100) / 100, 0);
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.red));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    if (position.y > 600) {
      removeFromParent();
    }
  }
}

class Bullet extends PositionComponent {
  static const double speed = 300;

  Bullet(Vector2 startPosition) {
    position = startPosition.clone();
  }

  @override
  void onLoad() {
    size = Vector2(10, 20);
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.yellow));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= speed * dt;
    if (position.y < 0) {
      removeFromParent();
    }
  }
}