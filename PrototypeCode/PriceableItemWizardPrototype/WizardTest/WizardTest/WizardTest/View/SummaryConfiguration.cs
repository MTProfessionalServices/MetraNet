using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using WizardTest.ViewModel;

namespace WizardTest.View
{
  public partial class SummaryConfiguration : WizardTest.WIzardEngine.WizardPage, ISummaryConfiguration
  {
    private SummaryConfigurationController _summaryConfigurationController;
    public SummaryConfiguration()
    {
      InitializeComponent();
    }

    public SummaryConfiguration(string pageCaption)
      : base(pageCaption)
    {
      InitializeComponent();
    }

    #region ISummaryConfiguration Members

    public List<SumConfig> SummaryConfigurationBind { get; set; }

    #endregion

    private void SummaryConfiguration_Load(object sender, EventArgs e)
    {
      _summaryConfigurationController =  new SummaryConfigurationController(this);
      _summaryConfigurationController.Load();
      dgvSummaryConfig.DataSource = SummaryConfigurationBind;
    }
  }
}
