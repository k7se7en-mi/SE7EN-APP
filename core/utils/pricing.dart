class Pricing {
  // VAT في السعودية غالباً 15%
  static const double kVatRate = 0.15;

  // رسوم الدفع عند الاستلام
  static const double kCodFee = 19.0;

  static double subtotal(Iterable<double> items) =>
      items.fold(0.0, (p, n) => p + n);

  static double vat(double sub) => sub * kVatRate;

  static double total({
    required Iterable<double> items,
    bool withCod = false,
  }) {
    final sub = subtotal(items);
    final tax = vat(sub);
    final cod = withCod ? kCodFee : 0.0;
    return sub + tax + cod;
  }
}