using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.UI.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Web.Script.Serialization;
using MetraTech.ActivityServices.Common;
using System.Collections.Generic;
using MetraTech.DataAccess;
using System.Text;



public partial class AjaxServices_DecisionService : MTListServicePage
{
  protected void Page_Load ( object sender, EventArgs e )
  {
    int id_interval;
    String str_interval = Request [ "id_interval" ];
    if ( string.IsNullOrEmpty ( str_interval ) )
    {
      var billManager = new BillManager ( UI );
      var iv = billManager.GetCurrentInterval ();
      if ( iv != null )
      {
        id_interval = iv.ID;
      }
      else
      {
        Logger.LogWarning ( "No interval (id_interval) specified" );
        Response.Write ( "{\"TotalRows\":\"0\",\"Items\":[]}" );
        Response.End ();
        return;
      }
    }
    else
    {
      id_interval = int.Parse ( str_interval );
    }

    using ( new HighResolutionTimer ( "DecisionService", 5000 ) )
    {
      using ( var conn = ConnectionManager.CreateConnection ( ) )
      {
          Logger.LogDebug("Looking for decisions for id_acc " + UI.User.AccountId + " and interval " + id_interval  );
        using ( var stmt = conn.CreateAdapterStatement ( "MetraViewServices", "__MVIEW_GET_CURRENT_DECISION_STATE__" ) )
        {
          stmt.AddParam ( "%%ID_ACC%%", UI.User.AccountId );
          stmt.AddParam ( "%%ID_INTERVAL%%", id_interval );
          using ( var rdr = stmt.ExecuteReader () )
          {
            var decisions = new Dictionary<string, DecisionInstance> ();
            while ( rdr.Read () )
            {
			  Logger.LogDebug("Found decision");
              var bucket = new BucketInstance ( Logger, rdr );
              DecisionInstance decision;
              if ( !decisions.TryGetValue ( bucket.DecisionId, out decision ) )
              {
                decision = new DecisionInstance ( bucket.DecisionId, Logger, rdr );
                decisions [ bucket.DecisionId ] = decision;
              }
              decision.BucketInstances.AddRange ( bucket.SplitBands () );
            }
            Response.Write ( "[" );
            bool first = true;
            foreach ( var d in decisions.Values )
            {
              if ( !first )
              {
                Response.Write ( "," );
              }
              first = false;
              var t = DecisionToJson ( d );
              Logger.LogDebug ( "Response: " + t );
              Response.Write ( t );
            }
            Response.Write ( "]" );
          }
        }
      }
/*
      var random = new Random ();
      Response.Write ( "[{\"title\":\"Commitment\",\"subtitle\":\"Quarterly Commitment\",\"startDate\":\"January 12, 2013\",\"endDate\":\"April 11, 2013\",\"ranges\":[0,30000],\"measures\":[" + random.Next ( 35000 ) + "],\"markers\":[24500, 27000, 30000],\"tickTitle\":\"revenue ($)\",\"rangeTitles\":[\"\",\"Commitment Tier\"],\"measureTitles\":[\"$10,000 so far\",\"Projected to $27,000\"],\"markerTitles\":[\"Last time incurred shortfall of $5,500\",\"Projected shortfall charge of $3,000\", \"Commitment Threshold\"],\"rangeTicks\":[\"\"],\"markerClass\":[\"past\",\"bad\"],\"rangeClass\":[],\"measureRanges\":[]}" );
      Response.Write ( ",{\"title\":\"Commitment\",\"subtitle\":\"Annual Commitment\",\"startDate\":\"October 17, 2012\",\"endDate\":\"October 16, 2013\",\"ranges\":[0,100000],\"measures\":[" + random.Next ( 110000 ) + "],\"markers\":[100000,111352.88,130000],\"tickTitle\":\"revenue ($)\",\"rangeTitles\":[\"\",\"Commitment Tier\"],\"measureTitles\":[\"$90,000 so far\",\"Projected to $130,000\"],\"markerTitles\":[\"Commitment Threshold\",\"Last time $111,352.88\", \"Projected $130,000\"],\"rangeTicks\":[\"\"],\"markerClass\":[\"\",\"past\",\"good\"],\"rangeClass\":[],\"measureRanges\":[]}" );
      Response.Write ( ",{\"title\":\"Allowance\",\"subtitle\":\"Free Minutes\",\"startDate\":\"March 1, 2013\",\"endDate\":\"March 31, 2013\",\"ranges\":[0,1000],\"measures\":[1000, 3000],\"markers\":[1000],\"tickTitle\":\"minutes\",\"rangeTitles\":[\"\",\"Free Minutes\"],\"measureTitles\":[\"1,000 minutes @ $0\", \"2,000 minutes totalling $238.72\"],\"markerTitles\":[\"1000 Free Minutes\"],\"rangeTicks\":[\"Included\",\"Overage\"],\"markerClass\":[],\"rangeClass\":[\"selected\", \"selected\"],\"measureRanges\":[0,1]}" );
      Response.Write ( ",{\"title\":\"Allowance\",\"subtitle\":\"Free Conferences\",\"startDate\":\"December 25, 2012\",\"endDate\":\"December 25, 2020\",\"ranges\":[0,10],\"measures\":[10],\"markers\":[10],\"tickTitle\":\"conferences\",\"rangeTitles\":[\"\",\"Free Conferences\"],\"measureTitles\":[\"10 conferences @ $0\"],\"markerTitles\":[\"10 Free Conferences\"],\"rangeTicks\":[\"Included\",\"Overage\"],\"markerClass\":[],\"rangeClass\":[\"selected\",\"future\"],\"measureRanges\":[0]}" );
      Response.Write ( ",{\"title\":\"Pricing\",\"subtitle\":\"Multi-Bucket Pricing\",\"startDate\":\"January 1, 2013\",\"endDate\":\"June 30, 2013\",\"ranges\":[0,100,200,300,400,500],\"measures\":[100,200,300,400,450],\"markers\":[450],\"tickTitle\":\"minutes\",\"rangeTitles\":[\"\",\"$0.10 per minute\",\"$0.08 per minute\",\"$0.07 per minute\",\"$0.06 per minute\",\"$0.05 per minute\",\"$0.03 per minute\"],\"measureTitles\":[\"100 minutes @ $0.10\",\"100 minutes @ $0.08\",\"100 minutes @ $0.07\",\"100 minutes @ $0.06\",\"50 minutes @ $0.05\"],\"markerTitles\":[\"450 minutes\"],\"rangeTicks\":[\"$0.10\",\"$0.08\",\"$0.07\",\"$0.06\",\"$0.05\",\"$0.03\"],\"markerClass\":[],\"rangeClass\":[\"selected\",\"selected\",\"selected\",\"selected\",\"selected\",\"future\"],\"measureRanges\":[0,1,2,3,4]}" );
      Response.Write ( ",{\"title\":\"Pricing\",\"subtitle\":\"Single-Bucket Pricing\",\"startDate\":\"March 1, 2013\",\"endDate\":\"March 31, 2013\",\"ranges\":[0,100,200,300,400,500],\"measures\":[350],\"markers\":[350],\"tickTitle\":\"minutes\",\"rangeTitles\":[\"\",\"$0.20 per minute\",\"$0.18 per minute\",\"$0.15 per minute\",\"$0.10 per minute\",\"$0.08 per minute\",\"$0.05 per minute\"],\"measureTitles\":[\"350 minutes @ $0.10\"],\"markerTitles\":[\"350 minutes\"],\"rangeTicks\":[\"$0.20\",\"$0.18\",\"$0.15\",\"$0.10\",\"$0.08\",\"$0.05\"],\"markerClass\":[],\"rangeClass\":[\"expired\",\"expired\",\"expired\",\"selected\",\"future\",\"future\"],\"measureRanges\":[3]}" );
      Response.Write ( "]" );
 * */
      Response.End ();
    }

  }

