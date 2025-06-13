import 'package:caslf/services/service.dart';
import 'package:caslf/validator/rule.dart';
import 'package:caslf/validator/rule_engine.dart';
import 'package:caslf/validator/rules/default_rules.dart';
import 'package:flutter/widgets.dart';

class RulesService implements Service, RuleProvider {
  RulesService._();

  static RulesService? _instance;
  factory RulesService() => _instance ??= RulesService._();

  final List<RuleProvider> _ruleProviders = [];

  @override
  Rule? getRule(String id) {
    Rule? result;

    var it = _ruleProviders.iterator;
    RuleProvider provider;

    while(result == null && it.moveNext()) {
      provider = it.current;
      result = provider.getRule(id);
    }

    return result;
  }

  RulesEngine create(
    BuildContext context,
    [RuleProvider? provider]
  ) => RulesEngine(context, provider ?? this);

  @override
  Future<void> init() {
    _ruleProviders.add(DefaultRules());

    return  Future.value();
  }

  @override
  Future<void> clear() => Future.value();
}
