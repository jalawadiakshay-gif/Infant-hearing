# Baalshravya - Early Infant Hearing Detection System

## Project Overview

**Baalshravya** (meaning "child's voice" in Sanskrit) is a comprehensive early infant hearing detection system designed for Indian healthcare contexts. The system supports both **BOA (Behavioral Observation Audiometry)** and **Questionnaire-based screening** methods, generating clinical reports and facilitating follow-up care.

The project follows a **V2 architecture** with modular features, Firebase-backed data storage, and multilingual support (English, Hindi, Kannada, Marathi).

---

## Architecture Overview

### V2 Architecture Pattern

The system uses a unified data model across all user roles:

- **AppUser** - Unified model for ASHA workers, parents, clinicians, admins
- **Child** - Infant/child registration model with denormalized screening data
- **Screening** - Unified screening model supporting both 'q' (questionnaire) and 'boa' (BOA) types
- **Referral** - Workflow lifecycle tracking for referrals
- **Followup** - Follow-up visit tracking

### Key Components

1. **Firebase Backend** - Authentication, Firestore database, Storage
2. **Riverpod-style State Management** - ChangeNotifier-based providers
3. **GoRouter** - Navigation routing
4. **MLKit CV** - Computer vision for baby detection and behavior analysis
5. **Audioplayers** - Clinical-grade stimulus playback
6. **PDF Generation** - Report creation using pdf package

---

## Feature Modules

### 1. Authentication & Onboarding

- **Splash Screen** - Initial app entry
- **Role Selection** - ASHA worker / Parent / Clinician selection
- **Phone Authentication** - OTP-based login with Firebase Auth
- **Google Sign-In** - Optional alternative authentication
- **Auto-profile Creation** - Seamless onboarding with Firestore profile creation

**Screens:**
- `splash_screen.dart` - App introduction
- `role_selection_screen.dart` - Role choice
- `phone_login_screen.dart` - Phone number entry
- `otp_verification_screen.dart` - OTP verification
- `language_selection_screen.dart` - Language preference

**Providers:**
- `auth_provider.dart` - Authentication state management
- `AppProvider` - Aggregated provider for auth/parent/baby

---

### 2. Baby Management

**Purpose:** Register and track infants/children in the system.

**Screens:**
- `baby_profile_screen.dart` - Baby profile creation with medical history
- `child_detail_screen.dart` - Child details view

**Providers:**
- `baby_provider.dart` - Manages list of children, selected baby

**Models (V2):**
- `child.dart` - Complete infant model with birth details, screening status, risk factors
- Supports child code generation (`BSV-MH-YYMM-XXXX` format)

**Data Fields:**
- Name, DOB, gender, parent information
- Birth weight, gestational age, birth type
- NICU admission status and duration
- Hospital/pediatrician names
- Hearing screening status
- Last screening date/type/result
- Status: 'new', 'pass', 'refer', 'monitor'

---

### 3. Questionnaire Screening (Phase 1)

**Purpose:** Initial risk factor assessment via caregiver questionnaire.

**Age-bandled questions** adaptive to baby's age (0-12 months):

- **Section 0:** Basic infant info (unscored)
- **Section 1:** High-risk medical factors (10 questions)
- **Section 2:** Auditory behavior (age-banded, 10 questions)
- **Section 3:** Advanced behavioral indicators (4 questions)
- **Section 4:** Parental concerns (4 questions)
- **Section 5:** Screening history (3 questions)

**Scoring System:**
- Each answer: Yes=1, Partial=0.5, No/Unanswered=0
- Risk percentage calculation across all sections
- Results: **PASS** (<30%), **MONITOR** (30-60%), **REFER** (>60%)

**Screens:**
- `questionnaire_screen.dart` - Main questionnaire interface
- `questionnaire_result_screen.dart` - Results display

**Providers:**
- `questionnaire_provider.dart` - State management, scoring, storage

**Services:**
- `questionnaire_report_service.dart` - PDF report generation

**Models:**
- `questionnaire_models.dart` - Question, Section, AnswerValue, RiskResult, ScoringResult

---

### 4. BOA Test (Behavioral Observation Audiometry)

**Purpose:** Clinical behavioral hearing assessment using adaptive stimulus protocol.

**Protocol:** JNMC-specified adaptive dB protocol (70 → 45/90 dB HL)

**Core Elements:**