  protected string DecisionToJson ( DecisionInstance decision )
  {
    // TODO: escape strings too
    string title = decision.Title;
    string subtitle = decision.Subtitle;
    string datesLabel = decision.DatesText;
    List<decimal> ranges = decision.Ranges;
    List<decimal> measures = decision.Measures;
    List<decimal> markers = decision.Markers;
    string tickTitle = decision.TickTitle;
    List<string> rangeTitles = decision.RangeTitles;
    List<string> measureTitles = decision.MeasureTitles;
    List<string> markerTitles = decision.MarkerTitles;
    List<string> rangeTicks = decision.RangeTicks;
    List<string> markerClasses = decision.MarkerClasses;
    List<string> rangeClasses = decision.RangeClasses;
    List<int> measureRanges = decision.MeasureRanges;

    StringBuilder builder = new StringBuilder ( "{" );
    builder.AppendFormat ( "\"title\":\"{0}\",\"subtitle\":\"{1}\",\"startDate\":\"{2}\",\"endDate\":\"{3}\",\"datesLabel\":\"{4}\",\"intervalId\":{5},\"ranges\":{6},\"measures\":{7},\"markers\":{8},\"tickTitle\":\"{9}\""
      , title, subtitle, decision.StartDate, decision.EndDate, datesLabel, decision.IntervalId, NumberListToJson ( ranges ), NumberListToJson ( measures ), NumberListToJson ( markers ), tickTitle );
    builder.AppendFormat ( ",\"rangeTitles\":{0},\"measureTitles\":{1},\"markerTitles\":{2},\"rangeTicks\":{3},\"markerClass\":{4},\"rangeClass\":{5},\"measureRanges\":{6},\"decisionId\":\"{7}\"",
      StringListToJson ( rangeTitles ), StringListToJson ( measureTitles ), StringListToJson ( markerTitles ), StringListToJson ( rangeTicks ), StringListToJson ( markerClasses ), StringListToJson ( rangeClasses ), NumberListToJson ( measureRanges ), decision.DecisionId );
    builder.Append ( "}" );
    return builder.ToString ();
  }

