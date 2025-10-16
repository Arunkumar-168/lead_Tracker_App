class Validator{
  static String? validateName({required String name}) {
    if (name.isEmpty) {
      return "name can't be empty";
    }
    return null;
  }

  static String? validateEmail({required String email}) {
    if (email.isEmpty) {
      return "email can't be empty";
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return "enter a valid email";
    }
    return null;
  }

  static String? validateCompany({required String company}) {
    if (company.isEmpty) {
      return "name can't be empty";
    }
    return null;
  }

  static String? validatePhone({required String phone}){
    if (phone.isEmpty) {
      return "phone Number can't be empty";
    } else if (phone.length < 10) {
      return "phone Number must be at 10 characters";
    }
    return null;
  }
  static String? validatePassword({required String password}){
    if (password.isEmpty) {
      return "password can't be empty";
    } else if (password.length < 6) {
      return "password must be at least 6 characters";
    }
    return null;
  }

}