import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/drivers/errors.dart';
import 'package:flutter_bzaru/helper/config.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/providers/auth_provider.dart';
import 'package:flutter_bzaru/resource/dio_client.dart';
import 'package:flutter_bzaru/resource/repository/bussiness_repository.dart';
import 'package:flutter_bzaru/resource/repository/customer_repository.dart';
import 'package:flutter_bzaru/resource/repository/order_repository.dart';
import 'package:flutter_bzaru/resource/repository/repository.dart';
import 'package:flutter_bzaru/resource/services/api_gateway.dart';
import 'package:flutter_bzaru/resource/services/api_gateway_impl.dart';
import 'package:flutter_bzaru/resource/services/firebase/analytics_service.dart';
import 'package:flutter_bzaru/resource/services/firebase/auth_service.dart';
import 'package:flutter_bzaru/resource/services/firebase/customer_firebase_service.dart';
import 'package:flutter_bzaru/resource/services/firebase/firebase_service.dart';
import 'package:flutter_bzaru/resource/services/firebase/merchant_firebase_Service.dart';
import 'package:flutter_bzaru/resource/services/firebase/order_Service.dart';
import 'package:flutter_bzaru/resource/session/session_impl.dart';
import 'package:flutter_bzaru/resource/session/session_service.dart';
import 'package:get_it/get_it.dart';

import 'resource/services/listeners/firebase_listeners.dart';

void setUpDependency(Config config) {
  final serviceLocator = GetIt.instance;

  String localeName = Platform.localeName ?? "en_US";
  String languageCode = localeName.split('_')[0];
  serviceLocator.registerSingleton<Locale>(
    Locale(languageCode),
    instanceName: 'locale',
  );

  serviceLocator.registerSingleton<AuthService>(AuthService(
      auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));
  serviceLocator.registerSingleton<FirebaseService>(FirebaseService(
      auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));
  serviceLocator.registerSingleton<OrderService>(
      OrderService(firestore: FirebaseFirestore.instance));
  serviceLocator.registerSingleton<MerchantFirebaseService>(
      MerchantFirebaseService(
          auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));
  serviceLocator.registerSingleton<CustomerFirebaseService>(
      CustomerFirebaseService(
          auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));
  serviceLocator
      .registerSingleton<SharedPrefrenceHelper>(SharedPrefrenceHelper());
  serviceLocator.registerSingleton<ErrorsProducer>(ErrorsProducer());
  serviceLocator.registerSingleton<FirebaseListeners>(
      FirebaseListeners(firestore: FirebaseFirestore.instance));
  serviceLocator.registerSingleton<AnalyticsService>(
      AnalyticsService(firestore: FirebaseFirestore.instance));
  serviceLocator.registerSingleton<ApiGateway>(
    ApiGatewayImpl(
      DioClient(Dio(), baseEndpoint: config.apiBaseUrl, logging: true),
      GetIt.instance<SharedPrefrenceHelper>(),
      GetIt.instance<AuthService>(),
      GetIt.instance<FirebaseService>(),
      GetIt.instance<MerchantFirebaseService>(),
      GetIt.instance<OrderService>(),
      GetIt.instance<CustomerFirebaseService>(),
      GetIt.instance<FirebaseListeners>(),
      GetIt.instance<AnalyticsService>(),
    ),
  );
  serviceLocator.registerFactory<SessionService>(
    () => SessionServiceImpl(
      GetIt.instance<SharedPrefrenceHelper>(),
    ),
  );
  serviceLocator.registerSingleton<AuthState>(AuthState());
  serviceLocator.registerSingleton<OrderRepository>(OrderRepository(
    GetIt.instance<ApiGateway>(),
    GetIt.instance<SessionService>(),
  ));
  serviceLocator.registerSingleton<Repository>(Repository(
    GetIt.instance<ApiGateway>(),
    GetIt.instance<SessionService>(),
  ));
  serviceLocator.registerSingleton<BussinessRepository>(BussinessRepository(
    GetIt.instance<ApiGateway>(),
    GetIt.instance<SessionService>(),
  ));
  serviceLocator.registerSingleton<CustomerRepository>(CustomerRepository(
    GetIt.instance<ApiGateway>(),
    GetIt.instance<SessionService>(),
  ));
}
