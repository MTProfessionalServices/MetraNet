
var entityTreeData = null;

$(function () {
  $.ui.fancytree.debugLevel = 0;

  //ShowWait();

  $.ajax({
    dataType: "json",
    url: window.entityTreeConfig.metadataUrl,
    headers: window.entityTreeConfig.headers || {},
    success: function (data) {
      entityTreeData = data;

      var treeInitData = [];

      $.each(entityTreeData.PropertyBags, function (i, item) {
        if (item.Type && $.inArray(item.Type.PropertyBagMode, window.entityTreeConfig.entitiesBaseTypes) > -1) {

          var rootEntityItem = {};
          rootEntityItem.title = item.Name + " ("+item.Namespace+")";
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
      //HideWait();
    }
  });

});

function initTree(treeInitData) {
  $("#" + window.entityTreeConfig.elementId).fancytree({
    init: function (event, data) {
      data.tree.rootNode.addChildren(treeInitData);
      data.tree.rootNode.sortChildren(null, false);
    },

    lazyload: function (e, data) {
      var entityProperties = [];

      $.each(entityTreeData[data.node.data.itemSource][data.node.data.itemIndex][data.node.data.itemCollection], function (propIndex, currentProperty) {

        var propertyForTree = {};
        propertyForTree.title = currentProperty.Name;
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
    }
  });
}
