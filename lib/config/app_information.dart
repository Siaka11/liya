import 'dart:ui';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppInformation {
  static const name = 'GUCE MOBILE';
  static const title = 'GUCE MOBILE';
  static const appIdAndroid = "";
  static const appIdIos = "";
  static const TOKEN = "";
  static const masterAdminEmail = "";
}

class Config {
  static const DEVELOPMENT_MODE = false;
  static const CONNECTION_TIMEOUT =
  360000; // 6 * 60 * 1000 = 360000 = 6 Minutes
  static const SESSION_TIMEOUT = 1800; // 30 Minutes
  static const AUTHENTICATE_TIMEOUT = 120000; // 2 minutes
  static const IDLE_TIMEOUT = 600; // 10 minutes/used by TouchID
  static const REQUEST_TIMEOUT = 40000;
  static const TOAST_DURATION = 5;
  static const ISAUTH = 'is_authenticated';
  static const COLUMN_SIZE_PORTRAIT = 4;
  static const COLUMN_SIZE_LANDSCAPE = 6;
}

class GWS_ACTION {
  static const SEARCH = 'search';
  static const LOGOUT = 'logout';
  static const NOTIFICATION = 'notification';
  static const SYNC = 'sync';
  static const UPDATE_USER_FILTER = 'updateUserFilter';
  static const UPDATE_USER = 'updateUser';
  static const RETRIEVE_TRANSACTION_HISTORY = 'retrieveTransactionHistory';
  static const RETRIEVE_TRANSACTION_DETAILS = 'retrieveTransactionDetails';
  static const RETRIEVERIMMDATA = 'retrieveRimmData';
}

class FORMAT {
  static const TIMESTAMP = 'yyyy-MM-dd';
}

class DOCUMENT_TYPES {
  static const SAD = "eSAD";
  static const LICENSE = "eLicense";
  static const FOREX = "eForex";
  static const TVF = "TVF";
  static const ERC = "eRC";
  static const PHYTO = "ePhyto";
  static const URM = "URM";
}


const documentRoles = {
  "eSAD": ['esad_trader', 'esad_declarant', 'esad_admin'],
  "eLicense": [
    "elicense_declarant",
    "elicense_trader",
    'elicense_govt_officer',
    "elicense_admin",
    "elicense_govt_officer",
    "elicense_govt_senior_officer",
    "elicense_govt_supervisor"
  ],
  "eForex": [
    'efemci_admin',
    'efemci_declarant',
    'efemci_govt_officer',
    'efemci_trader',
    "efemci_bank_agent",
    "efemci_govt_officer",
    "efemci_govt_supervisor"
  ],

  "ePhyto": [
    'ephyto_declarant',
    'ephyto_trader',
    'ephyto_gov_officer',
    'ephyto_super_administrator',
    'ephyto_administrator',
    'ephyto_gov_supervisor',
    'ephyto_gov_senior_officer'
  ],

  "URM": [
    'urm_declarant',
    'urm_trader',
    'urm_gov_officer',
    'urm_super_administrator',
    'urm_admin',
    'urm_gov_supervisor',
    'urm_gov_senior_officer'
  ],

  "TVF": ['tvf_trader',
    'tvf_declarant',
    'tvf_admin',
    'tvf_gov_officer',
    "tvf_bank_agent",
    "tvf_gov_officer",
    "tvf_gov_supervisor"],
  "eRC": ['vc_data_entry', "rest_fcvr"]
};

class Modules {
  static const SAD = "SAD";
  static const LICENSE = "LICENSE";
  static const TVF = "TVF";
  static const ERC = "ERC";
  static const FOREX = "FOREX";
  static const FULL_GWS="FULL_GWS";
  static const PHYTO="PHYTO";
  static const URM="URM";

}

var documentTypeFromModules={
  Modules.SAD:DOCUMENT_TYPES.SAD,
  Modules.LICENSE:DOCUMENT_TYPES.LICENSE,
  Modules.TVF:DOCUMENT_TYPES.TVF,
  Modules.ERC:DOCUMENT_TYPES.ERC,
  Modules.FOREX:DOCUMENT_TYPES.FOREX,
  Modules.PHYTO:DOCUMENT_TYPES.PHYTO,
  Modules.URM:DOCUMENT_TYPES.URM,
};

