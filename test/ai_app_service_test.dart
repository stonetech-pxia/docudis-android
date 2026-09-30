import 'package:docudis/anonymize/ai_apps.dart';
import 'package:docudis/anonymize/share_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingShare extends ShareService {
  const _RecordingShare(this.log);
  final List<String> log;

  @override
  Future<void> shareFile(String path, String fileName, {String mimeType = 'text/plain'}) async =>
      log.add('file:$path');

  @override
  Future<void> shareText(String text) async => log.add('text:$text');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];
  final shared = <String>[];
  late Future<Object?> Function(MethodCall) handler;
  final service = AiAppService(share: _RecordingShare(shared));

  setUp(() {
    calls.clear();
    shared.clear();
    handler = (call) async => false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AiAppService.channel, (call) {
      calls.add(call);
      return handler(call);
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AiAppService.channel, null);
  });

  test('android probes by package, iOS by scheme', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await service.isInstalled(AiApp.claude);
    expect(calls.single.arguments, {'package': 'com.anthropic.claude'});

    calls.clear();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await service.isInstalled(AiApp.claude);
    expect(calls.single.arguments, {'scheme': 'claude'});
  });

  test('installed() keeps only apps the platform reports', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    handler = (call) async => call.arguments['package'] == 'com.openai.chatgpt';
    expect(await service.installed(), [AiApp.chatgpt]);
  });

  test('unsupported platform reports nothing without touching the channel', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    expect(await service.installed(), isEmpty);
    expect(await service.open(AiApp.chatgpt), isFalse);
    expect(calls, isEmpty);
  });

  test('android sendFile goes direct when the app accepts it', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    handler = (call) async => true;
    expect(await service.sendFile(AiApp.chatgpt, '/r/1/output.txt', 'out.txt'), isTrue);
    expect(calls.single.method, 'sendFile');
    expect(calls.single.arguments['path'], '/r/1/output.txt');
    expect(shared, isEmpty);
  });

  test('android falls back to the share sheet when the app refuses', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(await service.sendText(AiApp.claude, 'hi'), isFalse);
    expect(shared, ['text:hi']);
  });

  test('iOS always uses the share sheet for sending', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(await service.sendFile(AiApp.claude, '/r/1/output.txt', 'out.txt'), isFalse);
    expect(calls, isEmpty);
    expect(shared, ['file:/r/1/output.txt']);
  });
}
