using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace WizardTest.View
{
  public partial class Stage : WizardTest.WIzardEngine.WizardPage
  {
    public Stage()
    {
      InitializeComponent();
    }

    public Stage(string pageCaption)
      : base(pageCaption)
    {
      InitializeComponent();
    }
  }
}