| Component | Description |
|-----------|-------------|
| **Frequencies** | 1 kHz, 3 kHz, Broadband Noise, Warble Tone |
| **dB Levels** | db70 (initial), db45 (reduced), db90 (elevated) |
| **Phases** | idle → checklist → noiseCheck → infantDetection → baselineLearning → playing → awaitingResponse → catchTrial → complete |
| **Responses** | Response Detected / No Response / Uncertain |
| **Outcomes** | Favorable Hearing Response / Monitor / Suspected Hearing Loss |

**Technical Implementation:**

- **BoaController** - Main controller (736 lines) managing:
  - Camera lifecycle and MLKit frame processing
  - Audio playback service
  - Adaptive protocol logic
  - Timer management (progress, cooldown, response window)
  - Reliability calculations

- **BoaAudioService** - Audio playback with:
  - Dedicated AudioPlayer instance
  - 3-second stimulus duration
  - Preloaded assets (45/70/90 dB WAV files)
  - Silent catch trials

- **BoaCvService** - Dual-pipeline computer vision:
  - **Pipeline A:** Google MLKit FaceDetector (face bounding, eye probabilities, head pose)
  - **Pipeline B:** Google MLKit PoseDetector (33-point skeleton, body motion, Moro reflex)
  - Age-adaptive weighting (neonatal 0-3m, early-infant 3-6m, older-infant 6-12m)
  - Baseline calibration and running averages
  - Camera shake detection
  - Sleeping/crying detection

- **BoaModels** - Domain enums and data classes:
  - `BoaFrequency`, `BoaDbLevel`, `BoaResponse`
  - `BoaTestPhase`, `BoaOutcome`, `BoaInfantAgeGroup`
  - `BoaTrial`, `CvSignalScores`, `CvExplanation`

- **BoaReportService** - PDF report generation:
  - Parent and clinical report types
  - Outcome hero card with color coding
  - Recommendation text
  - Screening timeline
  - Detailed trial table
  - Follow-up actions
  - Clinical summary with explanations

**Screens:**
- `boa_intro_screen.dart` - Introduction to BOA test
- `boa_wizard_screen.dart` - Setup wizard (checklist)
- `boa_test_screen.dart` - Main BOA test interface
- `boa_result_screen.dart` - Results display
- `boa_checklist_screen.dart` - Pre-test checklist

**Controllers:**
- `boa_controller.dart` - Core test logic
- `boa_checklist_controller.dart` - Pre-test checklist management
- `boa_state.dart` - Immutable state snapshot

---

### 5. ASHA Worker Module

**Purpose:** ASHA (Accredited Social Health Activist) worker dashboard for field operations.

**Dashboard Features:**
- ID badge display
- Screening summary stats (total, completed, pending, referrals)
- Quick actions (Register Baby, Sync Data)
- Pending screenings list
- Assigned villages list with infant counts
- Emergency referral FAB

**Screens:**
- `asha_dashboard_screen.dart` - Main dashboard
- `asha_infant_detail_screen.dart` - Individual infant detail
- `asha_village_screen.dart` - Village-specific view
- `asha_login_screen.dart` - ASHA worker login
- `asha_batch_registration_screen.dart` - Batch infant registration

**Providers:**
- `asha_provider.dart` - ASHA-specific data management

**Stats Calculation:**
- Total babies, completed, pending, referrals count
- Filtering by status ('new', 'pass', 'refer', 'monitor')

**Widgets:**
- `asha_id_badge_widget.dart` - Worker identification
- `asha_stats_card.dart` - Statistic display cards
- `village_tile_widget.dart` - Village listing
- ` infant_list_tile_widget.dart` - Infant listing

---

### 6. Parent Module

**Purpose:** Parent/guardian profile and information management.

**Screens:**
- `parent_info_screen.dart` - Parent information entry
- `parent_profile_screen.dart` - Parent profile view
- `simple_parent_profile_screen.dart` - Simplified profile

**Provider:**
- `parent_provider.dart` - Parent user profile management

---

### 7. History & Records

**Screens:**
- `history_screen.dart` - Complete screening history view
- Displays each infant with name, screened date, result icons for questionnaire and BOA
- View report functionality

**Card Layout:**
- Circle avatar with initial
- Infant name and screened date
- Result badges (Pass/Monitor/Refer)
- View report button

---

### 8. Home Screen

**Features:**
- Premium app bar with greeting, parent name, clinical badge
- Child profile card (if baby registered)
- Screening progress bar and status
- Quick action tiles (4×2 grid):
  - Start Phase 1 Screening
  - View History
  - AI Assistant / Chat Support
  - Medical Insights
- Awareness carousel with latest insights
- Latest insights section

