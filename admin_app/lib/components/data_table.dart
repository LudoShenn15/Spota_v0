import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final Function(int)? onEdit;
  final Function(int)? onDelete;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Theme.of(context).primaryColor.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              dataRowHeight: 48,
              headingRowHeight: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              columns: columns
                  .map((column) => DataColumn(
                        label: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            column,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              rows: List<DataRow>.generate(
                rows.length,
                (index) => DataRow(
                  cells: List<DataCell>.generate(
                    rows[index].length,
                    (cellIndex) => DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Text(
                          rows[index][cellIndex],
                          style: TextStyle(
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                  )..addAll([
                      if (onEdit != null)
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                            onPressed: () => onEdit!(index),
                          ),
                        ),
                      if (onDelete != null)
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade400),
                            onPressed: () => onDelete!(index),
                          ),
                        ),
                    ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}