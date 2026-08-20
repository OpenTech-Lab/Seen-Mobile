import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mobile/features/metadata/metadata_service.dart';

void main() {
  test('recognizes a missing profile_private relation', () {
    expect(
      isMissingProfilePrivateTableError(
        const PostgrestException(
          message:
              "Could not find the table 'public.profile_private' in the schema cache",
          code: 'PGRST205',
        ),
      ),
      isTrue,
    );
  });

  test('does not treat unrelated PostgREST errors as a compatibility case', () {
    expect(
      isMissingProfilePrivateTableError(
        const PostgrestException(
          message: 'row level security violation',
          code: '42501',
        ),
      ),
      isFalse,
    );
  });
}
