function GetPaymentBrokerCreditCardType(metraNetCreditCardType) {
  var result = 'Unknown';
  switch (metraNetCreditCardType) {
    case 'American_Express':
      result = 'AmericanExpress';
      break;
    case 'Discover':
      result = 'Discover';
      break;
    case 'Diners_Club':
      result = 'DinersClub';
      break;
    case 'JCB':
      result = 'JapanCreditBureau';
      break;
    case 'MasterCard':
      result = 'MasterCard';
      break;
    case 'Visa':
      result = 'Visa';
      break;
  }
  return result;
}