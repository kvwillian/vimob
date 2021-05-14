class StatusFilter {
  int amount;
  bool selected;
  String status;

  bool operator ==(other) =>
      other is StatusFilter && toString() == other.toString();

  int get hashCode => status.hashCode;

  @override
  String toString() {
    return "status: $status, amount: $amount, selected: $selected";
  }
}

enum FilterRange { max, min, currentMax, currentMin }