  protected string NumberListToJson ( List<decimal> range )
  {
    if ( range == null )
    {
      return "[]";
    }
    return "[" + string.Join ( ",", range ) + "]";
  }

  protected string NumberListToJson(List<int> range)
  {
      if (range == null)
      {
          return "[]";
      }
      return "[" + string.Join(",", range) + "]";
  }

  protected string StringListToJson(List<string> range)
  {
    if ( range == null )
    {
      return "[]";
    }
    return "[\"" + string.Join ( "\",\"", range ) + "\"]";
  }

}

public class BucketInstance
{
  public Dictionary<string, object> DecisionInstAttributes
  {
    get;
    set;
  }

  public string DecisionId
  {
    get;
    set;
  }

  public int IntervalId
  {
    get;
    set;
  }

  public List<BucketInstance> SplitBands ()
  {
    List<BucketInstance> bands = new List<BucketInstance> ();

    object val;
    if ( DecisionInstAttributes.TryGetValue ( "total_bands", out val ))
    {
      int cnt = Convert.ToInt32(val);
      for ( int i = 1; i <= cnt; i++ )
      {
        var suffix = "_band" + i;
        var dict = new Dictionary<string, object> ();
        foreach (var key in DecisionInstAttributes.Keys)
        {
          dict [ key ] = DecisionInstAttributes [ key ];
          if ( key.EndsWith ( suffix, StringComparison.InvariantCultureIgnoreCase ) )
          {
            dict [ key.Substring ( 0, key.LastIndexOf ( suffix ) ) ] = DecisionInstAttributes [ key ];
          }
        }
        bands.Add ( new BucketInstance ( this, dict ) );
      }
    }
    else
    {
      bands.Add ( this );
    }
    return bands;
  }

  public BucketInstance ( BucketInstance other, Dictionary<string, object> attribs )
  {
    this.Logger = other.Logger;
    TierStart = decimal.MinValue;
    TierEnd = decimal.MaxValue;
    this.DecisionInstAttributes = attribs;
    this.DecisionId = other.DecisionId;
    this.IntervalId = other.IntervalId;
    this.QualifiedTotal = other.QualifiedTotal;
    if ( this.DecisionInstAttributes.ContainsKey ( "tier_start" ) )
    {
      this.TierStart = Convert.ToDecimal(this.DecisionInstAttributes [ "tier_start" ]);
    }
    if ( this.DecisionInstAttributes.ContainsKey ( "tier_end" ) )
    {
      this.TierEnd = Convert.ToDecimal(this.DecisionInstAttributes [ "tier_end" ]);
    }
  }

  protected MetraTech.ILogger Logger;

