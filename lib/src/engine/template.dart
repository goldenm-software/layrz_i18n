import 'package:flutter/widgets.dart';

/// Base class for message template tokens.
///
/// Internal implementation detail. Represents a parsed element (literal text,
/// plain argument, or rich text argument) within a message template.
sealed class MessageToken {}

/// Literal text token.
///
/// Internal implementation detail. Represents a sequence of literal text
/// that has no special markers.
final class LiteralToken implements MessageToken {
  /// Creates a literal text token.
  const LiteralToken(this.text);

  /// The literal text content.
  final String text;
}

/// Plain string argument token (marker: `{name}`).
///
/// Internal implementation detail. Represents a plain text argument marker
/// that will be replaced with a string value during rendering.
final class ArgToken implements MessageToken {
  /// Creates a plain argument token.
  const ArgToken(this.name);

  /// The argument name.
  final String name;
}

/// Rich text argument token (marker: `[name]`).
///
/// Internal implementation detail. Represents a rich text argument marker
/// that will be replaced with an [InlineSpan] during rendering.
final class RichArgToken implements MessageToken {
  /// Creates a rich argument token.
  const RichArgToken(this.name);

  /// The argument name.
  final String name;
}

/// A compiled message template with tokenized forms for efficient rendering.
///
/// Internal implementation detail. Stores the parsed and tokenized forms of
/// a message string for efficient rendering with both plain and rich text arguments.
final class MessageTemplate {
  /// Creates a message template with tokenized forms.
  const MessageTemplate({required this.tokens, required this.forms});

  /// All tokens in the message (used by [render] and [renderRich]).
  final List<MessageToken> tokens;

  /// Plural forms (length 1 or 2); produced by splitting raw message on ' | ' before tokenizing.
  final List<List<MessageToken>> forms;

  /// Renders the given tokens with plain string arguments.
  ///
  /// Arguments:
  /// [tokens] the tokens to render
  /// [args] map of argument names to values
  ///
  /// Returns:
  /// The rendered plain text string.
  String render(List<MessageToken> tokens, Map<String, dynamic> args) {
    final buffer = StringBuffer();
    for (final token in tokens) {
      if (token is LiteralToken) {
        buffer.write(token.text);
      } else if (token is ArgToken) {
        if (args.containsKey(token.name)) {
          buffer.write('${args[token.name]}');
        } else {
          buffer.write('{${token.name}}');
        }
      } else if (token is RichArgToken) {
        buffer.write('[${token.name}]');
      }
    }
    return buffer.toString();
  }

  /// Renders the given tokens with rich text arguments.
  ///
  /// Arguments:
  /// [tokens] the tokens to render
  /// [args] map of argument names to plain string values
  /// [richArgs] map of argument names to [InlineSpan] values
  /// [style] optional base text style
  ///
  /// Returns:
  /// A [TextSpan] tree with rich formatting applied.
  TextSpan renderRich(
    List<MessageToken> tokens,
    Map<String, dynamic> args,
    Map<String, InlineSpan> richArgs,
    TextStyle? style,
  ) {
    final spans = <InlineSpan>[];
    for (final token in tokens) {
      if (token is LiteralToken) {
        if (token.text.isNotEmpty) {
          spans.add(TextSpan(text: token.text, style: style));
        }
      } else if (token is ArgToken) {
        final value = args.containsKey(token.name) ? '${args[token.name]}' : '{${token.name}}';
        if (value.isNotEmpty) {
          spans.add(TextSpan(text: value, style: style));
        }
      } else if (token is RichArgToken) {
        if (richArgs.containsKey(token.name)) {
          spans.add(richArgs[token.name]!);
        } else {
          spans.add(TextSpan(text: '[${token.name}]', style: style));
        }
      }
    }

    return TextSpan(children: spans.isNotEmpty ? spans : null, style: style);
  }
}

/// Tokenizes a raw message string into a [MessageTemplate].
///
/// Internal implementation detail. Parses a message string and splits it into
/// plural forms (separated by ' | '), then tokenizes each form.
MessageTemplate tokenizeMessage(String rawMessage) {
  final forms = rawMessage.split(' | ').map(_tokenizeForm).toList(growable: false);
  return MessageTemplate(
    tokens: _tokenizeForm(rawMessage),
    forms: forms,
  );
}

/// Tokenizes a single form (substring between ' | ' separators).
List<MessageToken> _tokenizeForm(String form) {
  final tokens = <MessageToken>[];
  final buffer = StringBuffer();

  int i = 0;
  while (i < form.length) {
    final char = form[i];

    if (char == '{') {
      // Flush accumulated literal text
      if (buffer.isNotEmpty) {
        tokens.add(LiteralToken(buffer.toString()));
        buffer.clear();
      }

      // Scan for closing }
      int end = i + 1;
      while (end < form.length && form[end] != '}') {
        end++;
      }

      if (end < form.length) {
        // Found closing }
        final name = form.substring(i + 1, end);
        if (name.isNotEmpty) {
          tokens.add(ArgToken(name));
          i = end + 1;
        } else {
          // Empty name, emit as literal and continue
          buffer.write(char);
          i++;
        }
      } else {
        // No closing }, emit opening { as literal
        buffer.write(char);
        i++;
      }
    } else if (char == '[') {
      // Flush accumulated literal text
      if (buffer.isNotEmpty) {
        tokens.add(LiteralToken(buffer.toString()));
        buffer.clear();
      }

      // Scan for closing ]
      int end = i + 1;
      while (end < form.length && form[end] != ']') {
        end++;
      }

      if (end < form.length) {
        // Found closing ]
        final name = form.substring(i + 1, end);
        if (name.isNotEmpty) {
          tokens.add(RichArgToken(name));
          i = end + 1;
        } else {
          // Empty name, emit as literal and continue
          buffer.write(char);
          i++;
        }
      } else {
        // No closing ], emit opening [ as literal
        buffer.write(char);
        i++;
      }
    } else {
      buffer.write(char);
      i++;
    }
  }

  // Flush remaining literal text
  if (buffer.isNotEmpty) {
    tokens.add(LiteralToken(buffer.toString()));
  }

  return tokens;
}

/// Cache of compiled message templates, keyed by raw message string.
final Map<String, MessageTemplate> _templateCache = {};

/// Gets or creates a compiled template for the given raw message.
///
/// Internal implementation detail. Caches compiled templates to avoid
/// re-tokenizing the same message string multiple times.
MessageTemplate getTemplate(String rawMessage) {
  var template = _templateCache[rawMessage];
  if (template != null) return template;

  template = tokenizeMessage(rawMessage);
  if (_templateCache.length >= 1024) {
    _templateCache.clear();
  }
  _templateCache[rawMessage] = template;
  return template;
}

/// Number of compiled message templates currently cached. Exposed for testing.
@visibleForTesting
int get cachedTemplateCount => _templateCache.length;

/// Clears the compiled-template cache. Exposed for testing.
@visibleForTesting
void clearTemplateCache() => _templateCache.clear();
