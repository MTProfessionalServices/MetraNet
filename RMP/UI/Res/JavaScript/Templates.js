var TPL_SUBSCRIPTION_DETAILS =  '<tpl for="ProductOffering">' +
                                    '<p>{Description}</p>' +
                                  '</tpl>';

 
     // Account Properties Template - the template name is "AccountTypeName + Tpl", add new ones here... 
     var baseTpl = new Ext.XTemplate(
     '<div>',
      '<b>{UserName} ({_AccountID})</b><br/>',
       '<tpl if="this.hasLDAP([values])">',

         '<tpl for="LDAP">',  
          
           '<tpl if="(this.isNull(FirstName) == false) && (this.isNull(LastName) == false)">',
              '<b>{FirstName:htmlEncode} {LastName:htmlEncode}</b><br/>',
           '</tpl>', 
           '<tpl if="(this.isNull(FirstName) == true) && (this.isNull(LastName) == false)">',
              '<b>{LastName:htmlEncode}</b><br/>',
           '</tpl>',            
           '<tpl if="(this.isNull(FirstName) == false) && (this.isNull(LastName) == true)">',
              '<b>{FirstName:htmlEncode}</b><br/>',
           '</tpl>',  
                  
           '<tpl if="this.isNull(Company) == false">',
             '{Company:htmlEncode}<br/>',
           '</tpl>',   
           
           '<tpl if="this.isNull(Address1) == false">',
             '{Address1:htmlEncode}<br/>',
           '</tpl>',      
                 
           '<tpl if="this.isNull(Address2) == false">',
             '{Address2:htmlEncode}<br/>',
           '</tpl>',            
           
           '<tpl if="this.isNull(Address3) == false">',
             '{Address3:htmlEncode}<br/>',
           '</tpl>',             
           
           '<tpl if="this.isNull(City) == false">',
              '{City:htmlEncode}',
           '</tpl>',     
           
           '<tpl if="(this.isNull(City) == false) && (this.isNull(State) == false)">',
              ', ',
           '</tpl>',                  
           
           '<tpl if="this.isNull(State) == false">',
              '{State:htmlEncode}',
           '</tpl>',            
           
           '<tpl if="(this.isNull(Zip) == false) && ((this.isNull(City) == false) ||(this.isNull(State) == false)) ">',
              ' ',
           '</tpl>',   
                    
           '<tpl if="this.isNull(Zip) == false">',
              '{Zip:htmlEncode}',
           '</tpl>',  
                     
           '<tpl if="(this.isNull(City) == false) || (this.isNull(State) == false) || (this.isNull(Zip) == false)">',
              '<br/>',
           '</tpl>', 
           
           '<tpl if="this.isNull(CountryValueDisplayName) == false">',
              '{CountryValueDisplayName:htmlEncode}<br/>',
           '</tpl>', 

           '<tpl if="(this.isNull(Email) == false) || (this.isNull(PhoneNumber) == false) || (this.isNull(FacsimileTelephoneNumber) == false)">',
            '<br/>', 
           '</tpl>',
                              
           '<tpl if="this.isNull(Email) == false">',
             '<img border="0" align="top" src="/Res/Images/icons/email.png"/> <a href="mailto:{Email}">{Email:htmlEncode}</a><br/>',
           '</tpl>',
                      
           
           '<tpl if="this.isNull(PhoneNumber) == false">',
             '<img border="0" align="top" src="/Res/Images/icons/telephone.png"/> {PhoneNumber:htmlEncode}<br/>',
           '</tpl>',
           
//           '<tpl if="this.isNull(FacsimileTelephoneNumber) == false">',
//             '<img border="0" align="top" src="/Res/Images/icons/fax.png"/> {FacsimileTelephoneNumber:htmlEncode}<br/>',
//           '</tpl>',

         '</tpl>',
       '</tpl>',

       '', {
          isNull: function(inputstring){
               var res = false;
               if((inputstring == null)  || (inputstring == '') || (inputstring == 'null'))
               {
                  res = true;
               }                   
               return res;
         }
         ,
         hasLDAP: function(accObj){
          if(accObj == undefined)
          {
            return false;
          }
          if(accObj[0] == undefined)
          {
            return false;
          }          
          
          if(accObj[0].LDAP == undefined)
          {
            return false;
          }
          
          return true;
         }
       }
       );
   
    var CoreSubscriberTpl = baseTpl;
    var CorporateAccountTpl = baseTpl;
    var SystemAccountTpl = baseTpl;
    var IndependentAccountTpl = baseTpl;
    var DepartmentAccountTpl = baseTpl;
    var Tpl  = baseTpl;   