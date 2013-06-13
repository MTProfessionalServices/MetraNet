using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.Placeholders;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using System.Linq;

namespace PropertyGui
{
    public partial class frmCompare : Form
    {
        #region Properties
        private bool IgnoreChanges = false;
        private Context Context1;
        private Context Context2;
        #endregion

      #region Constructor
      public frmCompare(Context context1, string context1Name, Context context2, string context2Name)
      {
          InitializeComponent();
          MinimizeBox = false;
          WindowState = FormWindowState.Maximized;

          if (context1 == null)
              throw new ArgumentException("context1 is null");

          Context1 = context1;
          Context2 = context2;
          txtContext1.Text = context1Name;
          txtContext2.Text = context2Name;

          treContext1.Init(Context1, null);
          treContext1.DefaultNodeContextMenu = mnuContext;
          treContext2.Init(Context2, null);
          treContext2.DefaultNodeContextMenu = mnuContext;

          Init();

          UpdateTrees();
          UpdateGui();
      }
      #endregion

      #region Init Methods

      private void Init()
      {
          IgnoreChanges = true;

          //Set the view modes
          cboViewMode.BeginUpdate();
          cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Entities);
          cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Enumerations);
          cboViewMode.Items.Add(MvcAbstraction.ViewModeType.AQGs);
          cboViewMode.Items.Add(MvcAbstraction.ViewModeType.UQGs);
          cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Emails);
          cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Functions);
          cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Expressions);
          cboViewMode.Items.Add(MvcAbstraction.ViewModeType.PageLayouts);
          cboViewMode.Sorted = true;
          cboViewMode.SelectedItem = MvcAbstraction.ViewModeType.Entities;
          cboViewMode.EndUpdate();

          //Init the PropertyDriven Type Filter
          cboPropertyTypeFilter.BeginUpdate();
          cboPropertyTypeFilter.Items.Clear();
          cboPropertyTypeFilter.DropDownStyle = ComboBoxStyle.DropDownList;
          cboPropertyTypeFilter.DisplayMember = "FilterString";
          foreach (var type in TypeHelper.AllTypes)
          {
              if (!type.IsPropertyBag && type.BaseType != BaseType.Unknown)
                  cboPropertyTypeFilter.Items.Add(type.Copy());
          }
          cboPropertyTypeFilter.Sorted = true;
          cboPropertyTypeFilter.EndUpdate();
          cboPropertyTypeFilter.SelectedIndex = 0;

          LoadFunctionCategoryFilter();
          LoadPropertyBagFilter();
          LoadNamespaceFilter();

          IgnoreChanges = false;
      }

      #endregion

      #region Tree Methods
      private void UpdateTrees()
      {
          UpdateTree(treContext1, Context1);
          UpdateTree(treContext2, Context2);
      }

      public void UpdateTree(ctlExpressionTree tree, Context context)
      {
          tree.ShowNamespaces = chkShowNamespaces.Checked;
          tree.ViewMode = (MvcAbstraction.ViewModeType)cboViewMode.SelectedItem;
          tree.PropertyTypeFilter = (MetraTech.ExpressionEngine.TypeSystem.Type)cboPropertyTypeFilter.SelectedItem;
          tree.FunctionFilter = cboCategory.Text;
          tree.EntityTypeFilter = cboPropertyBagFilter.SelectedItem.ToString();

          if (context != null)
              tree.LoadTree();
      }

      private void ShowExpression(Context masterContext, Expression expression, bool isPageLayout = false)
      {
          var dialog = new frmExpressionEngine();
          var context = new Context(masterContext, expression);
          dialog.Init(context, isPageLayout);
          dialog.ShowDialog();
      }
      #endregion

      #region Load Filter Methods
      public void LoadFunctionCategoryFilter()
      {
          IgnoreChanges = true;

          //Init the Function FixedCategory Filter
          cboCategory.BeginUpdate();
          cboCategory.Items.Clear();
          cboCategory.DropDownStyle = ComboBoxStyle.DropDownList;
          cboCategory.Items.AddRange(Context1.GetFunctionCategories(true).ToArray());
          cboCategory.Sorted = true;
          cboCategory.EndUpdate();
          cboCategory.SelectedIndex = 0;

          IgnoreChanges = false;
      }

      public void LoadNamespaceFilter()
      {
          IgnoreChanges = true;
          var list = new List<string>();
          if (Context1 != null)
              list.AddRange(Context1.Namespaces);
          if (Context2 != null)
              list.AddRange(Context2.Namespaces);
          list = list.Distinct().ToList();

          cboNamespace.BeginUpdate();
          cboNamespace.Items.AddRange(list.ToArray());
          cboNamespace.EndUpdate();
          IgnoreChanges = false;
      }

      public void LoadPropertyBagFilter()
      {
          IgnoreChanges = true;

          var list = new List<string>();
          if (Context1 != null)
              list.AddRange(Context1.PropertyBagManager.GetPropertyBagTypes());
          if (Context2 != null)
              list.AddRange(Context2.PropertyBagManager.GetPropertyBagTypes());
          list = list.Distinct().ToList();

          cboPropertyBagFilter.Items.Clear();
          cboPropertyBagFilter.Items.Add(PropertyBagConstants.AnyFilter);
          foreach (var name in list)
          {
              cboPropertyBagFilter.Items.Add(name);
          }
          cboPropertyBagFilter.Sorted = true;
          cboPropertyBagFilter.SelectedItem = cboPropertyBagFilter.Items[0];

          IgnoreChanges = false;
      }

      private void UpdateGui()
      {
          var viewMode = (MvcAbstraction.ViewModeType) cboViewMode.SelectedItem;

          var pbFlag = (viewMode == MvcAbstraction.ViewModeType.Entities);
          lblPropertyBag.Enabled = pbFlag;
          cboPropertyBagFilter.Enabled = pbFlag;
          lblProperty.Enabled = pbFlag;
          cboPropertyTypeFilter.Enabled = pbFlag;

          var funcFlag = (viewMode == MvcAbstraction.ViewModeType.Functions);
          lblCategory.Enabled = funcFlag;
          cboCategory.Enabled = funcFlag;

      }
      #endregion
        
      #region Events
      private void settingChanged(object sender, EventArgs e)
      {
          if (IgnoreChanges)
              return;

          UpdateGui();
          UpdateTrees();
      }


      private void treContext1_NodeMouseDoubleClick(object sender, TreeNodeMouseClickEventArgs e)
      {
        Context context;
        if (e.Node.TreeView.Equals(treContext1))
          context = Context1;
        else
          context = Context2;

        var tag = e.Node.Tag;
        if (tag is EmailInstance)
        {
          var emailInstance = (EmailInstance) tag;
          emailInstance.UpdateEntityParameters(context);
          var dialog = new frmExpressionEngine();
          var emailContext = new Context(context, emailInstance.BodyExpression, emailInstance);
          dialog.Init(emailContext, emailInstance);
          dialog.ShowDialog();
        }
        else if (tag is Aqg)
        {
          ShowExpression(context, ((Aqg) tag).Expression);
        }
        else if (tag is Uqg)
        {
          ShowExpression(context, ((Uqg) tag).Expression);
        }
        else if (tag is Expression)
        {
          ShowExpression(context, (Expression) tag);
        }
        else if (tag is PageLayout)
        {
          ShowExpression(context, new Expression(ExpressionType.Email, "", null), true);
        }
        else if (tag is PropertyBag)
        {
          //var dialog = new Form1(context, (PropertyBag)tag);
          //dialog.ShowDialog();
          var dialog = new frmPropertyBag(context, (PropertyBag) tag);
          dialog.ShowDialog();
        }
      }

      private void ExportList_OnClick(object sender, EventArgs e)
      {
        var outFile = File.CreateText(Path.Combine(DemoLoader.DirPath, "Export.csv"));
        outFile.WriteLine("Name, FullName, Description");
        foreach (var pb in Context1.PropertyBagManager.PropertyBags)
        {
          outFile.WriteLine(String.Format("{0},{1},{2}", pb.Name,pb.FullName, pb.Description));
        }
        outFile.Close();
        MessageBox.Show(@"Exported");
      }



        #endregion

      private void mnuEdit_DropDownOpening(object sender, EventArgs e)
      {
        //mnuEdit.Enabled = (
      }

      private void mnuEdit_DropDownItemClicked(object sender, ToolStripItemClickedEventArgs e)
      {    
      }

      private void mnuEdit_Click(object sender, EventArgs e)
      {
          var pv = (ProductViewEntity)treContext1.SelectedNode.Tag;
          var dialog = new frmPropertyBag(Context1, pv);
          dialog.ShowDialog();
      }     

    }
}
