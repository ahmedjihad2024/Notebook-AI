import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_u/app/services/firebase_messeging_services.dart';
import 'package:for_u/app/services/session_service.dart';
import 'package:for_u/app/services/storage_services/secure_storage_service.dart';
import 'package:for_u/app/services/storage_services/shared_prefrences_service.dart';
import 'package:for_u/app/services/storage_services/storage_service.dart';
import 'package:for_u/app/utils/overlay_loading/overlay_loading_manager.dart';
import 'package:for_u/app/utils/snackbar_helper.dart';
import 'package:notebook_ai/core/network/api/auth_api.dart';
import 'package:notebook_ai/core/network/api/captain_api.dart';
import 'package:notebook_ai/core/network/api/cashier_api.dart';
import 'package:notebook_ai/core/network/api/customer_api.dart';
import 'package:notebook_ai/core/network/dio_factory.dart';
import 'package:notebook_ai/core/repository/repository_impl.dart';
import 'package:for_u/domain/repository/repository.dart';
import 'package:for_u/domain/usecase/get_me_usecase.dart';
import 'package:for_u/domain/usecase/logout_usecase.dart';
import 'package:for_u/domain/usecase/register_device_usecase.dart';
import 'package:for_u/domain/usecase/request_otp_usecase.dart';
import 'package:for_u/domain/usecase/unregister_device_usecase.dart';
import 'package:for_u/domain/usecase/verify_otp_usecase.dart';
import 'package:for_u/domain/usecase/accept_order_usecase.dart';
import 'package:for_u/domain/usecase/get_captain_order_detail_usecase.dart';
import 'package:for_u/domain/usecase/get_captain_orders_usecase.dart';
import 'package:for_u/domain/usecase/get_captain_profile_usecase.dart';
import 'package:for_u/domain/usecase/mark_delivered_usecase.dart';
import 'package:for_u/domain/usecase/mark_failed_usecase.dart';
import 'package:for_u/domain/usecase/set_captain_availability_usecase.dart';
import 'package:for_u/domain/usecase/start_delivery_usecase.dart';
import 'package:for_u/domain/usecase/assign_captain_usecase.dart';
import 'package:for_u/domain/usecase/available_captains_usecase.dart';
import 'package:for_u/domain/usecase/reassign_captain_usecase.dart';
import 'package:for_u/domain/usecase/confirm_ready_usecase.dart';
import 'package:for_u/domain/usecase/get_cashier_order_detail_usecase.dart';
import 'package:for_u/domain/usecase/get_cashier_orders_usecase.dart';
import 'package:for_u/domain/usecase/get_cashier_profile_usecase.dart';
import 'package:for_u/domain/usecase/mark_item_prepared_usecase.dart';
import 'package:for_u/domain/usecase/mark_item_unavailable_usecase.dart';
import 'package:for_u/domain/usecase/reject_order_usecase.dart';
import 'package:for_u/domain/usecase/add_favorite_usecase.dart';
import 'package:for_u/domain/usecase/cancel_order_usecase.dart';
import 'package:for_u/domain/usecase/checkout_quote_usecase.dart';
import 'package:for_u/domain/usecase/coverage_check_usecase.dart';
import 'package:for_u/domain/usecase/create_address_usecase.dart';
import 'package:for_u/domain/usecase/create_order_usecase.dart';
import 'package:for_u/domain/usecase/delete_account_usecase.dart';
import 'package:for_u/domain/usecase/delete_address_usecase.dart';
import 'package:for_u/domain/usecase/get_addresses_usecase.dart';
import 'package:for_u/domain/usecase/get_categories_usecase.dart';
import 'package:for_u/domain/usecase/get_customer_order_detail_usecase.dart';
import 'package:for_u/domain/usecase/get_customer_orders_usecase.dart';
import 'package:for_u/domain/usecase/get_favorites_usecase.dart';
import 'package:for_u/domain/usecase/get_notifications_usecase.dart';
import 'package:for_u/domain/usecase/get_product_detail_usecase.dart';
import 'package:for_u/domain/usecase/get_products_usecase.dart';
import 'package:for_u/domain/usecase/get_profile_usecase.dart';
import 'package:for_u/domain/usecase/get_unread_notifications_count_usecase.dart';
import 'package:for_u/domain/usecase/mark_all_notifications_read_usecase.dart';
import 'package:for_u/domain/usecase/open_ticket_usecase.dart';
import 'package:for_u/domain/usecase/get_tickets_usecase.dart';
import 'package:for_u/domain/usecase/get_ticket_usecase.dart';
import 'package:for_u/domain/usecase/reply_ticket_usecase.dart';
import 'package:for_u/domain/usecase/open_cashier_ticket_usecase.dart';
import 'package:for_u/domain/usecase/open_captain_ticket_usecase.dart';
import 'package:for_u/domain/usecase/get_delivery_zones_usecase.dart';
import 'package:for_u/domain/usecase/get_legal_policies_usecase.dart';
import 'package:for_u/domain/usecase/mark_notification_read_usecase.dart';
import 'package:for_u/domain/usecase/places_autocomplete_usecase.dart';
import 'package:for_u/domain/usecase/places_details_usecase.dart';
import 'package:for_u/domain/usecase/rate_order_usecase.dart';
import 'package:for_u/domain/usecase/remove_favorite_usecase.dart';
import 'package:for_u/domain/usecase/update_address_usecase.dart';
import 'package:for_u/domain/usecase/update_profile_usecase.dart';
import 'package:for_u/domain/usecase/validate_cart_usecase.dart';
import 'package:for_u/presentation/views/user/cart/riverpod/cart_controller.dart';
import 'package:for_u/presentation/views/user/favorites/riverpod/favorites_controller.dart';
import 'package:for_u/presentation/views/shared/notifications/riverpod/notifications_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

