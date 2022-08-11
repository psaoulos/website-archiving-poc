const String backendAddress = "http://localhost:3000";

const String backendCrawlerStatusEndpoint = "/crawler/status";
const String backendCrawlerStartEndpoint = "/crawler/start";
const String backendCrawlerStopEndpoint = "/crawler/stop";
const String backendResultsGetEarliestArchiveEndpoint =
    "/results/getearliestarchive";
const String backendResultsGetLatestArchiveEndpoint =
    "/results/getlatestarchive";
const String backendResultsGetAllArchivesEndpoint = "/results/getallarchive";
const String backendResultsGetAllAddresses = "/results/getalladdresses";
const String backendResultsGetHTMLDifferences = "/results/generatehtml/<first_archive_id>/<second_archive_id>";
const String backendResultsGetPDFDifferences = "/results/generatepdf";
const String backendGetLogs = "/getlogs";
