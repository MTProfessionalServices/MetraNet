using System;
using MetraTech;
using System.IO;
using System.Collections;
using System.Text;
using System.Xml;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Diagnostics;
using Rowset=MetraTech.Interop.Rowset;


[assembly: Guid("00C1CDDF-2419-4f05-8751-97D643DB20DF")]

namespace MetraTech.Audit
{

  [Guid("2B9F7CA8-5D76-4265-AE99-8D42329D11AF")]
  public interface IAuditLogManager
  {
    int MaximumNumberRecords
    { 
      get;
      set; 
    }  
    //string GetAuditLogAsRowset(ProdCat.IMTProductOffering po);
    Rowset.IMTSQLRowset GetAuditLogAsRowset(Rowset.IMTDataFilter filter);

  }


  [ClassInterface(ClassInterfaceType.None)]
  [Guid("950FB417-F7AA-4345-8748-3B99C257D772")]
  public class AuditLogManager: IAuditLogManager
  {
    public AuditLogManager()
    {
      mMaximumNumberRecords=1000;
    }
    
    protected Logger mLogger = new Logger("[AuditLogManager]");
    
    protected int mMaximumNumberRecords;

    public int MaximumNumberRecords
    {  

      get
      {
        return mMaximumNumberRecords;
      }  

      set
      { 
        mMaximumNumberRecords = value; 
      }  
    }



    public Rowset.IMTSQLRowset GetAuditLogAsRowset(Rowset.IMTDataFilter filter)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(@"Queries\Audit");
      rowset.SetQueryTag("__SELECT_AUDIT_LOG_EX__");

      string condition = "1=1";
			string whereClause = "";
      if (filter!=null && filter.FilterString !=null && filter.FilterString.Length>0)
      {
				condition = filter.FilterString;
      }
			whereClause = String.Format("WHERE {0} ", condition);

      string topClause = "";
      if (mMaximumNumberRecords>0)
      {
        topClause = String.Format("{0}", mMaximumNumberRecords);
      }

      rowset.AddParam("%%WHERE_CLAUSE%%", whereClause, true);
      rowset.AddParam("%%TOP_CLAUSE%%", topClause, true);

      rowset.Execute();

      return rowset;
    }

  }

 
  

}
