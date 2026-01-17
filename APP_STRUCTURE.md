Impact Ledger – App UI and Functional Overview

Purpose
- This document summarizes the current Flutter app’s UI screens, navigation, and core functions to help an AI (or developer) understand the project structure before refactors.

High-level Summary
- Multi-role app with two primary flows: Organization and User/Volunteer.
- Features include authentication/registration, viewing and posting articles, reporting and viewing incidents, organization dashboards and team management, volunteer coordination, and user help resources.
- Android and iOS native projects are present; Android uses AGP 8.7.3 and Kotlin 2.1.0 (updated), Gradle 8.9.

Entry Points
- lib/main.dart: Flutter entry point, wires up navigation and wrappers.
- lib/Wrappers/main_wrapper.dart: Likely manages role-based routing (e.g., determines whether to show user home vs. org home based on auth state/role).

UI Structure (by feature)

Shared
- lib/Shared/Pages/login.dart: Shared login screen UI for both roles; integrates with Services/Authentication/auth.dart.
- lib/Shared/Inputs/post_incident.dart: Shared form widget/model to submit incident data.
- Reusable UI components in lib/Reusables:
  - buttons/buttons.dart
  - components/square_tile.dart
  - footer/{footer.dart, logo.dart}
  - inputfields/{password.dart, textfields.dart}

Organization Flow (lib/Organization)
- Authentication
  - Authentication/org_registration.dart: Organization registration UI and flow.
- Home
  - Home/org_home.dart: Organization landing/home page.
  - Home/Dashboard/org_dashboard.dart: Dashboard UI for org metrics/overview.
  - Home/OurTeam/{org_team.dart, add_team.dart}: Team listing and team member addition screens.
  - Home/Profile/org_profile.dart: Organization profile management screen.
  - Home/Volunteers/{org_volunteers.dart, contact_volunteers.dart}: Volunteer directory for orgs and communication screen.
- Articles
  - Articles/post_article.dart: UI for creating/posting articles.
  - Articles/article_service.dart: Service layer for fetching/posting articles.

User/Volunteer Flow (lib/User)
- Authentication
  - Authentication/{user_registration.dart, volunteer_reg.dart, volunteer_service.dart}: Registration forms and volunteer service helpers.
- Home
  - Home/user_home.dart: General user home.
  - Home/HomeScreen/{user_homescreen.dart, read_article.dart}: Main user home screen and article reader details page.
- Help
  - Home/Help/{help_main_screen.dart, help_child_screen.dart, user_help.dart, help_data.dart}: Help hub with hierarchical navigation (main -> child pages) and static/dynamic data support.
- Profile
  - Profile/user_profile.dart: User profile screen.
- Reports
  - Reports/user_reports.dart: User report submission/listing view.

Incidents (lib/Services/Incidents)
- map_selection.dart: Map-based selector for incident location.
- incident_upload.dart: Upload logic/services for incident data and media.

Backend/Services
- Services/Authentication/auth.dart: Authentication service (sign-in, sign-up, session management, possibly Firebase integration per firebase.json and android google-services.json).
- Services/database/database.dart: Data access layer for reading/writing app data (likely Firestore/Realtime DB).

Models
- Models/user.dart: User model (roles, identifiers, profile info used across flows).

Home (root-level)
- Home/landing_page.dart: Likely a pre-auth landing or role-choice page.

Assets
- assets/ and images/pngs: App icons and imagery used across the UI; iOS Runner assets are present. Additional image assets for services: firefighter.png, hospital.png, police.png, redcross.png, refugee.png, logo.png, etc.

Navigation Patterns
- Wrapper (main_wrapper.dart) likely decides initial route based on logged-in state and role (org vs user).
- User HomeScreen has an article list with a detail view (read_article.dart).
- Incident flow uses shared input (post_incident.dart) and a map selection step (map_selection.dart) before upload (incident_upload.dart).
- Organization navigation includes dashboard, team, volunteers, and articles sub-sections.

Core Functions by Feature
- Authentication
  - Sign in/out, registration for users, volunteers, and organizations.
  - Firebase configuration indicates Google services and possibly Google Sign-In.
- Articles
  - Organization can post articles (post_article.dart + article_service.dart).
  - Users can read articles (user_homescreen + read_article).
- Incidents
  - Users can create incident reports using shared input forms.
  - Map-based location selection; upload of metadata and media via incident_upload.dart.
  - Viewing incidents (Shared/Pages/view_incidents.dart) for browsing.
- Organization Management
  - Dashboard metrics display.
  - Team management (list/add team members).
  - Volunteer outreach/communication.
  - Profile editing for organization information.
- User Help
  - Help center with hierarchical screens to guide users to resources (help_main_screen -> help_child_screen; user_help consolidates flows).
- Profiles
  - User and organization profile screens to view/edit profile info.

State Management and Patterns (inferred)
- No explicit state management library folders found; likely using setState, InheritedWidgets, or lightweight patterns local to screens.
- Services layer suggests separation of concerns: UI widgets call service classes for data/auth.

Platform/Build
- Android: AGP 8.7.3, Kotlin 2.1.0 (settings.gradle), Gradle 8.9 wrapper. google-services plugin present and configured. android/app/ contains manifests and resources.
- iOS: Standard Runner project with Swift AppDelegate and asset catalogs.

Known Integrations
- Firebase (firebase.json, android/app/google-services.json, iOS xcconfig files).
- Google/Apple sign-in imagery present (images/apple.png, images/google.png), suggesting social auth options.

Potential Entry Routes at Runtime (typical)
1) App start -> main.dart -> main_wrapper.dart.
2) If not authenticated -> Shared/Pages/login.dart.
3) Post-auth routing:
   - If organization -> Organization Home (org_home.dart) -> Dashboard, Team, Volunteers, Profile, Articles.
   - If user -> User Home (user_home.dart/user_homescreen.dart) -> Read Articles, Report Incidents, Help, Profile, Reports.

Notes for Upcoming Changes
- If refactoring navigation, update main_wrapper.dart and main.dart routes to ensure role-based redirection remains intact.
- If modifying data models, review Models/user.dart and Service layers (auth.dart, database.dart, article_service.dart, incident_upload.dart) for impacted APIs.
- When altering incident flows, keep the map selection and shared incident input cohesion in mind.
- Reusable components under lib/Reusables are used across many screens; changes will have wide impact.

File Map (selected)
- lib/
  - main.dart
  - Wrappers/main_wrapper.dart
  - Shared/
    - Pages/login.dart
    - Inputs/post_incident.dart
  - Services/
    - Authentication/auth.dart
    - database/database.dart
    - Incidents/{map_selection.dart, incident_upload.dart}
  - Organization/
    - Authentication/org_registration.dart
    - Articles/{post_article.dart, article_service.dart}
    - Home/
      - org_home.dart
      - Dashboard/org_dashboard.dart
      - OurTeam/{org_team.dart, add_team.dart}
      - Volunteers/{org_volunteers.dart, contact_volunteers.dart}
      - Profile/org_profile.dart
  - User/
    - Authentication/{user_registration.dart, volunteer_reg.dart, volunteer_service.dart}
    - Home/{user_home.dart}
    - Home/HomeScreen/{user_homescreen.dart, read_article.dart}
    - Home/Help/{help_main_screen.dart, help_child_screen.dart, user_help.dart, help_data.dart}
    - Profile/user_profile.dart
    - Reports/user_reports.dart
  - Home/landing_page.dart

This document reflects the current file structure and inferred responsibilities to guide planned changes.