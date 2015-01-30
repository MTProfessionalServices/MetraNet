/*
 * GetData REST service
 * 
 * This service is responsible for receiving data from UI pages and page elements (e.g. searchable grids)
 * and forwarding that information to the GenericDataExtractor(GDE) object.  The GDE object will retrieve
 * the necessary information, and this service will return the data as JSON to the caller.
 * 
 * When GetData service is called, the following parameters must be supplied:
 *    - OutPropertyName: workflow property to extract the data from
 *    - AccID:  account ID of the currently managed user
 *    - PiID: Processor Instance ID, e.g. a GUID that identifies the workflow to use
 *    - Op: operation to perform, e.g. the name of workflow event to run
 *    - (optional) Args: list of additional parameters to send for processing, separated by **.
 *        Ex: param1=value1**param2=value2**param3=value3
 * 
 * The following parameters are optional and are generally provided via form submission
 *    - start: starting record id to return
 *    - limit: the number of records to return, e.g. grid page size
 *    - sort: name of the column to perform sorting on
 *    - dir: sort direction - ASC or DESC
 *    - set of filter names, values, operations, and data types in the following format:
 *        filter[i][field]
 *        filter[i][data][value]
 *        filter[i][data][type]
 *        filter[i][data][comparison]
 * 
 */
using System;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;
using MetraTech.Debug.Diagnostics;
using System.ServiceModel;

public partial class GetData : MTPage
{
  protected GenericDataExtractor gde;

  protected void Page_Load(object sender, EventArgs e)
  {
    string outPropertyName = Request["OutPropertyName"];
    using (new HighResolutionTimer("GetData:" + outPropertyName, 5000))
    {
      gde = new GenericDataExtractor(UI.User);

      //read the mode: either json or csv
      string mode = Request["mode"];
      if (String.IsNullOrEmpty(mode))
      {
        mode = "json";
      }

      ParseParameters();

      gde.OutPropertyName = outPropertyName;

      // set appropriate items on gde
      SetPageSortFilterInfo();

      string export = Request["export"];

      switch (mode.ToLower())
      {
        case "json":
          WriteOutJson(outPropertyName);
          break;

        case "csv":
          WriteOutCSV(outPropertyName, export);
          break;

        default:
          WriteOutJson(outPropertyName);
          break;
      }
    }
  }

  protected void WriteOutCSV(string outPropertyName, string export)
  {
    const int BATCH_SIZE = 100;

    Response.Buffer = false;
    Response.ContentType = "application/csv";
    Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
    Response.BinaryWrite(BOM);
    int recordsRead = 0;
    int totalRecords = gde.PageSize; //read out the total number of records from pageSize
    if (totalRecords > BATCH_SIZE)
      gde.PageSize = BATCH_SIZE;    //set it to the size of each batch; originally it was set to the total number of records

    var sb = new StringBuilder();
    sb.AppendLine("sep=,");
    //break up into multiple requests
    do
    {
      //retrieve data
      try
      {
        gde.GetData();
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        Response.StatusCode = 500;
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        Response.End();
        return;
      }
      catch (CommunicationException ex)
      {
        Response.StatusCode = 500;
        Logger.LogError(ex.Message);
        Response.End();
        return;
      }
      catch (Exception ex)
      {
        Response.StatusCode = 500;
        Logger.LogError(ex.Message);
        Response.End();
        return;
      }

      //append the CSV representation of the current request, and show headers for first page only
      bool bShowHeaders;
      if (!String.IsNullOrEmpty(export) && export.Equals("curpage"))
      {
        bShowHeaders = true; // Always show the headers if exporting the current page only
      }
      else
      {
        bShowHeaders = (gde.CurrentPage == 1);
      }
      sb.Append(gde.ConvertObjectToCSV(outPropertyName, bShowHeaders));

      gde.CurrentPage++;
      recordsRead += gde.PageSize;

    } while (recordsRead < totalRecords);

    string str = sb.ToString();
    str = KeyTerms.ProcessKeyTerms(str);
    Response.Write(str);
    Response.End();
  }

  protected void WriteOutJson(string outPropertyName)
  {
    //retrieve data
    try
    {
      gde.GetData();
    }
    catch (FaultException<MASBasicFaultDetail> ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Detail.ErrorMessages[0]);
      Response.End();
      return;
    }
    catch (CommunicationException ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.End();
      return;
    }
    catch (Exception ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.End();
      return;
    }

    string json;

