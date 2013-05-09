using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WizardTest.ViewModel;

namespace WizardTest
{
  interface ISummaryConfiguration
  {
    List<SumConfig> SummaryConfigurationBind { get; set; }

  }
}
