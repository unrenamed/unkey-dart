import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './utils.dart';

const String unkeyApiUrl = 'https://api.unkey.dev/v1';

Middleware rateLimit() {
  return (Handler innerHandler) {
    return (Request request) async {
      final envVars = DotEnv(includePlatformEnvironment: true)..load();

      // Extract the IP address from the 'x-forwarded-for' header
      final forwardedFor = request.headers['x-forwarded-for'];
      final ip = forwardedFor?.split(',').first.trim() ??
          request.context['remote-addr']?.toString() ??
          '';

      if (ip.isEmpty) {
        return Response.forbidden('IP address not found\n');
      }

      final unkeyRootKey = envVars["UNKEY_ROOT_KEY"];
      final unkeyNamespace = envVars["UNKEY_NAMESPACE"];

      // Make a rate-limit request to Unkey API
      final response = await http.post(
        Uri.parse('$unkeyApiUrl/ratelimits.limit'),
        headers: {
          'Authorization': 'Bearer $unkeyRootKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'namespace': unkeyNamespace,
          'identifier': ip, // Use the IP as the identifier
          'limit': 10,
          'duration': 30000, // 30 seconds
        }),
      );

      if (response.statusCode == 200) {
        // Process the rate limit response
        final jsonResponse = jsonDecode(response.body);
        final isRateLimited = jsonResponse['success'] == false;

        if (isRateLimited) {
          final message = 'Rate limit exceeded!\n'
              'Your IP: $ip\n'
              'Retry in ${(timeUntilDate(jsonResponse['reset']))}.\n'
              '${jsonResponse['remaining']} requests left until reset.';

          return Response(429, body: message);
        }

        // If not rate-limited, proceed to handle the request
        return innerHandler(request);
      } else {
        // Handle errors from the Unkey API
        return Response.internalServerError(body: 'Rate limit check failed\n');
      }
    };
  };
}

Middleware checkFeatureAccess() {
  return (Handler innerHandler) {
    return (Request request) async {
      final envVars = DotEnv(includePlatformEnvironment: true)..load();
      final authHeader = request.headers['Authorization'];

      // Check if the Authorization header exists and starts with 'Bearer '
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden('Authorization header missing or invalid');
      }

      // Extract the token by removing the 'Bearer ' prefix
      final token = authHeader.substring(7);

      // Make a verification request to Unkey API
      final response = await http.post(
        Uri.parse('$unkeyApiUrl/keys.verifyKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'apiId': envVars['UNKEY_API_ID'], 'key': token}),
      );

      if (response.statusCode == 200) {
        // Process the verification response
        final jsonResponse = jsonDecode(response.body);
        final isValid = jsonResponse['valid'] == true;

        if (!isValid) {
          return Response.forbidden(
              'Authorization token is invalid, expired, or lacks the required permissions for this action.\n');
        }

        // Attach the token to the request context for later use
        request = request.change(context: {'authToken': token});

        // If access is granted, proceed to handle the request
        return innerHandler(request);
      } else {
        // Handle errors from the Unkey API
        return Response.internalServerError(
            body: 'Key verification check failed\n');
      }
    };
  };
}
