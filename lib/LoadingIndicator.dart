import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                'Processing File(s)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20)
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