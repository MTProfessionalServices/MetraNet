using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.SecurityFramework;

namespace MetraTech.UI.Controls
{
  [ToolboxData("<{0}:MTBillingCycleControl runat=server></{0}:MTBillingCycleControl>")]
  public class MTBillingCycleControl : WebControl, IPostBackDataHandler
  {
    #region JS
    public string SCRIPT_INCLUDES = @"
        <script language=""javascript"">
          var intervalSections = ['daily','weekly','bi_weekly','monthly','semi_monthly','quarterly'/*,'annually'*/];
          
          function selectSection(showSectionName, bFromPageLoad)
          {
            for(var i = 0; i < intervalSections.length; i++)
            {
              var sectionName = intervalSections[i];

              var sectionSpan = '';
              if(sectionName.toLowerCase() == 'semi_monthly' || sectionName.toLowerCase() == 'quarterly')
              {
                sectionSpan = document.getElementById(""{CLIENT_ID}_"" + sectionName);
              }
              else
              {
                sectionSpan = document.getElementById(""{CLIENT_ID}_"" + sectionName + ""_wrapper"");
              }

              if(sectionSpan == null)
              {
                continue;
              }
              
              //show section.  NOTE: if annually or semiannually is selected, show quarterly, since they are sharing dropdown controls
              if((sectionName.toLowerCase() == showSectionName.toLowerCase())
                    || ( showSectionName.toLowerCase() == ""annually""  &&  sectionName.toLowerCase() == ""quarterly"")
                    || ( showSectionName.toLowerCase() == ""semi_annually""  &&  sectionName.toLowerCase() == ""quarterly"") )
              {
                sectionSpan.style.display = 'block';
                if((showSectionName.toLowerCase() == 'quarterly') || (showSectionName.toLowerCase() == 'annually') || (showSectionName.toLowerCase() == 'semi_annually'))
                {
                  displayMonths(showSectionName.toLowerCase(), bFromPageLoad);                
                } 
              }
              //hide section
              else
              {
                sectionSpan.style.display = 'none';
              }
            }
            
            // pre-processing if biweekly
            if (showSectionName.toLowerCase() == 'bi_weekly')
            {
              if(!{ReadOnly})
               onBiWeeklyChange();
            }

            // pre-processing if weekly
            if (showSectionName.toLowerCase() == 'weekly')
            {
              if(!{ReadOnly})
               {
                   var controlId = ""{CLIENT_ID}_weekly"";
                   var weekly = Ext.getCmp(controlId);
				   if(weekly.getValue() == '')
				   {
						weekly.setValue(weekly.store.getAt(1).data.value);
				   }
               }
            }
          }

          function onCyclesChange()
          {
            var controlId = ""{CLIENT_ID}_billingcycles"";
            //controlId = controlId.replace(/_/gi, '$');
            var cycles = document.getElementById(controlId);
            var selectedCycle = cycles.value;
            selectSection(selectedCycle, 0);
          }

          function displayMonths(QuarterlyOrAnnual, bFromPageLoad)
          {          
            var quarterlyIntervals = {quarterly_month_data};
            var controlIdBase = ""ctl00_ContentPlaceHolder1_"";
            var monthly = Ext.getCmp(controlIdBase + 'quarterly_startmonth');
            
            if((monthly + '') == 'undefined')
            {
              //this is read-only mode

              var monthlyIndexDom = Ext.get(controlIdBase + 'quarterly_startmonth' + '_readonly_index');
              if (monthlyIndexDom == null)
              {return;}
              if (QuarterlyOrAnnual == 'quarterly')
              {
                var monthlyValue = Ext.get(controlIdBase + 'quarterly_startmonth' + '_readonly_value');
                var monthlyIndex = monthlyIndexDom.dom.innerHTML;
                monthlyIndex = monthlyIndex - 1;
                var targetValue = eval('quarterlyIntervals[' + monthlyIndex + '][1]');
                monthlyValue.dom.innerHTML = targetValue;
              }
              return;
            }

            var oldValue = monthly.getValue();
            monthly.store.removeAll();
            
            var qmData;
            
            if (QuarterlyOrAnnual == 'quarterly')
            {
              qmData =  quarterlyIntervals;
            }
            else
            {
              qmData = {annual_month_data};
            }
             
            monthly.store.loadData(qmData);
 
            if(!bFromPageLoad)
            {
              oldValue = qmData[0][0];
            }
            monthly.setValue(oldValue);                  
          }

