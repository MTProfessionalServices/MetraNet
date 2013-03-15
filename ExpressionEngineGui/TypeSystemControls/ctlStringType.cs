using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;

namespace PropertyGui.TypeSystemControls
{
    public partial class ctlStringType : ctlBaseType
    {
        #region Properties
        private StringType StringType;
        #endregion

        #region Constructor
        public ctlStringType()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(Property property, Context context)
        {
            base.Init(property, context);
            StringType = (StringType)property.Type;
        }

        public override void SyncToForm()
        {
            numLength.Value = StringType.Length;
        }
        public override void SyncToObject()
        {
            StringType.Length = (int)numLength.Value;
        }
        #endregion
    }
}
