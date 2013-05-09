using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace WizardTest.View
{
  public partial class Synchronization : WizardTest.WIzardEngine.WizardPage
  {
    public Synchronization()
    {
      InitializeComponent();
    }

    public Synchronization(string pageCaption)
      : base(pageCaption)
    {
      InitializeComponent();
    }
  }
}
