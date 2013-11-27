using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace WizardTest.View
{
  public partial class ProductView : WizardTest.WIzardEngine.WizardPage
  {
    public ProductView()
    {
      InitializeComponent();
    }

    public ProductView(string pageCaption)
      : base(pageCaption)
    {
      InitializeComponent();
    }
  }
}
