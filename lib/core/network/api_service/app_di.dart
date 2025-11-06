// lib/app_di.dart


import 'package:alejandroloi/core/network/api_service/token_store.dart';

import '../../../repository/investment_repository.dart';
import '../../../services/investment_service.dart';
import 'api_client.dart';

class AppDI {
  static final _api = ApiClient(TokenStore()); // your secure storage impl
  static InvestmentRepository investmentRepo() =>
      InvestmentRepository(InvestmentService(_api));
}
