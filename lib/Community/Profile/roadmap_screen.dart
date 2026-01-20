import 'package:flutter/material.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roadmap')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _Phase(
              title: 'Phase 1 — Community Core (now)',
              body:
                  'Onboarding, activities, contribution logging, impact dashboard, recognition, announcements, notifications.',
              done: true,
            ),
            _Phase(
              title: 'Phase 2 — Trust & Transparency',
              body:
                  'Stronger moderation tools, export/reporting, advanced impact models, better anti-spam controls.',
              done: false,
            ),
            _Phase(
              title: 'Phase 3 — Cardano Verification (planned)',
              body:
                  'Optional proofs of contribution and verifiable impact snapshots. Preview UX is included; real integration is not implemented in this build.',
              done: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _Phase extends StatelessWidget {
  final String title;
  final String body;
  final bool done;

  const _Phase({required this.title, required this.body, required this.done});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(done ? Icons.check_circle_outline : Icons.timelapse),
        title: Text(title),
        subtitle: Text(body),
      ),
    );
  }
}
