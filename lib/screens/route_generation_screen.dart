// Add this import at the top of your file
import '../widgets/common/error_display.dart';

// In your build method where you show the route generation results
Widget _buildRouteContent() {
  switch (_routeProvider.status) {
    case RouteGenerationStatus.loading:
      return const Center(child: CircularProgressIndicator());
    case RouteGenerationStatus.error:
      return ErrorDisplay(
        message: _routeProvider.errorMessage ?? 'An error occurred while generating your route.',
        onRetry: () => _routeProvider.generateRoute(),
      );
    case RouteGenerationStatus.success:
      return _buildRouteDisplay();
    default:
      return _buildInputForm();
  }
}