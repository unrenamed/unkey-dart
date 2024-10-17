import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'router.dart';
import 'middleware.dart';

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure API route handlers
  final rootHandler =
      Pipeline().addMiddleware(logRequests()).addHandler(rootRouter.call);

  final apiV1Handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(rateLimit())
      .addHandler(v1Router.call);

  final apiV2Handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(rateLimit())
      .addMiddleware(checkFeatureAccess())
      .addHandler(v2Router.call);

  // Configure a main handler to route requests based on path
  final handler = Pipeline().addHandler((Request request) {
    if (request.url.path.startsWith('api/$apiVersion')) {
      return apiV1Handler(request);
    } else if (request.url.path.startsWith('api/$nextApiVersion')) {
      return apiV2Handler(request);
    }
    return rootHandler(request);
  });

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
