using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraNet.Models;
using MetraTech;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using PropertyType = MetraTech.DomainModel.Enums.Core.Global.PropertyType;

/// <summary>
/// Expects a session on the page for holding the specs:
/// <code>
/// <![CDATA[
///    public Dictionary<string, SpecCharacteristicValueModel> SpecValues
///    {
///     get { return Session["SpecValues"] as Dictionary<string, SpecCharacteristicValueModel>; }
///     set { Session["SpecValues"] = value; }
///     }
/// ]]>
/// </code>
/// Expects a panel to hold the properties:
/// <code>
///    <!-- Properties -->
///   <MT:MTPanel ID="pnlSubscriptionProperties" runat="server" Text="Properties" Collapsible="false" meta:resourcekey="pnlSubscriptionProperties">
///   </MT:MTPanel>
/// </code>
/// </summary>
public static class SpecCharacteristicsBinder
{
  /// <summary>
  /// BindProperties - adds controls to the page for each subscription property that is user visible
  /// </summary>
  /// <param name="panel"> </param>
  /// <param name="sub"> </param>
  /// <param name="page"></param>
  /// <param name="SpecValues"></param>
  public static void BindProperties(Panel panel, Subscription sub, MTPage page, Dictionary<string, SpecCharacteristicValueModel> SpecValues)
  {
    SpecValues.Clear();

    var poId = sub.ProductOfferingId;
    var subId = sub.SubscriptionId;

    // get the specs for this po
    var repository = new SpecCharacteristicRepository(page.UI);
    var specs = repository.LoadSpecCharacteristics(poId, EntityType.ProductOffering, false);

    // get the CharacteristicValues for the sub
    if (subId != null && subId != 0)
    {
      sub.CharacteristicValues = repository.LoadCharacteristicValuesForEntity((int)subId).Items;
    }

    if (specs != null && specs.Count > 0)
    {
      panel.Visible = true;
    }
    else
    {
      panel.Visible = false;
      return;
    }

    var orderedSpecs = specs.OrderBy(o => o.DisplayOrder);
    var groupedSpecs = orderedSpecs.GroupBy(c => c.Category);

    // loop over the specs and insert controls, 
    // keep track of control ids (SpecValues) so we can unbind and save in SubscriptionInstance.CharacteristicValues
    short i = 100;
    foreach (var group in groupedSpecs)
    {
      var section = new LiteralControl { Text = String.Format("<div class='SectionCaptionBar'>{0}</div>", @group.Key) };  // todo: get localization
      
      panel.Controls.Add(section);

      foreach (var spec in group)
      {
        i++;
        if (spec.SpecId != null)
        {
          var fullSpec = repository.LoadSpecCharacteristicValue((int)spec.SpecId);

          switch (fullSpec.SpecType)
          {
            case PropertyType.String:
              if (SpecValues.ContainsKey("spec" + fullSpec.SpecId)) //extra duplicate check
              {
                break;
              }
              var tbTemp = new MTTextBoxControl();
              tbTemp.ID = "spec" + fullSpec.SpecId;
              tbTemp.Label =
                fullSpec.NameDisplayNames[
                  (LanguageCode)
                  Enum.Parse(typeof(LanguageCode),
                             Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName.Replace("en", "us"), true)];
              if (tbTemp.Label == "") tbTemp.Label = fullSpec.Name;
              tbTemp.AllowBlank = !fullSpec.IsRequired;
              tbTemp.ReadOnly = fullSpec.IsUserEditable == false; 
              tbTemp.TabIndex = i;
              tbTemp.MaxLength = fullSpec.Length ?? 4000;
              if(subId != null && subId != 0)
              {
                foreach (var val in sub.CharacteristicValues.Where(val => val.SpecName == fullSpec.Name))
                {
                  tbTemp.Text = val.Value;
                  break;
                }
              }
              else
              {
                tbTemp.Text = fullSpec.StringValue;  
              }
              panel.Controls.Add(tbTemp);
              SpecValues.Add(tbTemp.ID, fullSpec);
              break;

            case PropertyType.Int:
              var tbTempInt = new MTNumberField();
              tbTempInt.ID = "spec" + fullSpec.SpecId;
              tbTempInt.Label =
                fullSpec.NameDisplayNames[
                  (LanguageCode)
                  Enum.Parse(typeof(LanguageCode),
                             Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName.Replace("en", "us"), true)];
              if (tbTempInt.Label == "") tbTempInt.Label = fullSpec.Name;
              tbTempInt.AllowBlank = !fullSpec.IsRequired;
              tbTempInt.ReadOnly = fullSpec.IsUserEditable == false; 
              tbTempInt.TabIndex = i;

              if (fullSpec.MinDecimal.HasValue)
                 tbTempInt.MinValue = fullSpec.Min.ToString();
              if (fullSpec.MaxDecimal.HasValue)
                tbTempInt.MaxValue = fullSpec.Max.ToString();

              tbTempInt.AllowDecimals = false;
              if (subId != null && subId != 0)
              {
                foreach (var val in sub.CharacteristicValues.Where(val => val.SpecName == fullSpec.Name))
                {
                  tbTempInt.Text = val.Value;
                  break;
                }
              }
              else
              {
                tbTempInt.Text = fullSpec.IntValue.ToString(CultureInfo.InvariantCulture);
              }
              panel.Controls.Add(tbTempInt);
              SpecValues.Add(tbTempInt.ID, fullSpec);
              break;

            case PropertyType.Decimal:
              var tbTempDec = new MTNumberField();
              tbTempDec.ID = "spec" + fullSpec.SpecId;
              tbTempDec.Label =
                fullSpec.NameDisplayNames[
                  (LanguageCode)
                  Enum.Parse(typeof(LanguageCode),
                             Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName.Replace("en", "us"), true)];
              if (tbTempDec.Label == "") tbTempDec.Label = fullSpec.Name;
              tbTempDec.AllowBlank = !fullSpec.IsRequired;
              tbTempDec.ReadOnly = fullSpec.IsUserEditable == false;
              tbTempDec.TabIndex = i;

              if(fullSpec.Min.HasValue)
                tbTempDec.MinValue =  fullSpec.MinDecimal.ToString();
              if(fullSpec.Max.HasValue)
                tbTempDec.MaxValue =  fullSpec.MaxDecimal.ToString();
              
              tbTempDec.AllowDecimals = true;
              if (subId != null && subId != 0)
              {
                foreach (var val in sub.CharacteristicValues.Where(val => val.SpecName == fullSpec.Name))
                {
                  tbTempDec.Text = val.Value;
                  break;
                }
              }
              else
              {
                tbTempDec.Text = fullSpec.DecimalValue.ToString();
              }
// ReSharper restore SpecifyACultureInStringConversionExplicitly
              panel.Controls.Add(tbTempDec);
              SpecValues.Add(tbTempDec.ID, fullSpec);
              break;

            case PropertyType.List:
              var tbTempDD = new MTDropDown();
              tbTempDD.ID = "spec" + fullSpec.SpecId;
              tbTempDD.Label =
                fullSpec.NameDisplayNames[
                  (LanguageCode)
                  Enum.Parse(typeof(LanguageCode),
                             Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName.Replace("en", "us"), true)];
              if (tbTempDD.Label == "") tbTempDD.Label = fullSpec.Name;
              tbTempDD.AllowBlank = !fullSpec.IsRequired;
              tbTempDD.ReadOnly = fullSpec.IsUserEditable == false; 
              tbTempDD.TabIndex = i;
              var values = fullSpec.Choices.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
              foreach (var tempVal in values)
              {
                var itm = new ListItem(tempVal, tempVal);  // get localization if exists
                tbTempDD.Items.Add(itm);
              }
              if (subId != null && subId != 0)
              {
                foreach (var val in sub.CharacteristicValues.Where(val => val.SpecName == fullSpec.Name))
                {
                  tbTempDD.SelectedValue = val.Value;
                  break;
                }
              }
              else
              {
                tbTempDD.SelectedValue = fullSpec.DefaultChoice;
              }
              panel.Controls.Add(tbTempDD);
              SpecValues.Add(tbTempDD.ID, fullSpec);
              break;

            case PropertyType.Boolean:
              var tbTempCheck = new MTCheckBoxControl();
              tbTempCheck.ID = "spec" + fullSpec.SpecId;
              tbTempCheck.BoxLabel =
                fullSpec.NameDisplayNames[
                  (LanguageCode)
                  Enum.Parse(typeof(LanguageCode),
                             Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName.Replace("en", "us"), true)];
              if (tbTempCheck.BoxLabel == "") tbTempCheck.BoxLabel = fullSpec.Name;
              tbTempCheck.ReadOnly = fullSpec.IsUserEditable == false;
              tbTempCheck.TabIndex = i;
              if (subId != null && subId != 0)
              {
                foreach (var val in sub.CharacteristicValues.Where(val => val.SpecName == fullSpec.Name))
                {
                  if (val.Value.ToUpper() == "Y")
                  {
                    tbTempCheck.Checked = true;
                  }
                  else
                  {
                    tbTempCheck.Checked = false;
                  }
                  break;
                }
              }
              else
              {
                tbTempCheck.Checked = fullSpec.BooleanValue;
              }
              panel.Controls.Add(tbTempCheck);
              SpecValues.Add(tbTempCheck.ID, fullSpec);
              break;

            case PropertyType.Datetime:
              var tbTempDate = new MTDatePicker();
              tbTempDate.ID = "spec" + fullSpec.SpecId;
              tbTempDate.Label =
                fullSpec.NameDisplayNames[
                  (LanguageCode)
                  Enum.Parse(typeof(LanguageCode),
                             Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName.Replace("en", "us"), true)];
              if (tbTempDate.Label == "") tbTempDate.Label = fullSpec.Name;
              tbTempDate.AllowBlank = !fullSpec.IsRequired;
              tbTempDate.ReadOnly = fullSpec.IsUserEditable == false; 
              tbTempDate.TabIndex = i;
// ReSharper disable SpecifyACultureInStringConversionExplicitly
              tbTempDate.MaxValue = fullSpec.BetweenEndDate.HasValue ? fullSpec.BetweenEndDate.ToString() : "";
// ReSharper restore SpecifyACultureInStringConversionExplicitly
// ReSharper disable SpecifyACultureInStringConversionExplicitly
              tbTempDate.MinValue = fullSpec.BetweenStartDate.HasValue ? fullSpec.BetweenStartDate.ToString() : "";
// ReSharper restore SpecifyACultureInStringConversionExplicitly
// ReSharper disable SpecifyACultureInStringConversionExplicitly
              if (subId != null && subId != 0)
              {
                foreach (var val in sub.CharacteristicValues.Where(val => val.SpecName == fullSpec.Name))
                {
                  tbTempDate.Text = val.Value;
                  break;
                }
              }
              else
              {
                tbTempDate.Text = fullSpec.DatetimeValue.ToString();
              }           
// ReSharper restore SpecifyACultureInStringConversionExplicitly
              panel.Controls.Add(tbTempDate);
              SpecValues.Add(tbTempDate.ID, fullSpec);
              break;

            default:
              throw new ArgumentOutOfRangeException();
          }
        }
      }

    }
  }

