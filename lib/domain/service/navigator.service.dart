import 'package:squirrel/domain/entities/order.entity.dart';
import 'package:squirrel/foundation/routing/app_router.dart';

/// Navigator service
class NavigatorService {
  /// Navigate to details
  ///
  void navigateToDetails(Order order) {
    appRouter.pushNamed(
      'order-details',
      pathParameters: {'orderId': order.id},
      extra: order,
    );
  }

  Future<void> navigateToHome() async {
    appRouter.go('/main');
  }
}
