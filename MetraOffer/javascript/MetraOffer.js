MetraControl = {};

/*MetraControl.productOfferings = function () {
  this.productOfferingHrefbyAction = {
    ViewPO: '',

  };
};

MetraControl.productOfferings.events = function () {

};
MetraControl.productOfferings.events.prototype.ViewPO = function (id) {

};
                                                    //todo need to implementation
MetraControl.priceList = function () {
};*/

//-----------------------------------------CommonJs MetraControl---------------------------------------------------------------

MetraControl.common = function () {

};

MetraControl.common.prototype.saveFilterModel = function (gridId) {
  if (gridId !== undefined) {
    var filters = [];
    var grid = window.Ext.getCmp(gridId);
    if (grid) {
      var allFilters = grid.filters.filters.items;
      if (allFilters && allFilters instanceof Array && allFilters.length > 0) {
        for (var i = 0, maxLength = allFilters.length; i < maxLength; i++) {
          var filter = allFilters[i];
          if (filter) {
            var itemFilter = {
              fieldName: filter.dataIndex,
              operationType: filter.filterOperation,
              value: "",
              type: filter.type,
              filterHideable: filter.filterHideable,
              filterReadOnly: filter.readonly
            };
            filters.push(itemFilter);
          }
        }
        var applyFilters = grid.filters.getFilterData();
        if (applyFilters && applyFilters instanceof Array && applyFilters.length > 0) {
          for (var countAllFilter = 0, length = filters.length; countAllFilter < length; countAllFilter++) {
            for (var countApplyFilter = 0, maxLeng = applyFilters.length; countApplyFilter < maxLeng; countApplyFilter++) {
              var allFilterItem = filters[countAllFilter];
              var applyFilter = applyFilters[countApplyFilter];
              if (allFilterItem.fieldName == applyFilter.field) {
                if (applyFilter.data) {
                  allFilterItem.value = applyFilter.data.value === undefined ? "" : applyFilter.data.value;
                  allFilterItem.operationType = applyFilter.data.comparison;
                }
              }
            }
          }
        }
      }
    }
    if (window.Ext) {
      window.Ext.util.Cookies.set("MCSaveFilterModel", JSON.stringify(filters));
    }
  }
};

MetraControl.common.prototype.gridRefresh = function (gridId) {
  var grid = window.Ext.getCmp(gridId);
  setTimeout(
    function () {
      if (window.winDialog.closed) {
        grid.getSelectionModel().deselectAll(true);
        grid.store.reload();
      }
      else
        setTimeout(arguments.callee, 10);
    },
    10);
};

MetraControl.common.prototype.openModalWindow = function (url) {
  window.OpenDialogWindow(url, "height=400,width=600,resizable=yes,scrollbars=yes");
};