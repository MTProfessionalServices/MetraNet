OverrideRenderer_ctl00_ContentPlaceHolder1_MTFilterGrid1 = function (cm) {

}

BeforeExpanderRender_ctl00_ContentPlaceHolder1_MTFilterGrid1 = function (tplString) {
    var xTemplate = "";

    // Render proration details
    xTemplate += '<div id="ErrorMessageDetails"><div id="ErrorMessageDetails{internalId}"></div></div>';

    tplString = xTemplate;
    return tplString;
};


// On expand get proration details
onExpand = function (record) {

    var errorMessage = TEXT_FLS_NO_ERROR_MESSAGE;

    if (record.data._State == 'REJECTED') {
        errorMessage = TEXT_FLS_ERROR_MESSAGE;
    }

    // Replace values
    var str = errorMessage.replace("[ErrorMessage]", record.data._ErrorMessage);

    // Insert string
    var el = Ext.fly("ErrorMessageDetails" + record.data.internalId);
    el.dom.innerHTML = str;
};