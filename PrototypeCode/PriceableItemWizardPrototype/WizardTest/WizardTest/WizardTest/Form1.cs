using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WizardTest.WIzardEngine;
using WizardTest.View;

namespace WizardTest
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
          WizardManager wizard = new WizardManager();
          wizard.Init("PI WIZARD", new List<WizardPage>()
                                     {
                                       {new GeneralInformation("General Information")},
                                       {new Extension("PriceableItem")},
                                       {new ServiceDefinition("ServiceDefinition")},
                                       {new ParameterTable("ParameterTable")},
                                       {new ProductView("ProductView")},
                                       {new Stage("Stage")},
                                       {new Synchronization("Synchronization")},
                                       {new SummaryConfiguration("SummaryConfiguration")}
                                     }
            );
            wizard.Start();
        }
    }
}
