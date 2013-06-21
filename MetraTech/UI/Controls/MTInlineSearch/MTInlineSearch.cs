using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.ComponentModel;
using System.Text;

using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;

namespace MetraTech.UI.Controls
{
    /// <summary>
    /// Summary description for MTInlineSearch.
    /// </summary>

    [ToolboxData("<{0}:MTInlineSearch runat=server></{0}:MTInlineSearch>")]
    public class MTInlineSearch : System.Web.UI.WebControls.TextBox
    {
        #region JavaScript

        private const string START_CONTROL = @"<div id='dropzone' ondragstart='handleOnDrag();' ondragenter='cancelEvent();' ondragover='cancelEvent();' ondrop='handleOnDrop();'><div class=""dropDown""><table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""clear:both;""><tr><td valign=""top""><label class=""x-form-item-label %%LABEL_STYLE%%"" style=""width:%%LABEL_WIDTH%%px;display:%%HIDE_LABEL%%"">%%CTL_LABEL%%:</label>%%OPTIONAL_SPACER%%</td><td valign=""top"" class=""%%EXTRA_SPACE_CSS%%"">";
        private const string END_CONTROL = @"</td><td valign=""top"">%%ACCOUNT_SELECTOR%%</td></tr></table></div></div>";

        private const string ACCOUNT_SELECTOR = @"<a href=""JavaScript:top.getSelection('setSelection','{CLIENT_ID}');"" name=""selectAccounts{CLIENT_ID}"" id=""selectAccounts{CLIENT_ID}""><img src=""/Res/images/icons/find.png"" border=""0"" alt=""Select Account""></a>";

        private const string SCRIPT_MAIN = @"
                      <script type=""text/javascript"">
                      Ext.onReady(function(){

                        // Inline search code
                        var ds{CLIENT_ID} = new Ext.data.Store({
                            proxy: new Ext.data.HttpProxy({
                                url: '/MetraNet/AjaxServices/FindAccountSvc.aspx'
                            }),
                            reader: new Ext.ux.JPathJsonReader({
                              root: 'Items',
                              totalProperty: 'TotalRows',
                              id: '_AccountID'
                            }, [
                              {name: 'UserName', mapping: 'UserName'},
                              {useJPath:true,name: 'FirstName', mapping: 'LDAP[ContactType == 1]/FirstName'},
                              {useJPath:true,name: 'LastName', mapping: 'LDAP[ContactType == 1]/LastName'},
                              {name: 'AccountType', mapping: 'AccountType'},
                              {name: 'AccountStatus', mapping: 'AccountStatus'},
                              {name: 'Folder', mapping: 'Internal.Folder'},
                              {name: '_AccountID', mapping: '_AccountID'}
                            ])
                        });
                        
                        //exit if error occurred
                        ds{CLIENT_ID}.on('loadexception',
                         function(a,conn,resp) {         	    
	                        if(resp.status == 200)
	                          {
	                            Ext.UI.SessionTimeout();
	                          }
	                          else if(resp.status == 500)
	                          {
	                            Ext.UI.SystemError();
	                          }
                        });

                        var resultTpl{CLIENT_ID} = new Ext.XTemplate(
                          '<tpl for="".""><div class=""search-item"">',
                              '<h3><img align=""middle"" src=""/ImageHandler/images/Account/{AccountType}/account.gif?State={AccountStatus}&Folder={Folder}"">{UserName:htmlEncode} ({_AccountID:htmlEncode})</h3>',
                                        
                              '<tpl if=""this.isNull(FirstName)==false && this.isNull(LastName)==false"">',
                                '{FirstName:htmlEncode} {LastName:htmlEncode}',
                              '</tpl>',
                              
                              '<tpl if=""this.isNull(FirstName) || this.isNull(LastName)"">',
                                '<tpl if=""this.isNull(FirstName)"">',
                                  '<tpl if=""this.isNull(LastName) == false"">',
                                    '{LastName:htmlEncode}',
                                  '</tpl>',
                                '</tpl>', 
                                         
                                '<tpl if=""this.isNull(LastName)"">',
                                  '<tpl if=""this.isNull(FirstName)==false"">',
                                    '{FirstName:htmlEncode}',
                                  '</tpl>',
                                '</tpl>',  
                              '</tpl>',          
                          '</div></tpl>',
                          {
                            isNull: function(inputString)
                            {
                              if((inputString == null) || (inputString == '') || (inputString == 'null'))
                              {
                                return true;
                              }
                              return false;
                            }
                          }
                        );
                            
                        var search{CLIENT_ID} = new Ext.form.ComboBox({
                            store: ds{CLIENT_ID},
                            displayField:'UserName',
                            cls:'inlineSearch', 
                            style:'float:left',
                            typeAhead: false,
                            loadingText: 'Searching...',
                            width: 200,
                            pageSize:0,
                            hideTrigger:true,
                            minChars:1,
                            allowBlank:{ALLOW_BLANK},
                            readOnly:{READ_ONLY},                            
                            tpl: resultTpl{CLIENT_ID},
                            //applyTo: '{CLIENT_ID}',
                            itemSelector: 'div.search-item',
                            onSelect: function(record){ // override default onSelect to do redirect
                              var display = record.data.UserName + ' (' + record.data._AccountID + ')';
                              //Ext.get(""{CLIENT_ID}"").dom.value = display;
                              search{CLIENT_ID}.setValue(display);
                              search{CLIENT_ID}.fireEvent('selected');
                              search{CLIENT_ID}.collapse();
                            }
                        });

                        //disable autocomplete
                        try{
                          Ext.get(""{CLIENT_ID}"").dom.setAttribute(""autocomplete"",""off""); 
                        }
                        catch(e){}

                        search{CLIENT_ID}.applyToMarkup(""{CLIENT_ID}"");
                        if (typeof(cBoxes) != 'undefined')
                        {
                          cBoxes['{CLIENT_ID}'] = search{CLIENT_ID};
                        }
                      });  
                      </script>";
        #endregion

        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
        [Localizable(true)]
        public string Label
        {
            get
            {
                String s = (String)ViewState["Label"];
                return ((s == null) ? String.Empty : s);
            }

            set
            {
                ViewState["Label"] = value;
            }
        }


        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
        [Localizable(true)]
        public string LabelWidth
        {
            get
            {
                String s = (String)ViewState["LabelWidth"];
                return ((s == null) ? String.Empty : s);
            }

            set
            {
                ViewState["LabelWidth"] = value;
            }
        }


        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
        [Localizable(true)]
        public bool HideLabel
        {
            get
            {
                bool b = false;
                if (ViewState["HideLabel"] != null)
                {
                    b = (bool)ViewState["HideLabel"];
                }
                return b;
            }

            set
            {
                ViewState["HideLabel"] = value;
            }
        }

        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
        [Localizable(true)]
        public bool AllowBlank
        {
            get
            {
                bool b = false;
                if (ViewState["AllowBlank"] != null)
                {
                    b = (bool)ViewState["AllowBlank"];
                }
                return b;
            }

            set
            {
                ViewState["AllowBlank"] = value;
            }
        }