    if (String.IsNullOrEmpty(outPropertyName))
    {
      json = gde.JSon;
    }
    else
    {
      json = gde.GetPropertyAsJSon(outPropertyName);
    }
    json = KeyTerms.ProcessKeyTerms(json);
    Utils.CommonLogger.LogInfo("GetData JSON = " + json);
    Response.Write(json);
    Response.End();
  }

  protected int CalculatePageID(int start, int pageSize)
  {
    return (start / pageSize) + 1;
  }

  /// <summary>
  /// Reads out paging information from start and limit request fields, and populates
  /// the GDE object
  /// </summary>
  protected void SetPaging()
  {
    int pageSize = 0;
    int start;

    //populate page size
    if (!String.IsNullOrEmpty(Request["limit"]))
    {
      if (Int32.TryParse(Request["limit"], out pageSize))
      {
        gde.PageSize = pageSize;
      }
    }

    //populate current page
    if (!String.IsNullOrEmpty(Request["start"]))
    {
      if (Int32.TryParse(Request["start"], out start))
      {
        if (pageSize != 0)
        {
          gde.CurrentPage = CalculatePageID(start, pageSize);
        }
      }
    }
  }

  /// <summary>
  /// Reads out sort and dir request values and sets them into GDE object
  /// </summary>
  protected void SetSorting()
  {
    //sort field
    if (!String.IsNullOrEmpty(Request["sort"]))
    {
      gde.SortProperty = Request["sort"];

      if (gde.SortProperty.EndsWith("ValueDisplayName"))
      {
        gde.SortProperty = gde.SortProperty.Substring(0, gde.SortProperty.Length - "ValueDisplayName".Length);
      }

      //sort direction
      if (Request["dir"] == "DESC")
      {
        gde.SortDirection = SortType.Descending;
      }
      else
      {
        gde.SortDirection = SortType.Ascending;
      }
    }
  }

  /// <summary>
  /// Reads out the filter information and sets it to GDE object
  /// Filters are coming from request object in the following format:
  ///         filter[i][field]
  ///         filter[i][data][value]
  ///         filter[i][data][type]
  ///         filter[i][data][comparison]  
  /// 
  /// </summary>
  protected void SetFilters()
  {
    int filterID = 0;
    while (!String.IsNullOrEmpty(Request["filter[" + filterID + "][field]"]))
    {
      string propertyName = Request["filter[" + filterID + "][field]"];
      if (String.IsNullOrEmpty(propertyName))
      {
        continue;
      }

      object value = Request["filter[" + filterID + "][data][value]"];
      MTFilterElement.OperationType op;

      switch (Request["filter[" + filterID + "][data][comparison]"])
      {
        case "eq":
          op = MTFilterElement.OperationType.Equal;
          break;

        case "lk":
          op = MTFilterElement.OperationType.Like_W;

          //need to append wildcard if for LIKE operation
          if (Request["filter[" + filterID + "][data][type]"] == "string")
          {
            value = AppendWildcard(value.ToString());
          }
          break;

        case "lt":
          op = MTFilterElement.OperationType.Less;
          break;

        case "lte":
          op = MTFilterElement.OperationType.LessEqual;
          break;

        case "gt":
          op = MTFilterElement.OperationType.Greater;
          break;

        case "gte":
          op = MTFilterElement.OperationType.GreaterEqual;
          break;

        case "ne":
          op = MTFilterElement.OperationType.NotEqual;
          break;


        case "":
          //if no operation is specified, default to LIKE_W for strings and equals for all other types
          if (Request["filter[" + filterID + "][data][type]"] == "string")
          {
            op = MTFilterElement.OperationType.Like_W;
            value = AppendWildcard(value.ToString());
          }
          else
          {
            op = MTFilterElement.OperationType.Equal;
          }
          break;

        default:
          //if no operation is specified, default to LIKE_W for strings and equals for all other types
          if (Request["filter[" + filterID + "][data][type]"] == "string")
          {
            op = MTFilterElement.OperationType.Like_W;
            value = AppendWildcard(value.ToString());
          }
          else
          {
            op = MTFilterElement.OperationType.Equal;
          }
          break;
      }

      //attempt converting to date time
      string dataType = this.Request["filter[" + filterID.ToString() + "][data][type]"];
      if (!String.IsNullOrEmpty(dataType) && (dataType.ToLower() == "date"))
      {
        DateTime tmpDate;
        if (DateTime.TryParse(value.ToString(), out tmpDate))
        {
          value = tmpDate;
        }
      }

      MTFilterElement mtfe = new MTFilterElement(propertyName, op, value);

      gde.Filters.Add(mtfe);

      filterID++;
    }
  }

  /// <summary>
  /// Reads out column info from request and sets the appropriate fields in GDE object
  /// Column info is received in the following format:
  ///     column[i][columnID]
  ///     column[i][dataIndex]
  ///     column[i][headerText]
  /// </summary>
  protected void SetColumns()
  {
    int columnIndex = 0;

    //attempt to find a column in the request stream
    while (!String.IsNullOrEmpty(Request["column[" + columnIndex + "][columnID]"]))
    {
      //read out the params
      string columnID = Request["column[" + columnIndex + "][columnID]"];
      string dataIndex = Request["column[" + columnIndex + "][mapping]"];
      string headerText = Request["column[" + columnIndex + "][headerText]"];
      string renderer = Request["column[" + columnIndex + "][renderer]"];

      MTColumnElement ce = new MTColumnElement();
      ce.ColumnID = columnID;
      ce.DataIndex = dataIndex;
      ce.HeaderText = headerText;
      ce.Renderer = renderer;

      gde.Columns.Add(ce);

      columnIndex++;
    }
  }

  /// <summary>
  /// Transfers the information containing paging, sorting, filters, and columns from request
  /// to the GDE object
  /// </summary>
  protected void SetPageSortFilterInfo()
  {
    SetPaging();
    SetSorting();
    SetFilters();
    SetColumns();
  }

  /// <summary>
  /// Appends wildcard character to the input string if it does not already have it in the last position.
  /// </summary>
  /// <param name="input">string to which the wildcard needs to be appended</param>
  /// <returns>modified string</returns>
  protected string AppendWildcard(string input)
  {
    const char WILDCARD_CHAR = '%';
    string output = input;

    //don't do anything for null/empty strings
    if (String.IsNullOrEmpty(output))
    {
      return input;
    }

    //if last char is the wildcard, don't do anything
    if (input.LastIndexOf(WILDCARD_CHAR) == input.Length - 1)
    {
      return input;
    }

    //append wildcard char if necessary
    output = output + WILDCARD_CHAR;

    return output;
  }

  /// <summary>
  /// Read out the top level vital info, containing ProcessorID, AccountID, Operation and optional arguments
  /// </summary>
  protected void ParseParameters()
  {
    gde.ProcessorInstanceId = Request["piid"];
    gde.AccountId = Request["AccId"];
    gde.Operation = Request["Op"];

    string additionalArguments = Request["Args"];
    if (!String.IsNullOrEmpty(additionalArguments))
    {
      ParseAdditionalArguments(additionalArguments);
    }

    //get parameters that apply only for non-workflow service method calls
    gde.ServiceMethodName = Request["ServiceMethodName"];
    if (!String.IsNullOrEmpty(gde.ServiceMethodName))
    {
      //read out the parameters
      int i = 0;

      while (!String.IsNullOrEmpty(Request["SvcMethodParamName[" + i + "]"]))
      {
        MTServiceParameter param = new MTServiceParameter();
        param.ParamName = Request["SvcMethodParamName[" + i + "]"];
        param.ParamValue = Request["SvcMethodParamValue[" + i + "]"];
        param.DataType = Request["SvcMethodParamType[" + i + "]"];

        gde.ServiceMethodParameters.Add(param);

        i++;
      }
    }
  }

  protected void ProcessKeyValuePairElement(string element)
  {
    string[] keyValuePair = element.Split(new char[] { '=' });

    //make sure we have two items: key and value
    if (keyValuePair.Length != 2)
    {
      return;
    }

    //read out key and value
    string key = keyValuePair[0];
    string value = keyValuePair[1];

    //populate the arguments dictionary
    if (!gde.Arguments.ContainsKey(key))
    {
      gde.Arguments.Add(key, value);
    }
    else
    {
      gde.Arguments[key] = value;
    }
  }

  protected void ParseAdditionalArguments(string args)
  {
    string[] elementSeparator = new string[] { "**" }; //instead of regular &    

    if (args.Length == 0)
    {
      return;
    }

    //break each element into array of key value pairs
    string[] elements = args.Split(elementSeparator, StringSplitOptions.None);

    //check the case when there is only one element
    if (args.Length > 0 && elements.Length == 0)
    {
      ProcessKeyValuePairElement(args);
    }

    //iterate through each key value pairs
    foreach (string elt in elements)
    {
      ProcessKeyValuePairElement(elt);
    }
  }

}
