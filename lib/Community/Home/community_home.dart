import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/user.dart';
import '../../Services/Community/community_service.dart';
import '../../Shared/theme/app_theme.dart';
import '../Activities/activities_list.dart';
import '../Impact/impact_dashboard.dart';
import '../Profile/profile_screen.dart';
import '../Map/map.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  int _index = 0;

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final trimmed = name.trim();
    final words = trimmed.split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return (words[0][0] + words[words.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = Provider.of<F_User?>(context);

    final pages = [
      _HomeTab(
        userId: user?.uid,
        onJoinActivity: () => setState(() => _index = 1),
        onLogContribution: () {
          Navigator.pushNamed(context, '/contributions/log');
        },
        onViewImpact: () => setState(() => _index = 2),
      ),
      const ActivitiesListScreen(embedded: true),
      const ImpactDashboardScreen(embedded: true),
      const MapScreen(),
      const ProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 68,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.eco_outlined,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
          ),
          title: Text(
            'Canopy',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.darkGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.darkGreen,
                    size: 24,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Builder(
                builder: (context) {
                  final userName = "Community Member";
                  final initials = _getInitials(userName);

                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials.isNotEmpty ? initials : '?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: pages[_index],
        floatingActionButton: _index != 1 || user == null
            ? null
            : FutureBuilder<String?>(
                future: CommunityService().getUserRole(userId: user.uid),
                builder: (context, snapshot) {
                  final role = snapshot.data ?? 'Member';
                  final isOrganizer = role == 'Organizer';
                  if (!isOrganizer) return const SizedBox.shrink();

                  return FloatingActionButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/activities/create'),
                    backgroundColor: AppTheme.tertiary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    child: const Icon(Icons.add, size: 28),
                  );
                },
              ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: NavigationBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              indicatorColor: AppTheme.primary.withOpacity(0.15),
              height: 70,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: AppTheme.darkGreen.withOpacity(0.5)),
                  selectedIcon: Icon(Icons.home, color: AppTheme.primary),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_note_outlined, color: AppTheme.darkGreen.withOpacity(0.5)),
                  selectedIcon: Icon(Icons.event_note, color: AppTheme.primary),
                  label: 'Activities',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined, color: AppTheme.darkGreen.withOpacity(0.5)),
                  selectedIcon: Icon(Icons.analytics, color: AppTheme.primary),
                  label: 'Impact',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined, color: AppTheme.darkGreen.withOpacity(0.5)),
                  selectedIcon: Icon(Icons.map, color: AppTheme.primary),
                  label: 'Map',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: AppTheme.darkGreen.withOpacity(0.5)),
                  selectedIcon: Icon(Icons.person, color: AppTheme.primary),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String? userId;
  final VoidCallback onJoinActivity;
  final VoidCallback onLogContribution;
  final VoidCallback onViewImpact;

  const _HomeTab({
    required this.userId,
    required this.onJoinActivity,
    required this.onLogContribution,
    required this.onViewImpact,
  });

  @override
  Widget build(BuildContext context) {
    return _HomeTabBody(
      userId: userId,
      onJoinActivity: onJoinActivity,
      onLogContribution: onLogContribution,
      onViewImpact: onViewImpact,
    );
  }
}

class _HomeTabBody extends StatefulWidget {
  final String? userId;
  final VoidCallback onJoinActivity;
  final VoidCallback onLogContribution;
  final VoidCallback onViewImpact;

  const _HomeTabBody({
    required this.userId,
    required this.onJoinActivity,
    required this.onLogContribution,
    required this.onViewImpact,
  });

  @override
  State<_HomeTabBody> createState() => _HomeTabBodyState();
}

class _HomeTabBodyState extends State<_HomeTabBody> {
  int _feedLimit = 3;

