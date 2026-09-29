import '../entities/premium_status.dart';
import '../repositories/premium_repository.dart';

class GetPremiumStatus {
  final PremiumRepository repository;

  const GetPremiumStatus(this.repository);

  Future<PremiumStatus> call() {
    return repository.getPremiumStatus();
  }
}
