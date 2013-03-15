using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

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
            treProperties.AddProperties(null, PropertyBag.Properties);
            treProperties.Sort();
            treProperties.HideSelection = false;
            treProperties.AllowEntityExpand = false;

            ctlProperty1.OnChangeEvent = PropertyChangeEvent;
            ctlProperty1.Init(Context);
        }
        #endregion

        #region Events
        private void treProperties_AfterSelect(object sender, TreeViewEventArgs e)
        {
            var property = (Property)treProperties.SelectedNode.Tag;
            ctlProperty1.SyncToForm(property);
        }
        public void PropertyChangeEvent()
        {
            var property = (Property)treProperties.SelectedNode.Tag;
            treProperties.SelectedNode.Text = property.Name;
        }
        #endregion

 
    }
}
