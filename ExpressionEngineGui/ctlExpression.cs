﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Expressions.Enumerations;

namespace PropertyGui
{
    public class ctlExpression : TextBox
    {
        #region Properties
        private Context Context;
        #endregion

        #region Constructor
        public ctlExpression()
        {
        }
        #endregion

        #region Methods

        public void Init(Context context, ContextMenuStrip mnuContext)
        {
            Context = context;

            ContextMenuStrip = mnuContext;
            Multiline = true;
            Font = GuiHelper.ExpressionFont;

            if (Context.Expression != null && Context.Expression.Type == ExpressionType.Email)
                WordWrap = true;
            else
                WordWrap = false;

            ScrollBars = ScrollBars.Both;

            if (Context.Expression != null)
                Text = Context.Expression.Content;
        }

        public void HandleTreeEvent(IExpressionEngineTreeNode item, string value)
        {
            if (item is Function)
                EditFunction((Function)item);
            else
                InsertSnippet(value);
        }

        public void EditFunction()
        {
            var name = SelectedText;
            var func = Context.GetFunction(name);
            if (func == null)
            {
                MessageBox.Show(string.Format("Unable to find Function '{0}'", name));
                return;
            }
            EditFunction(func);
        }

        public void EditFunction(Function func)
        {
            string str = null;
            switch (func.Name)
            {   
                case "In":
                    var frmIn = new frmFuncIn();
                    frmIn.Init(Context, null, null);
                    if (DialogResult.OK == frmIn.ShowDialog())
                        str = frmIn.GetValue();
                    break;
                default:
                    var frmFunc = new frmFunctionBinder();
                    frmFunc.Init(Context, func);
                    if (DialogResult.OK == frmFunc.ShowDialog())
                        str = frmFunc.GetExpression();
                    break;
            }
            if (str != null)
                Paste(str);
        }

        public void InsertSnippet(string snippet)
        {
            switch(Context.Expression.Type)
            {
                case ExpressionType.Email:
                case ExpressionType.Message:
                    snippet = "{" + snippet + "}";
                    break;
            }

            int start = SelectionStart;
            Paste(snippet);
            if (UserContext.Settings.AutoSelectInsertedSnippets)
            {
                SelectionStart = start;
                SelectionLength = snippet.Length;
            }
            Focus();
        }

        #endregion
    }
}