  public BucketInstance ( MetraTech.ILogger Logger, IMTDataReader rdr )
  {
    this.Logger = Logger;
    DecisionInstAttributes = new Dictionary<string, object> ();
    TierStart = decimal.MinValue;
    TierEnd = decimal.MaxValue;
	bool hasStart = false;
	bool hasEnd = false;

    for ( int i = 0; i < rdr.FieldCount; i++ )
    {
      Logger.LogDebug ( rdr.GetName ( i ) + " = " + rdr.GetValue ( i ) );
      if ( rdr.GetName ( i ).Equals ( "id_usage_interval", StringComparison.InvariantCultureIgnoreCase ) )
      {
        IntervalId = rdr.GetInt32 ( i );
      }
      else if ( rdr.GetName ( i ).Equals ( "tier_start", StringComparison.InvariantCultureIgnoreCase ) )
      {
        if ( !rdr.IsDBNull ( i ) )
        {
          TierStart = rdr.GetDecimal ( i );
		  hasStart = true;
        }
      }
      else if ( rdr.GetName ( i ).Equals ( "tier_end", StringComparison.InvariantCultureIgnoreCase ) )
      {
        if ( !rdr.IsDBNull ( i ) )
        {
          TierEnd = rdr.GetDecimal ( i );
		  hasEnd = true;
        }
      }
      else if ( rdr.GetName ( i ).Equals ( "qualified_total", StringComparison.InvariantCultureIgnoreCase ) )
      {
        if ( !rdr.IsDBNull ( i ) )
        {
          QualifiedTotal = rdr.GetDecimal ( i );
        }
      }
      else if ( rdr.GetName ( i ).Equals ( "decision_object_id", StringComparison.InvariantCultureIgnoreCase ) )
      {
        string [] values = rdr.GetString ( i ).Split ( new string [ 1 ] { "<|" }, StringSplitOptions.None );
        string [] headers = GetHeaders ( Convert.ToInt32 ( values [ 0 ] ) );
        for ( int j = 0; j < headers.Length; j++ )
        {
          DecisionInstAttributes [ headers [ j ] ] = values [ j + 1 ];
          Logger.LogDebug ( "\t" + headers [ j ] + " = " + values [ j + 1 ] );
          if ( headers [ j ].Equals ( "tier_start", StringComparison.InvariantCultureIgnoreCase ) )
          {
		    if (!string.IsNullOrEmpty(values [ j + 1 ]))
		    {
              TierStart = Convert.ToDecimal(values [ j + 1 ]);
			  hasStart = true;
			}
          }
          else if ( headers [ j ].Equals ( "tier_end", StringComparison.InvariantCultureIgnoreCase ) )
          {
		    if (!string.IsNullOrEmpty(values [ j + 1 ]))
		    {
              TierEnd = Convert.ToDecimal ( values [ j + 1 ] );
			  hasEnd = true;
			}
          }
        }
      }
      if ( !rdr.IsDBNull ( i ) )
      {
        DecisionInstAttributes [ rdr.GetName ( i ).ToLowerInvariant() ] = rdr.GetValue ( i );
      }
    }
	
	if (!hasStart)
	{
	  TierStart = 0;
	}
	if (!hasEnd)
	{
	  TierEnd = TierStart;
	}
	
    object DecisionIdFormat;
    DecisionInstAttributes.TryGetValue("decision_id_format", out DecisionIdFormat);

    if (string.IsNullOrEmpty(DecisionIdFormat as string))
    {
      DecisionIdFormat = "{id_acc}:{id_sub}:{id_po}:{id_sched}:{id_pi_template}:{id_pi_instance}";
    }
    DecisionId = Format(DecisionIdFormat as string);
  }

  // TODO: cache this
  public static string [] GetHeaders ( int id )
  {
    string [] list = null;
    using ( var conn = ConnectionManager.CreateConnection ( ) )
    {
      using ( var stmt = conn.CreateAdapterStatement ( "MetraViewServices", "__MVM_GET_COUNTER_HEADERS__") )
      {
        stmt.AddParam ( "%%FORMAT_ID%%", id );
        using ( var rdr = stmt.ExecuteReader () )
        {
          while ( rdr.Read () )
          {
            string a1 = string.Empty;
            if ( !rdr.IsDBNull ( "format_string1" ) )
            {
              a1 += rdr.GetString ( "format_string1" );
            }
            if ( !rdr.IsDBNull ( "format_string2" ) )
            {
              a1 += rdr.GetString ( "format_string2" );
            }
            if ( !rdr.IsDBNull ( "format_string3" ) )
            {
              a1 += rdr.GetString ( "format_string3" );
            }
            if ( !rdr.IsDBNull ( "format_string4" ) )
            {
              a1 += rdr.GetString ( "format_string4" );
            }
            if ( !rdr.IsDBNull ( "format_string5" ) )
            {
              a1 += rdr.GetString ( "format_string5" );
            }
            list = a1.ToLowerInvariant().Split ( ',' );
          }
        }
      }
    }
    return list;
  }



