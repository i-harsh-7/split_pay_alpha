import 'package:flutter/material.dart';
import '../components/header.dart';

class ManuallyAddPage extends StatefulWidget {
  final String groupId;
  final List<Map<String, String>> members;

  const ManuallyAddPage({
    super.key,
    required this.groupId,
    required this.members,
  });

  @override
  State<ManuallyAddPage> createState() => _ManuallyAddPageState();
}

class _ManuallyAddPageState extends State<ManuallyAddPage> {
  String? _selectedPaidBy;
  String _splitMethod = 'Equally'; // 'Equally' or 'By Items'
  final TextEditingController _totalAmountController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  Map<String, bool> _selectedMembers = {};
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize all members as selected by default for equally split
    for (var member in widget.members) {
      _selectedMembers[member['email']!] = true;
    }
    // Set first member as default payer
    if (widget.members.isNotEmpty) {
      _selectedPaidBy = widget.members[0]['email'];
    }
  }

  void _calculateEqualSplit() {
    if (_totalAmountController.text.isEmpty) return;

    try {
      _totalAmount = double.parse(_totalAmountController.text);
      final selectedCount = _selectedMembers.values.where((v) => v).length;

      if (selectedCount > 0) {
        setState(() {});
      }
    } catch (e) {
      // Invalid amount
    }
  }

  void _addItem() {
    final TextEditingController itemNameController = TextEditingController();
    final TextEditingController itemPriceController = TextEditingController();
    String? selectedMember = widget.members.isNotEmpty ? widget.members[0]['email'] : null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: Theme.of(context).primaryColor),
                  SizedBox(width: 12),
                  Text('Add Item'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Item Name', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    TextField(
                      controller: itemNameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Pizza',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    SizedBox(height: 16),

                    Text('Item Price', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    TextField(
                      controller: itemPriceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    SizedBox(height: 16),

                    Text('Taken By', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMember,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down),
                          items: widget.members.map((member) {
                            return DropdownMenuItem<String>(
                              value: member['email'],
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(member['avatar']!),
                                  ),
                                  SizedBox(width: 12),
                                  Text(member['name']!),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedMember = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (itemNameController.text.isEmpty ||
                        itemPriceController.text.isEmpty ||
                        selectedMember == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    try {
                      final price = double.parse(itemPriceController.text);
                      final memberData = widget.members.firstWhere(
                            (m) => m['email'] == selectedMember,
                      );

                      setState(() {
                        _items.add({
                          'name': itemNameController.text,
                          'price': price,
                          'takenBy': selectedMember,
                          'takenByName': memberData['name'],
                          'takenByAvatar': memberData['avatar'],
                        });

                        // Update total amount
                        _totalAmount = _items.fold(0.0, (sum, item) => sum + item['price']);
                        _totalAmountController.text = _totalAmount.toStringAsFixed(2);
                      });

                      Navigator.of(ctx).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid price'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Add Item'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _totalAmount = _items.fold(0.0, (sum, item) => sum + item['price']);
      _totalAmountController.text = _items.isEmpty ? '' : _totalAmount.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final isDark = theme.brightness == Brightness.dark;

    final selectedCount = _selectedMembers.values.where((v) => v).length;
    final splitAmount = (_totalAmount > 0 && selectedCount > 0)
        ? _totalAmount / selectedCount
        : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Header(
            title: 'Add Manually',
            heightFactor: 0.12,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Paid By Section
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paid By',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  border: Border.all(
                                    color: theme.primaryColor.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedPaidBy,
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
                                    items: widget.members.map((member) {
                                      return DropdownMenuItem<String>(
                                        value: member['email'],
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundImage: NetworkImage(member['avatar']!),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              member['name']!,
                                              style: TextStyle(color: textColor),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPaidBy = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),

                        // Split Method Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Split Method',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _splitMethod = 'Equally';
                                            _items.clear();
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _splitMethod == 'Equally'
                                                ? theme.primaryColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Equally',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _splitMethod == 'Equally'
                                                  ? Colors.white
                                                  : textColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _splitMethod = 'By Items';
                                            _totalAmountController.clear();
                                            _totalAmount = 0.0;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _splitMethod == 'By Items'
                                                ? theme.primaryColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'By Items',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _splitMethod == 'By Items'
                                                  ? Colors.white
                                                  : textColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Total Amount Section
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _totalAmountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      readOnly: _splitMethod == 'By Items',
                      onChanged: (value) => _calculateEqualSplit(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: '\$\$\$\$\$',
                        hintStyle: TextStyle(
                          color: textColor.withOpacity(0.3),
                          fontSize: 24,
                        ),
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),

                    SizedBox(height: 28),

                    // By Items - Add Items Button
                    if (_splitMethod == 'By Items') ...[
                      OutlinedButton.icon(
                        onPressed: _addItem,
                        icon: Icon(Icons.add),
                        label: Text('Add Items'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(color: theme.primaryColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Display Added Items
                      if (_items.isNotEmpty) ...[
                        Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        ..._items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(item['takenByAvatar']),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        item['takenByName'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textColor.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹ ${item['price'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.close, size: 20, color: Colors.red),
                                  onPressed: () => _removeItem(index),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 16),
                      ],
                    ],

                    // Members Section (Equally Split)
                    if (_splitMethod == 'Equally') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Members',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              bool allSelected = _selectedMembers.values.every((v) => v);
                              setState(() {
                                for (var key in _selectedMembers.keys) {
                                  _selectedMembers[key] = !allSelected;
                                }
                              });
                            },
                            child: Text('Include All'),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      ...widget.members.map((member) {
                        final email = member['email']!;
                        final isSelected = _selectedMembers[email] ?? false;

                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryColor.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMembers[email] = value ?? false;
                                  });
                                },
                                activeColor: theme.primaryColor,
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(member['avatar']!),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  member['name']!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Text(
                                isSelected ? '₹ ${splitAmount.toStringAsFixed(2)}' : '₹ 0',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],

                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Submit bill logic
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bill added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: Text(
            'Add Bill',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    super.dispose();
  }
}