// dart format off
class DI {
  static late final ProviderContainer container;

  // --- Core Infrastructure ---
  static final _sharedPreferences         = Provider<SharedPreferences>((ref) => throw UnimplementedError("Initialize SharedPreferences in DI.init()"));

  static final _secureStorage             = Provider((ref) => SecureStorageService());

  static final _sharedPrefsService        = Provider((ref) => SharedPrefsService(ref.read(_sharedPreferences)));

  static final _storageService            = Provider((ref) => StorageService(ref.read(_secureStorage), ref.read(_sharedPrefsService)));

  // --- Network ---
  static final _dio                       = Provider((ref) => buildDio(ref.read(_storageService)));

  static final _authApi                   = Provider((ref) => AuthApi(ref.read(_dio)));
  static final _cashierApi                = Provider((ref) => CashierApi(ref.read(_dio)));
  static final _captainApi                = Provider((ref) => CaptainApi(ref.read(_dio)));
  static final _customerApi               = Provider((ref) => CustomerApi(ref.read(_dio)));

  // --- Domain & Data ---
  // One repository, backed by every API. Features reach it only through use cases.
  static final _repository                = Provider<Repository>((ref) => RepositoryImpl(
                                              ref.read(_authApi),
                                              ref.read(_captainApi),
                                              ref.read(_cashierApi),
                                              ref.read(_customerApi),
                                            ));

  static final _sessionService            = Provider((ref) => SessionService(
                                              ref.read(_storageService),
                                              () => FirebaseMessegingServices.instance.fcmToken,
                                              registerDeviceUseCase:   RegisterDeviceUseCase(ref.read(_repository)),
                                              getMeUseCase:            GetMeUseCase(ref.read(_repository)),
                                              unregisterDeviceUseCase: UnregisterDeviceUseCase(ref.read(_repository)),
                                              logoutUseCase:           LogoutUseCase(ref.read(_repository)),
                                              onSessionCleared: () {
                                                ref.read(cartController.notifier).clear();
                                                ref.read(favoritesController.notifier).clear();
                                                ref.read(notificationsController.notifier).clear();
                                              },
                                            ));

