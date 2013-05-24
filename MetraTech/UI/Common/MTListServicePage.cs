using System;
using System.Diagnostics;
using System.Data;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using System.Threading;
using System.Globalization;
using MetraTech.ActivityServices.Common;
using System.Text;
using System.Collections;
using System.Reflection;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.UI.Tools;
using System.Text.RegularExpressions;
using MetraTech.DataAccess;

namespace MetraTech.UI.Common
{
  public class MTListServicePage : MTPage
  {
    protected string ConvertObjectToCSV<T>(MTList<T> mtList, bool bIncludeHeaders)
    {
      StringBuilder sb = new StringBuilder();

      //add headers if necessary
      if (bIncludeHeaders)
      {
        sb.Append(GenerateCSVHeader());
        if (sb.ToString().Length > 0)
        {
          sb.Append("\n");
        }
      }

      //iterate through the list of items
      foreach (object curItem in mtList.Items)
      {
        string curRowCSV = ConvertRowToCSV(curItem);
        sb.Append(curRowCSV);
        sb.Append("\n");
      }

      return sb.ToString();
    }

		protected string GenerateCSVHeader()
		{
			StringBuilder sb = new StringBuilder();
			//iterate through the fields that we want to extract
			int columnIndex = 0;
			while (!String.IsNullOrEmpty(Request["column[" + columnIndex.ToString() + "][columnID]"]))
			{
				string headerText = Request["column[" + columnIndex.ToString() + "][headerText]"];
				//fix for ESR-5139: MetraCare- Advanced Find Export- extra column in spreadsheet
				if (headerText.Equals("&nbsp;", StringComparison.InvariantCultureIgnoreCase))
				{
					columnIndex++;
					continue;
				}

				string columnID = Request["column[" + columnIndex.ToString() + "][columnID]"];
				if (columnIndex > 0 && sb.Length > 0)
				{
					sb.Append(",");
				}

				sb.Append("\"");
				if (headerText != null)
				{
					sb.Append(headerText.ToString().Replace("\"", "\"\""));
				}
				else
				{
					sb.Append(columnID.ToString().Replace("\"", "\"\""));
				}
				sb.Append("\"");

				columnIndex++;
			}

			return sb.ToString();
		}

		/// <summary>
		/// Export a single row of data to csv
		/// </summary>
		/// <param name="curRow"></param>
		/// <returns></returns>
		protected string ConvertRowToCSV(object curRow)
		{
			if (curRow == null)
			{
				return String.Empty;
			}

			StringBuilder sb = new StringBuilder();

			//iterate through the fields that we want to extract
			int columnIndex = 0;

			while (!String.IsNullOrEmpty(Request["column[" + columnIndex.ToString() + "][columnID]"]))
			{
				//fix for ESR-5139: MetraCare- Advanced Find Export- extra column in spreadsheet
				string headerText = Request["column[" + columnIndex.ToString() + "][headerText]"];
				if (headerText.Equals("&nbsp;", StringComparison.InvariantCultureIgnoreCase))
				{
					columnIndex++;
					continue;
				}

				string curDataIndex = Request["column[" + columnIndex.ToString() + "][mapping]"];
				object cellValue = null;

				try
				{
					if (curRow is EntityInstance)
					{
						EntityInstance entityInstance = curRow as EntityInstance;

						// For enums we must remove the ending ValueDisplayName
						if (curDataIndex.EndsWith("ValueDisplayName"))
						{
							curDataIndex = curDataIndex.Substring(0, curDataIndex.Length - 16);
						}

						PropertyInstance propertyInstance;
						if (curDataIndex == "internalId")  // For internalId which is a contrived UI property, we call Id on the entity instance
						{
							cellValue = entityInstance.Id.ToString();
						}
						else
						{
							propertyInstance = entityInstance[curDataIndex];
							cellValue = propertyInstance.Value;
						}
					}
					else
					{
						cellValue = Utils.GetPropertyEx(curRow, curDataIndex);
					}

				}
				catch { }

				if (columnIndex > 0 && sb.Length > 0)
				{
					sb.Append(",");
				}

				sb.Append("\"");
				if (cellValue != null)
				{
					sb.Append(cellValue.ToString().Replace("\"", "\"\""));
				}
				sb.Append("\"");

				columnIndex++;
			}

			return sb.ToString();
		}

    protected void SetPaging<T>(MTList<T> mtList)
    {
      int pageSize = 10;
      int start = 0;

      //initialize to defaults
      mtList.PageSize = pageSize;
      mtList.CurrentPage = 1;

      //populate page size
      if (!String.IsNullOrEmpty(this.Request["limit"]))
      {
        if (Int32.TryParse(this.Request["limit"], out pageSize))
        {
          mtList.PageSize = pageSize;
        }
      }

      //populate current page
      if (!String.IsNullOrEmpty(this.Request["start"]))
      {
        if (Int32.TryParse(this.Request["start"], out start))
        {
          if (pageSize != 0)
          {
            mtList.CurrentPage = CalculatePageID(start, pageSize);
          }
        }
      }
    }

