import 'package:flutter/material.dart';

class ReauthPasswordDialog extends StatefulWidget {
  const ReauthPasswordDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ReauthPasswordDialog(),
    );
  }

  @override
  State<ReauthPasswordDialog> createState() => _ReauthPasswordDialogState();
}

class _ReauthPasswordDialogState extends State<ReauthPasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Re-authenticate'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _passwordController,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'Current password',
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _submitting = true);
                  Navigator.of(context).pop(_passwordController.text);
                },
          child: _submitting
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Continue'),
        ),
      ],
    );
  }
}


