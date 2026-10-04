enum AccountType {
  schoolAdmin,
  student,
  parent,
  teacher,
}

extension AccountTypeLabel on AccountType {
  String get label {
    switch (this) {
      case AccountType.schoolAdmin:
        return 'School / Admin';
      case AccountType.student:
        return 'Student';
      case AccountType.parent:
        return 'Parent';
      case AccountType.teacher:
        return 'Teacher';
    }
  }

  String get apiValue {
    switch (this) {
      case AccountType.schoolAdmin:
        return 'school_admin';
      case AccountType.student:
        return 'student';
      case AccountType.parent:
        return 'parent';
      case AccountType.teacher:
        return 'teacher';
    }
  }
}