  public decimal TierStart
  {
    get;
    set;
  }

  public decimal TierEnd
  {
    get;
    set;
  }

  public decimal QualifiedTotal
  {
    get;
    set;
  }

  private string Format ( string format )
  {
    if ( string.IsNullOrEmpty ( format ) )
    {
      return string.Empty;
    }
    // TODO: prepopulate this
    // TODO: support custom rounding
    Dictionary<string, int> indexes = new Dictionary<string, int> ();
    object [] array = new object [ DecisionInstAttributes.Count + 4 ];
    int i = 0;
    array [ i ] = TierStart;
    indexes.Add ( "tier_start", i++ );
    array [ i ] = TierEnd;
    indexes.Add ( "tier_end", i++ );
    if ( !string.IsNullOrEmpty ( DecisionId ) )
    {
      array [ i ] = DecisionId;
      indexes.Add ( "decision_id", i++ );
    }
    array [ i ] = IntervalId;
    indexes.Add ( "id_usage_interval", i++ );
    array [ i ] = QualifiedTotal;
    indexes.Add ( "qualified_total", i++ );
    foreach ( string key in DecisionInstAttributes.Keys )
    {
      if ( !indexes.ContainsKey ( key ) )
      {
        array [ i ] = DecisionInstAttributes [ key ];
        indexes.Add ( key, i++ );
      }
    }
    var regex = new System.Text.RegularExpressions.Regex ( @"(?<open>{+)(?<key>[^}:]+)(?<format>:[^}]+)?(?<close>}+)", System.Text.RegularExpressions.RegexOptions.Compiled );
    System.Text.RegularExpressions.MatchEvaluator evaluator = ( m ) =>
    {
      if ( m.Success )
      {
        string open = m.Groups [ "open" ].Value;
        string close = m.Groups [ "close" ].Value;
        string key = m.Groups [ "key" ].Value;
        string fmt = m.Groups [ "format" ].Value;

        if ( open.Length % 2 == 0 )
        {
          return m.Value;
        }

        int index = -1;
        if (key != null)
        {
            key = key.ToLowerInvariant();
        }
        if ( !indexes.TryGetValue ( key + "." + System.Threading.Thread.CurrentThread.CurrentUICulture.Name, out index ) )
        {
          if ( !indexes.TryGetValue ( key + "." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName, out index ) )
          {
            if ( !indexes.TryGetValue ( key, out index ) )
            {
              index = -1;
            }
          }
        }
        if ( index > -1 )
        {
            // TODO: support currency symbol
            // TODO: support currency precision override
          object currency;
          if ( ( !string.IsNullOrEmpty ( fmt ) ) && fmt.Equals ( ":C", StringComparison.InvariantCultureIgnoreCase ) && DecisionInstAttributes.TryGetValue ( "tier_currency", out currency ) )
          {
            // TODO: lookup correct currency format for currency, and use that to format string
            return string.Format ( "{0}{1}{2}{3}", open, index, fmt, close );
          }
          else
          {
            return string.Format ( "{0}{1}{2}{3}", open, index, fmt, close );
          }
        }
        else
        {
          return string.Empty;
        }
      }
      return m.Value;
    };

    var fm = regex.Replace ( format, evaluator );
    return string.Format ( fm, array );
  }

  private bool TryGetLocalizedString(string baseKey, out object value)
  {
      string localizedKey = baseKey + "." + System.Threading.Thread.CurrentThread.CurrentUICulture.Name;
      if (DecisionInstAttributes.TryGetValue(localizedKey, out value))
      {
          if (value != null)
          {
              return true;
          }
      }
      localizedKey = baseKey + "." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName;
      if (DecisionInstAttributes.TryGetValue(localizedKey, out value))
      {
          if (value != null)
          {
              return true;
          }
      }
      if (DecisionInstAttributes.TryGetValue(baseKey, out value))
      {
          if (value != null)
          {
              return true;
          }
      }
      return false;
  }

