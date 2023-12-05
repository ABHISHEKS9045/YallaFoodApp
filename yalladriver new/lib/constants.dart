import 'package:foodie_driver/model/CurrencyModel.dart';

const FINISHED_ON_BOARDING = 'finishedOnBoarding';
const COLOR_ACCENT = 0xFF8fd468;
const COLOR_PRIMARY_DARK = 0xFF2c7305;
// ignore: non_constant_identifier_names
var COLOR_PRIMARY = 0xffa4d74c;
const DARK_VIEWBG_COLOR = 0xff191A1C;
const DARK_CARD_BG_COLOR = 0xff242528;
const FACEBOOK_BUTTON_COLOR = 0xFF415893;
const USERS = 'users';
const REPORTS = 'reports';
const CATEGORIES = 'vendor_categories';
const VENDORS = 'vendors';
const PRODUCTS = 'vendor_products';
const Setting = 'settings';
const CONTACT_US = 'ContactUs';
const ORDERS = 'restaurant_orders';
const OrderTransaction = "order_transactions";
const driverPayouts = "driver_payouts";
const SECOND_MILLIS = 1000;
const MINUTE_MILLIS = 60 * SECOND_MILLIS;
const HOUR_MILLIS = 60 * MINUTE_MILLIS;
String Lang = 'ar';
const gApi = 'AIzaSyCzsSTpM6RkMUMlyfxZK3Od30cKoGtIDdk' ;


// new key
// const SERVER_KEY = 'AAAAAIf8ixg:APA91bFuZXfrNtiSQdUuX7dVS7YbXSbAWLN1ZNW__UWvLfH_KPsnzIMknHGcq6Y5Vgi3_1BWXGRGi2EPZo6kpabvqLRntJRdMvY9OuxH2I6C3TAfTJn3fmEOMSZVetntPbA8UVZeyd7C';
// const GOOGLE_API_KEY = 'AIzaSyBK_LlbuVttvGR3GXIe1oF6qeci2ckGNNA';
// old key
const SERVER_KEY = 'AAAA3jnI8PI:APA91bG3opTCpB8ySIczJsBKV1MhN2EC576QLpx8pYIuPsPm2iDyt9XAa-bmLJLi7nnRnvObsNmkWuLxlP4D5JnSBMdpsaD3t2xVPfRFqV_Rku7hOGkCaNsR0vVkq6_dqWEvzTjvGBSX';
const GOOGLE_API_KEY = 'AIzaSyBK_LlbuVttvGR3GXIe1oF6qeci2ckGNNA';

String placeholderImage = 'https://Yalla.co.za/img/web_logo.png';

const ORDER_STATUS_PLACED = 'Order Placed';
const ORDER_STATUS_ACCEPTED = 'Order Accepted';
const ORDER_STATUS_REJECTED = 'Order Rejected';
const ORDER_STATUS_DRIVER_PENDING = 'Driver Pending';
const ORDER_STATUS_DRIVER_ACCEPTED = 'Driver Accepted';
const ORDER_STATUS_DRIVER_REJECTED = 'Driver Rejected';
const ORDER_STATUS_SHIPPED = 'Order Shipped';
const ORDER_STATUS_IN_TRANSIT = 'In Transit';
const ORDER_STATUS_COMPLETED = 'Order Completed';

const USER_ROLE_DRIVER = 'driver';

const DEFAULT_CAR_IMAGE = 'https://firebasestorage.googleapis.com/v0/b/production-a9404.appspot.com/o/uberEats%2Fdrivers%2FcarImages%2Fcar_default_image.png?alt=media&token=6381a50f-a71e-423b-bca2-ecdfb1dda664';

const Currency = 'currencies';
String symbol = '';
bool isRight = false;
int decimal = 2;

String currName = "";
CurrencyModel? currencyData;
