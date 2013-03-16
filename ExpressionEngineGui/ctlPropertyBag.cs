using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.Validations;

namespace PropertyGui
{
    /// <summary>
    /// Wraps a PropertyBag. Intetent is to drop this into the ProductView form in ICE. That's why it's a 
    /// control and not a form
    /// </summary>
    public partial class ctlPropertyBag : UserControl
    {
        #region Properties
        private Context Context;
        private PropertyBag PropertyBag;
        #endregion

        #region Constructor
        public ctlPropertyBag()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(Context context, PropertyBag propertyBag)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            if (propertyBag == null)
                throw new ArgumentException("propertyBag is null");

            //InitializeComponent();
            Context = context;
            PropertyBag = propertyBag;

            treProperties.Init(Context, mnuContext);
            treProperties.AllowEntityExpand = false;
            treProperties.HideSelection = false;

            LoadTree();
            //treProperties.AddProperties(null, PropertyBag.Properties);
            //treProperties.Sort();

            //treProperties.ShowLines = false;
            //treProperties.FullRowSelect = true;

            ctlProperty1.OnChangeEvent = PropertyChangeEvent;
            ctlProperty1.Init(Context);
            EnsureNodeSelected();
        }

        private void EnsureNodeSelected()
        {
            if (treProperties.SelectedNode == null && treProperties.Nodes.Count > 0)
                treProperties.SelectedNode = treProperties.Nodes[0];
            else
            {
                ctlProperty1.Visible = false;
            }
        }

        public void LoadTree()
        {
            treProperties.BeginUpdate();
            treProperties.Nodes.Clear();
            treProperties.AddProperties(null, PropertyBag.Properties);
            treProperties.Sort();
            treProperties.EndUpdate();
        }
        #endregion

        #region Events
        private void treProperties_AfterSelect(object sender, TreeViewEventArgs e)
        {
            var property = (Property)treProperties.SelectedNode.Tag;
            ctlProperty1.SyncToForm(property);
            ctlProperty1.Visible = true;
        }

        public void PropertyChangeEvent()
        {
            var property = (Property)treProperties.SelectedNode.Tag;
            //treProperties.SelectedNode.Text = property.Name;
            SuspendLayout();
            treProperties.UpdateSelectedNode();
            ResumeLayout();
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            var newName = PropertyBag.Properties.GetNewSequentialPropertyName();
            var property = PropertyFactory.Create(newName, TypeFactory.CreateString(), true, null);
            var node = treProperties.CreateNode(property, null);
            PropertyBag.Properties.Add(property);
            treProperties.SelectedNode = node;
            LoadTree();
        }

        private void btnValidate_Click(object sender, EventArgs e)
        {
            var messages = new ValidationMessageCollection();
            PropertyBag.Validate(false, messages, Context);
            if (messages.Count == 0)
                MessageBox.Show("No validation issues found.", "", MessageBoxButtons.OK, MessageBoxIcon.Information);
            else
                frmValidationMessages.Show(messages);
        }


        private void btnRefresh_Click(object sender, EventArgs e)
        {
            treProperties.PreserveState();
            LoadTree();
            treProperties.RestoreState();
        }

        #endregion
    }
}
