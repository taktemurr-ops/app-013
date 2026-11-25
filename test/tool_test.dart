import 'package:flutter_test/flutter_test.dart';
import 'package:uyg_ilac_hatirlatici/uyg_ilac_hatirlatici.dart';

void main() {
  test('33 dilde ad ve açıklama, doğru kimlik', () {
    expect(ilacHatirlaticiTool.id, ilacHatirlaticiId);
    expect(ilacHatirlaticiTool.title.length, 33);
    expect(ilacHatirlaticiTool.tagline.length, 33);
  });
}
