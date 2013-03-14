using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;

namespace PropertyGui
{
    public partial class frmPropertyBag : Form
    {
        #region Properties
        private Context Context;
        private PropertyBag PropertyBag;
        #endregion

        #region Constructor
        public frmPropertyBag(Context context, PropertyBag propertyBag)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            if (propertyBag == null)
                throw new ArgumentException("propertyBag is null");

            InitializeComponent();
            Context = context;
            PropertyBag = propertyBag;
            Text = string.Format("Property Bag ({0})", PropertyBag.Name);
            treProperties.Init(context, mnuContext);
            treProperties.AddProperties(null, PropertyBag.Properties);
            treProperties.HideSelection = false;
            WindowState = FormWindowState.Maximized;

            ctlProperty.OnChangeEvent = PropertyChangeEvent;
            ctlProperty.Init(Context);
        }
        #endregion

        #region Events
        private void treProperties_AfterSelect(object sender, TreeViewEventArgs e)
        {
            var property = (Property) treProperties.SelectedNode.Tag;
            ctlProperty.SyncToForm(property);
        }
        public void PropertyChangeEvent()
        {
            var property = (Property)treProperties.SelectedNode.Tag;
            treProperties.SelectedNode.Text = property.Name;
        }
        #endregion
    }
}
