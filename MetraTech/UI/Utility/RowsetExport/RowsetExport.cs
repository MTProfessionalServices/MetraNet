using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Globalization;
using System.Text;
using MetraTech.Interop.Rowset;
using COMDBObjects = MetraTech.Interop.COMDBObjects;
using ASP.interop;  // ASP interop signed with "MetraTech" key

[assembly: Guid("3DB3F4EC-5B53-4e16-A937-63EDCBD50534")]
namespace MetraTech.UI.Utility.RowsetExport
{

  [Guid("E4EB358A-F2E1-4ffe-B35D-0678E36A4C6A")]
  public interface IExport
  {
    void Init(IResponse response, string delimeter, string retChar, int timeZoneID, string culture, string dateTimeFormat);
    void AddPropertyToExport(string prop, string type);
    void WriteRowsetToResponse(IMTRowSet rs);
  }
  
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("C40C4C05-8005-4ade-859A-4F4CCBD41DBA")]
	public class Export : IExport
	{
    private IResponse mResponse = null;
    private string mDelimeter = null;
    private string mRetChar = null;
    private int mTimeZoneID = -1;
    private ArrayList mProps = new ArrayList();
    private ArrayList mTypes = new ArrayList();
    private IFormatProvider mCulture = null;
    private string mDateTimeFormat = "G";

		public Export()
		{
		}

    /// <summary>
    /// Init - Initializes the Export object with the ASP Response object and other locale settigs.
    /// </summary>
    /// <param name="response"></param>
    /// <param name="delimeter"></param>
    /// <param name="retChar"></param>
    /// <param name="timeZoneID"></param>
    /// <param name="culture"></param>
    /// <param name="dateTimeFormat"></param>
    public void Init(IResponse response, string delimeter, string retChar, int timeZoneID, string culture, string dateTimeFormat)
    {
      mResponse = response;
      mDelimeter = delimeter;
      mRetChar = retChar;
      mTimeZoneID = timeZoneID;
      mCulture = new System.Globalization.CultureInfo(culture, false);
      mDateTimeFormat = dateTimeFormat;
    }

    /// <summary>
    /// AddPropertyToExport - Creates a list of properties that should be exported from the rowset.
    /// </summary>
    /// <param name="prop"></param>
    /// <param name="type"></param>
    public void AddPropertyToExport(string prop, string type)
    {
      mProps.Add(prop);
      mTypes.Add(type);
    }

    /// <summary>
    /// WriteRowsetToResponse - Loops around passed in rowset writing out all the properties
    /// that have been added to the export list.  It also converts DateTime values with
    /// the correct timezone and locale.
    /// </summary>
    /// <param name="rs"></param>
    public void WriteRowsetToResponse(IMTRowSet rs)
    {
      if(mResponse.Equals(null))
      {
        throw new ApplicationException("Response object not set in Init() method.");
      }

      if(rs.Equals(null))
      {
        throw new ApplicationException("No data to export.");
      }

      COMDBObjects.COMLocaleTranslator localeTrans = new COMDBObjects.COMLocaleTranslatorClass();
      localeTrans.Init("US"); // Language is not used for GetDateTime

      StringBuilder sb = new StringBuilder();
      int i;
      int row = 0;
      
      rs.MoveFirst();
      while(!Convert.ToBoolean(rs.EOF))
      {
        i = 0;

        foreach(string prop in mProps)
        {
          string type = mTypes[i].ToString();

          switch(type)
          {
            case "DATETIME":
            case "DATE":
              // if we run into a null date time we append an empty string
              if (rs.get_Value(prop) == null)
              {
                sb.Append("");
              }
              else
              {
                try
                {
                  DateTime dt = DateTime.FromOADate((double)(localeTrans.GetDateTime(rs.get_Value(prop), mTimeZoneID, true)));
                  sb.Append(dt.ToString(mDateTimeFormat, mCulture));  // G = "08/17/2000 16:32:32" for "en-US"
                }
                catch (Exception)
                {
                  sb.Append("");
                }
              }
              break;

            default:
              try
              {
                sb.Append(rs.get_Value(prop).ToString());
              }
              catch
              {
                sb.Append(prop.ToString() + " NA");
              }
              break;
          }

          sb.Append(mDelimeter);
          i++;  
        }
        
        sb.Append(mRetChar);
        if((row % 10) == 0)  // Write to and Flush the response buffer every 10 rows
        {
          mResponse.Write(sb.ToString());
          mResponse.Flush();  
          sb.Remove(0, sb.Length);
        }
        rs.MoveNext();
        row++;
      }

      mResponse.Write(sb.ToString());
      mResponse.Flush();  
    }

  }
}
