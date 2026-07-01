extension NonNullInt on int? {
  int get orZero => this ?? 0;
}
