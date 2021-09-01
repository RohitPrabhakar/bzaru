enum UserRole { CUSTOMER, MERCHANT, ADMIN }

extension TypeOfSearch on UserRole {
  String asString() => {
        UserRole.CUSTOMER: "customer",
        UserRole.MERCHANT: "merchant",
        UserRole.ADMIN: "admin",
      }[this];
  static UserRole fromString(String value) => {
        "customer": UserRole.CUSTOMER,
        "merchant": UserRole.MERCHANT,
        "admin": UserRole.ADMIN,
      }[value];
}

enum OrderStatus {
  ACCEPTED,
  PACKING,
  PACKED,
  DELIVERY,
  COMPLETE,
  PLACED,
  RECIEVED,
  CANCEL,
  PICKUP,
}

extension OrderSearch on OrderStatus {
  String asString() => {
        OrderStatus.PLACED: "placed",
        OrderStatus.ACCEPTED: "accepted",
        OrderStatus.CANCEL: "cancelled",
        OrderStatus.PACKED: "packed",
        OrderStatus.PACKING: "packing",
        OrderStatus.DELIVERY: "out for delivery",
        OrderStatus.COMPLETE: "complete",
        OrderStatus.RECIEVED: "recieved",
        OrderStatus.PICKUP: "ready for pickup",
      }[this];

  OrderStatus fromString(String value) => {
        "placed": OrderStatus.PLACED,
        "accepted": OrderStatus.ACCEPTED,
        "cancelled": OrderStatus.CANCEL,
        "packed": OrderStatus.PACKED,
        "packing": OrderStatus.PACKING,
        "out for delivery": OrderStatus.DELIVERY,
        "complete": OrderStatus.COMPLETE,
        "recieved": OrderStatus.RECIEVED,
        "ready for pickup": OrderStatus.PICKUP,
      }[value];
}

enum OrderType {
  NEW,
  COMPLETED,
}

extension OrderSwitch on OrderType {
  String asString() => {
        OrderType.NEW: "new",
        OrderType.COMPLETED: "completed",
      }[this];

  static OrderType fromString(String value) => {
        "new": OrderType.NEW,
        "completed": OrderType.COMPLETED,
      }[value];
}

enum ModeOfOrder {
  PICKUP,
  DELIVERY,
}

extension OrderMode on ModeOfOrder {
  String asString() => {
        ModeOfOrder.PICKUP: "pickup",
        ModeOfOrder.DELIVERY: "delivery",
      }[this];

  static ModeOfOrder fromString(String value) => {
        "pickup": ModeOfOrder.PICKUP,
        "delivery": ModeOfOrder.DELIVERY,
      }[value];
}

enum UserActivityStatus {
  ACTIVE,
  INACTIVE,
}

extension ActivityStatus on UserActivityStatus {
  String asString() => {
        UserActivityStatus.ACTIVE: " active",
        UserActivityStatus.INACTIVE: " inactive",
      }[this];

  static UserActivityStatus fromString(String value) => {
        "active": UserActivityStatus.ACTIVE,
        "inactive": UserActivityStatus.INACTIVE,
      }[value];
}

enum ProductSize {
  LTR,
  KG,
  G,
  MG,
  ML,
  PC,
}

extension SizeOfProduct on ProductSize {
  String asString() => {
        ProductSize.G: "g",
        ProductSize.ML: "ml",
        ProductSize.KG: "kg",
        ProductSize.MG: "mg",
        ProductSize.LTR: "ltr",
        ProductSize.PC: "pc",
      }[this];

  static ProductSize fromString(String value) => {
        "g": ProductSize.G,
        "ml": ProductSize.ML,
        "kg": ProductSize.KG,
        "mg": ProductSize.MG,
        "ltr": ProductSize.LTR,
        "pc": ProductSize.PC,
      }[value];
}