          function onBiWeeklyChange()
          {
            var biWeekly = document.getElementById('{CLIENT_ID}_bi_weekly');
            var day =  document.getElementById('{CLIENT_ID}_quarterly_startday');
            var month = document.getElementById('{CLIENT_ID}_quarterly_startmonth');    
            var year = document.getElementById('{CLIENT_ID}_startyear');          
           
            if(year == null)
            {
              year = document.getElementById('{CLIENT_ID}_startyear')
            }

            //populate date, month, and year
            day.value = biWeekly.value;
            month.value = 'January' ;  //always select january 2000
            year.value = '2000';

          }
        </script>
      ";
    #endregion

    #region Private variables
    private string initialCycleName;
    #endregion

    #region Properties
    private int labelWidth = 120;
    public int LabelWidth
    {
      get { return labelWidth; }
      set { labelWidth = value; }
    }

    private bool readOnly;
    public bool ReadOnly
    {
      get { return readOnly; }
      set { readOnly = value; }
    }

    private bool allowBlank = false;
    public bool AllowBlank
    {
        get { return allowBlank; }
        set { allowBlank = value; }
    }

    private bool enforceCycle;
    public bool EnforceCycle
    {
      get { return enforceCycle; }
      set { enforceCycle = value; }
    }

    private MTDropDown cycleList;
    public MTDropDown CycleList
    {
      get
      {
        if (cycleList == null)
        {
          cycleList = new MTDropDown();
          cycleList.AllowBlank = true;
        }
        if(enforceCycle)
        {
          cycleList.ReadOnly = true;
        }
        else
        {
          cycleList.ReadOnly = ReadOnly;
        }
        return cycleList;
      }
    }

    private MTDropDown weekly;
    public MTDropDown Weekly
    {
      get
      {
        if (weekly == null)
        {
          weekly = new MTDropDown();
          weekly.AllowBlank = true;
          if (allowBlank)
          {
              ListItem itmBlank = new ListItem("", "");
              weekly.Items.Add(itmBlank);
          }
        }
        weekly.ReadOnly = ReadOnly;
        return weekly;
      }
    }

    private MTDropDown biWeekly;
    public MTDropDown BiWeekly
    {
      get
      {
        if (biWeekly == null)
        {
          biWeekly = new MTDropDown();
          biWeekly.AllowBlank = true;
          if (allowBlank)
          {
              ListItem itmBlank = new ListItem("", "");
              biWeekly.Items.Add(itmBlank);
          }
          biWeekly.ControlWidth = "200";
          biWeekly.ListWidth = "200";
        }
        biWeekly.ReadOnly = ReadOnly;
        return biWeekly;
      }
    }


    private MTDropDown monthly;
    public MTDropDown Monthly
    {
      get
      {
        if (monthly == null)
        {
          monthly = new MTDropDown();
          monthly.AllowBlank = true;
          if (allowBlank)
          {
              ListItem itmBlank = new ListItem("", "");
              monthly.Items.Add(itmBlank);
          }
        }
        monthly.ReadOnly = ReadOnly;
        return monthly;
      }
      set
      {
        monthly = value;
      }
    }

    private MTDropDown semiMonthly_First;
    public MTDropDown SemiMonthly_First
    {
      get
      {
        if (semiMonthly_First == null)
        {
          semiMonthly_First = new MTDropDown();
          semiMonthly_First.AllowBlank = true;
          if (allowBlank)
          {
              ListItem itmBlank = new ListItem("", "");
              semiMonthly_First.Items.Add(itmBlank);
          }
        }
        semiMonthly_First.ListWidth = "200";
        semiMonthly_First.ControlWidth = "200";
        semiMonthly_First.ReadOnly = ReadOnly;
        return semiMonthly_First;
      }
    }

