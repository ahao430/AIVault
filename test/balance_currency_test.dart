import 'package:aivault/adapters/provider_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BalanceResult.withCurrency（余额币种覆盖）', () {
    test('覆盖币种并保留其他字段', () {
      const r = BalanceResult(
          amount: 65.85, currency: 'USD', success: true);
      final overridden = r.withCurrency('CNY');
      expect(overridden.amount, 65.85);
      expect(overridden.currency, 'CNY');
      expect(overridden.success, true);
      expect(overridden.message, isNull);
    });

    test('失败结果同样可覆盖（币种对失败展示无影响）', () {
      const r = BalanceResult(
          amount: 0, currency: 'USD', success: false, message: 'HTTP 401');
      final overridden = r.withCurrency('CNY');
      expect(overridden.success, false);
      expect(overridden.message, 'HTTP 401');
    });
  });
}
