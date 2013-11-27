using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using WizardTest.Interfaces;
using WizardTest.Controller;

namespace WizardTest.View
{
    public partial class Extension : WizardTest.WIzardEngine.WizardPage, IExtension
    {
      private ExtensionController _extensionController;
      private WizardValidation _wizardValidation;

        public Extension()
        {
            InitializeComponent();
        }
        public Extension(string pageCaption)
            : base(pageCaption)
        {
            InitializeComponent();
        }

        private void Extension_Load(object sender, EventArgs e)
        {
          errProvExt.ContainerControl = this;
          _extensionController = new ExtensionController(this);
          _extensionController.Init();

          ExistingNamespaces.ForEach(nm => cbExistNamespace.Items.Add(nm));
          NamespaceNewChecked = true;
          ExtensionNewChecked = true;
        }

        #region ExtensionProperties
        public string Description
        {
            get
            {
                return rtbDescription.Text;
            }
            set
            {
                rtbDescription.Text =  value;
            }
        }

        public string Namespace
        {
            get 
            {
              return rbNewNamespace.Checked ? tbExtNamespace.Text : (string)cbExistNamespace.SelectedValue;
            }
          set
            {
              if (rbExistNamespace.Checked)
              {
                tbExtNamespace.Text = value;
              }
              else
              {
                cbExistNamespace.SelectedValue = value;
              }
            }
        }

        public string AuthorName
        {
            get
            {
                return tbAuthor.Text;
            }
            set
            {
                tbAuthor.Text = value;
            }
        }

        public new string Name
        {
          get
          {
            return rbCreateExtension.Checked ? tbNewExtension.Text : (string)cbExistExtension.SelectedValue;
          }
          set
          {
            if (rbExistNamespace.Checked)
            {
              tbExtNamespace.Text = value;
            }
            else
            {
              cbExistNamespace.SelectedValue = value;
            }
          }
        }

        public List<string> ExistingNamespaces { get; set; }
        public List<string> ExistingExtensions { get; set; }
      #endregion

        #region ExtensionViewProperties
      public bool NamespaceNewChecked
      {
        set
        {
          rbNewNamespace.Checked = value;
          tbExtNamespace.Enabled = value;
          cbExistNamespace.Enabled = !value;
        }
      }

      public bool NamespaceExistingChecked
      {
        set
        {
          rbExistNamespace.Checked = value;
          cbExistNamespace.Enabled = value;
          tbExtNamespace.Enabled = !value;
        }
      }

      public bool ExtensionNewChecked
      {
        set
        {
          rbCreateExtension.Checked = value;
          tbNewExtension.Enabled = value;
          cbExistExtension.Enabled = !value;
        }
      }

      public bool ExtensionExistingChecked
      {
        set
        {
          rbExistExtension.Checked = value;
          cbExistExtension.Enabled = value;
          tbNewExtension.Enabled = !value;
        }
      }
        #endregion

        public void Initialize()
        {
          _extensionController.Load();
        }

        public override void Save()
        {
            _extensionController.Save();
        }


      public override bool Validate()
       {
         _wizardValidation = new WizardValidation(errProvExt);
         _wizardValidation.Required(tbExtNamespace, PriceableItemWizard.ValidationExtentionName);
         _wizardValidation.Required(tbNewExtension, PriceableItemWizard.ValidationNamespaceName);
         _wizardValidation.Required(rtbDescription, PriceableItemWizard.ValidationExtensionDescription);
         _wizardValidation.Required(tbAuthor, PriceableItemWizard.ValidationAuthorName);

         return _wizardValidation.IsValid;
       }


        #region RadioButtonsEvents
        private void rbNewNamespace_Click(object sender, EventArgs e)
        {
          NamespaceNewChecked = true;
        }

        private void rbExistNamespace_Click(object sender, EventArgs e)
        {
          NamespaceExistingChecked = true;
        }

        private void rbCreateExtension_Click(object sender, EventArgs e)
        {
          ExtensionNewChecked = true;
        }

        private void rbExistExtension_Click(object sender, EventArgs e)
        {
          ExtensionExistingChecked = true;
        }
      #endregion

    }
}
