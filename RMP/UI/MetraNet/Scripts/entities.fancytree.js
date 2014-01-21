var EntityBrowser = function () {

  var entityTreeData = null;
  var lastSelectionRange = null;

  var currentTextAreaId = entityTreeConfig.elementId + 'Textarea';

  /* for IE we should save previous selection in text area */
  function getCurrentSelection() {
    if (!document.selection)
      return;

    $('#' + currentTextAreaId).focus();
    var selection1 = document.selection.createRange();
    return selection1;
  }

  function putTextIntoCursor(textToPut) {
    var droparea = document.getElementById(currentTextAreaId);
    //IE support
    if (document.selection) {
      if (lastSelectionRange === null)
        lastSelectionRange = getCurrentSelection();
      var sel = lastSelectionRange;
      sel.text = textToPut;
      lastSelectionRange.selectionStart = lastSelectionRange.selectionEnd;
      sel.select();
      $("#" + window.entityTreeConfig.elementId + "Tree, #" + window.entityTreeConfig.elementId + "Tree ul").blur();
      $("#" + currentTextAreaId).focus();
    } else if (droparea.selectionStart || droparea.selectionStart == '0') {
      var startPos = droparea.selectionStart;
      var endPos = droparea.selectionEnd;
      var scrollTop = droparea.scrollTop;
      droparea.value = droparea.value.substring(0, startPos) + textToPut + droparea.value.substring(endPos, droparea.value.length);
      $("#" + window.entityTreeConfig.elementId + "Tree, #" + window.entityTreeConfig.elementId + "Tree ul").blur();
      droparea.focus();
      droparea.selectionStart = startPos + textToPut.length;
      droparea.selectionEnd = startPos + textToPut.length;
      droparea.scrollTop = scrollTop;
    } else {
      droparea.value += textToPut;
      droparea.focus();
    }
  }

  function initializeDraggableTreeItem(targetNode) {
    $(targetNode).draggable({
      revert: "invalid",
      helper: "clone",
      containment: '#' + entityTreeConfig.elementId
    });
  }


  function GetFullEntityNameAndPutToTextArea(node) {
    var resultValue = node.data.sourceValue;

    function getParentAndConcatValue(sourceItem) {
      var currentParent = sourceItem.parent;
      if (!currentParent || currentParent.title == "root")
        return;

      resultValue = currentParent.data.sourceValue + "." + resultValue;
      getParentAndConcatValue(currentParent);
    }

    getParentAndConcatValue(node);

    putTextIntoCursor(resultValue);
  }

  function initTree(treeInitData) {
    $("#" + window.entityTreeConfig.elementId + "Tree").fancytree({
      init: function (event, data) {
        data.tree.rootNode.addChildren(treeInitData);
        data.tree.rootNode.sortChildren(null, false);
      },

      dblclick: function (event, data) {
        GetFullEntityNameAndPutToTextArea(data.node);
      },

      lazyload: function (e, data) {
        var entityProperties = [];

        $.each(entityTreeData[data.node.data.itemSource][data.node.data.itemIndex][data.node.data.itemCollection], function (propIndex, currentProperty) {

          var propertyForTree = {};
          propertyForTree.title = currentProperty.Name;
          propertyForTree.sourceValue = currentProperty.Name;
          if (currentProperty.Description)
            propertyForTree.tooltip = currentProperty.Description;

          // if property is some class
          if (currentProperty.Type && currentProperty.Type.BaseType == "PropertyBag") {
            $.each(entityTreeData.PropertyBags, function (currentBagItemIndex, currentBagItem) {
              var tempName = currentBagItem.Namespace + "." + currentBagItem.Name;
              if (tempName === currentProperty.Type.Name) {
                propertyForTree.folder = true;
                propertyForTree.lazy = true;

                propertyForTree.itemCollection = "Properties";
                propertyForTree.itemSource = "PropertyBags";
                propertyForTree.itemIndex = currentBagItemIndex;
              }
            });
          }

          // if property is enum 
          if (currentProperty.Type && currentProperty.Type.BaseType == "Enumeration") {
            $.each(entityTreeData.EnumCategories, function (currentEnumItemIndex, currentEnumItem) {
              var tempName = currentEnumItem.Namespace + "." + currentEnumItem.Name;
              if (tempName === currentProperty.Type.Category) {
                propertyForTree.folder = true;
                propertyForTree.lazy = true;

                propertyForTree.itemCollection = "Items";
                propertyForTree.itemSource = "EnumCategories";
                propertyForTree.itemIndex = currentEnumItemIndex;
              }
            });
          }

          entityProperties.push(propertyForTree);

        });

        data.result = entityProperties;
      },
      loadchildren: function (event, data) {
        data.node.sortChildren(null, true);
      },
      rendernode: function (event, data) {
        initializeDraggableTreeItem(data.node.li.children[0]);
      },
      
    });
  }


  this.createEntityTree = function () {
    $.ui.fancytree.debugLevel = 0;

    $('#' + currentTextAreaId).mouseup(function () {
      lastSelectionRange = getCurrentSelection();
    });
    $('#' + currentTextAreaId).keyup(function () {
      lastSelectionRange = getCurrentSelection();
    });

    $("#" + currentTextAreaId).droppable({
      drop: function (event, ui) {
        GetFullEntityNameAndPutToTextArea($(ui.draggable[0]).parent()[0].ftnode);
      }
    });


    $.ajax({
      dataType: "json",
      cache: false,
      url: window.entityTreeConfig.metadataUrl,
      headers: window.entityTreeConfig.headers || {},
      success: function (data) {
        entityTreeData = data;

        var treeInitData = [];

        $.each(entityTreeData.PropertyBags, function (i, item) {
          if (item.Type && $.inArray(item.Type.PropertyBagMode, window.entityTreeConfig.entitiesBaseTypes) > -1) {

            var rootEntityItem = {};
            rootEntityItem.sourceValue = item.Name;
            rootEntityItem.title = item.Name + " (" + item.Namespace + ")";
            if (item.Description)
              rootEntityItem.tooltip = item.Description;
            rootEntityItem.folder = true;
            rootEntityItem.lazy = true;

            rootEntityItem.itemCollection = "Properties";
            rootEntityItem.itemSource = "PropertyBags";
            rootEntityItem.itemIndex = i;

            treeInitData.push(rootEntityItem);
          }
        });

        initTree(treeInitData);
      }
    });
  };

};


$(function () {
  var entityBrowserInstance = new EntityBrowser();
  entityBrowserInstance.createEntityTree();
});