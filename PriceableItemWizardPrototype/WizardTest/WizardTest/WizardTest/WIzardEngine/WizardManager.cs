using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Diagnostics;
using System.Xml.Serialization;
using WizardTest.Model;

namespace WizardTest.WIzardEngine
{
    public partial class WizardManager : Form
    {
        private IList<WizardPage> _pageCollections = null;
        private int _currentPageIndex = -1;
        
        public WizardManager()
        {
            InitializeComponent();
        }

        public void Init(string wizardCaption, IList<WizardPage> pageCollections)
        {
          Debug.Assert(!(pageCollections == null || pageCollections.Count == 0));
          this.Text = wizardCaption;

          _pageCollections = pageCollections;
          _currentPageIndex = -1;

          TreeNode lastNode = null;
          int indexPage = 0;
          foreach (WizardPage page in _pageCollections)
          {
            lastNode = treeView.Nodes.Add(page.PageCaption);
            lastNode.Tag = indexPage;

            indexPage++;
          }

          treeView.ExpandAll();
          treeView.Enabled = false;
          ClearTreeBackColor();
          SetNodeBackColor(_currentPageIndex + 1);

        }

      private void SetPage(int pageIndex)
        {
            if (_currentPageIndex != -1)
            {
                _pageCollections[_currentPageIndex].Hide();
                pnlMain.Controls.Remove(_pageCollections[_currentPageIndex]);
            }

            _pageCollections[pageIndex].Dock = DockStyle.Fill;
            _pageCollections[pageIndex].Parent = this;
            pnlMain.Controls.Add(_pageCollections[pageIndex]);


            _pageCollections[pageIndex].Visible = true;
            lblPage.Text = _pageCollections[pageIndex].PageCaption;
            _currentPageIndex = pageIndex;
        }

        public DialogResult Start()
        {
            SetWizrdState(0);
            return this.ShowDialog();
        }

        private bool IsCurrentPageLast()
        {
            return _currentPageIndex != -1 && _pageCollections.Last() == _pageCollections[_currentPageIndex];
        }

        private bool IsCurrentPageFirst()
        {
            return _currentPageIndex == -1 || _pageCollections.First() == _pageCollections[_currentPageIndex];
        }

        private bool IsCurrentPagePreLast()
        {
          return _currentPageIndex == -1 || _pageCollections[_pageCollections.Count - 2] == _pageCollections[_currentPageIndex];
        }

        private void SetFirstPage()
        {
            btnBack.Enabled = false;
            btnBack.Visible = true;
            btnCancel.Visible = true;
        }

        private void SetMidlePage()
        {
            btnBack.Enabled = true;
            btnNext.Text = PriceableItemWizard.ButtonNext;
            btnBack.Visible = true;
            btnCancel.Visible = true;
        }

        private void SetLastPage()
        {
            btnNext.Text = PriceableItemWizard.ButtonFinish;
            btnCancel.Visible = false;
            btnBack.Visible = false;
        }

        private void SetPreLastPage()
        {
          btnNext.Text = PriceableItemWizard.ButtonSynchronize;
        }

        private void SetWizrdState(int newIndexPage)
        {
            if (newIndexPage != -1)
            {
                SetPage(newIndexPage);

                SetMidlePage();
                if (IsCurrentPageFirst())
                {
                    SetFirstPage();
                }

                if (IsCurrentPageLast())
                {
                    SetLastPage();
                }
                
                if (IsCurrentPagePreLast())
                {
                  SetPreLastPage();
                }

            }
        }

        private void btnBack_Click(object sender, EventArgs e)
        {
          ClearTreeBackColor();
          
          if (_pageCollections[_currentPageIndex].Validate())
          {
            SetNodeBackColor(_currentPageIndex - 1);
            if (_pageCollections[_currentPageIndex].Back())
            {
              SetWizrdState(_currentPageIndex - 1);
              _pageCollections[_currentPageIndex - 1].Init();
            }
          }
          else
          {
            SetNodeBackColor(_currentPageIndex);
          }
        }

        private void btnNext_Click(object sender, EventArgs e)
        {
          ClearTreeBackColor();
   
          if (_pageCollections[_currentPageIndex].Validate())
          {
            if (_pageCollections[_currentPageIndex].Next(IsCurrentPageLast()))
            {
              if (IsCurrentPageLast())
              {
                Close();
              }
              else
              {
                _pageCollections[_currentPageIndex].Save();
                SetNodeBackColor(_currentPageIndex + 1);
                SetWizrdState(_currentPageIndex + 1);
              }
            }
          }
          else
          {
            SetNodeBackColor(_currentPageIndex);
          }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            if (_pageCollections[_currentPageIndex].Cancel())
            {
                SetWizrdState(-1);

              DialogResult dialogResult = MessageBox.Show(PriceableItemWizard.CancelWizardInformation,
                                                          PriceableItemWizard.CancelWindowInformation,
                                                          MessageBoxButtons.OKCancel, MessageBoxIcon.Information);
              if (dialogResult == DialogResult.OK)
              {
                PIModel.Instance.SerializePIModel();
                Close();
              }
            }

        }

        private void treeView_NodeMouseClick(object sender, TreeNodeMouseClickEventArgs e)
        {
          ClearTreeBackColor();
          _pageCollections.Select(item => item.PageCaption == e.Node.Text);
          _pageCollections[Convert.ToInt32(e.Node.Tag)].Init();
          SetWizrdState(Convert.ToInt32(e.Node.Tag));

        }

        private void ClearTreeBackColor()
        {
          foreach (TreeNode node in treeView.Nodes)
          {
            node.BackColor = Color.White;
            node.ForeColor = Color.Black;
          }
        }

       private void SetNodeBackColor(int pageIndex)
       {
         treeView.Nodes[pageIndex].BackColor = Color.MidnightBlue;
         treeView.Nodes[pageIndex].ForeColor = Color.White;
       }

        private void treeView_AfterSelect(object sender, TreeViewEventArgs e)
        {
         
        }
    }
}