    private MTDropDown semiMonthly_Second;
    public MTDropDown SemiMonthly_Second
    {
      get
      {
        if (semiMonthly_Second == null)
        {
          semiMonthly_Second = new MTDropDown();
          semiMonthly_Second.AllowBlank = true;
          if (allowBlank)
          {
              ListItem itmBlank = new ListItem("", "");
              semiMonthly_Second.Items.Add(itmBlank);
          }
        }
        semiMonthly_Second.ListWidth = "200";
        semiMonthly_Second.ControlWidth = "200";
        semiMonthly_Second.ReadOnly = ReadOnly;
        return semiMonthly_Second;
      }
    }


    private MTDropDown quarterly_Month;
    public MTDropDown Quarterly_Month
    {
      get
      {
        if (quarterly_Month == null)
        {
          quarterly_Month = new MTDropDown();
          quarterly_Month.AllowBlank = true;
          if (allowBlank)
          {
              ListItem itmBlank = new ListItem("", "");
              quarterly_Month.Items.Add(itmBlank);
          }
        }
        quarterly_Month.ListWidth = "200";
        quarterly_Month.ControlWidth = "200";
        quarterly_Month.ReadOnly = ReadOnly;
        return quarterly_Month;
      }
    }

    private MTDropDown quarterly_Day;
    public MTDropDown Quarterly_Day
    {
      get
      {
        if (quarterly_Day == null)
        {
            quarterly_Day = new MTDropDown();
            Quarterly_Day.AllowBlank = true;
            {
                ListItem itmBlank = new ListItem("", "");
                Quarterly_Day.Items.Add(itmBlank);
            }
        }
        quarterly_Day.ListWidth = "200";
        quarterly_Day.ControlWidth = "200";
        quarterly_Day.ReadOnly = ReadOnly;
        return quarterly_Day;
      }
    }

    private TextBox startYear;
    public TextBox StartYear
    {
      get
      {
        if (startYear == null)
        {
          startYear = new TextBox();
          startYear.Attributes.Add("style", "display:none");
          startYear.ID = "startyear";
        }
        startYear.ReadOnly = ReadOnly;
        return startYear;
      }
    }

    #endregion

    #region Public Methods
    public void SetCycle(string cycleName)
    {
      EnsureChildControls();
      this.CycleList.SelectedValue = cycleName;
      this.initialCycleName = cycleName;
    }

    public static string GetBiWeeklyIntervalBasedOnY2K(DateTime inDate)
    {
      int inDay = inDate.Day;
      DateTime today = MetraTime.Now;
      DateTime y2k = new DateTime(2000, 1, 1);
      string text = string.Empty;

      TimeSpan tsDiffBnNowAndY2K = today.Subtract(y2k);
      int diffDaysBnNowAndY2K = tsDiffBnNowAndY2K.Days;

      int todayOffset = (diffDaysBnNowAndY2K + 1) % 14;
      int startDayBeforeToday;

      //cover interval before todays date
      for (int i = 1; i <= todayOffset; i++)
      {
        if (inDay == i)
        {
          startDayBeforeToday = i - todayOffset;
          DateTime startDate = today.AddDays(startDayBeforeToday);
          text = startDate.ToShortDateString() + " - " + startDate.AddDays(13).ToShortDateString();

          return text;
        }
      }

      //cover interval from 2 wks before today up until where the first loop started
      startDayBeforeToday = -13;

      for (int i = todayOffset + 1; i <= 14; i++)
      {
        if (inDay == i)
        {
          DateTime startDate = today.AddDays(startDayBeforeToday);
          text = startDate.ToShortDateString() + " - " + startDate.AddDays(13).ToShortDateString();

          return text;
        }
        startDayBeforeToday++;
      }

      return string.Empty;
    }