        [Bindable(true)]
        [Category("Appearance")]
        [DefaultValue("")]
        [Localizable(true)]
        public new bool ReadOnly
        {
            get
            {
                bool b = false;
                if (ViewState["ReadOnly"] != null)
                {
                    b = (bool)ViewState["ReadOnly"];
                }
                return b;
            }

            set
            {
                ViewState["ReadOnly"] = value;
            }
        }

        public MTInlineSearch()
        {
            this.Init += new System.EventHandler(this.Control_Load);
        }

        private void Control_Load(object sender, System.EventArgs e)
        {
            //mPage = (MetraTech.UI.Common.MTPage)Page;
        }

        /// <summary>
        /// The account id used for binding.
        /// </summary>
        [Bindable(true), Category("Appearance"), DefaultValue("")]
        public string AccountID
        {
            get
            {
                string id = Utils.ExtractStringLastInstance(base.Text, "(", ")");
                if (id == "")
                {
                    id = base.Text;
                }
                return id;
            }

            set
            {
                if (string.IsNullOrEmpty(value))
                {
                    base.Text = "";
                }
                else
                {
                    MTPage page = this.Page as MTPage;
                    string id = Utils.ExtractStringLastInstance(base.Text, "(", ")");
                    try
                    {
                        if (id == "")
                        {
                            base.Text = AccountLib.GetFieldID(int.Parse(value), page.UI.User, page.ApplicationTime);
                        }
                        else
                        {
                            base.Text = AccountLib.GetFieldID(int.Parse(id), page.UI.User, page.ApplicationTime);
                        }
                    }
                    catch (Exception)
                    {
                        base.Text = value;
                        if (base.Text == "1")
                        {
                            var resManager = new ResourcesManager();
                            string rootText = resManager.GetLocalizedResource("ROOT");
                            base.Text = rootText;
                        }
                    }
                }
            }
        }

        /// <summary> 
        /// Render this control to the output parameter specified.
        /// </summary>
        /// <param name="output"> The HTML writer to write out to </param>
        protected override void Render(HtmlTextWriter output)
        {
            LabelWidth = ((LabelWidth == String.Empty) ? "120" : LabelWidth);
            string labelStyle = AllowBlank ? "Caption" : "CaptionRequired";
            string hideLabel = HideLabel ? "none;" : "block;";

            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
            // Added JavaScript encoding
            //string html = START_CONTROL.Replace("%%CTL_LABEL%%", Label);
            string html = START_CONTROL.Replace("%%CTL_LABEL%%", Label.EncodeForJavaScript());
            if (HideLabel)
            {
                html = html.Replace("%%OPTIONAL_SPACER%%", @"<label style=""width:%%LABEL_WIDTH%%px;""></label>");
            }
            else
            {
                html = html.Replace("%%OPTIONAL_SPACER%%", "");
            }
            html = html.Replace("%%LABEL_WIDTH%%", LabelWidth);
            html = html.Replace("%%LABEL_STYLE%%", labelStyle);
            html = html.Replace("%%EXTRA_SPACE_CSS%%", ReadOnly ? "x-extra-space-readonly" : "x-extra-space");
            html = html.Replace("%%HIDE_LABEL%%", hideLabel);

            output.Write(html);

            string endControl = "";
            if (ReadOnly)
            {
                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                // Added HTML encoding
                //output.Write(Page.Server.HtmlEncode(Text));
                output.Write((Text ?? string.Empty).EncodeForHtml());
                endControl = END_CONTROL.Replace("%%ACCOUNT_SELECTOR%%", "");
                output.Write(endControl.Replace("{CLIENT_ID}", this.ClientID));
            }
            else
            {
                base.Render(output);
                endControl = END_CONTROL.Replace("%%ACCOUNT_SELECTOR%%", ACCOUNT_SELECTOR);
                output.Write(endControl.Replace("{CLIENT_ID}", this.ClientID));
                string mainScript = SCRIPT_MAIN.Replace("{CLIENT_ID}", this.ClientID);
                mainScript = mainScript.Replace("{ALLOW_BLANK}", this.AllowBlank.ToString().ToLower());
                mainScript = mainScript.Replace("{READ_ONLY}", this.ReadOnly.ToString().ToLower());
                output.Write(mainScript);
            }

        }

    }
}