  public string RangeTickFormat
  {
      get
      {
          object fmt;
          if (TryGetLocalizedString("range_tick_format", out fmt))
          {
              return fmt as string;
          }
          else
          {
              return "{per_unit_rate}";// string.Empty;
          }
      }
  }

  public string RangeTick
  {
      get
      {
          return Format(RangeTickFormat);
      }
  }

  public string RangeTitleFormat
  {
      get
      {
          object fmt;
          if (TryGetLocalizedString("range_title_format", out fmt))
          {
              return fmt as string;
          }
          else
          {
              return string.Empty;
          }
      }
  }

  public string RangeTitle
  {
      get
      {
          return Format(RangeTitleFormat);
      }
  }

  public string MeasureTitleFormat
  {
      get
      {
          object fmt;
          if (TryGetLocalizedString("measure_title_format", out fmt))
          {
              return fmt as string;
          }
          else
          {
              return "{qualified_events:#} events qualified";
          }
      }
  }

  public string MeasureTitle
  {
      get
      {
          return Format(MeasureTitleFormat);
      }
  }


}

public class DecisionInstance
{
  public string DecisionId
  {
    get;
    set;
  }

  public int IntervalId
  {
    get;
    set;
  }

  public Dictionary<string, string> DecisionTypeAttributes
  {
    get;
    set;
  }

  public List<BucketInstance> BucketInstances
  {
    get;
    set;
  }

  public DecisionInstance ( string decisionId, MetraTech.ILogger Logger, IMTDataReader rdr )
  {
    this.DecisionId = decisionId;
    this.DecisionTypeAttributes = new Dictionary<string, string> (); ;
    this.BucketInstances = new List<BucketInstance> ();
    string [] values = rdr.GetString ( "decision_object_id" ).Split ( new string [ 1 ] { "<|" }, StringSplitOptions.None );
    string [] headers = BucketInstance.GetHeaders ( Convert.ToInt32 ( values [ 0 ] ) );
    for ( int j = 0; j < headers.Length; j++ )
    {
      DecisionTypeAttributes [ headers [ j ] ] = values [ j + 1 ];
    }
    IntervalId = rdr.GetInt32 ( "id_usage_interval" );
    for (int i = 0; i < rdr.FieldCount; i++)
    {
        if (rdr.GetName(i).Equals("start_date", StringComparison.InvariantCultureIgnoreCase) && !rdr.IsDBNull(i))
        {
            StartDate = rdr.GetDateTime(i);
        }
        else if (rdr.GetName(i).Equals("end_date", StringComparison.InvariantCultureIgnoreCase) && !rdr.IsDBNull(i))
        {
            EndDate = rdr.GetDateTime(i);
        }
    }
  }

  public DateTime StartDate
  {
    get;
    set;
  }

  public DateTime EndDate
  {
    get;
    set;
  }

  public string Title
  {
    get
    {
      string txt = GetLocalizedString ( "title" );
      if ( string.IsNullOrEmpty ( txt ) )
      {
        txt = DecisionType;
      }
      else
      {
        return Format ( txt );
      }
      if ( string.IsNullOrEmpty ( txt ) )
      {
        txt = "Unnamed Decision";
      }
      return txt;
    }
  }

  public string DecisionType
  {
    get
    {
      string txt = GetLocalizedString ( "decision_type" );
      if ( string.IsNullOrEmpty ( txt ) )
      {
        txt = string.Empty;
      }
      return txt;
    }
  }

  public string Subtitle
  {
    get
    {
      string txt = GetLocalizedString ( "subtitle" );
      if ( string.IsNullOrEmpty ( txt ) )
      {
        txt = string.Empty;
      }
      else
      {
        return Format ( txt );
      }
      return txt;
    }
  }

  public string DatesTextFormat
  {
    get
    {
      string txt = GetLocalizedString ( "dates_text_format" );
      if ( string.IsNullOrEmpty ( txt ) )
      {
        txt = "{start_date:D} - {end_date:D}";
      }
      return txt;
    }
  }

