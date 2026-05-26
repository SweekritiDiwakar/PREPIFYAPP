enum InviteResult {
  success,
  userNotFound,
  alreadyMember,
  isSelf,
  listNotFound,
  notLoggedIn;

  String get message => switch (this) {
    InviteResult.success       => 'Member added successfully!',
    InviteResult.userNotFound  => 'No user found with that username or email.',
    InviteResult.alreadyMember => 'This person is already in the list.',
    InviteResult.isSelf        => 'You can\'t invite yourself.',
    InviteResult.listNotFound  => 'List not found.',
    InviteResult.notLoggedIn   => 'You must be logged in.',
  };

  bool get isSuccess => this == InviteResult.success;
}