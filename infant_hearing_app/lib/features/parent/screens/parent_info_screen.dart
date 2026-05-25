// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_strings.dart';
// import '../../../core/constants/route_constants.dart';
// import '../../../core/utils/validators.dart';
// import '../../../core/utils/extensions.dart';
// import '../../../shared/widgets/app_text_field.dart';
// import '../../../shared/widgets/app_button.dart';
// import '../../../shared/widgets/app_dropdown.dart';
// import '../../../shared/widgets/step_indicator.dart';
// import '../../../shared/widgets/screen_header.dart';
// import '../models/parent_model.dart';
// import '../providers/parent_provider.dart';

// class ParentInfoScreen extends StatefulWidget {
//   const ParentInfoScreen({super.key});

//   @override
//   State<ParentInfoScreen> createState() => _ParentInfoScreenState();
// }

// class _ParentInfoScreenState extends State<ParentInfoScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _ageController = TextEditingController();
//   final _contactController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _addressController = TextEditingController();

//   String? _selectedGender;

//   final _ageFocus = FocusNode();
//   final _contactFocus = FocusNode();
//   final _emailFocus = FocusNode();
//   final _addressFocus = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill if data exists
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final parent = context.read<ParentProvider>().parent;
//       if (parent != null) {
//         _nameController.text = parent.name;
//         _ageController.text = parent.age.toString();
//         _contactController.text = parent.contactNumber;
//         _emailController.text = parent.email ?? '';
//         _addressController.text = parent.address;
//         setState(() => _selectedGender = parent.gender);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _ageController.dispose();
//     _contactController.dispose();
//     _emailController.dispose();
//     _addressController.dispose();
//     _ageFocus.dispose();
//     _contactFocus.dispose();
//     _emailFocus.dispose();
//     _addressFocus.dispose();
//     super.dispose();
//   }

//   Future<void> _onNext() async {
//     if (!_formKey.currentState!.validate()) return;

//     await context.read<ParentProvider>().saveParent(
//           name: _nameController.text.trim(),
//           age: int.parse(_ageController.text.trim()),
//           gender: _selectedGender!,
//           contactNumber: _contactController.text.trim(),
//           email: _emailController.text.trim(),
//           address: _addressController.text.trim(),
//         );

//     if (!mounted) return;
//     context.showSnackBar('Parent information saved!');
//     context.pushNamed(RouteConstants.babyProfile);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isSaving = context.select<ParentProvider, bool>((p) => p.isSaving);

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           'Screening Setup',
//           style: GoogleFonts.dmSans(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: TextButton(
//               onPressed: () => context.pushReplacementNamed(RouteConstants.login),
//               child: Text(
//                 'Sign out',
//                 style: GoogleFonts.dmSans(
//                   fontSize: 13,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Step indicator
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               child: StepIndicator(
//                 currentStep: 1,
//                 totalSteps: 3,
//                 stepLabels: const ['Parent', 'Baby', 'Screening'],
//               ),
//             ),

//             // Scrollable form
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),

//                       const ScreenHeader(
//                         title: 'Parent\nInformation',
//                         subtitle:
//                             'Tell us about the parent or guardian responsible for this child.',
//                         icon: Icons.family_restroom_rounded,
//                       ),

//                       const SizedBox(height: 32),

