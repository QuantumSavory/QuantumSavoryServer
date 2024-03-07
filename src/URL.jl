const SEPARATOR = "/"

const REGISTER_URL = "/register"
const REQUEST_ID_URL = "/id"
const REGISTER_NET = "/net"
const INITIALIZE = "/initialize"
const APPLY = "/apply"
const TAG = "/tag"
const TIME = "/time"

const CREATE_REQUEST_ID_URL = REQUEST_ID_URL
const CREATE_REGISTER_NET_URL = string(REGISTER_URL, REGISTER_NET)
const CREATE_TAG_URL = string(REGISTER_URL, TAG)
const INITIALIZE_REGISTER_URL = string(REGISTER_URL, INITIALIZE)
const APPLY_OPERATION_URL = string(REGISTER_URL, APPLY)
const GET_TIME_URL = TIME