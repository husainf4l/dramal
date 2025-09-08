import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/dr_amal_damra_logo.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final AuthController _authController = Get.find<AuthController>();
  final ThemeController _themeController = Get.find<ThemeController>();

  // Focus nodes for automatic scrolling
  final FocusNode _loginEmailFocus = FocusNode();
  final FocusNode _loginPasswordFocus = FocusNode();
  final FocusNode _signupFirstNameFocus = FocusNode();
  final FocusNode _signupLastNameFocus = FocusNode();
  final FocusNode _signupEmailFocus = FocusNode();
  final FocusNode _signupPasswordFocus = FocusNode();
  final FocusNode _signupConfirmPasswordFocus = FocusNode();

  // Login form controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // Sign up form controllers
  final TextEditingController _signupFirstNameController =
      TextEditingController();
  final TextEditingController _signupLastNameController =
      TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController =
      TextEditingController();
  final TextEditingController _signupConfirmPasswordController =
      TextEditingController();

  final RxBool _isLoginLoading = false.obs;
  final RxBool _isSignupLoading = false.obs;
  final RxBool _isGoogleLoading = false.obs;
  final RxBool _isAppleLoading = false.obs;
  final RxBool _obscureLoginPassword = true.obs;
  final RxBool _obscureSignupPassword = true.obs;
  final RxBool _obscureSignupConfirmPassword = true.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    // Add focus listeners for automatic scrolling
    _loginEmailFocus.addListener(() => _scrollToFocusedField(_loginEmailFocus));
    _loginPasswordFocus
        .addListener(() => _scrollToFocusedField(_loginPasswordFocus));
    _signupFirstNameFocus
        .addListener(() => _scrollToFocusedField(_signupFirstNameFocus));
    _signupLastNameFocus
        .addListener(() => _scrollToFocusedField(_signupLastNameFocus));
    _signupEmailFocus
        .addListener(() => _scrollToFocusedField(_signupEmailFocus));
    _signupPasswordFocus
        .addListener(() => _scrollToFocusedField(_signupPasswordFocus));
    _signupConfirmPasswordFocus
        .addListener(() => _scrollToFocusedField(_signupConfirmPasswordFocus));
  }

  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus && mounted) {
      // Use addPostFrameCallback to ensure layout is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _scrollController.hasClients &&
            focusNode.context != null) {
          try {
            // Get the BuildContext from the focus node
            final BuildContext? fieldContext = focusNode.context;
            if (fieldContext != null) {
              // Calculate scroll position based on keyboard and field position
              final RenderBox? renderBox =
                  fieldContext.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final position = renderBox.localToGlobal(Offset.zero);
                final screenHeight = MediaQuery.of(fieldContext).size.height;
                final keyboardHeight =
                    MediaQuery.of(fieldContext).viewInsets.bottom;

                // Scroll to make the field visible above keyboard
                final targetScrollPosition = _scrollController.offset +
                    (position.dy - (screenHeight - keyboardHeight - 120));

                if (targetScrollPosition > 0) {
                  _scrollController.animateTo(
                    targetScrollPosition.clamp(
                        0.0, _scrollController.position.maxScrollExtent),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }
            }
          } catch (e) {
            // Fallback: just ensure content is visible
            if (_scrollController.position.maxScrollExtent > 0) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent * 0.5,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupFirstNameController.dispose();
    _signupLastNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();
    _signupFirstNameFocus.dispose();
    _signupLastNameFocus.dispose();
    _signupEmailFocus.dispose();
    _signupPasswordFocus.dispose();
    _signupConfirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginEmailController.text.isEmpty ||
        _loginPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    _isLoginLoading.value = true;

    final success = await _authController.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text,
    );

    _isLoginLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.snackbar(
        'Error',
        'Invalid email or password',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleSignup() async {
    if (_signupFirstNameController.text.isEmpty ||
        _signupLastNameController.text.isEmpty ||
        _signupEmailController.text.isEmpty ||
        _signupPasswordController.text.isEmpty ||
        _signupConfirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (_signupPasswordController.text !=
        _signupConfirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    _isSignupLoading.value = true;

    final success = await _authController.signUp(
      _signupEmailController.text.trim(),
      _signupPasswordController.text,
      firstName: _signupFirstNameController.text.trim(),
      lastName: _signupLastNameController.text.trim(),
    );

    _isSignupLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    _isGoogleLoading.value = true;

    final success = await _authController.signInWithGoogle();

    _isGoogleLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> _handleAppleSignIn() async {
    _isAppleLoading.value = true;

    final success = await _authController.signInWithApple();

    _isAppleLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 48),

                          // Minimal hero section
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                // Dr. Amal Damra Logo
                                DrAmalDamraLogo(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  height: 100,
                                  fontSize: 24,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Clean minimal tab bar
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              unselectedLabelColor: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                              labelStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              indicatorPadding: const EdgeInsets.all(2),
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Login'),
                                Tab(text: 'Sign Up'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tab content container with proper sizing
                          SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.7, // Fixed height for tab content
                            child: TabBarView(
                              controller: _tabController,
                              children: [_buildLoginTab(), _buildSignupTab()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }

  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Email field with Apple-style design
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _loginEmailController,
              focusNode: _loginEmailFocus,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.email_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Password field with Apple-style design
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _loginPasswordController,
                focusNode: _loginPasswordFocus,
                obscureText: _obscureLoginPassword.value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                ),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.45),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.lock_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  suffixIcon: IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    icon: Icon(
                      _obscureLoginPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      size: 20,
                    ),
                    onPressed: () => _obscureLoginPassword.toggle(),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Login button with Apple-style design
          Obx(
            () => Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoginLoading.value ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoginLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(
                        'Log In',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Forgot password with better styling
          TextButton(
            onPressed: () {
              Get.snackbar('Info', 'Forgot password feature coming soon!');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
            child: const Text('Forgot Password?'),
          ),

          const SizedBox(height: 32),

          // Divider with better styling
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  thickness: 0.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.55),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.05,
                      ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  thickness: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Social login buttons with Apple-style design
          Row(
            children: [
              // Google Sign In
              Expanded(
                child: Obx(() => Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                        ),
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).shadowColor.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: OutlinedButton.icon(
                        onPressed:
                            _isGoogleLoading.value ? null : _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: _isGoogleLoading.value
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              )
                            : Image.asset(
                                'assets/images/google_logo.png',
                                width: 18,
                                height: 18,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.g_mobiledata,
                                  size: 20,
                                  color: Colors.red,
                                ),
                              ),
                        label: Text(
                          'Google',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    )),
              ),

              const SizedBox(width: 12),

              // Apple Sign In
              Expanded(
                child: Obx(() => Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                        ),
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).shadowColor.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: OutlinedButton.icon(
                        onPressed:
                            _isAppleLoading.value ? null : _handleAppleSignIn,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: _isAppleLoading.value
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.apple,
                                size: 20,
                              ),
                        label: Text(
                          'Apple',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignupTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // First name field with Apple-style design
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _signupFirstNameController,
                focusNode: _signupFirstNameFocus,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                ),
                decoration: InputDecoration(
                  hintText: 'First Name',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.45),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.person_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Last name field with Apple-style design
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _signupLastNameController,
                focusNode: _signupLastNameFocus,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                ),
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.45),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.person_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email field with Apple-style design
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _signupEmailController,
                focusNode: _signupEmailFocus,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                ),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.45),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password field with Apple-style design
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _signupPasswordController,
                  focusNode: _signupPasswordFocus,
                  obscureText: _obscureSignupPassword.value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.45),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.lock_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                    suffixIcon: IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      icon: Icon(
                        _obscureSignupPassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                        size: 20,
                      ),
                      onPressed: () => _obscureSignupPassword.toggle(),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm password field with Apple-style design
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _signupConfirmPasswordController,
                  focusNode: _signupConfirmPasswordFocus,
                  obscureText: _obscureSignupConfirmPassword.value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.45),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.lock_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                    suffixIcon: IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      icon: Icon(
                        _obscureSignupConfirmPassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                        size: 20,
                      ),
                      onPressed: () => _obscureSignupConfirmPassword.toggle(),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sign up button with Apple-style design
            Obx(
              () => Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSignupLoading.value ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSignupLoading.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'Sign Up',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Terms and conditions with better styling
            Text(
              'By signing up, you agree to our Terms of Service and Privacy Policy',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.05,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Divider with better styling
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    thickness: 0.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Or continue with',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.55),
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.05,
                        ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    thickness: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Social login buttons with Apple-style design
            Row(
              children: [
                // Google Sign In
                Expanded(
                  child: Obx(() => Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                          ),
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: OutlinedButton.icon(
                          onPressed: _isGoogleLoading.value
                              ? null
                              : _handleGoogleSignIn,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _isGoogleLoading.value
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 18,
                                  height: 18,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.g_mobiledata,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                ),
                          label: Text(
                            'Google',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      )),
                ),

                const SizedBox(width: 12),

                // Apple Sign In
                Expanded(
                  child: Obx(() => Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                          ),
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: OutlinedButton.icon(
                          onPressed:
                              _isAppleLoading.value ? null : _handleAppleSignIn,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _isAppleLoading.value
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.apple,
                                  size: 20,
                                ),
                          label: Text(
                            'Apple',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
