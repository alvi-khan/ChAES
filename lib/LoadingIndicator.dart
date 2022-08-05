import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key, required this.current, required this.total}) : super(key: key);
  final int current, total;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Processing File(s)  $current / $total',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20)
            ),
            const SizedBox(height: 20),
            SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                    color: Colors.blueGrey.shade400,
                    strokeWidth: 5
                )
            ),
          ],
        )
    );
  }
}