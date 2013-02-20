using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;

namespace PropertyGui
{
    public partial class frmSendEvent : Form
    {
        #region Properties
        private Context Context;
        private ComplexType Event;
        #endregion

        #region Constructor
        public frmSendEvent()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(Context context)
        {
            Context = context;

            cboEvent.BeginUpdate();
            cboEvent.Sorted = true;
            cboEvent.DisplayMember = "Name";
            cboEvent.Items.AddRange(context.GetEntities(ComplexType.ComplexTypeEnum.ServiceDefinition).ToArray());
            cboEvent.EndUpdate();
        }

        private void SetProperties()
        {
            //ctlProperties.Clear();
            Event = (ComplexType)cboEvent.SelectedItem;
            ctlProperties.DefaultBindingType = ctlValueBinder.BindingTypeEnum.Constant;
            ctlProperties.ShowBinderIcon = false;
            ctlProperties.Init(Context, Event.Properties);
        }

        #endregion

        #region Events
        private void cboEvent_SelectedIndexChanged(object sender, EventArgs e)
        {
            SetProperties();
        }
        #endregion
    }
}
