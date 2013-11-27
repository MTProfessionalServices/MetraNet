using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WizardTest.WIzardEngine
{
    public partial class WizardBasePage<TModel> : UserControl where TModel : new()
    {
        private TModel _model;

        public WizardBasePage()
        {
            InitializeComponent();
        }


    }
}
