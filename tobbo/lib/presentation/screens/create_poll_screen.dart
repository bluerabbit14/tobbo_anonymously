import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tobbo/core/constants/app_limits.dart';
import 'package:Tobbo/core/constants/app_radii.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/router/app_routes.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';
import 'package:Tobbo/presentation/app_scope.dart';
import 'package:Tobbo/presentation/widgets/empty_state.dart';
import 'package:Tobbo/presentation/widgets/tobbo_button.dart';
import 'package:Tobbo/presentation/widgets/tobbo_loader.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _question = TextEditingController();
  final _options = [TextEditingController(), TextEditingController()];
  bool _nearby = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _question.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canPost {
    if (_question.text.trim().isEmpty) return false;
    if (_options.length < AppLimits.minOptions) return false;
    return _options.every((c) => c.text.trim().isNotEmpty);
  }

  String? get _validationHint {
    if (_question.text.isNotEmpty && _question.text.trim().isEmpty) return 'Add a question.';
    if (_options.any((c) => c.text.isNotEmpty) && _options.any((c) => c.text.trim().isEmpty)) {
      return "Option can't be empty.";
    }
    return _error;
  }

  Future<void> _post() async {
    if (!_canPost) return;
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      final poll = await context.pollStore.createPoll(
        question: _question.text,
        options: _options.map((c) => c.text).toList(),
        shareWithNearby: _nearby,
      );
      if (!mounted) return;
      context.pushReplacement(AppRoutes.poll(poll.publicCode));
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.sm, AppSpacing.pagePadding, AppSpacing.xxl),
              children: [
            ScreenHeader(title: 'Ask Tobbo', onBack: () => context.pop()),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'What do you need an honest answer to?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Your question', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _question,
              maxLength: AppLimits.maxQuestionLength,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                counterText: '${_question.text.length} / ${AppLimits.maxQuestionLength}',
                filled: true,
                fillColor: palette.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.input)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Options', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < _options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TextField(
                  controller: _options[i],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '${i + 1}',
                    filled: true,
                    fillColor: palette.surface,
                    suffixIcon: _options.length > AppLimits.minOptions
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _options.removeAt(i).dispose();
                              });
                            },
                            icon: const Icon(Icons.close, size: 18),
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.input)),
                  ),
                ),
              ),
            if (_options.length < AppLimits.maxOptions)
              TextButton(
                onPressed: () => setState(() => _options.add(TextEditingController())),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Add option'),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _nearby,
              onChanged: (value) => setState(() => _nearby = value),
              title: const Text('Share with people nearby'),
            ),
            Text(
              'Your question appears in the nearby feed. Your identity never does.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_validationHint != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_validationHint!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: AppSpacing.xl),
            TobboButton(
              label: _submitting ? 'Posting…' : 'Post anonymously',
              onPressed: _canPost && !_submitting ? _post : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'Posted anonymously. No names, no profiles.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
            ),
          ),
          if (_submitting) const TobboLoadingOverlay(),
        ],
      ),
    );
  }
}
