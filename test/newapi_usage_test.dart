import 'package:aivault/adapters/newapi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quotaPerDollar 换算常量（NewAPI：1 美元 = 500000 配额）', () {
    expect(NewApiAdapter.quotaPerDollar, 500000.0);
    expect(1000000 / NewApiAdapter.quotaPerDollar, 2.0);
    expect(250000 / NewApiAdapter.quotaPerDollar, 0.5);
  });

  test('能力声明：用量查询走 user/self 同一接口（随余额能力）', () {
    final caps = NewApiAdapter().capabilities;
    expect(caps.balance, isTrue);
    expect(caps.checkIn, isTrue);
    expect(caps.prewarm, isFalse);
  });
}