    #endregion

    #region Methods
    protected void PopulateDaysOfMonth(MTDropDown list)
    {
      for (int i = 1; i <= 31; i++)
      {
        list.Items.Add(i.ToString());
      }

      list.SelectedIndex = list.Items.Count - 1; //CORE-3384: Set the default selection to be the end of the month instead of the first day
    }

    protected string GetEnumAsJSon(Type enumDataType)
    {
      StringBuilder sb = new StringBuilder();
      sb.Append("[");

      List<MetraTech.DomainModel.BaseTypes.EnumData> enumDataList =
        enumDataList = BaseObject.GetEnumData(enumDataType);
      
      int i = 0;
      foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enumDataList)
      {
        if (i != 0)
        {
          sb.Append(",");
        }
        sb.Append("['");
        sb.Append(enumData.EnumInstance.ToString());
        sb.Append("','");
        sb.Append(enumData.DisplayName);
        sb.Append("']");

        i++;
      }

      sb.Append("]");

      return sb.ToString();
    }

    protected void PopulateBiWeeklyIntervals(MTDropDown list)
    {
      DateTime today = MetraTime.Now;
      DateTime y2k = new DateTime(2000, 1, 1);
      string text = string.Empty;

      TimeSpan tsDiffBnNowAndY2K = today.Subtract(y2k);
      int diffDaysBnNowAndY2K = tsDiffBnNowAndY2K.Days;

      int todayOffset = (diffDaysBnNowAndY2K + 1) % 14;
      int startDayBeforeToday;

      //cover interval before todays date
      for (int i = 1; i <= todayOffset; i++)
      {
        startDayBeforeToday = i - todayOffset;
        DateTime startDate = today.AddDays(startDayBeforeToday);
        text = i.ToString() + ": " + startDate.ToShortDateString() + "-" + startDate.AddDays(13).ToShortDateString();

        list.Items.Add(new ListItem(text, i.ToString()));
      }

      //cover interval from 2 wks before today up until where the first loop started
      startDayBeforeToday = -13;

      for (int i = todayOffset + 1; i <= 14; i++)
      {
        DateTime startDate = today.AddDays(startDayBeforeToday);
        text = i.ToString() + ": " + startDate.ToShortDateString() + "-" + startDate.AddDays(13).ToShortDateString();
        list.Items.Add(new ListItem(text, i.ToString()));

        startDayBeforeToday++;
      }


      //list.Attributes.Add("onchange", "javascript:onBiWeeklyChange()");
      list.Listeners = "{ select: onBiWeeklyChange }";
      

    }

    protected override void OnPreRender(EventArgs e)
    {
      base.OnPreRender(e);

      this.TabIndex = 0;

      //registers javascript on the page
      if (!Page.ClientScript.IsClientScriptBlockRegistered(Page.GetType(), "JS"))
      {
        SCRIPT_INCLUDES = SCRIPT_INCLUDES.Replace("{METRATIME_TODAY}", MetraTime.Now.ToShortDateString());
        SCRIPT_INCLUDES = SCRIPT_INCLUDES.Replace("{quarterly_month_data}", GetQuarterlyEnumJSon());
        SCRIPT_INCLUDES = SCRIPT_INCLUDES.Replace("{annual_month_data}", GetEnumAsJSon(typeof(MonthOfTheYear)));
        string baseID; 
        if(Parent is Panel)
        {
          baseID = Parent.ClientID.Substring(0, Parent.ClientID.LastIndexOfAny(new char[] { '_' }));
        }
        else
        {
          baseID = Parent.ClientID; 
        }
        SCRIPT_INCLUDES = SCRIPT_INCLUDES.Replace("{CLIENT_ID}", baseID);
        SCRIPT_INCLUDES = SCRIPT_INCLUDES.Replace("{ReadOnly}", ReadOnly.ToString().ToLower());

        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JS", SCRIPT_INCLUDES);
      }

      //register javascript that initializes secondary elements based on the selected cycle
      // SECENG: CORE-4794 CLONE - BSS 29002 Security - CAT .NET - Cross Site Scripting in MetraTech Binaries (SecEx)
	  string selectCycle = (String.IsNullOrEmpty(initialCycleName)) ? MetraTech.UI.Tools.Utils.EncodeForJavaScript(CycleList.SelectedValue) : initialCycleName;
      if (initialCycleName != String.Empty)
      {
        if (!Page.ClientScript.IsStartupScriptRegistered(Page.GetType(), "InitCycle"))
        {
          Page.ClientScript.RegisterStartupScript(Page.GetType(), "InitCycle", "<script>Ext.onReady(function() {selectSection('" + selectCycle + "',1)});</script>");

          if (selectCycle.ToLower() == "bi_weekly")
          {
            //set dropdown to the day value
            BiWeekly.SelectedValue = this.Quarterly_Day.SelectedValue;
          }
        }
        initialCycleName = String.Empty;
      }
    }


