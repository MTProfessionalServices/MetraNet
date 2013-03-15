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
            Text = string.Format("PropertyDriven Bag ({0})", PropertyBag.Name);
            WindowState = FormWindowState.Maximized;
            ctlPropertyBag.Init(Context, PropertyBag);
        }
        #endregion

        #region Events
        private void mnuSave_Click(object sender, EventArgs e)
        {
            try
            {
                PropertyBag.Save("");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }
        #endregion

    }
}
