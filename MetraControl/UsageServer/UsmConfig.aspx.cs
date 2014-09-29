using System;
using MetraTech.Security;
using IMTSessionContext = MetraTech.Interop.MTYAAC.IMTSessionContext;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UsageServer;

public partial class MetraControl_UsageServer_UsmConfig : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      // Verify the user has permission to view this page
      if (!UI.CoarseCheckCapability("Update Runtime Configuration")) Response.End();

      if (!IsPostBack)
      {
        InitForm();
      }
    }

    private void InitForm()
    {
      try
      {
        UsmServiceClient client = new UsmServiceClient();
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        ConfigCrossServer config;
        client.GetConfigCrossServer(out config);

        DailyTextBox.Text = Server.HtmlEncode(config.gracePeriodDailyInDays.ToString());
        WeeklyTextBox.Text = Server.HtmlEncode(config.gracePeriodWeeklyInDays.ToString());
        BiWeeklyTextBox.Text = Server.HtmlEncode(config.gracePeriodBiWeeklyInDays.ToString());
        SemiMonthlyTextBox.Text = Server.HtmlEncode(config.gracePeriodSemiMonthlyInDays.ToString());
        MonthlyTextBox.Text = Server.HtmlEncode(config.gracePeriodMonthlyInDays.ToString());
        QuarterlyTextBox.Text = Server.HtmlEncode(config.gracePeriodQuarterlyInDays.ToString());
        SemiAnnuallyTextBox.Text = Server.HtmlEncode(config.gracePeriodSemiAnnuallyInDays.ToString());
        AnnuallyTextBox.Text = Server.HtmlEncode(config.gracePeriodAnnuallyInDays.ToString());

        DailyCheckBox.Checked = config.isGracePeriodDailyEnabled;
        WeeklyCheckBox.Checked = config.isGracePeriodWeeklyEnabled;
        BiWeeklyCheckBox.Checked = config.isGracePeriodBiWeeklyEnabled;
        SemiMonthlyCheckBox.Checked = config.isGracePeriodSemiMonthlyEnabled;
        MonthlyCheckBox.Checked = config.isGracePeriodMonthlyEnabled;
        QuarterlyCheckBox.Checked = config.isGracePeriodQuarterlyEnabled;
        SemiAnnuallyCheckBox.Checked = config.isGracePeriodSemiAnnuallyEnabled;
        AnnuallyCheckBox.Checked = config.isGracePeriodAnnuallyEnabled;

        AutoSoftClose.Checked = config.isAutoSoftCloseBillGroupsEnabled;
        AutoRunEopCheckBox.Checked = config.isAutoRunEopOnSoftCloseEnabled;
        RunSchedAdaptersCheckBox.Checked = config.isRunScheduledAdaptersEnabled;
        BlockIntervalsCheckBox.Checked = config.isBlockNewAccountsWhenClosingEnabled;
      }
      catch
      {
        SetError(Resources.ErrorMessages.ERROR_USM_CONFIG_UNABLE_TO_RETRIEVE);
        this.Logger.LogError("MetraControl is unable to retrieve the USM configuration changes.");
      }
    }

    private static int ConvertToInt(string convertMe,
                                    string fieldName)
    {
      int result;

      try
      {
        result = Convert.ToInt32(convertMe);
      }
      catch (Exception)
      {
        throw new ArgumentException(fieldName + " " + Resources.ErrorMessages.ERROR_USM_CONFIG_INVALID_GRACE_PERIOD);
      }

      if (result < 0)
      {
        throw new ArgumentException(fieldName + " " + Resources.ErrorMessages.ERROR_USM_CONFIG_INVALID_GRACE_PERIOD);
      }

      return result;
    }

    protected void SaveConfigButton_Click(object sender, EventArgs e)
    {
      try
      {
        UsmServiceClient client = new UsmServiceClient();
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        ConfigCrossServer config = new ConfigCrossServer();

        try
        {
          config.gracePeriodDailyInDays = ConvertToInt(DailyTextBox.Text,
                                                       Resources.ErrorMessages.ERROR_USM_CONFIG_BAD_DAILY);
          config.gracePeriodWeeklyInDays = ConvertToInt(WeeklyTextBox.Text,
                                                       Resources.ErrorMessages.ERROR_USM_CONFIG_BAD_WEEKLY);
          config.gracePeriodBiWeeklyInDays = ConvertToInt(BiWeeklyTextBox.Text,
                                                       Resources.ErrorMessages.ERROR_USM_CONFIG_BAD_BIWEEKLY);
          config.gracePeriodSemiMonthlyInDays = ConvertToInt(SemiMonthlyTextBox.Text,
                                                       Resources.ErrorMessages.ERROR_USM_CONFIG_BAD_SEMIMONTHLY);
          config.gracePeriodMonthlyInDays = ConvertToInt(MonthlyTextBox.Text,
                                                       Resources.ErrorMessages.ERROR_USM_CONFIG_BAD_MONTHLY);
          config.gracePeriodQuarterlyInDays = ConvertToInt(QuarterlyTextBox.Text,
                                                       Resources.ErrorMessages.ERROR_USM_CONFIG_BAD_QUARTERLY);
          config.gracePeriodSemiAnnuallyInDays = ConvertToInt(SemiAnnuallyTextBox.Text,
                                                       Resources.ErrorMessages.ERROR_USM_CONFIG_BAD_SEMIANNUALLY);
          config.gracePeriodAnnuallyInDays = ConvertToInt(AnnuallyTextBox.Text,
                                                       Resources.ErrorMessages.ERROR_USM_CONFIG_BAD_ANNUALLY);
        }
        catch (Exception ex)
        {
          SetError(ex.Message);
          return;
        }

        config.isGracePeriodDailyEnabled = DailyCheckBox.Checked;
        config.isGracePeriodWeeklyEnabled = WeeklyCheckBox.Checked;
        config.isGracePeriodBiWeeklyEnabled = BiWeeklyCheckBox.Checked;
        config.isGracePeriodSemiMonthlyEnabled = SemiMonthlyCheckBox.Checked;
        config.isGracePeriodMonthlyEnabled = MonthlyCheckBox.Checked;
        config.isGracePeriodQuarterlyEnabled = QuarterlyCheckBox.Checked;
        config.isGracePeriodSemiAnnuallyEnabled = SemiAnnuallyCheckBox.Checked;
        config.isGracePeriodAnnuallyEnabled = AnnuallyCheckBox.Checked;

        config.isAutoSoftCloseBillGroupsEnabled = AutoSoftClose.Checked;
        config.isAutoRunEopOnSoftCloseEnabled = AutoRunEopCheckBox.Checked;
        config.isRunScheduledAdaptersEnabled = RunSchedAdaptersCheckBox.Checked;
        config.isBlockNewAccountsWhenClosingEnabled = BlockIntervalsCheckBox.Checked;

        this.Logger.LogDebug("Making call to update configuration.");
        client.SetConfigCrossServer(config);
      }
      catch
      {
        SetError(Resources.ErrorMessages.ERROR_USM_CONFIG_UNABLE_TO_SAVE);
        this.Logger.LogError("MetraControl is unable to save the USM configuration changes.");
      }
    }

    protected void CancelButton_Click(object sender, EventArgs e)
    {
      // reset the form to original settings
      InitForm();
    }

}