var statusDefault={
  DOCUMENT_TYPES.SAD:STATUSES.PAID,
  DOCUMENT_TYPES.ERC:STATUSES.FCVR_ISSUED,
  DOCUMENT_TYPES.LICENSE:STATUSES.APPROVED,
  DOCUMENT_TYPES.FOREX:STATUSES.APPROVED,
  DOCUMENT_TYPES.TVF:STATUSES.TVF_VALIDATED,
  DOCUMENT_TYPES.PHYTO:STATUSES.PROCESSED,
  DOCUMENT_TYPES.URM:STATUSES.PROCESSED
};

var statusForFilter = {
  Modules.SAD: [
    {"status": 'Paid', "value": false},
    {"status": 'Assessed', "value": false},
    {"status": 'Cancelled', "value": false},
    {"status": 'Totally exited', "value": false}
  ],
  Modules.LICENSE: [
    {"status": 'Queried', "value": false},
    {"status": 'Rejected', "value": false},
    {"status": 'Approved', "value": false},
    {"status": 'Canceled', "value": false}
  ],
  Modules.FOREX: [
    {"status": 'Approved', "value": false},
    {"status": 'Queried', "value": false},
    {"status": 'Cancelled', "value": false},
    {"status": 'Rejected', "value": false},
    {"status": 'Executed', "value": false}
  ],

  Modules.PHYTO: [
    {"status": 'Requested', "value": false},
    {"status": 'Queried', "value": false},
    {"status": 'Approved', "value": false},
    {"status": 'Rejected', "value": false},
    {"status": 'Cancelled', "value": false},
    {"status": 'Replaced', "value": false},
    {"status": 'Signed', "value": false},
    {"status": 'Partially_Approved', "value": false},
  ],

  Modules.TVF: [
    {"status": 'PENDING DOMICILIATION', "value": false},
    {"status": 'PENDING AUTHORIZATION', "value": false},
    {"status": 'PENDING PRIOR AUTH', "value": false},
    {"status": 'QUERIED', "value": false},
    {"status": 'VALIDATED', "value": false},
    {"status": 'CANCELLED', "value": false}
  ],
  Modules.ERC: [
    {"status": 'Rejected', "value": false},
    {"status": 'FCVR Issued', "value": false},
    {"status": 'Submitted', "value": false}
  ],
  Modules.URM: [
    {"status": 'Queried', "value": false},
    {"status": 'Requested', "value": false},
    {"status": 'Processed', "value": false},
    {"status": 'Generated', "value": false},
    {"status": 'In-Process', "value": false}
  ],

};

class STATUSES {
  static const ALL = "All";
  static const PAID = "Paid";
  static const ASSESSED = "Assessed";
  static const STORED = "Stored";
  static const SENT = "Sent";
  static const GENERATED = "Generated";
  static const ACCEPTED = "Accepted";
  static const EXPIRED = "Expired";
  static const REQUESTED = "Requested";
  static const CANCELLED = "Cancelled";
  static const CANCELLED_ = "CANCELLED";
  static const CANCELED = "Canceled";
  static const CANCELED_ = "CANCELED";
  static const REGISTERED = "Registered";
  static const QUERIED = "Queried";
  static const QUERY = "Query";
  static const QUERIED_ = "QUERIED";
  static const ARCHIVED = "Archived";
  static const EXITED = "Exited";
  static const USED = "Used";
  static const REJECTED = "Rejected";
  static const APPROVED = "Approved";
  static const TVF_VALIDATED = "VALIDATED";
  static const PARTIALLY_APPROVED = "Partially_Approved";
  static const TOTALLY_EXITED = "Totally Exited";
  static const EXECUTED = "Executed";
  static const BEFORE_PENDING_PRIOR_AUTH = "BEFORE PENDING PRIOR AUTH";
  static const PENDING_PRIOR_AUTH = "PENDING PRIOR AUTH";
  static const PENDING_AUTHORIZATION = "PENDING AUTHORIZATION";
  static const PENDING_DOMICILIATION = "PENDING DOMICILIATION";
  static const RECEIVED_VALIDATING_DOCUMENTS = "Received - Validating Documents";
  static const SUBMITTED = "Submitted";
  static const WAITING_FOR_PAYMENT = "Waiting_For_Payment";
  static const QUERY_REPONSE_QUERIED = "Query - Response required";
  static const PROCESSING = "Processing";
  static const BEING_FINALIZED = "Being Finalized";
  static const FCVR_ISSUED = "FCVR Issued";
  static const SENT_ERROR = "Sent Error";
  static const SENT_OK = "Sent Ok";
  static const TRANSACTION_COMPLETED = "Transaction Completed";
  static const VC_COMPLETED = "VC Completed";
  static const PETITION_QUERY = "Petition Query";
  static const VALIDATED = "PENDING DOMICILIATION";
  static const PARTIALLY_PROCESSED = "Partially_Processed";
  static const PROCESSED = "Processed";
  static const IN_PROCESSED = "In-Process";
  static const REPLACED = "Replaced";
  static const CONFIRMED = "Confirmed";
  static const SIGNED = "Signed";
}

