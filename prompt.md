Comprehensive Flutter App Redesign Prompt: Impact Ledger Community Platform
Project Overview
Transform the existing Impact Ledger Flutter application from a dual-role (Organization/User) incident reporting system into a modern, community-focused impact tracking platform. The redesign emphasizes community engagement, contribution logging, and transparent impact measurement with future blockchain integration readiness.
Design Philosophy & Visual Standards
Modern UI Principles

Design Language: Material Design 3 with custom community-focused theming
Visual Hierarchy: Clear, scannable layouts with purposeful use of white space
Typography System:

Display/Hero Text: 32-40sp, Weight 700 (Bold) - For splash screens and major headings
Page Titles: 24-28sp, Weight 600 (SemiBold) - For screen headers
Section Headers: 18-20sp, Weight 600 (SemiBold) - For card titles and sections
Body Text: 15-16sp, Weight 400 (Regular) - For primary content
Secondary Text: 13-14sp, Weight 400 (Regular) - For metadata and descriptions
Labels/Captions: 12sp, Weight 500 (Medium) - For form labels and tags
Button Text: 15-16sp, Weight 600 (SemiBold) - For CTAs
Font Family: Inter, SF Pro, or Roboto for cross-platform consistency



Color System

Primary Palette:

Primary: Vibrant community color (e.g., #2563EB - trust blue or #10B981 - impact green)
Primary Variant: Darker shade for emphasis
On Primary: White text on primary backgrounds


Secondary Palette: Complementary accent colors for actions and highlights
Surface Colors:

Background: #FFFFFF (light mode), #121212 (dark mode)
Surface: #F9FAFB (light mode), #1E1E1E (dark mode)
Cards: Elevated with subtle shadows (elevation 2-4dp)


Semantic Colors:

Success: #10B981 (contributions, achievements)
Warning: #F59E0B (pending actions)
Error: #EF4444 (validation issues)
Info: #3B82F6 (announcements, updates)



Component Styling

Cards: Rounded corners (12-16dp radius), subtle shadows, clear content hierarchy
Buttons:

Primary: Filled, rounded (8-12dp), min height 48dp for accessibility
Secondary: Outlined, same dimensions
Text buttons: For tertiary actions


Input Fields: Outlined style, 12dp radius, clear focus states, 48dp min height
Icons: 24dp for standard actions, 20dp for inline, 32dp+ for feature highlights
Spacing: 8dp grid system (8, 16, 24, 32, 48dp intervals)


Feature-by-Feature Implementation Requirements
1. ENTRY & COMMUNITY ONBOARDING
Screens to Build
1.1 Splash Screen

File: lib/Shared/Pages/splash_screen.dart
UI Elements:

Full-screen gradient or hero image background
Community logo (centered, 80-120dp)
Mission statement text (18sp, Weight 500, centered, max 2 lines)
Subtle loading indicator or animation
App version number (bottom, 11sp, Weight 400, 60% opacity)


Functions:

Auto-navigate after 2-3 seconds
Check authentication state
Initialize app services
Smooth fade transition to next screen



1.2 Welcome Screen

File: lib/Shared/Pages/welcome_screen.dart
UI Elements:

Hero section with compelling visual (illustrations or photos)
"Why This Matters" heading (28sp, Weight 700)
3-4 benefit cards with icons (16dp padding, 12dp radius)

Icon (32dp, primary color)
Benefit title (16sp, Weight 600)
Description (14sp, Weight 400, secondary text color)


Bottom CTA button: "Get Started" (full width minus 32dp margin)
"Already a member? Sign In" text button (14sp, Weight 500)


Functions:

Swipeable carousel (optional)
Navigate to join community screen
Link to login for existing users



1.3 Join Community Screen

File: lib/Shared/Authentication/join_community.dart
UI Elements:

Progress indicator at top (4-step process)
Form sections with clear labels:

Name/Alias field (outlined input, 48dp height)
Location/Zone dropdown or autocomplete (with map icon)
Community Role selector (radio buttons or chip group):

Member (default)
Volunteer
Organizer


Profile photo upload (optional, circular 80dp placeholder)


Helper text under each field (12sp, Weight 400, 70% opacity)
Primary CTA: "Join Community" (bottom, 56dp height)
Terms acceptance checkbox (12sp text)


Functions:

Form validation (name required, location required, role required)
Create user account with role tagging
Store in Models/community_user.dart
Service: Services/Authentication/community_auth.dart
Navigate to guidelines screen



1.4 Community Guidelines Screen

File: lib/Shared/Pages/community_guidelines.dart
UI Elements:

Scrollable content area with sections:

Title: "Community Guidelines" (24sp, Weight 700)
Guideline cards (each with icon, title 16sp Weight 600, description 14sp)
Acceptance section at bottom (sticky):

Checkbox: "I agree to follow these guidelines"
Button: "Continue to Community" (disabled until checked)






Functions:

Track guideline acceptance
Store acceptance timestamp
Navigate to community home on acceptance




2. COMMUNITY HOME (CENTRAL HUB)
Screen to Build
2.1 Community Home Screen

File: lib/Community/Home/community_home.dart
UI Elements:

App Bar (64dp height):

Community logo/name (left, 20sp Weight 600)
Notification bell icon (right, badge for unread)
Profile avatar (right, 36dp circular)


Status Banner (if prototype mode):

Amber background, 48dp height
Icon + "Prototype Mode" text (14sp Weight 500)
Dismissible


Community Overview Panel (top card, 16dp margin):

"Community Impact" header (18sp Weight 600)
3-column stat grid:

Active Initiatives (number + label, 24sp Weight 700, 13sp Weight 400)
Members Participating (number + label)
Total Impact Points (number + label)


Subtle dividers between stats


Quick Action Buttons (row of 3 cards, equal width):

"Join an Activity" (icon: calendar_add, primary color)
"Log Contribution" (icon: add_circle, success color)
"View Impact" (icon: analytics, info color)
Each card: 96dp height, icon 32dp, label 14sp Weight 600


Live Activity Feed:

Section header: "Recent Activity" (16sp Weight 600, with "View All" link)
List of activity cards (each 72dp height):

Avatar (40dp circular, left)
Activity text (14sp Weight 400, 2 lines max)
Timestamp (12sp Weight 400, 60% opacity)
Activity icon/badge (right, 20dp)


Show 5 most recent, then "Load More" button


Bottom Navigation Bar:

Home (selected)
Activities
Impact
Profile




Functions:

Fetch community overview data: Services/Community/community_service.dart
Real-time activity feed subscription (Firebase or polling)
Navigate to respective screens on quick action tap
Pull-to-refresh functionality




3. COMMUNITY ACTIVITIES & INITIATIVES
Screens to Build
3.1 Activities List Screen

File: lib/Community/Activities/activities_list.dart
UI Elements:

App Bar: "Activities" (20sp Weight 600), filter icon (right)
Filter Chips (horizontal scroll):

All, Cleanups, Events, Tasks
Selected chip: filled primary color, others outlined


Create Activity FAB (bottom right, 56dp, only for organizers):

Icon: add, primary color


Activity Cards (list, 16dp margin between):

Activity type badge (top-left corner chip, 12sp Weight 500)
Activity title (16sp Weight 600, 1-2 lines)
Location (14sp Weight 400, with location icon)
Date/Time (14sp Weight 400, with calendar icon)
Participants count (14sp Weight 400, with people icon)
Status indicator (Upcoming/Ongoing/Completed, colored dot + text)
"View Details" button (text button, 14sp Weight 600)


Empty state: Illustration + "No activities yet" (16sp Weight 500)


Functions:

Fetch activities list: Services/Activities/activity_service.dart
Filter by type
Sort by date (upcoming first)
Navigate to activity detail
Create new activity (organizers only)



3.2 Activity Detail Screen

File: lib/Community/Activities/activity_detail.dart
UI Elements:

Hero Image (full width, 240dp height, with back button overlay)
Content Scroll Area:

Activity title (24sp Weight 700)
Status chip (right-aligned)
Description section:

"About" header (18sp Weight 600)
Full description text (15sp Weight 400, formatted)


Details grid (2 columns):

Location (with map preview/link)
Date & Time
Required Participants
Current Participants


Participants section:

"Who's Joining" header (18sp Weight 600)
Horizontal avatar list (40dp each, overlap -12dp)
"+X more" text if overflow


Map preview card (if location available, 200dp height)


Bottom Action Bar (sticky, 72dp height):

If not joined: "Join Activity" button (primary, full width minus margin)
If joined: "Leave Activity" (outlined) + "Check In" (primary) buttons




Functions:

Fetch activity details by ID
Join/leave activity logic
Update participant count in real-time
Check-in functionality (location verification optional)
Share activity (native share sheet)
Service: Services/Activities/activity_service.dart



3.3 Create Activity Screen (Organizers only)

File: lib/Community/Activities/create_activity.dart
UI Elements:

Form with sections:

Activity Type selector (dropdown, 48dp height)
Title field (outlined input)
Description field (multiline, min 120dp height)
Location picker (tap to open map selection)
Date picker (with calendar icon)
Time picker
Required participants (number input)
Cover image upload (optional, 16:9 ratio)


Bottom buttons: "Cancel" (text) + "Create Activity" (primary)


Functions:

Form validation
Image upload to storage
Create activity in database
Notify community members
Reuse map selection: lib/Services/Location/map_selection.dart




4. CONTRIBUTION LOGGING (CORE INTERACTION)
Screens to Build
4.1 Log Contribution Screen

File: lib/Community/Contributions/log_contribution.dart
UI Elements:

App Bar: "Log Your Contribution" (20sp Weight 600)
Form Sections:

Activity Selection (required):

Dropdown showing user's joined activities
"Select Activity" placeholder (14sp Weight 400)


Contribution Type (required):

Radio group or segmented button:

Time (hours input)
Effort (description required)
Materials (itemized list)


Conditional inputs based on selection


Time/Duration:

If type = Time: number input with "hours" suffix
If type = Effort: text field for description


Materials (if type = Materials):

Add item button
List of items with quantity and remove option


Optional Details:

Notes field (multiline, 100dp height, 12sp placeholder)
Photo upload (up to 3 images, thumbnail preview 80dp)


Impact Indicator (auto-calculated):

"Estimated Impact: X points" (16sp Weight 600, success color)




Bottom Action: "Submit Contribution" (primary button, 56dp height)


Functions:

Fetch user's joined activities
Calculate impact points based on contribution type
Validate required fields
Upload photos to storage
Submit contribution: Services/Contributions/contribution_service.dart
Model: Models/contribution.dart
Navigate to confirmation screen



4.2 Submission Confirmation Screen

File: lib/Community/Contributions/contribution_confirmation.dart
UI Elements:

Success icon (80dp, animated checkmark, success color)
"Contribution Logged!" heading (24sp Weight 700)
Summary card:

Activity name
Contribution type
Impact points earned (24sp Weight 700, highlighted)


Encouragement text: "Thank you for making a difference!" (15sp Weight 400)
Bottom buttons:

"View My Impact" (primary)
"Log Another" (outlined)
"Back to Home" (text button)




Functions:

Display submitted contribution details
Navigate to impact dashboard
Navigate back to log contribution (reset form)
Navigate to home




5. COMMUNITY IMPACT & TRANSPARENCY
Screens to Build
5.1 Impact Dashboard Screen

File: lib/Community/Impact/impact_dashboard.dart
UI Elements:

App Bar: "Community Impact" (20sp Weight 600), filter/date range icon
Tabs: "Community" (selected) | "My Impact"
Community Tab Content:

Total Impact Card (hero section):

Large number (48sp Weight 700, primary color)
"Total Impact Points" label (16sp Weight 500)
Trend indicator (arrow + percentage, 14sp)


Quick Stats Grid (3 columns):

Actions Completed
Participation Rate (%)
Active Members
Each: number (24sp Weight 700) + label (13sp Weight 400)


Impact Indicators Section:

"Environmental Impact" card:

CO2 offset, trees planted equivalent (with icons)


"Social Impact" card:

Volunteer hours, people helped


Chart/visual representation (bar or line chart)


Recent Contributions Feed (similar to activity feed)


My Impact Tab Content:

Personal stats header (same layout as community total)
Contribution breakdown (pie or donut chart):

Time contributions
Effort contributions
Materials contributions


Achievement timeline
"Export My Data" button (outlined, bottom)




Functions:

Fetch aggregated community data
Fetch user's personal contribution data
Calculate environmental/social indicators
Data visualization using charts (charts_flutter or fl_chart)
Export user data as CSV/PDF
Service: Services/Impact/impact_service.dart
Date range filtering



5.2 Community Progress Visuals

File: lib/Community/Impact/progress_visuals.dart
UI Elements:

Timeline view:

Horizontal scrollable timeline
Milestone markers (50dp circles with icons)
Connecting lines
Milestone labels (14sp Weight 500)


Counters section:

Animated counters for key metrics
Count-up animation on screen load


Charts section:

Monthly contribution trends (line chart)
Activity type distribution (bar chart)
Member growth (area chart)


Export/Share button (top-right)


Functions:

Render interactive charts
Timeline navigation
Animation triggers
Share charts as images




6. RECOGNITION & INCENTIVES (NON-MONETARY)
Screens to Build
6.1 Badges & Recognition Screen

File: lib/Community/Recognition/badges_screen.dart
UI Elements:

App Bar: "Recognition" (20sp Weight 600)
User Header:

Profile photo (80dp circular)
Name (20sp Weight 600)
Total points (36sp Weight 700, primary color)
Current level/rank (16sp Weight 500, with icon)


Badges Grid:

Section header: "Your Badges" (18sp Weight 600)
Grid layout (2 columns on mobile, 3+ on tablet):

Badge card (aspect ratio 1:1):

Badge icon/illustration (64dp)
Badge name (14sp Weight 600)
Earned date (12sp Weight 400) or locked state


Locked badges: greyscale with lock icon overlay




Milestones Section:

"Contribution Milestones" header (18sp Weight 600)
Progress cards:

Milestone title (16sp Weight 600)
Progress bar (linear, 8dp height)
"X/Y completed" text (14sp Weight 400)
Reward preview (badge icon, 24dp)




Leaderboard Section (Optional, collapsible):

"Community Leaders" header with toggle
Top 10 list:

Rank badge (24sp Weight 700, circular)
Avatar (40dp)
Name (15sp Weight 600)
Points (14sp Weight 500, right-aligned)
Highlight current user row (subtle background)






Functions:

Fetch user badges and progress
Calculate milestone completion
Fetch leaderboard data (anonymized or opt-in)
Badge unlock animations
Service: Services/Recognition/recognition_service.dart
Model: Models/badge.dart, Models/milestone.dart



6.2 Community Acknowledgements Screen

File: lib/Community/Recognition/acknowledgements.dart
UI Elements:

List of acknowledgement cards:

Date header (sticky, 14sp Weight 600, surface color)
Acknowledgement card:

Icon (32dp, type-based color)
Message text (15sp Weight 400)
From: community name or user (13sp Weight 400)
Timestamp (12sp Weight 400, 60% opacity)




Filter options: All, From Community, From Members
Empty state: "No acknowledgements yet"


Functions:

Fetch acknowledgements for user
Mark as read
Filter functionality




7. COMMUNICATION & UPDATES
Screens to Build
7.1 Announcements Board

File: lib/Community/Communication/announcements.dart
UI Elements:

App Bar: "Announcements" (20sp Weight 600), search icon
Pinned Section (if any):

"Pinned" label (14sp Weight 600, with pin icon)
Pinned announcement cards (distinguished background)


Announcement Cards:

Priority indicator (colored left border: 4dp width)
Title (16sp Weight 600, 2 lines max)
Preview text (14sp Weight 400, 3 lines max, ellipsis)
Metadata row:

Author avatar (24dp)
Author name (13sp Weight 500)
Timestamp (12sp Weight 400)
Category chip (12sp)


Unread indicator (blue dot, 8dp)


Pull-to-refresh
"Load More" at bottom


Functions:

Fetch announcements (paginated)
Mark as read on tap
Search announcements
Navigate to full announcement view
Service: Services/Communication/announcement_service.dart



7.2 Announcement Detail Screen

File: lib/Community/Communication/announcement_detail.dart
UI Elements:

Title (24sp Weight 700)
Author info (avatar + name + role, 14sp)
Timestamp (13sp Weight 400)
Priority badge (if high priority)
Full content (15sp Weight 400, formatted text with links)
Attachments section (if any, downloadable)
Bottom action: "Got It" or "Dismiss" button


Functions:

Render formatted content (supports markdown or HTML)
Download attachments
Mark as read
Share announcement



7.3 Notification Center

File: lib/Community/Communication/notifications.dart
UI Elements:

App Bar: "Notifications" (20sp Weight 600), mark all read icon
Tabs: "All" | "Unread" | "Activity" | "System"
Notification Cards:

Icon (32dp, type-based color: activity=blue, reminder=amber, achievement=green)
Title (15sp Weight 600)
Message (14sp Weight 400, 2 lines)
Timestamp (12sp Weight 400)
Unread indicator (background highlight)
Swipe actions: "Mark Read" | "Delete"


Empty states for each tab
"Clear All" button (bottom, if notifications exist)


Functions:

Fetch notifications (filtered by tab)
Mark as read (individual or bulk)
Delete notifications
Navigate to related content on tap
Push notification handling
Service: Services/Communication/notification_service.dart




8. SETTINGS & PROJECT CONTEXT
Screens to Build
8.1 Profile & Preferences Screen

File: lib/Community/Profile/profile_screen.dart
UI Elements:

Profile Header:

Cover photo (optional, 160dp height)
Avatar (96dp circular, editable icon overlay)
Name (20sp Weight 700)
Role badge (14sp Weight 500, chip)
Member since date (13sp Weight 400)


Stats Row (3 columns):

Contributions, Points, Rank


Settings Sections (grouped lists):

Account Settings:

Edit Profile (navigation item)
Change Password
Notification Preferences


Preferences:

Language
Theme (Light/Dark/System)
Accessibility Options


Community:

Community Info
Guidelines (link)
Leaderboard Participation (toggle)


About:

Hackathon Context
Roadmap
Privacy Policy
Terms of Service


Danger Zone:

Leave Community (outlined, error color)
Delete Account (text button, error color)




Bottom: "Sign Out" button (outlined, 48dp height)


Functions:

Fetch user profile data
Navigate to edit screens
Toggle preferences (save immediately)
Handle sign out
Service: Services/Profile/profile_service.dart



8.2 Edit Profile Screen

File: lib/Community/Profile/edit_profile.dart
UI Elements:

Form fields (same styling as join community):

Name/Alias
Bio (multiline, 150dp height)
Location
Avatar upload
Cover photo upload (optional)


Save/Cancel buttons (sticky bottom)


Functions:

Pre-populate current values
Image upload
Form validation
Update profile service call
Navigate back with confirmation



8.3 Community Info Page

File: lib/Community/Settings/community_info.dart
UI Elements:

Community logo (120dp)
Community name (24sp Weight 700)
Description (15sp Weight 400)
Statistics section:

Total members
Active activities
Total impact


Mission/Vision cards
Contact information (if available)
Social links (icon buttons)


Functions:

Fetch community details
Open external links
Share community link



8.4 Hackathon Context Page

File: lib/Community/Settings/hackathon_context.dart
UI Elements:

"Built for [Hackathon Name]" header (24sp Weight 700)
Project description sections:

Problem Statement (18sp Weight 600 header)
Our Solution
Technology Stack
Team


Judge-focused callouts:

Highlighted boxes with amber/info background
"Key Feature" badges
"Future Implementation" sections


Demo credentials (if applicable, copyable text)
GitHub/Project links (buttons)


Functions:

Static content display
Copy demo credentials
Open external links
Share project



8.5 Roadmap / "What's Next" Screen

File: lib/Community/Settings/roadmap_screen.dart
UI Elements:

Timeline visualization:

Phase cards (vertical layout):

Phase number & name (20sp Weight 700)
Status indicator (Completed/In Progress/Planned)
Feature list (checkboxes for completed)
Target date (14sp Weight 500)


Phases:

✓ Phase 1: Core Community Features (Completed)
→ Phase 2: Enhanced Engagement (In Progress)
Phase 3: Cardano Integration (Planned)
Phase 4: Scale & Governance (Planned)




Expandable cards for detailed features
"Get Involved" CTA at bottom


Functions:

Expand/collapse phase details
Link to contribution opportunities
Share roadmap




9. CARDANO INTEGRATION (FUTURE-READY, NOT ACTIVE)
Screens to Build
9.1 Transparency Layer Preview

File: lib/Community/Blockchain/transparency_preview.dart
UI Elements:

Info Banner (top, amber background):

Icon: info_outline (24dp)
"Coming Soon: Blockchain Verification" (16sp Weight 600)
Dismiss option


Explainer Section:

"Why Blockchain?" header (20sp Weight 700)
Benefit cards (icon + title + description):

Immutable Records
Transparent Auditing
Decentralized Trust
Verifiable Impact




Current State Card:

"Blockchain Readiness: 70%" (progress bar)
Completed items (with checkmarks):

Data structure design
Contribution tracking
User authentication


Pending items (greyed):

Cardano wallet integration
Smart contract deployment
On-chain verification




Demo Section (disabled state):

"View on Blockchain Explorer" button (disabled, greyed)
"Verify Contribution Hash" input (disabled)
Tooltip: "Available after Cardano integration"


Learn More CTA button


Functions:

Educational content display
Progress tracking visualization
Link to Cardano documentation
Prepare data structures for future migration



9.2 Future Proof-of-Contribution Preview

File: lib/Community/Blockchain/proof_of_contribution.dart
UI Elements:

Mockup of future contribution card:

QR code placeholder (120dp)
"Contribution Hash" label (14sp Weight 600)
Hash value (12sp Weight 400, monospace font, copyable)
"Verified on Cardano" badge (disabled/greyed)
Blockchain explorer link (disabled)


Explainer text:

"In the future, each contribution will be..." (15sp Weight 400)
Feature list with icons


"This is a preview" disclaimer (13sp Weight 500, amber background)


Functions:

Generate mock contribution hashes (local, not on-chain)
Copy hash to clipboard
Educational content



9.3 Blockchain Settings (Hidden/Developer)

File: lib/Community/Blockchain/blockchain_settings.dart
UI Elements (accessible via long-press on version number):

Developer options:

"Enable Blockchain Preview Mode" toggle
"Mock Wallet Address" input
"Test Transaction" button (disabled)
"Clear Blockchain Cache" button


Integration status section:

API endpoint status
Network selection (Testnet/Mainnet)
Last sync timestamp


Warning banner: "Development Only"


Functions:

Developer mode toggles
Abstracted blockchain service layer
Migration hooks prepared: Services/Blockchain/cardano_service.dart




Technical Implementation Requirements
State Management

Recommended: Provider or Riverpod for app-wide state
Files to Create:

lib/Providers/auth_provider.dart - Authentication state
lib/Providers/community_provider.dart - Community data
lib/Providers/activity_provider.dart - Activities state
lib/Providers/contribution_provider.dart - Contribution state
lib/Providers/theme_provider.dart - Theme/preferences



Navigation Structure

Update: lib/Wrappers/main_wrapper.dart for new role-based routing
New Routes:

dart  '/splash' → SplashScreen
  '/welcome' → WelcomeScreen
  '/join' → JoinCommunityScreen
  '/guidelines' → GuidelinesScreen
  '/home' → CommunityHomeScreen (authenticated)
  '/activities' → ActivitiesListScreen
  '/activities/:id' → ActivityDetailScreen
  '/log-contribution' → LogContributionScreen
  '/impact' → ImpactDashboardScreen
  '/recognition' → BadgesScreen
  '/notifications' → NotificationsScreen
  '/profile' → ProfileScreen
  // ... etc

Use named routes with type-safe navigation
Implement deep linking for shareable activities/announcements

Data Models
Create models in lib/Models/:

community_user.dart - User with role (member/volunteer/organizer)
activity.dart - Community activity/initiative
contribution.dart - User contribution record
badge.dart - Achievement badge
milestone.dart - Progress milestone
announcement.dart - Community announcement
notification.dart - In-app notification
impact_metrics.dart - Aggregated impact data

Services Layer
Create services in lib/Services/:

Authentication:

community_auth.dart - Updated auth with role support


Community:

community_service.dart - Community data and stats


Activities:

activity_service.dart - CRUD for activities, join/leave


Contributions:

contribution_service.dart - Log and fetch contributions


Impact:

impact_service.dart - Calculate and aggregate impact metrics


Recognition:

recognition_service.dart - Badges, milestones, leaderboard


Communication:

announcement_service.dart - Announcements CRUD
`notification_service.dart


Notification management

Profile:

profile_service.dart - User profile operations


Blockchain (future-ready):

cardano_service.dart - Abstracted blockchain layer


Storage:

storage_service.dart - Image/file uploads


Location:

Reuse map_selection.dart from existing codebase



Firebase/Backend Updates

Firestore Collections:

  /communities/{communityId}
  /users/{userId} - Add role field, impact_points
  /activities/{activityId} - New collection
  /contributions/{contributionId} - New collection
  /announcements/{announcementId} - New collection
  /badges/{badgeId} - Static badge definitions
  /user_badges/{userId}/badges/{badgeId} - User's earned badges

Security Rules: Update for role-based access (organizers can create activities)
Cloud Functions (optional):

Calculate impact metrics on contribution submission
Send notifications on activity updates
Generate leaderboard on schedule



Reusable Components
Create in lib/Shared/Components/:

community_card.dart - Styled card wrapper
stat_card.dart - Metric display card (number + label)
activity_card.dart - Activity list item
contribution_card.dart - Contribution list item
badge_card.dart - Badge display
progress_bar.dart - Custom progress indicator
empty_state.dart - Consistent empty state widget
loading_indicator.dart - Branded loading spinner
custom_button.dart - Styled button variants
section_header.dart - Consistent section headers

Accessibility & Localization

Accessibility:

Minimum tap targets: 48dp
Semantic labels for all interactive elements
Screen reader support
High contrast mode support
Font scaling support (respect system settings)


Localization (prepare for):

Create lib/l10n/ directory
Use intl package
Extract all strings to ARB files
Support English (primary), add others later



Error Handling & Loading States

Patterns:

Loading: Skeleton screens or shimmer effects
Error: Friendly error messages with retry option
Success: Confirmation with clear next actions
Offline: Offline mode indicators, queue actions


Components:

lib/Shared/Components/error_view.dart
lib/Shared/Components/loading_view.dart
lib/Shared/Components/offline_banner.dart



Performance Optimizations

Image Loading:

Use cached_network_image package
Implement lazy loading for lists
Compress uploads before sending


List Optimization:

Use ListView.builder for long lists
Implement pagination (20-50 items per page)
Cache frequently accessed data


State Management:

Use select or watch efficiently
Avoid rebuilding entire trees
Memoize expensive computations



Testing Requirements

Unit Tests: All service methods
Widget Tests: Critical user flows (onboarding, log contribution)
Integration Tests: End-to-end hackathon demo scenario
Test Coverage: Aim for 70%+ on services layer


Migration Strategy from Current App
Phase 1: Parallel Development

Keep existing code in separate directories
Build new screens in lib/Community/
Create new models/services alongside old ones
Test new flows independently

Phase 2: Data Migration

Map existing user data to new community_user model
Convert old incident reports to contributions (if applicable)
Migrate organization data to community structure
Archive old articles/reports or integrate as announcements

Phase 3: Cutover

Update main.dart and main_wrapper.dart to use new navigation
Deprecate old screens (keep for reference)
Update Firebase rules
Deploy with feature flag for rollback

Phase 4: Cleanup

Remove unused old code
Update documentation
Final testing and optimization


Hackathon Demo Flow
Recommended Demo Scenario (5 minutes)

Onboarding (30s):

Launch app → Splash → Welcome → Join Community (pre-filled) → Guidelines


Community Home (45s):

Show overview stats
Highlight live activity feed
Tap "View Impact" quick action


Impact Dashboard (60s):

Show community metrics
Switch to "My Impact" tab
Highlight environmental/social indicators
Mention blockchain future: "This becomes verifiable on-chain"


Activities (60s):

Back → Tap "Join an Activity"
Show activity list
Tap featured activity → Show details
Tap "Join Activity" → Confirmation


Log Contribution (90s):

Back to Home → Tap "Log Contribution"
Select just-joined activity
Choose contribution type (Time: 3 hours)
Add optional photo
Show impact points calculation
Submit → Confirmation screen


Recognition (30s):

Tap "View My Impact" from confirmation
Show updated stats
Scroll to badges → "First Contribution" badge unlocked (animation)


Future Vision (30s):

Profile → Hackathon Context
Scroll to Cardano Integration callout
"This becomes trustless and verifiable with Cardano"
Show roadmap briefly



Judge-Facing Features to Highlight

Modern, polished UI (show design system in action)
Real-time updates (activity feed, stats)
Comprehensive contribution tracking
Impact measurement and visualization
Non-monetary incentives (badges, recognition)
Clear blockchain integration roadmap
Hackathon context page (transparency)


Deliverables Checklist
Code Structure

 All screens implemented per spec
 All models created
 All services implemented
 Navigation configured
 State management integrated
 Reusable components built

Visual Design

 Design system documented
 Typography system implemented
 Color palette configured
 Component library complete
 Dark mode support
 Responsive layouts (mobile + tablet)

Functionality

 Onboarding flow complete
 Authentication working
 Activities CRUD functional
 Contribution logging working
 Impact calculations accurate
 Recognition system functional
 Notifications working
 Profile management complete

Quality

 No critical bugs
 Smooth animations (60fps)
 Fast load times (<3s cold start)
 Offline mode graceful
 Error handling comprehensive
 Accessibility features implemented

Documentation

 README updated
 Architecture documented
 API/service docs
 Hackathon context page complete
 Roadmap clear
 Demo script prepared

Hackathon Readiness

 Demo account seeded
 Sample data populated
 Prototype mode banner working
 Blockchain preview screens done
 Judge-facing content finalized
 APK/IPA build ready
 Presentation slides prepared


Success Criteria
For Judges

"This looks professional and production-ready"
"The blockchain integration plan is clear and credible"
"I can see myself using this in my community"
"The impact tracking is comprehensive and transparent"

For Users (Demo Feedback)

"Onboarding was quick and clear"
"I immediately understood how to contribute"
"The app feels rewarding without being gamified"
"I trust this system to track my contributions fairly"

Technical Metrics

App launches in <3 seconds
Screens load data in <1 second
Contribution submission succeeds in <2 seconds
No crashes during demo
Smooth 60fps animations


Final Notes
This is a comprehensive redesign that transforms Impact Ledger from a dual-role incident reporting app to a community-focused impact tracking platform. Every screen, component, and interaction has been specified to modern standards with hackathon success in mind.
Key Differentiators:

Modern, polished UI - Feels like a professional consumer app
Clear value proposition - Community impact over individual reporting
Blockchain-ready architecture - Credible future vision without current complexity
Non-monetary incentives - Sustainable engagement model
Transparent impact tracking - Builds trust in the system

Execute this specification with attention to detail, and the app will stand out in any hackathon. The design system ensures consistency, the component library enables rapid development, and the clear structure makes judging easy.