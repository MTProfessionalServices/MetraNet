using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using WizardTest.Interfaces;

namespace WizardTest.View
{
    public partial class ServiceDefinition : WizardTest.WIzardEngine.WizardPage, IServiceDefinition
    {
      private ServiceDefinitionController _serviceDefinitionController;
      private WizardValidation _wizardValidation;

      public ServiceDefinition()
      {
        InitializeComponent();
      }

      public ServiceDefinition(string pageCaption)
        : base(pageCaption)
      {
        InitializeComponent();
      }

      private void ServiceDefinition_Load(object sender, EventArgs e)
      {
        _serviceDefinitionController = new ServiceDefinitionController(this);
      }

      #region IServiceDefinition Members

        public string Description
        {
          get { return rtbDescription.Text; }
          set { rtbDescription.Text = value; }
        }

      public string Configuration
      {
        get { return tbSdConfig.Text; }
        set { tbSdConfig.Text = value; }
      }

      public new string Name
      {
        get { return tbName.Text; }
        set { tbName.Text = value; }
      }

      public string TableName { get; set; }

      #endregion

      public override void Save()
      {
        _serviceDefinitionController.Save();
      }

      public override bool Validate()
      {
        _wizardValidation =  new WizardValidation(epServiceDefinition);
        _wizardValidation.Required(tbName,PriceableItemWizard.ValidationServDefName);
        _wizardValidation.Required(rtbDescription, PriceableItemWizard.ValidationServDefDescription);
        return _wizardValidation.IsValid;
      }


    }
}