class DB_NAMES {
  static const SAD = "eSadDB";
  static const LICENSE = "eLicenseDB";
  static const FOREX = "eForexDB";
  static const TVF = "tvfDB";
  static const ERC = "ercDB";
  static const NOTIFICATION = "notificationDB";
  static const PHYTO = "ePhytoDB";
  static const URM = "urmDB";
}

class DEVICE_PLATFORMS {
  static const ANDROID = "android";
  static const IOS = "ios";
}

class COUNTRY {
  static const CURRENCY = 'XOF';
}

class COLOR {
  static const Color RED = Color(0xFFfd6263);
  static const Color GREEN = Color(0xFF6db169);
  static const Color BLUE = Color(0xFF72b5e4);
  static const Color YELLOW = Color(0xFFffe556);
  static const Color ORANGE = Color(0xFFffa25d);
  static const Color PURPLE = Color(0xFFa860a4);
  static const Color BROWN = Color(0xFF85543c);
}

class STATUS_COLOR {
  static const Color PAID = Color(0xFF11c1f3);
  static const Color ALL = Color(0xFF6db269);
  static const Color CANCELLED = Color(0xFFff7272);
  static const Color CANCELLED_ = Color(0xFFff7272);
  static const Color CANCELED = Color(0xFFff7272);
  static const Color CANCELED_ = Color(0xFFff7272);
  static const Color EXPIRED = Color(0xFFc25354);
  static const Color ASSESSED = Color(0xFF6db269);
  static const Color REQUESTED = Color(0xFF6db269);
  static const Color REGISTERED = Color(0xFF74C08A);
  static const Color QUERIED = Color(0xFFffc900);
  static const Color EXITED = Color(0xFFa97ba6);
  static const Color TOTALLY_EXITED = Color(0xFFa97ba6);
  static const Color REJECTED = Color(0xFF722f37);
  static const Color PENDING_PRIOR_AUTH = Color(0xFFebb7b7);
  static const Color BEFORE_PENDING_PRIOR_AUTH = Color(0xFFebb7b7);
  static const Color PENDING_AUTHORIZATION = Color(0xFFEED2EE);
  static const Color PENDING_DOMICILIATION = Color(0xFFdad1e4);
  static const Color REPLACED = Color(0xFFa97ba6);
  static const Color GENERATED = Color(0xffd3d3d3);
  static const Color IN_PROCESSED = Color(0xFFffc900);
  static const Color DEFAULT = Color(0xFF74C08A);


  static getColor(status) {
    switch (status) {
      case STATUSES.ALL:
        return ALL;
      case STATUSES.PAID:
        return PAID;
      case STATUSES.CANCELLED:
        return CANCELLED;
      case STATUSES.CANCELLED_:
        return CANCELLED;
      case STATUSES.CANCELED:
        return CANCELED;
      case STATUSES.CANCELED_:
        return CANCELED;
      case STATUSES.EXPIRED:
        return EXPIRED;
      case STATUSES.ASSESSED:
        return ASSESSED;
      case STATUSES.REQUESTED:
        return REQUESTED;
      case STATUSES.REGISTERED:
        return REGISTERED;
      case STATUSES.QUERIED:
        return QUERIED;
      case STATUSES.QUERIED_:
        return QUERIED;
      case STATUSES.EXITED:
        return EXITED;
      case STATUSES.TOTALLY_EXITED:
        return TOTALLY_EXITED;
      case STATUSES.REJECTED:
        return REJECTED;
      case STATUSES.PENDING_PRIOR_AUTH:
        return PENDING_PRIOR_AUTH;
      case STATUSES.BEFORE_PENDING_PRIOR_AUTH:
        return BEFORE_PENDING_PRIOR_AUTH;
      case STATUSES.PENDING_AUTHORIZATION:
        return PENDING_AUTHORIZATION;
      case STATUSES.RECEIVED_VALIDATING_DOCUMENTS:
        return DEFAULT;
      case STATUSES.SUBMITTED:
        return DEFAULT;
      case STATUSES.QUERY_REPONSE_QUERIED:
        return DEFAULT;
      case STATUSES.PROCESSING:
        return DEFAULT;
      case STATUSES.BEING_FINALIZED:
        return DEFAULT;
      case STATUSES.FCVR_ISSUED:
        return DEFAULT;
      case STATUSES.SENT_ERROR:
        return DEFAULT;
      case STATUSES.PETITION_QUERY:
        return DEFAULT;
      case STATUSES.VALIDATED:
        return DEFAULT;
      case STATUSES.REPLACED:
        return REPLACED;
      case STATUSES.SIGNED:
        return DEFAULT;
      case STATUSES.CONFIRMED:
        return DEFAULT;
      case STATUSES.GENERATED:
        return GENERATED;
      case STATUSES.IN_PROCESSED:
        return IN_PROCESSED;
      default:
        return DEFAULT;
    }
  }
}