    /// <summary>
    /// This enum will contain the display text from MonthOfYearByQuarter enum, but the values will come from MonthOfTheYear enum
    /// </summary>
    /// <returns></returns>
    private string GetQuarterlyEnumJSon()
    {
      StringBuilder sb = new StringBuilder();
      sb.Append("[");

      List<MetraTech.DomainModel.BaseTypes.EnumData> enumListQuarters =
       BaseObject.GetEnumData(typeof(MonthOfTheYearByQuarter));

      List<MetraTech.DomainModel.BaseTypes.EnumData> enumListMonths =
       BaseObject.GetEnumData(typeof(MonthOfTheYear));

      for (int i = 0; i < enumListQuarters.Count; i++)
      {
        if (i != 0)
        {
          sb.Append(",");
        }

        sb.Append("['");
        sb.Append(enumListMonths[i].EnumInstance.ToString()); //dropdown value
        sb.Append("','");
        sb.Append(enumListQuarters[i].DisplayName); //display text
        sb.Append("']");
      }

      sb.Append("]");

      return sb.ToString();
    }

    protected void AddControl(MTDropDown ctrl, Control parent, String Label, String classID)
    {
      ctrl.Label = Label;
      ctrl.ID = classID;
      ctrl.AllowBlank = true;
      
      parent.Controls.Add(ctrl);
    }

    protected override void OnInit(EventArgs e)
    {
      base.OnInit(e);

      //enable the control to receive postbacks
      Page.RegisterRequiresPostBack(this);

      EnsureChildControls();
    }

    //rehydrates the MTDropdownField control from an array
    protected void RetrieveMTDropDownItems(MTDropDown mtdf, object[] data)
    {
      for (int i = 0; i < data.Length; i++)
      {
        ListItem li = new ListItem();

        string[] item = (string[])data[i];
        li.Text = (string)item[0];
        li.Value = (string)item[1];

        mtdf.Items.Add(li);
      }
    }

    //Serializes the contents of MTDropdownField into an array
    protected Array PersistMTDropdownItems(MTDropDown mtdf)
    {
      object[] data = new object[mtdf.Items.Count];

      for (int i = 0; i < mtdf.Items.Count; i++)
      {
        string[] item = new string[2];
        item[0] = mtdf.Items[i].Text;
        item[1] = mtdf.Items[i].Value;

        data[i] = item;
      }

      return data;
    }

    //manually load view state including all dropdowns
    protected override void LoadViewState(object savedState)
    {
      if (savedState != null)
      {
        object[] myState = (object[])savedState;

        if (myState[0] != null)
        {
          base.LoadViewState(myState[0]);
        }

        //cycle list
        if (myState[1] != null)
        {
          RetrieveMTDropDownItems(CycleList, (object[])myState[1]);
        }
        if (myState[2] != null)
        {
          RetrieveMTDropDownItems(Weekly, (object[])myState[2]);
        }

        if (myState[3] != null)
        {
          RetrieveMTDropDownItems(Quarterly_Month, (object[])myState[3]);
        }

      }
    }