  // --- snack bar Helper
  static final _snackBarHelper            = Provider((ref) => SnackbarHelper());

  static final _loadingService            = Provider<LoadingManager>((ref) => OverlayLoadingManager());

  /// Call this in your main.dart before runApp()
  static Future<void> init({ProviderContainer? container}) async {
    final prefs   = await SharedPreferences.getInstance();

    DI.container  = container ?? ProviderContainer(
      overrides: [_sharedPreferences.overrideWithValue(prefs)],
    );

    // Warm the token cache so the first API request doesn't pay the secure-storage read.
    await DI().storageService.getToken();
  }
}

extension DICoreServicesExtension on DI {
  StorageService      get storageService   => DI.container.read(DI._storageService);
  SessionService      get sessionService   => DI.container.read(DI._sessionService);
  SnackbarHelper      get snackBarHelper   => DI.container.read(DI._snackBarHelper);
  LoadingManager      get loadingService   => DI.container.read(DI._loadingService);
}

extension DIUseCasesExtension on DI {
  Repository get _repo => DI.container.read(DI._repository);

  // --- Auth ---
  RequestOtpUseCase           get requestOtpUseCase           => RequestOtpUseCase(_repo);
  VerifyOtpUseCase            get verifyOtpUseCase            => VerifyOtpUseCase(_repo);
  GetMeUseCase                get getMeUseCase                => GetMeUseCase(_repo);
  LogoutUseCase               get logoutUseCase               => LogoutUseCase(_repo);
  RegisterDeviceUseCase       get registerDeviceUseCase       => RegisterDeviceUseCase(_repo);
  UnregisterDeviceUseCase     get unregisterDeviceUseCase     => UnregisterDeviceUseCase(_repo);

  // --- Captain ---
  GetCaptainProfileUseCase    get getCaptainProfileUseCase    => GetCaptainProfileUseCase(_repo);
  SetCaptainAvailabilityUseCase get setCaptainAvailabilityUseCase => SetCaptainAvailabilityUseCase(_repo);
  GetCaptainOrdersUseCase     get getCaptainOrdersUseCase     => GetCaptainOrdersUseCase(_repo);
  GetCaptainOrderDetailUseCase get getCaptainOrderDetailUseCase => GetCaptainOrderDetailUseCase(_repo);
  AcceptOrderUseCase          get acceptOrderUseCase          => AcceptOrderUseCase(_repo);
  StartDeliveryUseCase        get startDeliveryUseCase        => StartDeliveryUseCase(_repo);
  MarkDeliveredUseCase        get markDeliveredUseCase        => MarkDeliveredUseCase(_repo);
  MarkFailedUseCase           get markFailedUseCase           => MarkFailedUseCase(_repo);

  // --- Cashier ---
  GetCashierProfileUseCase    get getCashierProfileUseCase    => GetCashierProfileUseCase(_repo);
  GetCashierOrdersUseCase     get getCashierOrdersUseCase     => GetCashierOrdersUseCase(_repo);
  GetCashierOrderDetailUseCase get getCashierOrderDetailUseCase => GetCashierOrderDetailUseCase(_repo);
  MarkItemPreparedUseCase     get markItemPreparedUseCase     => MarkItemPreparedUseCase(_repo);
  MarkItemUnavailableUseCase  get markItemUnavailableUseCase  => MarkItemUnavailableUseCase(_repo);
  ConfirmReadyUseCase         get confirmReadyUseCase         => ConfirmReadyUseCase(_repo);
  RejectOrderUseCase          get rejectOrderUseCase          => RejectOrderUseCase(_repo);
  AvailableCaptainsUseCase    get availableCaptainsUseCase    => AvailableCaptainsUseCase(_repo);
  AssignCaptainUseCase        get assignCaptainUseCase        => AssignCaptainUseCase(_repo);
  ReassignCaptainUseCase      get reassignCaptainUseCase      => ReassignCaptainUseCase(_repo);

