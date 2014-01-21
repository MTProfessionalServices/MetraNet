 function generateDatePicker(ctrlName, dateFormat) {
              
              Ext.onReady(function() {
                //var dateFormat = '" + mam_GetDictionary("JS_DATE_FORMAT") + "';
                eval("var field" + ctrlName + " = document.getElementById('" + ctrlName + "');");

                eval("var picker" + ctrlName + " = new Ext.DatePicker({hidden: true,format:dateFormat});");

                eval("picker" + ctrlName + ".on('select', function(picker, date) \
                {\
                  field" + ctrlName + ".value = date.format(dateFormat);\
                  picker.hide();\
                });");

                eval("picker" + ctrlName + ".render('div" + ctrlName + "');");

				eval("var doc = Ext.get(document);");
				eval(" doc.on('click', function(event, target) {\
                                                    var elem = Ext.get(target);\
                                                    var elid = elem.id;\
                                                    if(elem.findParent('[id=div" + ctrlName + "]') == null && elem.id != 'openCalendar" + ctrlName  + "') \
                                                    {\
                                                      picker" + ctrlName + ".hide();\
                                                    }\
                                                  })");
                                                  
                eval("\
                Ext.EventManager.on('openCalendar" + ctrlName + "', 'click', function() { \
                  if (picker" + ctrlName + ".hidden) {  \
                    var dateInCtrl = Date.parseDate(field" + ctrlName + ".value, dateFormat, true); \
                    if (dateInCtrl != null) { \
                      picker" + ctrlName + ".setValue(dateInCtrl); \
                    } \
                    else { \
                      picker" + ctrlName + ".setValue(new Date()); \
                    } \
                    picker" + ctrlName + ".show(); \
                  } \
                  else { \
                    picker" + ctrlName + ".hide(); \
                  }\
                });\
                 "); 

              });
            }