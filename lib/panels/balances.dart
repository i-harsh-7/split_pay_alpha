import 'package:flutter/material.dart';
import '../components/header.dart'; // Make sure to use the path to your Header widget

class BalancesPanel extends StatelessWidget {
  const BalancesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color textPrimary = theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final Color cardColor = theme.cardColor;
    final Color owedColor = theme.brightness == Brightness.dark ? Colors.red[300]! : Colors.redAccent;
    final Color owingColor = theme.brightness == Brightness.dark ? Colors.greenAccent : Colors.green;

    return Scaffold(
      body: Column(
        children: [
          Header(
            title: "Your Balances",
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  Text("You Owe",
                                      style: TextStyle(
                                          color: owedColor, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹ 200",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  Text("You are Owed",
                                      style: TextStyle(
                                          color: owingColor, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹ 200",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        "Detailed balances will appear here",
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