**Quick Actions:**
- `Icons.biotech_rounded` → Questionnaire screening
- `Icons.analytics_rounded` → History
- `Icons.psychology_rounded` → Chatbot
- `Icons.menu_book_rounded` → Medical insights

---

### 9. Medical Insights Screen

Educational content about:
- Hearing milestones (0-3m, 3-6m, 6-12m)
- Clinical screening recommendations (EHDI timeline)
- Risk factors (low birth weight, prematurity, NICU, family history, infections)

---

### 10. Chatbot / AI Assistant

- Route: `/chatbot`
- Integrated in home screen quick actions
- Placeholder for AI-based hearing support

---

### 11. Settings & Localization

**Languages Supported:** English, Hindi, Kannada, Marathi

**Localization System:**
- ARB files for each language (`app_en.arb`, `app_hi.arb`, `app_kn.arb`, `app_mr.arb`)
- LanguageProvider manages current language state
- SharedPreferences persistence
- AppLanguage enum with code, native name, English name, TTS/STT locales

**Route:** `/language-select`

---

### 12. Core Utilities

**Services:**
- `tts_service.dart` - Text-to-speech with language support, pause/resume/stop
- `audio_service.dart` - Central audio player with preloading
- `notification_service.dart` - (referenced but minimal)

**Utils:**
- `validators.dart` - Form validation helpers
- `extensions.dart` - Dart extensions
- `report_generator.dart` - Basic BOA report generation

**Constants:**
- `route_constants.dart` - All route name constants (57 routes)
- `app_language.dart` - AppLanguage enum with 4 languages
- `app_strings.dart` - String catalog
- `app_config.dart` - Environment configuration (dev/staging/prod)

**Theme:**
- `app_colors.dart` - Premium medical color palette
- `app_text_styles.dart` - Poppins/Inter typography system
- `app_spacing.dart` - Consistent spacing scale
- `app_theme.dart` - Theme data composition

---

### 13. Data Services

**Firestore Service (`app_firestore_service.dart`):**
- User profile management
- Child registration and retrieval
- Screening submission and history
- Video compression (target <5 MB)
- Media upload to Firebase Storage
- Referral workflow management
- Followup scheduling and tracking

**Key Methods:**
- `getChildrenForAsha()` - Stream children for ASHA worker
- `registerChild()` - Register new infant
- `submitScreening()` - Save screening result
- `updateChildScreeningStatus()` - Update child status
- `uploadScreeningMedia()` - Video + PDF upload with error handling
- Referral/create, update, getPending, getForChild
- Followup schedule, complete, getPending

---

### 14. Media & Assets

**Audio Assets** (assets/audio/):
- `boa_45db.wav` - 45 dB stimulus
- `boa_70db.wav` - 70 dB stimulus
- `boa_90db.wav` - 90 dB stimulus

**Localization ARB Files:**
- `app_en.arb` - English
- `app_hi.arb` - Hindi
- `app_kn.arb` - Kannada
- `app_mr.arb` - Marathi

**Images:**
- App logo and UI assets

---

### 15 Dependencies

Key Flutter packages:
- `provider` - State management
- `go_router` - Navigation (v13.2.0)
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `audioplayers` - Audio playback
- `camera` - Camera access
- `google_mlkit_face_detection` - Face detection
- `google_mlkit_pose_detection` - Pose estimation
- `pdf` - PDF generation
- `printing` - PDF sharing
- `flutter_animate` - Animations
- `lottie` - Lottie animations
- `uuid` - UUID generation
- `video_compress` - Video compression to <5 MB
- `shared_preferences` - Local storage
- `speech_to_text` - Speech recognition
- `connectivity_plus` - Connectivity monitoring
- `flutter_local_notifications` - Push notifications
- `syncfusion_flutter_charts` - Charts (if needed)
- `cached_network_image` - Image loading

---

### 16. Screens Summary (Total: ~40 screens)

| Category | Screens |
|----------|---------|
| Auth | 7 (splash, login, register, OTP, role select, language select, phone login) |
| Baby | 2 (profile, child detail) |
| Questionnaire | 3 (screen, result) |
| BOA | 5 (intro, wizard, test, result, checklist) |
| ASHA | 5 (dashboard, detail, village, login, batch registration) |
| Parent | 3 (info, profile, simple profile) |
| Home | 1 (main home screen) |
| History | 1 (history screen) |
| Medical Insights | 1 |
| Settings | 1 (language select) |

---

### 17. Key Flows

