import '../entities/premium_status.dart';

abstract class PremiumRepository {
  Future<PremiumStatus> getPremiumStatus();
}