  // --- Customer ---
  GetProfileUseCase           get getProfileUseCase           => GetProfileUseCase(_repo);
  UpdateProfileUseCase        get updateProfileUseCase        => UpdateProfileUseCase(_repo);
  GetProductsUseCase          get getProductsUseCase          => GetProductsUseCase(_repo);
  GetProductDetailUseCase     get getProductDetailUseCase     => GetProductDetailUseCase(_repo);
  GetCategoriesUseCase        get getCategoriesUseCase        => GetCategoriesUseCase(_repo);
  GetFavoritesUseCase         get getFavoritesUseCase         => GetFavoritesUseCase(_repo);
  AddFavoriteUseCase          get addFavoriteUseCase          => AddFavoriteUseCase(_repo);
  RemoveFavoriteUseCase       get removeFavoriteUseCase       => RemoveFavoriteUseCase(_repo);
  GetNotificationsUseCase     get getNotificationsUseCase     => GetNotificationsUseCase(_repo);
  GetUnreadNotificationsCountUseCase get getUnreadNotificationsCountUseCase => GetUnreadNotificationsCountUseCase(_repo);
  MarkNotificationReadUseCase get markNotificationReadUseCase => MarkNotificationReadUseCase(_repo);
  MarkAllNotificationsReadUseCase get markAllNotificationsReadUseCase => MarkAllNotificationsReadUseCase(_repo);
  GetAddressesUseCase         get getAddressesUseCase         => GetAddressesUseCase(_repo);
  CreateAddressUseCase        get createAddressUseCase        => CreateAddressUseCase(_repo);
  UpdateAddressUseCase        get updateAddressUseCase        => UpdateAddressUseCase(_repo);
  DeleteAddressUseCase        get deleteAddressUseCase        => DeleteAddressUseCase(_repo);
  CoverageCheckUseCase        get coverageCheckUseCase        => CoverageCheckUseCase(_repo);
  GetDeliveryZonesUseCase     get getDeliveryZonesUseCase     => GetDeliveryZonesUseCase(_repo);
  PlacesAutocompleteUseCase   get placesAutocompleteUseCase   => PlacesAutocompleteUseCase(_repo);
  PlacesDetailsUseCase        get placesDetailsUseCase        => PlacesDetailsUseCase(_repo);
  ValidateCartUseCase         get validateCartUseCase         => ValidateCartUseCase(_repo);
  CheckoutQuoteUseCase        get checkoutQuoteUseCase        => CheckoutQuoteUseCase(_repo);
  CreateOrderUseCase          get createOrderUseCase          => CreateOrderUseCase(_repo);
  GetCustomerOrdersUseCase    get getCustomerOrdersUseCase    => GetCustomerOrdersUseCase(_repo);
  GetCustomerOrderDetailUseCase get getCustomerOrderDetailUseCase => GetCustomerOrderDetailUseCase(_repo);
  CancelOrderUseCase          get cancelOrderUseCase          => CancelOrderUseCase(_repo);
  RateOrderUseCase            get rateOrderUseCase            => RateOrderUseCase(_repo);
  OpenTicketUseCase           get openTicketUseCase           => OpenTicketUseCase(_repo);
  GetTicketsUseCase           get getTicketsUseCase           => GetTicketsUseCase(_repo);
  GetTicketUseCase            get getTicketUseCase            => GetTicketUseCase(_repo);
  ReplyTicketUseCase          get replyTicketUseCase          => ReplyTicketUseCase(_repo);
  OpenCashierTicketUseCase    get openCashierTicketUseCase    => OpenCashierTicketUseCase(_repo);
  OpenCaptainTicketUseCase    get openCaptainTicketUseCase    => OpenCaptainTicketUseCase(_repo);
  GetLegalPoliciesUseCase     get getLegalPoliciesUseCase     => GetLegalPoliciesUseCase(_repo);
  DeleteAccountUseCase        get deleteAccountUseCase        => DeleteAccountUseCase(_repo);
}

// dart format on
