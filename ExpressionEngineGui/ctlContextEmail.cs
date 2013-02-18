using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;

namespace PropertyGui
{
    public partial class ctlContextEmail : ctlContextBase
    {
        #region Constructor
        public ctlContextEmail()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods

        public void Init(MetraTech.ExpressionEngine.Context context, EmailTemplate emailTemplate)
        {
            base.Init(context);

            ctlBody.Init(Context, null);

            ctlTo.Text = emailTemplate.ToExpression.Content;
            ctlCc.Text = emailTemplate.CcExpresson.Content;
            ctlSubject.Text = emailTemplate.SubjectExpression.Content;
            ctlBody.Text = emailTemplate.BodyExpression.Content;
        }

        public override void InsertSnippet(string snippet)
        {
            ctlBody.InsertSnippet(snippet);
        }

        public override void HandleTreeEvent(MetraTech.ExpressionEngine.IExpressionEngineTreeNode item, string value)
        {
            //ToDo... figure out which one last had focus and guide to it
            ctlBody.HandleTreeEvent(item, value);
        }

        #endregion

    }
}
