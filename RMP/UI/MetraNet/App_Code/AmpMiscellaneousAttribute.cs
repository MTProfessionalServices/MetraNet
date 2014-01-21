using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for AmpDecisionMiscellaneousAttribute
/// </summary>
public class AmpDecisionMiscellaneousAttribute
{
  private string mID;
  public string ID
  {
    get { return mID; }
    set { mID = value; }
  }

  private string mName;
  public string Name
  {
    get { return mName; }
    set { mName = value; }
  }

  private string mHardCodedValue;
  public string HardCodedValue
  {
    get { return mHardCodedValue; }
    set { mHardCodedValue = value; }
  }

  private string mColumnName;
  public string ColumnName
  {
    get { return mColumnName; }
    set { mColumnName = value; }
  }
}