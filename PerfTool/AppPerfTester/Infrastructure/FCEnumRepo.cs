using System;
using System.Collections.Generic;
using System.Data.Linq;
using System.Linq;
using System.Data;
using log4net;


namespace BaselineGUI
{
  using DbEnum = Dictionary<string, FCEnumRepo.DbEnumPair>;

  public class FCEnumRepo : FrameworkComponentBase, IFrameworkComponent
  {
    private static readonly ILog log = LogManager.GetLogger(typeof(FCEnumRepo));

    public class DbEnumPair
    {
      public string nm_enum_data { set; get; }
      public int id_enum_data { set; get; }

    }


    public Dictionary<string, DbEnum> dbEnums = new Dictionary<string, DbEnum>();
    public int Count = 0;

    public DataTable tabularModel;

    public FCEnumRepo()
    {
      name = "EnumRepo";
      fullName = "Enumerated Values";

      tabularModel = new DataTable();
      tabularModel.Columns.Add(new DataColumn("Namespace", typeof(string)));
      tabularModel.Columns.Add(new DataColumn("Enum", typeof(string)));
      tabularModel.Columns.Add(new DataColumn("Enum Value", typeof(string)));
      tabularModel.Columns.Add(new DataColumn("Numeric Value", typeof(int)));
    }

    public void Bringup()
    {
      DataContext dc = new DataContext(Framework.conn);
      List<DbEnumPair> pvs = dc.ExecuteQuery<DbEnumPair>("select * from dbo.t_enum_data").ToList<DbEnumPair>();
      foreach (DbEnumPair pv in pvs)
      {
        string[] tokens = pv.nm_enum_data.Split('/');
        Stack<string> stk = new Stack<string>();
        foreach (string tkn in tokens)
        {
          stk.Push(tkn);
        }

        string enumNs = "";
        string enumName = "";
        string enumTag = "";

        if (stk.Count > 0)
        {
          enumTag = stk.Pop();
        }

        if (stk.Count > 0)
        {
          enumName = stk.Pop();
        }

        if (stk.Count > 0)
        {
          enumNs = string.Join("/", stk.Reverse());
        }


        string key = enumNs + "~>" + enumName;
        DbEnum e;
        if (dbEnums.ContainsKey(key))
        {
          e = dbEnums[key];
        }
        else
        {
          e = new DbEnum();
          dbEnums.Add(key, e);
        }

        e.Add(enumTag, pv);
        Count++;

        DataRow row = tabularModel.NewRow();
        row["Namespace"] = enumNs;
        row["Enum"] = enumName;
        row["Enum Value"] = enumTag;
        row["Numeric Value"] = pv.id_enum_data;
        tabularModel.Rows.Add(row);

      }

      AppRefData.FastEnums.Instance.init(this);

      bringupState.message = string.Format("Loaded {0} enums", Count);
    }

    public int getValue(string ns, string enumName, string enumTag)
    {
      try
      {
        string key = ns + "~>" + enumName;
        return dbEnums[key][enumTag].id_enum_data;
      }
      catch
      {
        log.FatalFormat("Failed to find {0}~>{1}.{2}", ns, enumName, enumTag);
      }
      return 0;
    }

    public void Teardown()
    {
    }

  }
}
