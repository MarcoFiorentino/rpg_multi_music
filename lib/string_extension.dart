extension StringExtension on String {
  // Restituisce la strinca con la prima lettera maiuscola
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

  // Converte una stringa in boolean
  bool toBoolean() {
    return (this.toLowerCase() == "true") ? true : false;
  }
}