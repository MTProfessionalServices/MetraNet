using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace WizardTest.View
{
  public partial class ParameterTable : WizardTest.WIzardEngine.WizardPage
  {
    public ParameterTable()
    {
      InitializeComponent();
    }

    public ParameterTable(string pageCaption)
      : base(pageCaption)
    {
      InitializeComponent();
    }
  }
}
