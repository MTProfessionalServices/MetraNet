var checkboxes = new Array();
var checkedCheckboxes = new Array();

function getCheckedCheckboxes() {
  checkedCheckboxes = new Array();
  for (var i = 0; i < checkboxes.length; i++) {
    if (document.getElementById(checkboxes[i]).checked) {
      checkedCheckboxes.push(checkboxes[i]);
    }
  }

  document.getElementById('ctl00_ContentPlaceHolder1_hfCheckedCheckboxes').value = checkedCheckboxes;
}

var state = false;
function showBulkUpdateConfirm(btnOkId) {
  if (window.location.search.indexOf("IsBulkUpdate=true") <= 0 || state == true) return true;
  var itemsUpdate = Ext.get("pNumberUpdatingRecords").dom.innerHTML;


  var updatedItem = TEXT_NO_PROPERTIES_GOING_TO_UPDATED; //No properties are going to be updated

  if (checkedCheckboxes.length > 0) {
    updatedItem = "";

    for (var i = 0; i < checkedCheckboxes.length; i++) {
      updatedItem += (i + 1) + '. ' + getPropertyName(checkedCheckboxes[i]) + " = " + getValue(checkedCheckboxes[i]) + '<br />';
    }
  }

  var mypanel = new Ext.Panel({
    renderTo: "divPanelRender",
    title: TEXT_PROPERTIES_GOING_TO_UPDATED, //Properties that are going to be updated
    collapsible: false,
    autoScroll: true,
    height: 150,
    width: 450,
    html: updatedItem,
    padding: 10,
    headerCfg: {
      cls: 'x-panel-header x-unselectable',
      style: 'width:450px;'
    }
  });

  var panelContainer = mypanel.getEl().dom.innerHTML;
  var confirmMessage = itemsUpdate + "<br/><br/>" + TEXT_SURE_MAKE_CHANGE + "<br />" + panelContainer;

  Ext.MessageBox.confirm(TEXT_ATTENTION_CHANGES_PERMANENT, confirmMessage, function (btn) {
    if (btn == 'yes') {
      state = true;
      document.getElementById(btnOkId).click();
    }
    else {
      state = false;
    }

  });
  return false;
}

function removeWrapper(checkBoxName) {
  if (checkBoxName.length > 8 && checkBoxName.indexOf("_wrapper") + 8 == checkBoxName.length) {
    checkBoxName = checkBoxName.substring(0, checkBoxName.length - 8);
  }
  return checkBoxName;
}

function getPropertyName(checkBoxName) {
  var clientId = 'check_ctl00_ContentPlaceHolder1_';
  if (checkBoxName.indexOf('_MTField_') >= 0) {
    clientId = "check_MTField_ctl00_ContentPlaceHolder1_";
  }
  checkBoxName = checkBoxName.substring(clientId.length + 2, checkBoxName.length);
  checkBoxName = removeWrapper(checkBoxName);
  return checkBoxName;
}

function getValue(checkBoxId) {
  var clientId = "check_";
  if (checkBoxId.indexOf('_MTField_') >= 0) {
    clientId += "MTField_";
  }
  checkBoxId = checkBoxId.substring(clientId.length, checkBoxId.length);
  checkBoxId = removeWrapper(checkBoxId);
  var val = Ext.getCmp(checkBoxId).getValue();
  if (String(val).length > 0 && String(val) != undefined) {
    return String(val);  
  }
  return '<b>Empty</b>';
}

function isDeniedProperty(element, properties) {
  var clientId = "MTField_ctl00_ContentPlaceHolder1_";
  for (var i = 0; i < properties.length; i++) {
    if ((element.id.substring(0, clientId.length) == clientId &&
      element.id.substring(clientId.length + 2, element.id.length) == properties[i]) ||
      (element.id.substring(0, clientId.length) == clientId &&
        (element.id.substring(clientId.length + 2, element.id.length) == properties[i] + "_wrapper"))) {
      return true;
    }
  }

  return false;
}

Ext.onReady(function () {

  if (window.location.search.indexOf("IsBulkUpdate=true") > 0) {
    var elems = Ext.query(".x-form-item");

    var deniedProperties = document.getElementById('ctl00_ContentPlaceHolder1_hfDeniedProperties').value.split(",");
    var hiddenElements = 0;

    for (var i = 0; i < elems.length; i++) {

      // Hide fields for denied properties
      if (isDeniedProperty(elems[i], deniedProperties)) {
        elems[i].style.display = 'none';
        Ext.getCmp(Ext.get(elems[i].id).child("table input").id).setValue("1");
        hiddenElements += 1;
        continue;
      }

      if (!Ext.getCmp(Ext.get(elems[i].id).child("table input").id).readOnly) {
        var checkbox = document.createElement("input");
        checkbox.setAttribute("type", "checkbox");
        checkbox.setAttribute("id", "check_" + elems[i].id);
        Ext.getCmp(Ext.get(elems[i].id).child("table input").id).disable();

        checkbox.onclick = function () {
          var elem = Ext.getCmp(Ext.get(this.id).parent().parent().child("table input").id);
          if (this.checked) {
            elem.enable();
          } else {
            elem.disable();
          }
        };

        checkboxes.push("check_" + elems[i].id);

        var div = document.createElement("div");
        div.style.margin = "3px 0 0 0";
        div.style.position = "absolute";
        div.style.zIndex = "100";

        div.appendChild(checkbox);

        elems[i].insertBefore(div, elems[i].childNodes[0]);
      }
      else {
        Ext.get(elems[i].id).hide().setHeight(0).removeClass("x-form-item");
      }
    }

    if (hiddenElements >= elems.length) {
      Ext.MessageBox.show({
        msg: TEXT_NO_PROPERTIES_FOR_BULKUPDATE, //There are no properties for bulk update
        icon: Ext.MessageBox.WARNING,
        title: TEXT_ERROR_NOTHING_UPDATED_BULKUPDATE, //Nothing will be updated
        buttons: Ext.Msg.OK,
        fn: function (btn) {
          if (btn == 'ok') {
            window.history.back();
          }
        }
      });
    }
  }
});