using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WizardTest.View;
using WizardTest.ViewModel;
using WizardTest.Model;

namespace WizardTest
{
  class SummaryConfigurationController
  {
    private readonly ISummaryConfiguration _summaryConfiguration;
    private SumConfig _sdSumConfig = new SumConfig();
    private SumConfig _extSumConfig = new SumConfig();


    public SummaryConfigurationController(ISummaryConfiguration summaryConfiguration)
    {
      _summaryConfiguration = summaryConfiguration;
    }

    public void Load()
    {
      _sdSumConfig.Element = PIModel.Instance.ServiceDefinition.Element;
      _sdSumConfig.ElementName = PIModel.Instance.ServiceDefinition.Name;
      _sdSumConfig.ElementTable = PIModel.Instance.ServiceDefinition.TableName;

      _extSumConfig.Element = PIModel.Instance.ExtensionModel.Element;
      _extSumConfig.ElementName = PIModel.Instance.ExtensionModel.Name;

      _summaryConfiguration.SummaryConfigurationBind =  new List<SumConfig>();

      _summaryConfiguration.SummaryConfigurationBind.Add(_extSumConfig);
      _summaryConfiguration.SummaryConfigurationBind.Add(_sdSumConfig);
    }

  }
}
