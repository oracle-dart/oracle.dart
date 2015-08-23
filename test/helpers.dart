import 'package:oracle/oracle.dart' as oracle;
import 'package:matcher/matcher.dart';

Matcher throwsSqlException(int code) => new SqlExceptionThrownMatcher(code);

class SqlExceptionThrownMatcher extends Matcher {
  final int _code;

  const SqlExceptionThrownMatcher(this._code);

  bool matches(f, Map state) {
    try {
      f();
      addStateInfo(state, {'failure_type': 'fuction retuned normally'});
      return false;
    } catch (e) {
      if (e is! oracle.SqlException) {
        addStateInfo(state, {
          'failure_type': 'expected SqlException, got ${e.runtimeType}'
        });
        return false;
      } else if (_code != e.code) {
        print('rawr');
        addStateInfo(state, {
          'failure_type':
              'error code mismatch: expected <$_code>, got <${e.code}>'
        });
        return false;
      }

      return true;
    }
  }

  Description describe(Description description) =>
      description.add('a SqlException with error code <$_code> to be thrown');

  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription.add(matchState['failure_type']);
  }
}
