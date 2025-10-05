// widgets/tree_list_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:verify_clone/domain/entities/tree_items.dart';

class TreeListSection extends StatelessWidget {
  final List<TreeItem> items;
  final VoidCallback? onViewAll;
  final void Function(TreeItem)? onItemTap;

  const TreeListSection({
    super.key,
    required this.items,
    this.onViewAll,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final latest3 = [...items]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final visible = latest3.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tree List',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < visible.length; i++) ...[
          _TreeTile(
            key: ValueKey(visible[i].id),
            item: visible[i],
            onTap: () => onItemTap?.call(visible[i]),
          ),
          if (i != visible.length - 1) const Divider(height: 1),
        ],
        const SizedBox(height: 6),
        InkWell(
          onTap: onViewAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View Full Tree List',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_right_alt, size: 18, color: Colors.blue),
            ],
          ),
        ),
      ],
    );
  }
}

class _TreeTile extends StatelessWidget {
  final TreeItem item;
  final VoidCallback? onTap;
  const _TreeTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy hh:mm a').format(item.updatedAt);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFEAF5E8),
              child: Text(
                '${item.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusPill(status: item.status),
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final TreeStatus status;
  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color fg;
    late final Color bg;
    late final IconData icon;
    late final String label;

    switch (status) {
      case TreeStatus.verified:
        fg = const Color(0xFF16A34A);
        bg = const Color(0x3316A34A);
        icon = Icons.check_circle;
        label = 'Verified';
        break;
      case TreeStatus.pending:
        fg = const Color(0xFFF59E0B);
        bg = const Color(0x33F59E0B);
        icon = Icons.access_time;
        label = 'Pending';
        break;
      case TreeStatus.invalid:
        fg = const Color(0xFFEF4444);
        bg = const Color(0x33EF4444);
        icon = Icons.error_outline;
        label = 'Invalid';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