  // Dummy news data
  final List<Map<String, dynamic>> _communityNews = [
    {
      'title': 'New Recycling Center Opens in Kibera',
      'description': 'Community members can now drop off sorted materials at the new facility on Olympic Estate Road.',
      'image': 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400',
      'date': '2 days ago',
    },
    {
      'title': 'Beach Cleanup Collects 2 Tons of Waste',
      'description': 'Volunteers gathered last weekend for the largest coastal cleanup event this year.',
      'image': 'https://images.unsplash.com/photo-1618477461853-cf6ed80faba5?w=400',
      'date': '1 week ago',
    },
    {
      'title': 'Blockchain Rewards Program Launches',
      'description': 'Earn ADA tokens for verified environmental contributions through our new platform.',
      'image': 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=400',
      'date': '2 weeks ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {},
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          StreamBuilder<CommunityOverview>(
            stream: CommunityService().watchOverview(),
            builder: (context, snapshot) {
              final overview = snapshot.data ??
                  const CommunityOverview(
                    activeInitiatives: 0,
                    membersParticipating: 0,
                    totalImpactPoints: 0,
                  );

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up,
                            color: Colors.white.withOpacity(0.9), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Community Impact',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Initiatives',
                            value: '${overview.activeInitiatives}',
                            icon: Icons.flag_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: 'Members',
                            value: '${overview.membersParticipating}',
                            icon: Icons.people_outline,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: 'Points',
                            value: '${overview.totalImpactPoints}',
                            icon: Icons.star_outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: 'Join Activity',
                  icon: Icons.event_available_outlined,
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: widget.onJoinActivity,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionCard(
                  title: 'Log Impact',
                  icon: Icons.add_circle_outline,
                  gradient: LinearGradient(
                    colors: [AppTheme.accent, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: widget.onLogContribution,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _QuickActionCard(
            title: 'View My Impact Dashboard',
            icon: Icons.analytics_outlined,
            gradient: LinearGradient(
              colors: [AppTheme.tertiary, Color(0xFFD4B972)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: widget.onViewImpact,
            expanded: true,
          ),
          const SizedBox(height: 26),
          
          // Community Updates Section
          Row(
            children: [
              Icon(Icons.newspaper, color: AppTheme.darkGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Community Updates',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkGreen,
                      fontSize: 18,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // News Cards
          ..._communityNews.map((news) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.lightGreen.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                    child: Container(
                      width: 90,
                      height: 90,
                      color: AppTheme.lightGreen.withOpacity(0.2),
                      child: Icon(
                        Icons.image_outlined,
                        color: AppTheme.primary.withOpacity(0.5),
                        size: 32,
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news['title'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.darkGreen,
                                  fontSize: 14,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            news['description'],
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.darkGreen.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: AppTheme.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                news['date'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 26),
          Row(
            children: [
              Icon(Icons.history, color: AppTheme.darkGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkGreen,
                      fontSize: 18,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                child: Row(
                  children: [
                    const Text('View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream:
                CommunityService().watchRecentActivityFeed(limit: _feedLimit),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const [];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                );
              }

              if (items.isEmpty) {
                return Column(
                  children: List.generate(3, (i) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreen.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_outline,
                                color: AppTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Member logged a contribution',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.darkGreen,
                                        fontSize: 13,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Just now',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.darkGreen.withOpacity(0.6),
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.tertiary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.bolt,
                                    color: AppTheme.tertiary, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    color: AppTheme.tertiary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              }

              return Column(
                children: [
                  ...items.map((item) {
                    final text = (item['text'] ?? 'New activity') as String;
                    final subtitle = (item['subtitle'] ?? 'Update') as String;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreen.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_outline,
                                color: AppTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.darkGreen,
                                        fontSize: 13,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.darkGreen.withOpacity(0.6),
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.tertiary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.bolt,
                                    color: AppTheme.tertiary, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    color: AppTheme.tertiary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool expanded;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: expanded ? 70 : 95,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: expanded
              ? Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 22, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 22, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 19,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}