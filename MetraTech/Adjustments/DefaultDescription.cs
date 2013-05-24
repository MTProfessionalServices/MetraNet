using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Text.RegularExpressions;
using MetraTech.Interop.MTProductCatalog;
using PCExec = MetraTech.Interop.MTProductCatalogExec;
using MetraTech.Localization;

namespace MetraTech.Adjustments
{
  [Guid("70677235-a9dd-4ab8-8455-150f7867850f")]
  public interface IAdjustmentDescription : IMTPCBase
  {
    string DefaultDescription
    {
      get;set;
    }
    string PreparedDescription
    {
      get;
    }

    string UserFriendlyDescription
    {
      get;
    }
    IAdjustmentType AdjustmentType
    {
      get;set;
    }

    string Expand(IAdjustmentTransaction aTrx);
    
  }
	/// <summary>
	/// Summary description for DefaultDescription.
	/// </summary>
	/// 
  [Guid("07a3b450-2d09-45c0-9468-cfe89a5e4188")]
  [ClassInterface(ClassInterfaceType.None)]
	
	public class AdjustmentDescription : PCBase, IAdjustmentDescription
	{
		public AdjustmentDescription()
		{
			mDescParams = new SortedList();
      mDefaultDescription = string.Empty;
      mExpandedDescription = string.Empty;
      mUserFriendlyDescription = string.Empty;
      mPreparedDescription = string.Empty;
		}
    public string DefaultDescription
    {
      get
      {
        return mDefaultDescription;
      }
      set
      {
        lock(typeof(AdjustmentDescription))
        {
          mDefaultDescription = value;
          mExpandedDescription = string.Empty;
          mUserFriendlyDescription = string.Empty;
          mPreparedDescription = string.Empty;
        }
      }
    }

    public string PreparedDescription
    {
      get
      {
        if(mPreparedDescription.Length == 0)
          return Prepare(mDefaultDescription);
        else
          return mPreparedDescription;
      }
    }

    public string UserFriendlyDescription
    {
      get
      {
        if(mUserFriendlyDescription.Length == 0)
          Prepare(mDefaultDescription);
        return mUserFriendlyDescription;
      }
    }

    public string Prepare(string aDefaultDesc)
    {
      lock(typeof(AdjustmentDescription))
      {
        /*
         * Use following regular expression to parse out substitution parameters
         * in default description: ((?<=\W)@)\w+
         * This means: Every string that starts with '@' that is preceeded by a non-alphanumeric character (\W)
         * and followed by one or more alpha numeric characters (\w) is considered to be a parameter
         * Example: String "Adjustment @ for conference with ID @ConferenceID and time <@ScheduledTime>"
         * will yield 2 matches: @ConferenceID and @ScheduledTime
         */
        int offset = 0;
        if(mAdjustmentType == null)
          throw new NullReferenceException("AdjustmentType property not set");
        PCExec.IProductViewProperty pvprop = null;
        mDescParams = new SortedList();
        mDefaultDescription = aDefaultDesc;
        mPreparedDescription = mDefaultDescription;
        mUserFriendlyDescription = mPreparedDescription;
        Regex regex = new Regex((@"((?<=\W)@)\w+"));
        ICollection  matches = regex.Matches(aDefaultDesc);
        foreach(Match descparam in matches)
        {
          string strParam = descparam.Value.Substring(1); /*cut off '@'*/
          if(!mDescParams.ContainsValue(strParam))
          {
            mDescParams.Add(offset, strParam);
            offset++;
          }
          int idx = mDescParams.IndexOfValue(strParam);
          string repl = "{" + String.Format("{0}",idx) + "}";
          mPreparedDescription = mPreparedDescription.Replace(descparam.Value, repl);
          PCExec.IMTPriceableItemTypeReader ajreader = new  PCExec.MTPriceableItemTypeReaderClass();
          PCExec.IMTPriceableItemType pitype = ajreader.Find
            (
            (MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)GetSessionContext(),
            mAdjustmentType.PriceableItemTypeID);
          if(pitype != null)
          {
						PCExec.IProductView pv = pitype.GetProductViewObject();
            pvprop = pv.GetPropertyByName(strParam);
            strParam = LocalizedDescription.GetInstance().GetByID(GetSessionContext().LanguageID, pvprop.DescriptionID);
          }
          mUserFriendlyDescription = mUserFriendlyDescription.Replace(descparam.Value, String.Format("{0}", strParam));
        }
      }

      return mPreparedDescription;
    }

    public string Expand(IAdjustmentTransaction aTrx)
    {
      //TODO: does it make sense to cache any
      //of the previously expanded records?
      Hashtable ajparams = aTrx.UsageRecord;
      if(mPreparedDescription.Length == 0)
        Prepare(DefaultDescription);
      string[] paramvalues = new string [mDescParams.Values.Count];
      foreach(string defaultDescParam in mDescParams.Values)
      {
        //if a Usage records doesn't have this parameter, 
        //don't return an error, just put User friendly non-expanded name
        string val = string.Empty;
        if(ajparams.ContainsKey(defaultDescParam))
          val = System.Convert.ToString(ajparams[defaultDescParam]);
        else if(ajparams.ContainsKey("c_" + defaultDescParam))
          val = System.Convert.ToString(ajparams["c_" + defaultDescParam]);
        else
          val = string.Format("<{0}>", defaultDescParam);
        paramvalues[mDescParams.IndexOfValue(defaultDescParam)] = val;
      }

      return mExpandedDescription = string.Format(mPreparedDescription, paramvalues);
    }

    public IAdjustmentType AdjustmentType
    {
      get
      {
        return mAdjustmentType;
      }
      set
      {
        lock(typeof(AdjustmentDescription))
        {
          mAdjustmentType = value;
        }
      }

    }

    private string mDefaultDescription;
    private string mPreparedDescription;
    private string mUserFriendlyDescription;
    private string mExpandedDescription;
    private SortedList mDescParams;
    IAdjustmentType mAdjustmentType;

	}
}
