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
        #region Properties
        private EmailInstance EmailInstance;
        #endregion

        #region Constructor
        public ctlContextEmail()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods

        public void Init(MetraTech.ExpressionEngine.Context context, EmailInstance emailInstance)
        {
            base.Init(context);
            EmailInstance = emailInstance;

            IgnoreChanges = true;
            txtTemplate.Text = emailInstance.EmailTemplate;

            ctlBody.Init(Context, null);

            ctlTo.Text = emailInstance.ToExpression.Content;
            ctlCc.Text = emailInstance.CcExpression.Content;
            ctlSubject.Text = emailInstance.SubjectExpression.Content;
            ctlBody.Text = emailInstance.BodyExpression.Content;

            IgnoreChanges = false;
        }

        public void SyncToObject()
        {
            EmailInstance.ToExpression.Content = ctlTo.Text;
            EmailInstance.CcExpression.Content = ctlCc.Text;
            EmailInstance.SubjectExpression.Content = ctlSubject.Text;
            EmailInstance.BodyExpression.Content = ctlBody.Text;
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

        private void ctlBody_TextChanged(object sender, EventArgs e)
        {
            if (IgnoreChanges)
                return;

            SyncToObject();
        }


    }
}
