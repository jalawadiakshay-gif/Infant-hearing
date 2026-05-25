class ApiEndpoints {
  static const baseUrl = "https://your-backend-url.com/api";

  // Auth
  static const sendOtp = "/auth/send-otp";
  static const verifyOtp = "/auth/verify-otp";
  static const login = "/auth/login";
  static const register = "/auth/register";

  // Parent
  static const createParent = "/parent/create";
  static const getParent = "/parent/profile";

  // Baby
  static const createBaby = "/baby/create";
  static const getBabies = "/baby/list";

  // Questionnaire
  static const submitQuestionnaire = "/questionnaire/submit";
  static const getQuestionnaireResult = "/questionnaire/result";

  // BOA
  static const submitBoa = "/boa/submit";
  static const getBoaResult = "/boa/result";
}