import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget {
  final List<String> columns;
  final List<DataRow> rows;
  final bool isLoading;
  final String? emptyMessage;
  final Widget? loadingWidget;
  final double? maxHeight;
  final ScrollController? scrollController;

  const TableWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.emptyMessage,
    this.loadingWidget,
    this.maxHeight,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: loadingWidget ?? const CircularProgressIndicator(),
      );
    }

    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_rows_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'Aucune donnée disponible',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }

    final table = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            return Theme.of(context).colorScheme.surface;
          },
        ),
        dataRowColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
            }
            if (states.contains(WidgetState.hovered)) {
              return Theme.of(context).colorScheme.onSurface.withOpacity(0.04);
            }
            return Theme.of(context).colorScheme.surface;
          },
        ),
        columns: columns.map((column) {
          return DataColumn(
            label: Text(
              column,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          );
        }).toList(),
        rows: rows,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: maxHeight != null
            ? SizedBox(
                height: maxHeight,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: table,
                ),
              )
            : table,
      ),
    );
  }
}