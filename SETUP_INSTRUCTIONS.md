# Setup Instructions for 3 Main Database Collections

## Overview

Your app now has **3 main Firestore collections** set up:

1. ✅ **`users`** - User accounts (already exists)
2. ✅ **`roommate_profiles`** - Roommate finder profiles (already exists)
3. ✅ **`community_content`** - Community shared content (notes, PDFs, images) - **NEWLY CREATED**

## What Was Created

### New Files:
1. **`lib/models/community_content.dart`** - Model for community content
2. **`lib/services/community_content_service.dart`** - Service for managing community content
3. **`lib/state/community_content_provider.dart`** - Provider for state management
4. **`DATABASE_STRUCTURE.md`** - Complete database documentation

### Updated Files:
1. **`lib/services/storage_service.dart`** - Added methods for PDF and file uploads
2. **`firestore.rules`** - Updated security rules for all 3 collections
3. **`pubspec.yaml`** - Added `file_picker` dependency

## Next Steps

### 1. Install Dependencies
Run this command in your terminal:
```bash
flutter pub get
```

### 2. Add Provider to Main App
Update `lib/main.dart` to include the `CommunityContentProvider`:

```dart
import 'state/community_content_provider.dart';

// In the MultiProvider providers list, add:
ChangeNotifierProvider(create: (_) => CommunityContentProvider()),
```

### 3. Deploy Firestore Rules
Deploy the updated security rules to Firebase:
```bash
firebase deploy --only firestore:rules
```

### 4. Create Firestore Indexes (if needed)
If you plan to use complex queries, create composite indexes in Firebase Console:
- Go to Firebase Console > Firestore > Indexes
- The app will prompt you to create indexes when needed, or you can create them manually based on `DATABASE_STRUCTURE.md`

## Usage Examples

### Upload Community Content (Notes/PDFs/Images)

```dart
final contentProvider = Provider.of<CommunityContentProvider>(context, listen: false);

// Pick PDF files
final pdfFiles = await contentProvider.pickFiles(
  allowedExtensions: ['pdf'],
);

// Pick images
final images = await contentProvider.pickImages(allowMultiple: true);

// Create content
await contentProvider.createContent(
  title: 'Study Notes - Data Structures',
  description: 'Complete notes for DS course',
  contentType: 'pdf', // or 'image', 'note', 'mixed'
  files: pdfFiles,
  category: 'study_notes',
  tags: ['data-structures', 'computer-science'],
  subject: 'Data Structures',
  college: 'Your College',
  branch: 'Computer Science',
);
```

### Display Community Content

```dart
StreamBuilder<List<CommunityContent>>(
  stream: contentProvider.getPublicContentStream(
    category: 'study_notes',
    limit: 20,
  ),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final content = snapshot.data![index];
          return ListTile(
            title: Text(content.title),
            subtitle: Text('${content.downloadCount} downloads'),
            onTap: () {
              // View/download content
              contentProvider.downloadContent(content.id);
            },
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

## Database Collections Summary

### 1. Users Collection (`users`)
- **Purpose:** Store user accounts
- **Document ID:** User's UID
- **Service:** `UserService`
- **Already in use:** ✅

### 2. Roommate Profiles Collection (`roommate_profiles`)
- **Purpose:** Store roommate finder profiles
- **Document ID:** User's UID (one per user)
- **Service:** `RoommateService`
- **Already in use:** ✅

### 3. Community Content Collection (`community_content`)
- **Purpose:** Store uploaded notes, PDFs, images for community sharing
- **Document ID:** Auto-generated
- **Service:** `CommunityContentService`
- **Provider:** `CommunityContentProvider`
- **Storage:** Files stored in Firebase Storage under `community_content/` folder
- **Newly created:** ✅

## File Storage Structure

Files are stored in Firebase Storage with this structure:
```
community_content/
  ├── pdfs/
  │   └── {userId}/
  │       └── {filename}.pdf
  ├── images/
  │   └── {userId}/
  │       └── {filename}.jpg
  └── files/
      └── {userId}/
          └── {filename}
```

## Security Rules

All collections now have proper security rules:
- Users can only update their own profile
- Users can only create/update their own roommate profile
- Users can only create/update their own community content
- Public content is readable by all authenticated users

## Need Help?

Refer to `DATABASE_STRUCTURE.md` for detailed field descriptions and best practices.