    //manually save list items of all dropdowns
    protected override object SaveViewState()
    {
      object baseState = base.SaveViewState();
      object[] allStates = new object[4];
      
      allStates[0] = baseState;
      allStates[1] = PersistMTDropdownItems(CycleList);
      allStates[2] = PersistMTDropdownItems(Weekly);
      allStates[3] = PersistMTDropdownItems(Quarterly_Month);
      
      return allStates;
    }

    protected override void OnLoad(EventArgs e)
    {

      EnsureChildControls();
      base.OnLoad(e);

      if (Page.IsPostBack)
      {
        try
        {
          if (ViewState["Cycle"] != null)
          {
            CycleList.SelectedValue = (string)ViewState["Cycle"];
          }

          if (ViewState["Weekly"] != null)
          {
            Weekly.SelectedValue = (string)ViewState["Weekly"];
          }

          if (ViewState["BiWeekly"] != null)
          {
            BiWeekly.SelectedValue = (string)ViewState["BiWeekly"];
          }

          if (ViewState["Monthly"] != null)
          {
            Monthly.SelectedValue = (string)ViewState["Monthly"];
          }

          if (ViewState["SemiMonthlyFirst"] != null)
          {
            SemiMonthly_First.SelectedValue = (string)ViewState["SemiMonthlyFirst"];
          }

          if (ViewState["SemiMonthlySecond"] != null)
          {
            SemiMonthly_Second.SelectedValue = (string)ViewState["SemiMonthlySecond"];
          }

          if (ViewState["QuarterlyMonth"] != null)
          {
            Quarterly_Month.SelectedValue = (string)ViewState["QuarterlyMonth"];
          }

          if (ViewState["QuarterlyDay"] != null)
          {
            Quarterly_Day.SelectedValue = (string)ViewState["QuarterlyDay"];
          }
        }
        catch { }
      }
    }

