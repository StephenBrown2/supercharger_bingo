import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/services/api_service.dart';
import 'package:supercharger_bingo/services/write_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('delete uses the session and exact check-in ID', () async {
    final dio = Dio();
    final api = ApiService(dio: dio, sessionId: 'test');
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          expect(request.method, 'GET');
          expect(request.uri.path, '/supercharging/misc.php');
          expect(request.queryParameters, {
            'action': 'delete_checkin',
            'checkin_id': 90105,
          });
          expect(request.headers['cookie'], contains('SCLSESSION=test'));
          handler.resolve(
            Response(
              requestOptions: request,
              statusCode: 302,
              headers: Headers.fromMap({
                'location': ['/supercharging/'],
              }),
            ),
          );
        },
      ),
    );
    final result = await api.deleteCheckin(90105);
    expect(result.outcome, WriteOutcome.accepted);
  });

  for (final status in [200, 302, 401, 500]) {
    test(
      'delete preserves local data on ambiguous, login, or error response $status',
      () async {
        final dio = Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (request, handler) => handler.resolve(
                Response(
                  requestOptions: request,
                  statusCode: status,
                  data: 'Could not delete check-in',
                  headers: Headers.fromMap({
                    if (status == 302) 'location': ['/login.php'],
                  }),
                ),
              ),
            ),
          );
        final result = await ApiService(
          dio: dio,
          sessionId: 'test',
        ).deleteCheckin(90105);
        expect(result.outcome, isNot(WriteOutcome.accepted));
      },
    );
  }
}
