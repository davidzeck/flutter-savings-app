import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_item.g.dart';

/// Status enum for dashboard items
enum ItemStatus {
  @JsonValue('active')
  active,
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

/// Priority enum for dashboard items
enum ItemPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

/// Dashboard item data model
///
/// Represents a single item displayed on the dashboard.
/// Supports JSON serialization for API communication and local caching.
@JsonSerializable()
class DashboardItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final ItemStatus status;
  final ItemPriority priority;

  /// Category label (e.g., "Operations", "Finance", "HR")
  final String category;

  /// Assigned user name
  @JsonKey(name: 'assigned_to')
  final String? assignedTo;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  /// Progress percentage (0-100)
  final int progress;

  const DashboardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    this.assignedTo,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.progress = 0,
  });

  factory DashboardItem.fromJson(Map<String, dynamic> json) =>
      _$DashboardItemFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardItemToJson(this);

  /// Check if item is overdue
  bool get isOverdue {
    if (dueDate == null) return false;
    if (status == ItemStatus.completed || status == ItemStatus.cancelled) {
      return false;
    }
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if item is high priority or urgent
  bool get isHighPriority =>
      priority == ItemPriority.high || priority == ItemPriority.urgent;

  DashboardItem copyWith({
    String? id,
    String? title,
    String? description,
    ItemStatus? status,
    ItemPriority? priority,
    String? category,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    int? progress,
  }) {
    return DashboardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        category,
        assignedTo,
        createdAt,
        updatedAt,
        dueDate,
        progress,
      ];

  @override
  String toString() => 'DashboardItem(id: $id, title: $title, status: $status)';
}
