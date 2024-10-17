import 'package:faker_dart/faker_dart.dart';

final faker = Faker.instance;

var users = generateUsers(50);

List<Map<String, dynamic>> generateUsers(int count) {
  return List.generate(count, (_) => createUser());
}

Map<String, dynamic> createUser() {
  return {
    'id': faker.datatype.uuid(),
    'firstName': faker.name.firstName(),
    'lastName': faker.name.lastName(),
    'email': faker.internet.email(),
    'address': faker.address.streetAddress(),
    'bio': faker.lorem.sentence(),
    'phone': faker.phoneNumber.phoneNumber(),
    'image': faker.image.image(),
    'company': faker.company.companyName(),
    'job': faker.name.jobTitle(),
    'website': faker.internet.url(),
    'createdAt': faker.date.past(DateTime.now()).toString(),
    'updatedAt': faker.date.past(DateTime.now()).toString(),
  };
}
