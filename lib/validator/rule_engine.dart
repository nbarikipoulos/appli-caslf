import 'package:caslf/validator/rule.dart';
import 'package:flutter/widgets.dart';

abstract interface class RuleProvider {
  Rule? getRule(String id);
}

class RulesEngine {
  final BuildContext _context;
  final RuleProvider _ruleProvider;

  RulesEngine._({
    required BuildContext context,
    required RuleProvider rulesProvider
  }): _context = context, _ruleProvider = rulesProvider;

  factory RulesEngine(
    BuildContext context,
    RuleProvider provider
  ) => RulesEngine._(context: context, rulesProvider: provider);

  String? validate(
    dynamic input,
    String ruleId,
    [Map? parameters]
  ) {
   String? result;

   Rule rule = _ruleProvider.getRule(ruleId)!; // FIXME !
   result = rule.validate(_context, input, parameters);

   return result;
  }
}
