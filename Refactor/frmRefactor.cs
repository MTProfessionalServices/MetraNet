using System;
using System.Collections.Generic;
using System.Windows.Forms;
using MetraTech.ICE.ExpressionEngine.Enumerations;

namespace MetraTech.ICE.ExpressionEngine
{
  public partial class frmRefactor : Form
  {
    #region Properties

    private RefactorEngine RefactorEngine;
    #endregion

    #region Constructor
    public frmRefactor()
    {
      InitializeComponent();

      cboRefactorMode.Items.Add(RefactorMode.PropertyName);
      cboRefactorMode.Items.Add(RefactorMode.Enum);
      cboRefactorMode.SelectedItem = RefactorMode.PropertyName;

      panEnum.Top = panProperty.Top;
      panEnum.Left = panProperty.Left;
    }
    #endregion

    #region Methods
    private void Search()
    {
      lstElements.Items.Clear();

      RefactorEngine = new RefactorEngine();
      RefactorEngine.RefactorMode = (RefactorMode) cboRefactorMode.SelectedItem;
      if (RefactorEngine.RefactorMode == RefactorMode.PropertyName)
      {
        RefactorEngine.OldPropertyName = txtOldPropertyName.Text;
        RefactorEngine.NewPropertyName = txtNewPropertyName.Text;
      }
      else
      {
        RefactorEngine.OldEnumSpace = ctlEnum.EnumSpace;
        RefactorEngine.OldEnumType = ctlEnum.EnumType;
        RefactorEngine.NewEnumSpace = txtNewEnumSpace.Text;
        RefactorEngine.NewEnumType = txtNewEnumType.Text;       
      }

      var refactorItems = RefactorEngine.GetRefactorItems();
      foreach (var refactorItem in refactorItems)
      {
        lstElements.Items.Add(refactorItem, true);
      }
    }

    private void Save()
    {
      var refactorItems = new List<RefactorItem>();
      for (int index = 0; index < lstElements.Items.Count; index++)
      {
        //if (lstElements.GetSelected(index))
        refactorItems.Add((RefactorItem)lstElements.Items[index]);
      }

      RefactorEngine.RefactorItem(refactorItems);
    }
    #endregion

    #region Events
    private void btnSearch_Click(object sender, EventArgs e)
    {
      try
      {
        Search();
      }
      catch (Exception ex)
      {
        Helper.ShowErrorMsg(ex.Message);
      }
    }

    private void lstElements_SelectedIndexChanged(object sender, EventArgs e)
    {
      var item = (RefactorItem) lstElements.SelectedItem;
      txtMatches.Text = item.GetMatchDetails();
    }

    private void cboRefactorMode_SelectedIndexChanged(object sender, EventArgs e)
    {
      var mode = (RefactorMode) cboRefactorMode.SelectedItem;
      panProperty.Visible = (mode == RefactorMode.PropertyName);
      panEnum.Visible = (mode == RefactorMode.Enum);
    }

    private void btnSave_Click(object sender, EventArgs e)
    {
      try
      {
        Save();
      }
      catch (Exception ex)
      {
        Helper.ShowErrorMsg(ex.Message);
      }
    }
    #endregion


  }
}
