class ListStringify {
  static String list1DStringify(List list) {
    String result = "[";
    list.forEach((element) {
      result += element.toString();
      result += " ,";
    });
    result += "]";
    return result;
  }
}
