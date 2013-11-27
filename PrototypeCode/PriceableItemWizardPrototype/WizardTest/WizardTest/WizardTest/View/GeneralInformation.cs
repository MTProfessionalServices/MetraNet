using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace WizardTest.View
{
  public partial class GeneralInformation : WizardTest.WIzardEngine.WizardPage
  {
    public GeneralInformation()
    {
      InitializeComponent();
    }

    public GeneralInformation(string pageCaption)
      : base(pageCaption)
    {
      InitializeComponent();
    }
  }
}
