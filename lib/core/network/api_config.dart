/// Real backend base URL (verified running).
/// Centralized single source of truth — do NOT duplicate this URL elsewhere.
/// Do NOT change to localhost or any other trycloudflare URL.
abstract final class ApiConfig {
  static const baseUrl = 'https://smart-attendance-smoky.vercel.app';
  static const loginPath = '/api/v1/auth/login';
}
