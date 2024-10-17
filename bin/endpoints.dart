import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'helpers.dart';
import 'utils.dart';

Response rootHandler(Request req) {
  return Response.ok("Hello, World!\n");
}

Response echoHandler(Request req) {
  final message = req.params['message'];
  return Response.ok('$message\n');
}

Response getUsers(Request req) => getList(req, users);
Response getUserById(Request req) => getItemById(req, users, 'User');
Response deleteUser(Request req) => deleteItem(req, users, 'User');
Future<Response> addUser(Request req) => addItem(req, users, 'User');
Future<Response> updateUser(Request req) => updateItem(req, users, 'User');
