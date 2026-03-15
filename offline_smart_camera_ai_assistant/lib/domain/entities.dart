import 'package:collection/collection.dart';

enum ChatRole { user, assistant }

class BoundingBox {
  const BoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  factory BoundingBox.full() => const BoundingBox(
        left: 0,
        top: 0,
        width: 1,
        height: 1,
      );

  Map<String, dynamic> toMap() => {
        'left': left,
        'top': top,
        'width': width,
        'height': height,
      };

  factory BoundingBox.fromMap(Map<String, dynamic> map) => BoundingBox(
        left: (map['left'] as num).toDouble(),
        top: (map['top'] as num).toDouble(),
        width: (map['width'] as num).toDouble(),
        height: (map['height'] as num).toDouble(),
      );
}

class KnowledgeEntry {
  KnowledgeEntry({
    required this.name,
    required this.category,
    required this.description,
    required this.nutrition,
    required this.growthTips,
    required this.healthInfo,
    required this.season,
  });

  final String name;
  final String category;
  final String description;
  final String nutrition;
  final String growthTips;
  final String healthInfo;
  final String season;

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'description': description,
        'nutrition': nutrition,
        'growth_tips': growthTips,
        'health_info': healthInfo,
        'season': season,
      };

  factory KnowledgeEntry.fromMap(Map<String, dynamic> map) => KnowledgeEntry(
        name: map['name'] as String,
        category: map['category'] as String,
        description: map['description'] as String,
        nutrition: map['nutrition'] as String? ?? '',
        growthTips: map['growth_tips'] as String? ?? '',
        healthInfo: map['health_info'] as String? ?? '',
        season: map['season'] as String? ?? '',
      );
}

class DetectedObject {
  DetectedObject({
    required this.name,
    required this.confidence,
    required this.boundingBox,
    this.knowledge,
  });

  final String name;
  final double confidence;
  final BoundingBox boundingBox;
  final KnowledgeEntry? knowledge;

  DetectedObject copyWith({KnowledgeEntry? knowledge}) {
    return DetectedObject(
      name: name,
      confidence: confidence,
      boundingBox: boundingBox,
      knowledge: knowledge ?? this.knowledge,
    );
  }
}

class DetectionSession {
  DetectionSession({
    required this.id,
    required this.imagePath,
    required this.objectName,
    required this.confidence,
    required this.createdAt,
  });

  final String id;
  final String imagePath;
  final String objectName;
  final double confidence;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'image_path': imagePath,
        'object_name': objectName,
        'confidence': confidence,
        'created_at': createdAt.toIso8601String(),
      };

  factory DetectionSession.fromMap(Map<String, dynamic> map) => DetectionSession(
        id: map['id'] as String,
        imagePath: map['image_path'] as String,
        objectName: map['object_name'] as String,
        confidence: (map['confidence'] as num).toDouble(),
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final ChatRole role;
  final String content;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'session_id': sessionId,
        'role': role.name,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        sessionId: map['session_id'] as String,
        role: ChatRole.values
            .firstWhereOrNull((role) => role.name == map['role']) ??
        ChatRole.user,
        content: map['content'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class ConversationContext {
  ConversationContext({
    required this.objectName,
    required this.knowledge,
    required this.messages,
  });

  final String objectName;
  final KnowledgeEntry? knowledge;
  final List<ChatMessage> messages;
}
