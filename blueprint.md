# Blueprint: Student Community & Roommate Finder

## Build Roadmap (Step-by-Step)

This document outlines the development plan for a Flutter application designed to help students find compatible roommates and connect with a verified student community.

---

### 🔹 Phase 1 – Setup + Auth + Basic Shell

**Goal:** User can log in and see main navigation.

1.  **Project Setup:**
    *   Create the Flutter project and apply the new, organized folder structure.
    *   Add initial Firebase dependencies: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`.
2.  **Authentication Flow:**
    *   Implement a `SplashScreen` to check the user's authentication state and redirect accordingly.
    *   Create `LoginScreen` and `RegisterScreen` for email/password and Google Sign-In.
    *   Build a `CompleteProfileScreen` to capture essential user data after registration (name, college, avatar).
3.  **Main Application Shell:**
    *   Construct a `MainScaffold` containing a `BottomNavigationBar` with three primary tabs:
        *   Tab 1: Community (Placeholder)
        *   Tab 2: Roommates (Placeholder)
        *   Tab 3: Profile (Placeholder)

✅ **End of Phase 1:** A user can sign up, complete their initial profile, log in, and navigate the basic structure of the app.

---

### 🔹 Phase 2 – Roommate Finder Core

**Goal:** Users can create detailed roommate profiles and browse others in a grid.

1.  **Roommate Profile Creation:**
    *   Develop the `RoommateProfileForm` where users can input their preferences:
        *   Location (City, Area)
        *   Budget
        *   Hobbies and Interests (e.g., travel, gaming, sports)
        *   Living preferences (e.g., "lives alone," "looking for a roommate").
    *   Save this data to a `roommate_profiles` collection in Firestore.
2.  **Roommate Discovery:**
    *   Create the `RoommateScreen` which will display roommate profiles in a 2x2 grid using `GridView.builder`.
    *   Design and build the `RoommateCard` widget for the grid.
3.  **Filtering:**
    *   Implement a `RoommateFilterSheet` to allow users to filter roommates based on:
        *   City
        *   Interests (using selectable chips).
    *   Manage the filter state using a `FilterProvider`.

✅ **End of Phase 2:** A user can create their roommate-specific profile, see other users in a grid, and apply basic filters to find a match.

---

### 🔹 Phase 3 – Personal Chat

**Goal:** Users can connect and initiate one-on-one conversations.

1.  **Connection Logic:**
    *   On the `RoommateDetailScreen`, add a "Connect" or "Message" button.
    *   When tapped, check if a chat between the two users already exists.
    *   If it exists, navigate to the `ChatScreen`.
    *   If not, create a new chat document in Firestore and then navigate to the `ChatScreen`.
2.  **Chat UI:**
    *   Build a `ChatsListScreen` to display a list of all the user's ongoing conversations.
    *   Create the `ChatScreen` for messaging, including:
        *   A `ListView` to display chat bubbles.
        *   A `TextField` at the bottom to compose and send messages.
3.  **Data Structure:**
    *   Store chat messages in a `messages` sub-collection within each chat document.

✅ **End of Phase 3:** The core social loop is complete: a user can discover a potential roommate, view their profile, and start a private conversation.

---

### 🔹 Phase 4 – Public Community Section

**Goal:** Create a public space for students to share ideas, projects, and notes.

1.  **Community Tab:**
    *   In the "Community" section of the app, implement a `TabBar` with two tabs:
        *   **Personal:** This will house the `ChatsListScreen`.
        *   **Public:** This will contain the public feed.
2.  **Public Feed:**
    *   Build a `PublicFeedScreen` to display a list of posts from all users.
    *   Create a `CreatePostScreen` for users to share content, including a title, description, category, and optional links.
    *   Implement a `PostDetailScreen` to show a full post and its comments.
3.  **Data Structure:**
    *   Create a `posts` collection to store public posts.
    *   Create a `comments` sub-collection for each post.
    *   **Categories:** `Startup | Project | Notes | Event | Other`.

✅ **End of Phase 4:** The app now has a public-facing side for broader student interaction and knowledge sharing.

---

### 🔹 Phase 5 – Verification and Trust Features

**Goal:** Enhance platform safety and user trust.

1.  **Implement College ID Verification:**
    *   In the `CompleteProfileScreen` or `ProfileScreen`, add an option to "Upload college ID."
    *   Upload the image to Firebase Storage and save the URL in the user's document.
    *   Set a `verificationStatus` field to `"pending"`.
2.  **Display "Verified" Badge:**
    *   Show a visual "Verified" badge next to the user's name on:
        *   `RoommateCard`
        *   `RoommateDetailScreen`
        *   `ChatScreen` header
3.  **Implement Safety Features:**
    *   Add "Block" and "Report" user buttons in the `RoommateDetailScreen` and `ChatScreen`.
    *   Store reports in a `reports` collection for moderation.

✅ **End of Phase 5:** The platform feels more secure and trustworthy, which is critical for its target audience.

---

### 🔹 Phase 6 – Polish and Optional Extras

**Goal:** Refine the user experience and add bonus features.

1.  **UI/UX Enhancements:**
    *   Refine the color scheme, typography, and theme.
    *   Add subtle animations and transitions.
2.  **Advanced Search/Filter:**
    *   Implement search by user name or college.
    *   Add a "Show only verified roommates" filter.
3.  **Notifications:**
    *   Integrate Firebase Cloud Messaging (FCM) for push notifications for:
        *   New chat messages.
        *   New connection requests.
        *   Comments on a user's post.
4.  **Theme Toggle:**
    *   Include a button to toggle between light and dark themes.
5.  **Community/Personal Toggle:**
    *   Add a custom switch-style button to toggle between the Personal and Public community views.