//                       // Identity section
//                       _buildSectionTitle('IDENTITY'),
//                       const SizedBox(height: 12),
//                       _buildCard([
//                         AppTextField(
//                           controller: _nameController,
//                           label: AppStrings.parentName,
//                           hint: 'Full name of parent/guardian',
//                           prefixIcon: Icons.person_outline_rounded,
//                           textCapitalization: TextCapitalization.words,
//                           validator: (v) => Validators.required(v, fieldName: 'Parent name'),
//                           textInputAction: TextInputAction.next,
//                           onFieldSubmitted: (_) =>
//                               FocusScope.of(context).requestFocus(_ageFocus),
//                         ),
//                         const SizedBox(height: 14),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: AppTextField(
//                                 controller: _ageController,
//                                 label: AppStrings.parentAge,
//                                 hint: 'e.g. 28',
//                                 prefixIcon: Icons.cake_outlined,
//                                 keyboardType: TextInputType.number,
//                                 validator: Validators.age,
//                                 focusNode: _ageFocus,
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.digitsOnly,
//                                   LengthLimitingTextInputFormatter(3),
//                                 ],
//                                 textInputAction: TextInputAction.next,
//                                 onFieldSubmitted: (_) =>
//                                     FocusScope.of(context).requestFocus(_contactFocus),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               flex: 3,
//                               child: AppDropdown<String>(
//                                 value: _selectedGender,
//                                 label: AppStrings.gender,
//                                 hint: 'Select',
//                                 prefixIcon: Icons.wc_rounded,
//                                 items: Gender.values
//                                     .map(
//                                       (g) => DropdownMenuItem(
//                                         value: g.label,
//                                         child: Text(g.label),
//                                       ),
//                                     )
//                                     .toList(),
//                                 onChanged: (v) => setState(() => _selectedGender = v),
//                                 validator: (v) => v == null ? 'Select gender' : null,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ]),

//                       const SizedBox(height: 24),

//                       // Contact section
//                       _buildSectionTitle('CONTACT DETAILS'),
//                       const SizedBox(height: 12),
//                       _buildCard([
//                         AppTextField(
//                           controller: _contactController,
//                           label: AppStrings.contactNumber,
//                           hint: '+91 98765 43210',
//                           prefixIcon: Icons.phone_outlined,
//                           keyboardType: TextInputType.phone,
//                           validator: Validators.phone,
//                           focusNode: _contactFocus,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-]')),
//                           ],
//                           textInputAction: TextInputAction.next,
//                           onFieldSubmitted: (_) =>
//                               FocusScope.of(context).requestFocus(_emailFocus),
//                         ),
//                         const SizedBox(height: 14),
//                         AppTextField(
//                           controller: _emailController,
//                           label: 'Email Address',
//                           hint: 'example@email.com',
//                           prefixIcon: Icons.email_outlined,
//                           keyboardType: TextInputType.emailAddress,
//                           focusNode: _emailFocus,
//                           textInputAction: TextInputAction.next,
//                           onFieldSubmitted: (_) =>
//                               FocusScope.of(context).requestFocus(_addressFocus),
//                         ),
//                         const SizedBox(height: 14),
//                         AppTextField(
//                           controller: _addressController,
//                           label: AppStrings.address,
//                           hint: 'House no., street, city, state',
//                           prefixIcon: Icons.location_on_outlined,
//                           maxLines: 3,
//                           textCapitalization: TextCapitalization.sentences,
//                           validator: (v) => Validators.required(v, fieldName: 'Address'),
//                           focusNode: _addressFocus,
//                           textInputAction: TextInputAction.done,
//                         ),
//                       ]),

//                       const SizedBox(height: 36),

//                       AppPrimaryButton(
//                         label: AppStrings.nextStep,
//                         onPressed: _onNext,
//                         isLoading: isSaving,
//                         icon: null,
//                       ),

//                       const SizedBox(height: 32),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Row(
//       children: [
//         Container(
//           width: 3,
//           height: 14,
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: GoogleFonts.dmSans(
//             fontSize: 11,
//             fontWeight: FontWeight.w700,
//             color: AppColors.textSecondary,
//             letterSpacing: 1.2,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCard(List<Widget> children) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.border, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: children,
//       ),
//     );
//   }
// }



// FIX 3: parent_info_screen.dart was referencing fields that don't exist in
// ParentModel (age, gender) and calling saveParent() with the wrong signature.
// It was also using a Gender enum that doesn't exist anywhere in the codebase.
//
// Since parent_profile_screen.dart covers exactly the same purpose with correct
// code, this file simply re-exports it. All navigation to RouteConstants.parentInfo
// (currently only the "Edit" button in profile_screen.dart) will land on the
// fully working ParentProfileScreen.

export 'parent_profile_screen.dart';