  private string Format(string format)
  {
    if ( string.IsNullOrEmpty ( format ) )
    {
      return string.Empty;
    }
    // TODO: prepopulate this
    // TODO: support custom rounding
    Dictionary<string, int> indexes = new Dictionary<string, int> ();
    object [] array = new object [ DecisionTypeAttributes.Count + 4 ];
    int i = 0;
    array [ i ] = StartDate;
    indexes.Add ( "start_date", i++ );
    array [ i ] = EndDate;
    indexes.Add ( "end_date", i++ );
    array [ i ] = DecisionId;
    indexes.Add ( "decision_id", i++ );
    array [ i ] = IntervalId;
    indexes.Add ( "id_usage_interval", i++ );
    foreach ( string key in DecisionTypeAttributes.Keys )
    {
      if ( !indexes.ContainsKey ( key ) )
      {
        array [ i ] = DecisionTypeAttributes [ key ];
        indexes.Add ( key, i++ );
      }
    }

    var regex = new System.Text.RegularExpressions.Regex ( @"(?<open>{+)(?<key>\w+)(?<format>:[^}]+)?(?<close>}+)", System.Text.RegularExpressions.RegexOptions.Compiled );
    System.Text.RegularExpressions.MatchEvaluator evaluator = ( m ) =>
    {
      if ( m.Success )
      {
        string open = m.Groups [ "open" ].Value;
        string close = m.Groups [ "close" ].Value;
        string key = m.Groups [ "key" ].Value;
        string fmt = m.Groups [ "format" ].Value;

        if ( open.Length % 2 == 0 )
        {
          return m.Value;
        }

        int index = -1;
        if (key != null)
        {
            key = key.ToLowerInvariant();
        }
        if ( !indexes.TryGetValue ( key + "." + System.Threading.Thread.CurrentThread.CurrentUICulture.Name, out index ) )
        {
          if ( !indexes.TryGetValue ( key + "." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName, out index ) )
          {
            if ( !indexes.TryGetValue ( key, out index ) )
            {
              index = -1;
            }
          }
        }
        if (index > -1)
        {
            // TODO: support currency symbol
            // TODO: support currency precision override
          string currency;
          if ( ( !string.IsNullOrEmpty ( fmt ) ) && fmt.Equals ( ":C", StringComparison.InvariantCultureIgnoreCase ) && DecisionTypeAttributes.TryGetValue ( "tier_currency", out currency ) )
          {
            // TODO: lookup correct currency format for currency, and use that to format string
            return string.Format ( "{0}{1}{2}{3}", open, index, fmt, close );
          }
          else
          {
            return string.Format ( "{0}{1}{2}{3}", open, index, fmt, close );
          }
        }
        else
        {
          return string.Empty;
        }
      }
      return m.Value;
    };

    return string.Format ( regex.Replace ( format, evaluator ), array );
  }

  public string DatesText
  {
    get
    {
      return Format ( DatesTextFormat );
    }
  }

  public string TierMetric
  {
    get
    {
      string txt = GetLocalizedString ( "tier_metric" );
      if ( string.IsNullOrEmpty ( txt ) )
      {
        txt = string.Empty;
      }
      return txt;
    }
  }

  public string TickTitle
  {
    get
    {
      string txt = GetLocalizedString ( "tick_title" );
      if ( string.IsNullOrEmpty ( txt ) )
      {
        txt = TierMetric;
      }
      else
      {
        return Format ( txt );
      }
      return txt;
    }
  }

  public List<decimal> Ranges
  {
    get
    {
      List<decimal> list = new List<decimal> ();
      foreach ( var b in BucketInstances )
      {
        if ( !list.Contains ( b.TierStart ) )
        {
          list.Add ( b.TierStart );
        }
        if ( !list.Contains ( b.TierEnd ) )
        {
          list.Add ( b.TierEnd );
        }
      }
      list.Sort ();
      return list;
    }
  }

  public List<decimal> Measures
  {
    get
    {
      List<decimal> list = new List<decimal> ();
      foreach ( var b in BucketInstances )
      {
	  if (b.QualifiedTotal > 0.0m)
	  {
	    var m = b.QualifiedTotal;
		if ( m > b.TierEnd )
		{
		  m = b.TierEnd;
		}
        if ( !list.Contains ( b.QualifiedTotal ) )
        {
          list.Add ( b.QualifiedTotal );
        }
        if ( !list.Contains ( m ) )
        {
          list.Add ( m );
        }
		}
      }
	  if (list.Count == 0)
	  {
	    list.Add(0.0m);
	  }
      list.Sort ();
      return list;
    }
  }

