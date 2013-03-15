using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.PropertyBags;

namespace PropertyGui
{
    public partial class ctlP1 : UserControl
    {
        #region Properties
        private Context Context;
        private PropertyBag PropertyBag;
        #endregion

        #region Constructor
        public ctlP1()
        {
            InitializeComponent();
        }
        #endregion

        public void Init(Context context, PropertyBag propertyBag)
        {
            ctlExpressionTree1.Init(context, null);
            ctlExpressionTree1.AddProperties(null, propertyBag.Properties, null);
            ctlExpressionTree1.Sort();
        }
    }
}