**1. New User Onboarding:**
```
Splash → Role Selection → (Parent) Baby Profile → Questionnaire → BOA Test → Report
                         ↓
                   (ASHA) Dashboard → Register Baby → Screening flows
```

**2. Questionnaire Flow:**
```
QuestionnaireScreen → (answer questions) → Section progression → Submit → 
QuestionnaireResultScreen (PASS/MONITOR/REFER)
```

**3. BOA Flow:**
```
BoaWizardScreen (checklist) → BoaTestScreen (adaptive protocol) → 
BoaResultScreen (outcome: Favorable/Monitor/Suspected Loss) → 
PDF Report Generation → Firestore Storage
```

**4. ASHA Worker Flow:**
```
Login → Dashboard → View pending screenings → Open infant detail → 
View/modify screening results → Referral management → Followup tracking
```

**5. Parent Flow:**
```
Login → Home → View child profile → Access past screening reports → 
Understand results → Follow-up recommendations
```

---

### 18. Report Generation

**Two report types:**

1. **Questionnaire Report** (`questionnaire_report_service.dart`):
   - Risk percentage display
   - Section-wise score breakdown
   - Detailed response list
   - Follow-up actions
   - Parent/clinical variants

2. **BOA Report** (`boa_report_service.dart`):
   - Outcome hero card (color-coded)
   - Recommendation text
   - Screening timeline
   - Detailed trial table (dB level, frequency, response, type)
   - Clinical summary with explanations
   - Follow-up actions
   - Important notices/disclaimers

Both services support:
- `generateReportBytes()` - Return PDF as Uint8List
- `generateAndShareReport()` - Share via system share sheet
- Parent and clinical report types with different content

---

### 19. Configuration & Environment

**Environment Setup:**
- `AppConfig.environment` - dev/staging/prod
- `AppConfig.apiBaseUrl` - Environment-specific API URLs
- Dart defines: `--dart-define=ENV=prod`, `--dart-define=API_URL=...`
- `USE_MOCKS`, `USE_FIREBASE` flags

**Firebase Configuration:**
- `firebase.json` - Storage rules
- `firebase_options.dart` - Auto-generated Firebase options
- Multiple services: Auth, Firestore, Storage, Messaging, Sign-in

**App Constants:**
- Route names (57 constants in `route_constants.dart`)
- Language codes (English, Hindi, Kannada, Marathi)
- Color palette (medical-grade with WCAG compliance)
- Text typography (Poppins headings, Inter body text)

---

### 20. Technical Highlights

**Architecture Strengths:**
- ✅ V2 unified data model (single Child, Screening, User models)
- ✅ Offline-first Firestore with snapshot streaming
- ✅ Comprehensive timer management in BOA controller (race conditions fixed)
- ✅ Dual-pipeline CV with age-adaptive scoring
- ✅ Robust error handling (media upload failures don't block screening save)
- ✅ Multilingual support from ground up (4 languages)
- ✅ Video compression before upload (target <5 MB)
- ✅ Safe disposal patterns throughout (audio, camera, timers)
- ✅ Consent-aware response windows (clinical gating)

**Key Fixes Documented:**
- Audio leak: Each controller owns its AudioPlayer
- Camera lifecycle: Proper stop/dispose sequencing
- Race conditions: Single AI mutex + frame throttle
- Temporal signaling: Stimulus start/end gating
- Response window timeout: Auto-advance after 8 seconds
- Cooldown: 2s between trials
- Habituation guard: Warn after 3 consecutive no-responses

---

## Project Statistics

- **Total Lines of Code:** ~15,000+ lines across Dart files
- **Features:** 5 major modules (Auth, Baby, Questionnaire, BOA, ASHA)
- **Screens:** ~40 distinct screens
- **Supported Languages:** 4 (English, Hindi, Kannada, Marathi)
- **Report Types:** 2 (Parent, Clinical) with PDF generation
- **Storage:** Firebase Firestore + Firebase Storage
- **ML Technology:** Google MLKit (Face + Pose detection)
- **Audio:** Austinplayer with clinical-grade calibration
- **Video:** Compressed to <5 MB before Firebase Storage upload

---

## Future Enhancements (Potential)

1. **Speech-to-Text** integration for auditory response verification
2. **ABR/ASSR** test integration for formal diagnostic results
3. **Telehealth** video consultation features
4. **Cloud Functions** for server-side scoring and risk assessment
5. **SMS/WhatsApp** report delivery to parents
6. **Multi-language** ARB file expansion
7. **Advanced analytics** dashboard for program monitoring
8. **Export** reports to Google Health format