  public List<int> MeasureRanges
  {
    get
    {
        List<int> list = new List<int>();
        int i = 0;
        foreach (var b in BucketInstances)
        {
            if (b.QualifiedTotal > 0.0m)
            {
                list.Add(i);
            }
            i++;
        }
        return list;
    }
  }

  public List<decimal> Markers
  {
    get
    {
      List<decimal> list = new List<decimal> ();
      decimal max = decimal.MinValue;
      foreach ( var b in BucketInstances )
      {
          if (b.QualifiedTotal > max)
          {
              max = b.QualifiedTotal;
          }
      }
      if (max > decimal.MinValue)
      {
          list.Add(max);
          if (IncludeProjections)
          {
              var n = (EndDate - StartDate).TotalSeconds;
              var d = (MetraTech.MetraTime.Now - StartDate).TotalSeconds;
              if (MetraTech.MetraTime.Now > EndDate)
              {
                  d = n;
              }
              if (d > 0.0 && n > d)
              {
                  var ratio = n / d;
                  list.Add(max * ((decimal) ratio));
              }
          }
      }
      return list;
    }
  }

  public bool IncludeProjections
  {
      get
      {
          string val;
          if (DecisionTypeAttributes.TryGetValue("include_projections", out val))
          {
              if (!string.IsNullOrEmpty(val))
              {
                  return Convert.ToBoolean(val);
              }
              else
              {
                  return false;
              }
          }
          else
          {
              return false;
          }
      }
  }

  public List<string> MarkerClasses
  {
    get
    {
        List<string> list = new List<string>();
        decimal max = decimal.MinValue;
        decimal end = decimal.MinValue;
        foreach (var b in BucketInstances)
        {
            if (b.QualifiedTotal > max)
            {
                max = b.QualifiedTotal;
            }
            if (b.TierEnd > end)
            {
                end = b.TierEnd;
            }
        }
        if (max > decimal.MinValue)
        {
            list.Add(string.Empty);
            if (IncludeProjections)
            {
                var n = (EndDate - StartDate).TotalSeconds;
                var d = (MetraTech.MetraTime.Now - StartDate).TotalSeconds;
                if (MetraTech.MetraTime.Now > EndDate)
                {
                    d = n;
                }
                if (d > 0.0 && n > d)
                {
                    var ratio = n / d;
                    var projected = max * ((decimal)ratio);
                    if (projected > end)
                    {
                        list.Add("good");
                    }
                    else
                    {
                        list.Add("bad");
                    }
                }
            }
        }
        return list;
    }
  }

  public List<string> RangeClasses
  {
    get
    {
        List<string> list = new List<string>();
        foreach (var b in BucketInstances)
        {
            if (b.TierStart > b.QualifiedTotal)
            {
                list.Add("future");
            }
            else if (b.QualifiedTotal > 0.0m)
            {
                list.Add("selected");
            }
            else
            {
                list.Add("expired");
            }
        }
        return list;
    }
  }

  public List<string> RangeTitles
  {
    get
    {
        List<string> list = new List<string>();
        foreach (var b in BucketInstances)
        {
            list.Add(b.RangeTitle);
        }
        return list;
    }
  }

  public List<string> MeasureTitles
  {
    get
    {
        List<string> list = new List<string>();
        foreach (var b in BucketInstances)
        {
            list.Add(b.MeasureTitle);
        }
        return list;
    }
  }

  public List<string> MarkerTitles
  {
    get
    {
      return null; // TODO: implement
    }
  }

  public List<string> RangeTicks
  {
    get
    {
      List<string> list = new List<string> ();
      foreach ( var b in BucketInstances )
      {
          list.Add ( b.RangeTick );
      }
      return list;
    }
  }

  private string GetLocalizedString ( string baseKey )
  {
    string value;
    string localizedKey = baseKey + "." + System.Threading.Thread.CurrentThread.CurrentUICulture.Name;
    if ( DecisionTypeAttributes.TryGetValue ( localizedKey, out value ) )
    {
      if ( value != null )
      {
        return value;
      }
    }
    localizedKey = baseKey + "." + System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName;
    if ( DecisionTypeAttributes.TryGetValue ( localizedKey, out value ) )
    {
      if ( value != null )
      {
        return value;
      }
    }
    if ( DecisionTypeAttributes.TryGetValue ( baseKey, out value ) )
    {
      if ( value != null )
      {
        return value;
      }
    }
    return string.Empty;
  }
}
