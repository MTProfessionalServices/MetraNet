using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.PropertyBags;

namespace PropertyGui
{
    public partial class Form1 : Form
    {
        #region Properties
        private Context Context;
        private PropertyBag PropertyBag;
        #endregion

        #region Constructor
        public Form1(Context context, PropertyBag propertyBag)
        {
            InitializeComponent();

            if (context == null)
                throw new ArgumentException("context is null");
            if (propertyBag == null)
                throw new ArgumentException("propertyBag is null");


            Context = context;
            PropertyBag = propertyBag;
            Text = string.Format("Property Bag ({0})", PropertyBag.Name);
            WindowState = FormWindowState.Maximized;
            ctlP11.Init(context, propertyBag);
        }
        #endregion
    }
}