  /// <summary>
  /// UnbindProperies - places control values into subscriptionInstance.CharacteristicValues
  /// </summary>
  /// <param name="charVals"> </param>
  /// <param name="panel"> </param>
  /// <param name="SpecValues"></param>
  public static void UnbindProperies(List<CharacteristicValue> charVals, Panel panel, Dictionary<string, SpecCharacteristicValueModel> SpecValues)
  {
    foreach (var v in SpecValues)
    {
      var clientId = panel.ClientID;
      clientId = clientId.Replace(panel.ID, v.Key);
      string val;
      switch (v.Value.SpecType)
      {
        case PropertyType.String:
          val = panel.Page.Request[clientId];
          break;
        case PropertyType.Int:
          val = panel.Page.Request[clientId]; 
          break;
        case PropertyType.Decimal:
          val = panel.Page.Request[clientId]; 
          break;
        case PropertyType.List:
          val = panel.Page.Request[clientId.Replace("_", "$")]; 
          break;
        case PropertyType.Boolean:
          if (panel.Page.Request[clientId] != null)
          {
            val = "Y"; 
          }
          else
          {
            val = "N";
          }
          break;
        case PropertyType.Datetime:
          val = panel.Page.Request[clientId]; 
          break;
        default:
          throw new ArgumentOutOfRangeException();
      }

      var characteristicValue = new CharacteristicValue {SpecName = v.Value.Name, Value = val, SpecType = v.Value.SpecType};

      if (v.Value.ValueId.HasValue)
        characteristicValue.SpecCharValId = v.Value.ValueId;

      characteristicValue.StartDate = MetraTime.Now;

      charVals.Add(characteristicValue);
    }

  }
}