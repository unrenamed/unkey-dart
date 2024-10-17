import 'package:shelf_router/shelf_router.dart';
import 'endpoints.dart';

const apiVersion = 'v1';
const nextApiVersion = 'v2';

// Configure root routes.
final rootRouter = Router()..get('/', rootHandler);

// Configure API v1 routes.
final v1Router = Router()
  ..get('/api/$apiVersion/echo/<message>', echoHandler)
  ..get('/api/$apiVersion/users', getUsers)
  ..get('/api/$apiVersion/users/<id>', getUserById);

// Configure API v2 routes.
final v2Router = Router()
  ..post('/api/$nextApiVersion/users', addUser)
  ..put('/api/$nextApiVersion/users/<id>', updateUser)
  ..delete('/api/$nextApiVersion/users/<id>', deleteUser);