class POUCH_RESPONSE_STATUS {
  static const MISSING = 404;
  static const UPDATE_CONFLICT = 409;
}

class ACTIVITYNAME {
  static const ESAD = "eSAD";
  static const ELICENSE = "eLicense";
  static const EFOREX = "eForex";
  static const TVF = "TVF";
  static const ERC = "eRC";
  static const EPHYTO = "ePhyto";
  static const URM = "URM";
}

class ACTIONNAME {
  static const LIST = "list";
  static const DETAIL = "detail";
  static const SHARE = "share";
  static const PDF = "pdf";
  static const HISTORY = "history";
  static const SEARCH = "search";
}

class REST_URL {
  static const BASE = "BASEURL";
  static const GWS = "GWS";
  static const FULL_GWS = "FULL_GWS";
  static const TEST_ENV = "TEST_ENV";

  static const LOCAL = {
    BASE: "http://localhost:8089/",
    Modules.SAD: "http://localhost:8089/gws/esad/",
    GWS: "gws/",
    FULL_GWS: "http://localhost:8089/gws",
    Modules.LICENSE: "http://localhost:8089/gws/elicense/",
    Modules.FOREX: "http://localhost:8089/gws/efem/",
    Modules.TVF: "http://localhost:8089/gws/tvf/",
    Modules.ERC: "http://localhost:8089/gws/valuewebb/",
    Modules.PHYTO: "http://localhost:8089/gws/ephyto/",
    TEST_ENV: true
  };

  static const UAT = {
    BASE: "https://uat.guce.ci/",
    Modules.SAD: "https://uat.guce.ci/esad/",
    GWS: "gws/",
    FULL_GWS: "https://uat.guce.ci/gws/",
    Modules.LICENSE: "https://uat.guce.ci/elicense/",
    Modules.FOREX: "https://uat.guce.ci/efem/",
    Modules.TVF: "https://uat.guce.ci/tvf/",
    Modules.ERC: "https://uat.guce.ci/vw/",
    Modules.PHYTO: "https://uat.guce.ci/phyto/",
    Modules.URM: "https://uat.guce.ci/urm/",
    TEST_ENV: true
  };

  static const PROD = {
    BASE: "https://appmo.guce.gouv.ci/",
    FULL_GWS: "https://appmo.guce.gouv.ci/gws/",
    Modules.SAD: "https://applb01.guce.gouv.ci/esad/",
    GWS: "gws/",
    Modules.LICENSE: "https://app3.guce.gouv.ci/elicense/",
    Modules.FOREX: "https://applb01.guce.gouv.ci/efem/",
    Modules.TVF: "https://app.guce.gouv.ci/tvf/",
    Modules.ERC: "https://applb01.guce.gouv.ci/vw/",
    Modules.PHYTO: "https://guce.gouv.ci/phyto/",
    Modules.URM: "https://app3.guce.gouv.ci/urm/",
    TEST_ENV: false
  };

  static const TRN = {
    BASE: "https://trn.guce.gouv.ci/",
    FULL_GWS: "https://trn.guce.gouv.ci/gws/",
    Modules.SAD: "https://trn.guce.gouv.ci/esad/",
    GWS: "gws/",
    Modules.LICENSE: "https://trn.guce.gouv.ci/elicense/",
    Modules.FOREX: "https://trn.guce.gouv.ci/efem/",
    Modules.TVF: "https://trn.guce.gouv.ci/tvf/",
    Modules.ERC: "https://trnvw.guce.gouv.ci/valuewebb/",
    TEST_ENV: true
  };

  static get() {
    Map<String, Object> urls;
    switch (dotenv.get("ENV")) {
      case "UAT":
        urls = UAT;
        break;
      case "TRN":
        urls = TRN;
        break;
      case "PROD":
        urls = PROD;
        break;
      case "LOCAL":
        urls = LOCAL;
        break;
      default:
        urls = UAT;
    }
    return urls;
  }
}
