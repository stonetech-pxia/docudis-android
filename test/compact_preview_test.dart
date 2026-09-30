import 'package:docudis/anonymize/ui/protect_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('short text is returned whole, trimmed', () {
    expect(compactPreview('  hello world \n'), 'hello world');
  });

  test('long text keeps the beginning and the last words', () {
    final words = List.generate(80, (i) => 'word$i');
    final out = compactPreview(words.join(' '));
    expect(out, startsWith('word0 word1'));
    expect(out, endsWith('word74 word75 word76 word77 word78 word79'));
    expect(out, contains(' … '));
    expect(out.length, lessThan(220));
  });

  test('text without spaces falls back to the last 20 characters', () {
    final text = '${List.generate(300, (i) => '字').join()}结尾在这里';
    final out = compactPreview(text);
    expect(out, endsWith('结尾在这里'));
    expect(out.split(' … ').last.length, 20);
  });
}
