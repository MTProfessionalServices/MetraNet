function getCustomReportUrl(value, meta, record, rowIndex, colIndex, store, intervalId, billGroupId) {
  var url = "";

  if (record.data.RequiresInput) {
    url = String.format("javascript:onReportRequiresParameters(\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\")",
                        record.data.internalId,
                        record.data.Name,
                        record.data.Extension,
                        record.data.QueryName,
                        record.data.GridLayoutName);
  }
  else {
    switch (record.data.Type) {
      case "Basic":
        url = String.format("javascript:onViewBasicReport(\"{0}\",\"{1}\",\"{2}\")",
                        record.data.internalId,
                        record.data.Name,
                        record.data.QueryName);
        break;

      case "Configured":
        url = String.format("javascript:onViewConfiguredReport(\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\")",
                        record.data.internalId,
                        record.data.Name,
                        record.data.Extension,
                        record.data.QueryName,
                        record.data.GridLayoutName);
        break;

      case "Custom":
        url = String.format("javascript:onViewCustomReport(\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\")",
                        record.data.internalId,
                        record.data.Name,
                        record.data.Extension,
                        record.data.QueryName,
                        record.data.GridLayoutName,
                        record.data.URL);
        break;

      case "BillingGroupStatistics":
	    case "IntervalStatistics":
        url = String.format("javascript:onViewIntervalStatisticsReport(\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\")",
                        record.data.internalId,
                        record.data.Name,
                        record.data.Extension,
                        record.data.QueryName,
                        record.data.GridLayoutName,
                        intervalId,
                        billGroupId);
        break;

      default:

    }
  }

  return url;
}

function onReportRequiresParameters(internalId, name, extension, queryName, gridLayoutName) {
  alert("Report \'" + name + "\' requires input parameters, which is not yet supported");
}

function onViewBasicReport(internalId, name, queryName) {
  var showReportUrl = String.format("/MetraNet/Reporting/ShowBasicReport.aspx?InternalId={0}&Name={1}&QueryName={2}",
        internalId,
        encodeURIComponent(name),
        queryName);

  document.location.href = showReportUrl;
}

function onViewConfiguredReport(internalId, name, extension, queryName, gridLayoutName) {
  var showReportUrl = String.format("/MetraNet/Reporting/ShowConfiguredReport.aspx?InternalId={0}&Name={1}&Extension={2}&QueryName={3}&GridLayoutName={4}",
        internalId,
        encodeURIComponent(name),
        extension,
        queryName, 
        gridLayoutName);

  document.location.href = showReportUrl;
}

function onViewCustomReport(internalId, name, extension, queryName, gridLayoutName, customReportUrl) {
  var paramSeparator = "?";
  // Check if the custom URL already has parameters, in which case we need to add ours with "&", instead of "?"
  if (customReportUrl.indexOf("?") != -1) {
    paramSeparator = "&";
  }

  var showReportUrl = String.format("{5}{6}InternalId={0}&Name={1}&Extension={2}&QueryName={3}&GridLayoutName={4}",
        internalId,
        encodeURIComponent(name),
        extension,
        queryName,
        gridLayoutName,
        customReportUrl,
        paramSeparator);

  document.location.href = showReportUrl;
}

function onViewIntervalStatisticsReport(internalId, name, extension, queryName, gridLayoutName, intervalId, billGroupId)
{
  var showReportUrl;

  if (intervalId == "" ){
    showReportUrl = String.format("/MetraNet/Reporting/IntervalStatisticsParameters.aspx?InternalId={0}&Name={1}&Extension={2}&QueryName={3}&GridLayoutName={4}",
    internalId,
    encodeURIComponent(name),
    extension,
    queryName,
    gridLayoutName);
  }
  else
  {
    showReportUrl = String.format("ShowConfiguredReport.aspx?InternalId={0}&Name={1}&Extension={2}&QueryName={3}&GridLayoutName={4}&IntervalId={5}&BillGroupId={6}",
    internalId,
    encodeURIComponent(name),
    extension,
    queryName,
    gridLayoutName,
    intervalId,
    billGroupId);
  }
  document.location.href = showReportUrl;
}
