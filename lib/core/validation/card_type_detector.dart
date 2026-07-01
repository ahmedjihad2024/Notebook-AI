enum CardType {
  visa,
  mastercard,
  americanExpress,
  discover,
  unknown;

  String get displayName => switch (this) {
    visa => 'Visa',
    mastercard => 'Mastercard',
    americanExpress => 'American Express',
    discover => 'Discover',
    unknown => 'Unknown',
  };

  String get logoPath => switch (this) {
    visa => 'assets/images/visa.png',
    mastercard => 'assets/images/mastercard.png',
    americanExpress => 'assets/images/amex.png',
    discover => 'assets/images/discover.png',
    unknown => 'assets/images/visa.png', // Default fallback
  };

  int get maxLength => switch (this) {
    americanExpress => 15,
    _ => 16,
  };

  int get cvvLength => switch (this) {
    americanExpress => 4,
    _ => 3,
  };
}

class CardTypeDetector {
  static CardType detectCardType(String cardNumber) {
    // Remove all non-digit characters
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.isEmpty) return CardType.unknown;

    // Visa: starts with 4
    if (cleanNumber.startsWith('4')) {
      return CardType.visa;
    }

    // Mastercard: starts with 51-55 or 2221-2720
    if (RegExp(r'^5[1-5]').hasMatch(cleanNumber) ||
        RegExp(r'^2[2-7][2-9][0-9]').hasMatch(cleanNumber) ||
        RegExp(r'^27[0-1][0-9]').hasMatch(cleanNumber) ||
        RegExp(r'^2720').hasMatch(cleanNumber)) {
      return CardType.mastercard;
    }

    // American Express: starts with 34 or 37
    if (RegExp(r'^3[47]').hasMatch(cleanNumber)) {
      return CardType.americanExpress;
    }

    // Discover: starts with 6011, 622126-622925, 644-649, 65
    if (cleanNumber.startsWith('6011') ||
        RegExp(
          r'^622(12[6-9]|1[3-9][0-9]|[2-8][0-9][0-9]|9[0-1][0-9]|92[0-5])',
        ).hasMatch(cleanNumber) ||
        RegExp(r'^64[4-9]').hasMatch(cleanNumber) ||
        cleanNumber.startsWith('65')) {
      return CardType.discover;
    }

    return CardType.unknown;
  }

  static String formatCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    final cardType = detectCardType(cleanNumber);

    if (cardType == CardType.americanExpress) {
      // Format as XXXX XXXXXX XXXXX
      if (cleanNumber.length <= 4) return cleanNumber;
      if (cleanNumber.length <= 10)
        return '${cleanNumber.substring(0, 4)} ${cleanNumber.substring(4)}';
      return '${cleanNumber.substring(0, 4)} ${cleanNumber.substring(4, 10)} ${cleanNumber.substring(10, 15)}';
    } else {
      // Format as XXXX XXXX XXXX XXXX
      final groups = <String>[];
      for (int i = 0; i < cleanNumber.length; i += 4) {
        if (i + 4 <= cleanNumber.length) {
          groups.add(cleanNumber.substring(i, i + 4));
        } else {
          groups.add(cleanNumber.substring(i));
        }
      }
      return groups.join(' ');
    }
  }

  static String formatExpiryDate(String expiryDate) {
    final cleanDate = expiryDate.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanDate.length <= 2) return cleanDate;
    return '${cleanDate.substring(0, 2)}/${cleanDate.substring(2, 4)}';
  }

  static String maskCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length < 4) return cardNumber;

    final lastFour = cleanNumber.substring(cleanNumber.length - 4);
    final maskedPart = '*' * (cleanNumber.length - 4);
    return '$maskedPart $lastFour';
  }
}
