class SecurityScoreEngine {
  int calculate({
    required bool screenLock,
    required bool usbDebugging,
    required bool developerOptions,
    required bool rooted,
    required bool emulator,
    required bool latestSecurityPatch,
    required bool deviceEncrypted,
  }) {
    int score = 100;

    if (!screenLock) score -= 20;
    if (usbDebugging) score -= 15;
    if (developerOptions) score -= 10;
    if (rooted) score -= 30;
    if (emulator) score -= 5;
    if (!latestSecurityPatch) score -= 20;
    if (!deviceEncrypted) score -= 10;

    if (score < 0) {
      score = 0;
    }

    return score;
  }
}
