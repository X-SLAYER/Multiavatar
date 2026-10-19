import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiavatar/multiavatar.dart';

const _svgStart =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 231 231">';
const _svgEnd = '</svg>';
const _envPathPrefix = '<path d="M33.83,33.83a115.5,115.5,0,1,1,0,163.34';

String _digest(String value) => sha256.convert(utf8.encode(value)).toString();

void main() {
  group('multiavatar', () {
    test('returns an empty string for empty input', () {
      expect(multiavatar(''), isEmpty);
      expect(multiavatar('', trBackground: true), isEmpty);
    });

    test('produces a well-formed svg document', () {
      final svg = multiavatar('Pixelium');

      expect(svg, startsWith(_svgStart));
      expect(svg, endsWith(_svgEnd));
      expect(RegExp('<svg').allMatches(svg).length, 1);
      expect(RegExp('</svg>').allMatches(svg).length, 1);
    });

    test('is deterministic for the same input', () {
      expect(multiavatar('Pixelium'), multiavatar('Pixelium'));
      expect(
        multiavatar('X-SLAYER', trBackground: true),
        multiavatar('X-SLAYER', trBackground: true),
      );
    });

    test('produces different avatars for different inputs', () {
      final avatars = {
        for (final name in ['Pixelium', 'X-SLAYER', 'Binx Bond', 'Starcrasher'])
          multiavatar(name),
      };

      expect(avatars.length, 4);
    });

    test('is case sensitive', () {
      expect(multiavatar('pixelium'), isNot(multiavatar('Pixelium')));
    });

    test('includes the background circle by default', () {
      expect(multiavatar('Pixelium'), contains(_envPathPrefix));
    });

    test('removes only the background when trBackground is true', () {
      final withBackground = multiavatar('X-SLAYER');
      final withoutBackground = multiavatar('X-SLAYER', trBackground: true);

      expect(withoutBackground, isNot(contains(_envPathPrefix)));
      expect(withoutBackground, startsWith(_svgStart));
      expect(withoutBackground, endsWith(_svgEnd));

      // Stripping the background path from the full avatar must yield the
      // transparent one, so every other part is left untouched.
      final envEnd = withBackground.indexOf('/>', _svgStart.length) + 2;
      expect(
        _svgStart + withBackground.substring(envEnd),
        withoutBackground,
      );
    });

    test('supports unicode and long inputs', () {
      for (final input in ['محمد', '日本語', '🙂🚀', 'a' * 10000, ' ']) {
        final svg = multiavatar(input);
        expect(svg, startsWith(_svgStart), reason: input);
        expect(svg, endsWith(_svgEnd), reason: input);
      }
    });

    test('fills every color placeholder for a wide range of inputs', () {
      for (var i = 0; i < 1000; i++) {
        final svg = multiavatar('avatar-$i');

        expect(svg, startsWith(_svgStart), reason: 'avatar-$i');
        expect(svg, endsWith(_svgEnd), reason: 'avatar-$i');
        // A missing theme color would leave an empty value such as `fill:;`.
        expect(svg, isNot(contains(':;')), reason: 'avatar-$i');
        expect(svg, isNot(contains('null')), reason: 'avatar-$i');
      }
    });

    test('matches the reference output for known seeds', () {
      expect(_digest(multiavatar('Pixelium')), _pixeliumDigest);
      expect(
        _digest(multiavatar('X-SLAYER', trBackground: true)),
        _xSlayerTransparentDigest,
      );
    });
  });
}

// SHA-256 of the generated svg, pinned to catch unintended output changes.
const _pixeliumDigest =
    '2dacb03db221fa57f390214c308c17cad6fa6de5142243e21d3bae2fe09f8991';
const _xSlayerTransparentDigest =
    'a268d35ef4bac3bea4d784bc92dd03c29d6b412722ec78c25497d90dd866abad';