    protected override void CreateChildControls()
    {
      EnsureChildControls();

      //CycleList.Attributes.Add("onchange", "javascript:onCyclesChange();");
      CycleList.Listeners = "{ select: onCyclesChange }";
      CycleList.TabIndex = this.TabIndex;

      var resManager = new ResourcesManager();
      string billingCycleLabel = resManager.GetLocalizedResource("BILLING_CYCLES");
     
      AddControl(CycleList, this, billingCycleLabel, "billingcycles");

      string endDayOfWeekLabel = resManager.GetLocalizedResource("END_DAY_OF_WEEK");
      AddControl(Weekly, this, endDayOfWeekLabel, UsageCycleType.Weekly.ToString().ToLower());
      Weekly.TabIndex = (short)(this.TabIndex + 1);

      string biWeeklyLabel = resManager.GetLocalizedResource("SELECT_INTERVAL");
      AddControl(BiWeekly, this, biWeeklyLabel, UsageCycleType.Bi_weekly.ToString().ToLower());
      BiWeekly.TabIndex = (short)(this.TabIndex + 1);
      Controls.Add(StartYear);

      string endDayOfMonthLabel = resManager.GetLocalizedResource("END_DAY_OF_MONTH");
      AddControl(Monthly, this, endDayOfMonthLabel, UsageCycleType.Monthly.ToString().ToLower());
      Monthly.TabIndex = (short)(this.TabIndex + 1);

      //populate days of month
      PopulateDaysOfMonth(Monthly);

      //pupulate biweekly intervals
      PopulateBiWeeklyIntervals(BiWeekly);

      //semi-monthly
      HtmlGenericControl span = new HtmlGenericControl("div");
      Controls.Add(span);
      span.ID = UsageCycleType.Semi_monthly.ToString().ToLower();
      span.Style.Add("display", "none");

      span.Controls.Add(SemiMonthly_First);
      string firstEndDayOfMonthLabel = resManager.GetLocalizedResource("FIRST_END_DAY_OF_MONTH");
      //SemiMonthly_First.Label = MTResources.FIRST_END_DAY_OF_MONTH;
      SemiMonthly_First.Label = firstEndDayOfMonthLabel;
      SemiMonthly_First.ID = span.ID + "_first";
      SemiMonthly_First.TabIndex = (short)(this.TabIndex + 1);
      SemiMonthly_First.AllowBlank = true;
      SemiMonthly_First.ControlWidth = "200";

      PopulateDaysOfMonth(SemiMonthly_First);    

     // span.Controls.Add(new HtmlGenericControl("br"));

      span.Controls.Add(SemiMonthly_Second);
      string secondEndDayOfMonthLabel = resManager.GetLocalizedResource("SECOND_END_DAY_OF_MONTH");
      //SemiMonthly_Second.Label = MTResources.SECOND_END_DAY_OF_MONTH;
      SemiMonthly_Second.Label = secondEndDayOfMonthLabel;
      SemiMonthly_Second.ID = span.ID + "_second";
      SemiMonthly_Second.TabIndex = (short)(this.TabIndex + 2);
      SemiMonthly_Second.AllowBlank = true;
      SemiMonthly_Second.ControlWidth = "200";

      PopulateDaysOfMonth(SemiMonthly_Second);

      //quarterly
      span = new HtmlGenericControl("div");
      Controls.Add(span);
      span.ID = UsageCycleType.Quarterly.ToString().ToLower();

      span.Style.Add("display", "none");

      span.Controls.Add(Quarterly_Month);
      string startMonthLabel = resManager.GetLocalizedResource("START_MONTH");
      //Quarterly_Month.Label = MTResources.START_MONTH;
      Quarterly_Month.Label = startMonthLabel;
      Quarterly_Month.ID = span.ID + "_startmonth";
      Quarterly_Month.TabIndex = (short)(this.TabIndex + 1);
      Quarterly_Month.AllowBlank = true;

     // span.Controls.Add(new HtmlGenericControl("br"));

      span.Controls.Add(Quarterly_Day);
      string startDayLabel = resManager.GetLocalizedResource("START_DAY");
     // Quarterly_Day.Label = MTResources.START_DAY;
      Quarterly_Day.Label = startDayLabel;
      Quarterly_Day.ID = span.ID + "_startday";
      Quarterly_Day.TabIndex = (short)(this.TabIndex + 2);
      Quarterly_Day.AllowBlank = true;

      PopulateDaysOfMonth(Quarterly_Day);
    }
    #endregion

    #region IPostBackDataHandler Members

    public bool LoadPostData(string postDataKey, System.Collections.Specialized.NameValueCollection postCollection)
    {
      EnsureChildControls();

      string prefix = string.Empty;
      if ((Parent != null) && (!String.IsNullOrEmpty(Parent.UniqueID)))
      {
        prefix = Parent.UniqueID + "$";
      }


      ViewState["Cycle"] = postCollection[prefix + CycleList.UniqueID];
      ViewState["Weekly"] = postCollection[prefix + Weekly.UniqueID];
      ViewState["BiWeekly"] = postCollection[prefix + BiWeekly.UniqueID];
      ViewState["Monthly"] = postCollection[prefix + Monthly.UniqueID];
      ViewState["SemiMonthlyFirst"] = postCollection[prefix + SemiMonthly_First.UniqueID];
      ViewState["SemiMonthlySecond"] = postCollection[prefix + SemiMonthly_Second.UniqueID];
      ViewState["QuarterlyMonth"] = postCollection[prefix + Quarterly_Month.UniqueID];
      ViewState["QuarterlyDay"] = postCollection[prefix + Quarterly_Day.UniqueID];

      bool res = false;
      return res;
    }

    public void RaisePostDataChangedEvent()
    {
      //throw new Exception("The method or operation is not implemented.");
    }

    #endregion
  }
}