    protected void SetFilters<T>(MTList<T> mtList)
    {
      int filterID = 0; 
      
      while (!String.IsNullOrEmpty(this.Request["filter[" + filterID.ToString() + "][field]"]))
      {
        string propertyName = this.Request["filter[" + filterID.ToString().Replace("#", "") + "][field]"];
        if (String.IsNullOrEmpty(propertyName))
        {
          continue;
        }

        //ESR-5005 CLONE - MetraView- Booleans in search need to be pull-down list
        object value = null;
        
        if (this.Request["filter[" + filterID.ToString() + "][data][type]"] == "boolean")
        {
            value = this.Request["filter[" + filterID.ToString() + "][data][value]"].Replace("false", "0").Replace("true", "1");
        }
        else
        {
            value = this.Request["filter[" + filterID.ToString() + "][data][value]"];
        }
        
        MTFilterElement.OperationType op;

        switch (this.Request["filter[" + filterID.ToString() + "][data][comparison]"])
        {
          case "eq":
            op = MTFilterElement.OperationType.Equal;
            break;

          case "lk":
            op = MTFilterElement.OperationType.Like_W;

            //need to append wildcard if for LIKE operation
            if (Request["filter[" + filterID + "][data][type]"] == "string")
            {
              //ESR-5562 Can't search for accounts 
              value = Server.HtmlDecode(value.ToString());
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
            if (this.Request["filter[" + filterID.ToString() + "][data][type]"] == "string")
            {
              op = MTFilterElement.OperationType.Like_W;
              //ESR-5562 Can't search for accounts 
              value = Server.HtmlDecode(value.ToString());
              value = AppendWildcard(value.ToString());
            }
            else
            {
              op = MTFilterElement.OperationType.Equal;
            }
            break;

          default:
            //if no operation is specified, default to LIKE_W for strings and equals for all other types
            if (this.Request["filter[" + filterID.ToString() + "][data][type]"] == "string")
            {
              op = MTFilterElement.OperationType.Like_W;
              //ESR-5562 Can't search for accounts 
              value = Server.HtmlDecode(value.ToString());
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
        if (string.Compare(dataType, "date", true, CultureInfo.InvariantCulture) == 0)
        {
          DateTime tmpDate;
          if (DateTime.TryParse(value.ToString(), out tmpDate))
          {
            value = tmpDate;
          }
        }

        // we are dealing with a list
        if (string.Compare(dataType, "list", true, CultureInfo.InvariantCulture) == 0)
        {
          var values = value.ToString().Split(new [] {','});
          var len = values.Length;
          if(len > 1)
          {
            var orOp = AddOrList(propertyName, values, 0);
            mtList.Filters.Add(orOp);
            filterID++;
            continue;
          }
        }

        //CORE-5825 corrected conversion of value if parameter is numeric.
        if (string.Compare(dataType, "numeric", true, CultureInfo.InvariantCulture) == 0)
        {
          double tmpValue = -1;
          if (double.TryParse(value.ToString(), out tmpValue))
          {
            value = tmpValue;
          }
        }

        MTFilterElement mtfe = new MTFilterElement(propertyName, op, value);

        mtList.Filters.Add(mtfe);

        filterID++;
      }
    }
 
    public static MTBinaryFilterOperator AddOrList(string propertyName, string[] orList, int pos)
    {
      var orOp = new MTBinaryFilterOperator(null, MTBinaryFilterOperator.BinaryOperatorType.OR, null);

      orOp.LeftHandElement = new MTFilterElement(propertyName, MTFilterElement.OperationType.Equal, orList[pos]);

      if (orList.Length - pos > 2)
      {
        pos++;
        orOp.RightHandElement = AddOrList(propertyName, orList, pos);
      }
      else
      {
        pos++;
        orOp.RightHandElement = new MTFilterElement(propertyName, MTFilterElement.OperationType.Equal, orList[pos]);
      }
      return orOp;
    }

    protected void SetSorting<T>(MTList<T> mtList)
    {
      //sort field
      if (!String.IsNullOrEmpty(this.Request["sort"]))
      {
        string sortProperty = this.Request["sort"].Replace("#", ".");

        //if sort field ends with either Value DisplayName or AsString, strip both
        if (sortProperty.ToLower().EndsWith("valuedisplayname") ||
          sortProperty.ToLower().EndsWith("asstring"))
        {

          if (sortProperty.ToLower().EndsWith("valuedisplayname"))
          {
            sortProperty = sortProperty.Substring(0, sortProperty.Length - "ValueDisplayName".Length);
          }
          else if (sortProperty.ToLower().EndsWith("asstring"))
          {
            sortProperty = sortProperty.Substring(0, sortProperty.Length - "AsString".Length);
          }

        }

        SortType sortType = SortType.Ascending;
        //sort direction
        if (this.Request["dir"] == "DESC")
        {
          sortType = SortType.Descending;
        }

        mtList.SortCriteria.Add(new MetraTech.ActivityServices.Common.SortCriteria(sortProperty, sortType));
      }
    }

    #region MTList Helpers
    protected void ApplyFilterSortCriteria<T>(IMTBaseFilterSortStatement statement, MTList<T> mtList)
    {
        ApplyFilterSortCriteria<T>(statement, mtList, null, null);
    }

    protected void ApplyFilterSortCriteria<T>(IMTBaseFilterSortStatement statement, MTList<T> mtList, FilterColumnResolver resolver, object helper)
    {
        #region Apply Sorting
        //add sorting info if applies
        if (mtList.SortCriteria != null && mtList.SortCriteria.Count > 0)
        {
            foreach (MetraTech.ActivityServices.Common.SortCriteria sc in mtList.SortCriteria)
            {
                object dummy = null;
                string sortColumn = sc.SortProperty;

                if (resolver != null)
                {
                    sortColumn = resolver(sc.SortProperty, ref dummy, helper);
                }

                if (sortColumn.Contains("%20"))
                {
                    sortColumn = "[" + sortColumn.Replace("%20", " ") + "]";
                }

                statement.SortCriteria.Add(
                    new MetraTech.DataAccess.SortCriteria(
                        sortColumn,
                        ((sc.SortDirection == SortType.Ascending) ? MetraTech.DataAccess.SortDirection.Ascending : MetraTech.DataAccess.SortDirection.Descending)));
            }
        }

        #endregion

        #region Apply Filters
        //apply filters
        foreach (MTBaseFilterElement filterElement in mtList.Filters)
        {
            BaseFilterElement fe = ConvertMTFilterElement(filterElement, resolver, helper);

            statement.AddFilter(fe);
        }
        #endregion

        #region Apply Pagination
        //set paging info
        statement.CurrentPage = mtList.CurrentPage;
        statement.PageSize = mtList.PageSize;
        #endregion
    }

    protected delegate string FilterColumnResolver(string propName, ref object propValue, object helper);

    private BaseFilterElement ConvertMTFilterElement(MTBaseFilterElement filterElement, FilterColumnResolver resolver, object helper)
    {
        BaseFilterElement bfe = null;

        if (filterElement.GetType() == typeof(MTBinaryFilterOperator))
        {
            MTBinaryFilterOperator bfo = filterElement as MTBinaryFilterOperator;

            bfe = new BinaryFilterElement(
                        ConvertMTFilterElement(bfo.LeftHandElement, resolver, helper),
                        (BinaryFilterElement.BinaryOperatorType)((int)bfo.OperatorType),
                        ConvertMTFilterElement(bfo.RightHandElement, resolver, helper));
        }
        else if (filterElement.GetType() == typeof(MTFilterElement))
        {
            MTFilterElement fe = filterElement as MTFilterElement;
            object filterValue = fe.Value;
            string filterColumn = fe.PropertyName;

            if (resolver != null)
            {
                filterColumn = resolver(fe.PropertyName, ref filterValue, helper);
            }

            if (filterColumn.Contains("%20"))
            {
                filterColumn = "[" + filterColumn.Replace("%20", " ") + "]";
            }

            bfe = new FilterElement(filterColumn,
              (FilterElement.OperationType)((int)fe.Operation),
              filterValue);
        }
        else
        {
            throw new MASBasicException("Unexpected MTBaseFilterElement type");
        }

        return bfe;
    }
    #endregion

    protected string FixJsonDate(string input)
    {
      MatchEvaluator me = new MatchEvaluator(MTListServicePage.MatchDate);
      string json = Regex.Replace(input, "\\\\/\\Date[(](-?\\d+)[)]\\\\/", me, RegexOptions.None);

      return json;
    }


    public static string MatchDate(Match m)
    {
      long longDate = 0;

      if (m.Groups.Count >= 2)
      {
        if (long.TryParse(m.Groups[1].Value, out longDate))
        {
          long ticks1970 = new DateTime(1970, 1, 1).Ticks;
          string retVal = new DateTime(longDate * 10000 + ticks1970).ToLocalTime().ToString();
          return retVal;
        }
      }
      return m.Value;
    }

    protected string FixJsonBigInt(string input)
    {
      string regex = "(?<=\\\"\\w+\\\":)\\-{0,1}\\d{17,}";
      var me = new MatchEvaluator(MatchBigInt);
      string json = Regex.Replace(input, regex, me, RegexOptions.None);

      return json;
    }

    public static string MatchBigInt(Match m)
    {
      return String.Format("\"{0}\"", m.Value);
    }

    private int CalculatePageID(int start, int pageSize)
    {
      return (start / pageSize) + 1;
    }

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
      //ESR-4621 Filtering on enums in usage PV 
      //(filtering on a PV for a string i.e. accountName=’TV4’ the semantics is to get all rows where accountName stars with ‘TV4’ so we will also get TV400.)
      output = output.Replace("'" + WILDCARD_CHAR.ToString(), "");
      output = output.Replace("*", WILDCARD_CHAR.ToString());
      output = output.Replace(WILDCARD_CHAR + WILDCARD_CHAR.ToString(), WILDCARD_CHAR.ToString());

      return output;
    }
  }
}
