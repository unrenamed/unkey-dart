# Rate Limiting and Access Control Middleware for Dart Shelf Web Server

This [Dart](https://dart.dev/) application implements middleware for the [Shelf](https://pub.dev/packages/shelf) web server that enables rate limiting for all `/api/` endpoints and restricts access to specific `/api/v2` endpoints based on authorization tokens validated through the [Unkey API](https://www.unkey.com/docs/api-reference/overview). The solution is designed to enhance API security and manage user access while providing seamless integration for developers.

## Features & Benefits

- **Rate Limiting**\
  Limits requests to /api/ endpoints to prevent abuse.
- **IP-Based Rate Limiting**\
  Uses the `x-forwarded-for` header for accurate user identification.
- **Authorization for Premium Features**\
  Restricts `/api/v2` access to users with valid Unkey API keys.
- **Public API Access**\
  Allows unrestricted use of `/api/v1` and root `/` endpoints.

## Use Cases

- **API Management**\
  Controls access and prevents abuse of API endpoints.
- **Feature Flagging**\
  Enables features for testers without public exposure.
- **Dynamic User Access Control**\
  Simplifies permission management across API versions.

## Route Overview

| Method | Endpoint                 | Required Headers                                         | Description                 |
| ------ | ------------------------ | -------------------------------------------------------- | --------------------------- |
| GET    | `/`                      | None                                                     | Returns the welcome message |
| GET    | `/api/v1/echo/<message>` | `x-forwarded-for: <ip>`                                  | Returns the echoed message  |
| GET    | `/api/v1/users`          | `x-forwarded-for: <ip>`                                  | Retrieves a list of users   |
| GET    | `/api/v1/users/<id>`     | `x-forwarded-for: <ip>`                                  | Retrieves a user by ID      |
| POST   | `/api/v2/users`          | `x-forwarded-for: <ip>`, `Authorization: Bearer <token>` | Adds a new user             |
| PUT    | `/api/v2/users/<id>`     | `x-forwarded-for: <ip>`, `Authorization: Bearer <token>` | Updates an existing user    |
| DELETE | `/api/v2/users/<id>`     | `x-forwarded-for: <ip>`, `Authorization: Bearer <token>` | Deletes a user by ID        |

## Quickstart Guide

### Create a Unkey Root Key

1. Navigate to [Unkey Root Keys](https://app.unkey.com/settings/root-key) and click **"Create New Root Key"**.
2. Name your root key.
3. Select the following workspace permissions:
   - `create_key`
   - `read_key`
   - `encrypt_key`
   - `decrypt_key`
4. Click **"Create"** and save your root key securely.

### Create a Unkey API

1. Go to [Unkey APIs](https://app.unkey.com/apis) and click **"Create New API"**.
2. Enter a name for the API.
3. Click **"Create"**.

### Create a Unkey ratelimit namespace

1. Go to [Unkey Ratelimits](https://app.unkey.com/ratelimits) and click **"Create New Namespace"**.
2. Enter a name for the namespace.
3. Click **"Create"**.

### Generate Your First Unkey API Key

1. From the [Unkey APIs](https://app.unkey.com/apis) page, select your newly created API.
2. Click **"Create Key"** in the top right corner.
3. Fill out the form with the following suggested values:
   - Prefix: `dart.rest.api`
   - Owner: `superuser`
   - Bytes: `30`
4. Click **"Create"** and copy the generated key. You'll use it instead of `<token>` in `/api/v2` routes.

### Running the sample

1. Clone the repository to your local machine:

   ```bash
   git clone git@github.com:unrenamed/unkey-dart
   cd unkey-dart
   ```

2. Create a `.env` file in the root directory and populate it with the following environment variables:

   ```env
   UNKEY_ROOT_KEY=your-unkey-root-key
   UNKEY_API_ID=your-unkey-api-id
   UNKEY_NAMESPACE=your-unkey-namespace
   ```

   Ensure you replace `your-unkey-*` with your actual Unkey credentials.

3. Start the server:

   You can run the example with the [Dart SDK](https://dart.dev/get-dart)
   like this:

   ```
   $ dart run bin/server.dart
   Server listening on port 8080
   ```

   If you have [Docker Desktop](https://www.docker.com/get-started) installed, you can build and run with the `docker` command:

   ```
   $ docker build . -t myserver
   $ docker run -it -p 8080:8080 myserver
   Server listening on port 8080
   ```
