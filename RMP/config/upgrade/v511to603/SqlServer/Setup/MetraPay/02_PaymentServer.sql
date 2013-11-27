use %%METRAPAY%%

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT

BEGIN TRANSACTION

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_ps_creditcard_old]') AND type in (N'U'))
BEGIN

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_ps_creditcard]') AND type in (N'U'))
		DROP TABLE [dbo].[t_ps_creditcard]

	-- Restore original table
	EXECUTE sp_rename N'dbo.t_ps_creditcard_old', N't_ps_creditcard', 'OBJECT' 
END
GO

DELETE FROM t_ps_payment_instrument
GO

DELETE FROM t_ps_credit_card
GO

DELETE FROM %%NETMETER%%..t_payment_instrument
GO

CREATE TABLE t_ps_creditcard2(
	[id_payment_instrument] [VARCHAR](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[nm_customer] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_ccnum] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[nm_ccseccode] [varchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_primary] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[nm_enabled] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[nm_authreceived] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[id_acc] [int] NOT NULL,
	[nm_address] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_city] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_state] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_zip] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_country] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[id_creditcardtype] [int] NOT NULL,
	[nm_bankname] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_lastfourdigits] [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[nm_expdate] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[id_expdatef] [int] NOT NULL,
	[nm_startdate] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_issuernumber] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_cardid] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_cardverifyvalue] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nm_pcard] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

INSERT INTO t_ps_creditcard2
(
	id_payment_instrument,
	nm_customer,
	nm_ccnum,
	nm_ccseccode,
	nm_primary,
	nm_enabled,
	nm_authreceived,
	id_acc,
	nm_address,
	nm_city,
	nm_state,
	nm_zip,
	nm_country,
	id_creditcardtype,
	nm_bankname,
	nm_lastfourdigits,
	nm_expdate,
	id_expdatef,
	nm_startdate,
	nm_issuernumber,
	nm_cardid,
	nm_cardverifyvalue,
	nm_pcard
)
SELECT 
	NEWID(),
	nm_customer,
	nm_ccnum,
	nm_ccseccode,
	nm_primary,
	nm_enabled,
	nm_authreceived,
	id_acc,
	nm_address,
	nm_city,
	nm_state,
	nm_zip,
	nm_country,
	id_creditcardtype,
	nm_bankname,
	nm_lastfourdigits,
	nm_expdate,
	id_expdatef,
	ISNULL(nm_startdate,''),
	ISNULL(nm_issuernumber,''),
	nm_cardid,
	nm_cardverifyvalue,
	nm_pcard
FROM
	t_ps_creditcard
	
create table #countryMap
(
	shortName varchar(10),
	enumName varchar(255)
)
GO

insert into #countryMap (shortName, enumName) values ('2', 'metratech.com/paymentserver/PaymentMethodCountry/Afghanistan')
insert into #countryMap (shortName, enumName) values ('3', 'metratech.com/paymentserver/PaymentMethodCountry/Albania')
insert into #countryMap (shortName, enumName) values ('4', 'metratech.com/paymentserver/PaymentMethodCountry/Algeria')
insert into #countryMap (shortName, enumName) values ('5', 'metratech.com/paymentserver/PaymentMethodCountry/American Samoa')
insert into #countryMap (shortName, enumName) values ('6', 'metratech.com/paymentserver/PaymentMethodCountry/Andorra')
insert into #countryMap (shortName, enumName) values ('7', 'metratech.com/paymentserver/PaymentMethodCountry/Angola')
insert into #countryMap (shortName, enumName) values ('8', 'metratech.com/paymentserver/PaymentMethodCountry/Anguilla')
insert into #countryMap (shortName, enumName) values ('9', 'metratech.com/paymentserver/PaymentMethodCountry/Antarctica')
insert into #countryMap (shortName, enumName) values ('10', 'metratech.com/paymentserver/PaymentMethodCountry/Antigua')
insert into #countryMap (shortName, enumName) values ('11', 'metratech.com/paymentserver/PaymentMethodCountry/Argentina')
insert into #countryMap (shortName, enumName) values ('12', 'metratech.com/paymentserver/PaymentMethodCountry/Armenia')
insert into #countryMap (shortName, enumName) values ('13', 'metratech.com/paymentserver/PaymentMethodCountry/Aruba')
insert into #countryMap (shortName, enumName) values ('15', 'metratech.com/paymentserver/PaymentMethodCountry/Australia')
insert into #countryMap (shortName, enumName) values ('16', 'metratech.com/paymentserver/PaymentMethodCountry/Austria')
insert into #countryMap (shortName, enumName) values ('17', 'metratech.com/paymentserver/PaymentMethodCountry/Azerbaijan')
insert into #countryMap (shortName, enumName) values ('18', 'metratech.com/paymentserver/PaymentMethodCountry/Bahamas')
insert into #countryMap (shortName, enumName) values ('19', 'metratech.com/paymentserver/PaymentMethodCountry/Bahrain')
insert into #countryMap (shortName, enumName) values ('20', 'metratech.com/paymentserver/PaymentMethodCountry/Bangladesh')
insert into #countryMap (shortName, enumName) values ('21', 'metratech.com/paymentserver/PaymentMethodCountry/Barbados')
insert into #countryMap (shortName, enumName) values ('22', 'metratech.com/paymentserver/PaymentMethodCountry/Belarus')
insert into #countryMap (shortName, enumName) values ('23', 'metratech.com/paymentserver/PaymentMethodCountry/Belgium')
insert into #countryMap (shortName, enumName) values ('24', 'metratech.com/paymentserver/PaymentMethodCountry/Belize')
insert into #countryMap (shortName, enumName) values ('25', 'metratech.com/paymentserver/PaymentMethodCountry/Benin')
insert into #countryMap (shortName, enumName) values ('224', 'metratech.com/paymentserver/PaymentMethodCountry/Bermuda')
insert into #countryMap (shortName, enumName) values ('26', 'metratech.com/paymentserver/PaymentMethodCountry/Bhutan')
insert into #countryMap (shortName, enumName) values ('27', 'metratech.com/paymentserver/PaymentMethodCountry/Bolivia')
insert into #countryMap (shortName, enumName) values ('28', 'metratech.com/paymentserver/PaymentMethodCountry/Bosnia/Hercegovina')
insert into #countryMap (shortName, enumName) values ('29', 'metratech.com/paymentserver/PaymentMethodCountry/Botswana')
insert into #countryMap (shortName, enumName) values ('30', 'metratech.com/paymentserver/PaymentMethodCountry/Brazil')
insert into #countryMap (shortName, enumName) values ('31', 'metratech.com/paymentserver/PaymentMethodCountry/British Virgin Islands')
insert into #countryMap (shortName, enumName) values ('32', 'metratech.com/paymentserver/PaymentMethodCountry/Brunei')
insert into #countryMap (shortName, enumName) values ('33', 'metratech.com/paymentserver/PaymentMethodCountry/Bulgaria')
insert into #countryMap (shortName, enumName) values ('34', 'metratech.com/paymentserver/PaymentMethodCountry/Burkina Faso')
insert into #countryMap (shortName, enumName) values ('35', 'metratech.com/paymentserver/PaymentMethodCountry/Burundi')
insert into #countryMap (shortName, enumName) values ('37', 'metratech.com/paymentserver/PaymentMethodCountry/Cambodia')
insert into #countryMap (shortName, enumName) values ('38', 'metratech.com/paymentserver/PaymentMethodCountry/Cameroon')
insert into #countryMap (shortName, enumName) values ('39', 'metratech.com/paymentserver/PaymentMethodCountry/Canada')
insert into #countryMap (shortName, enumName) values ('40', 'metratech.com/paymentserver/PaymentMethodCountry/Cape Verde Islands')
insert into #countryMap (shortName, enumName) values ('41', 'metratech.com/paymentserver/PaymentMethodCountry/Cayman Islands')
insert into #countryMap (shortName, enumName) values ('42', 'metratech.com/paymentserver/PaymentMethodCountry/Central African Republic')
insert into #countryMap (shortName, enumName) values ('43', 'metratech.com/paymentserver/PaymentMethodCountry/Chad Republic')
insert into #countryMap (shortName, enumName) values ('44', 'metratech.com/paymentserver/PaymentMethodCountry/Chile')
insert into #countryMap (shortName, enumName) values ('45', 'metratech.com/paymentserver/PaymentMethodCountry/China')
insert into #countryMap (shortName, enumName) values ('225', 'metratech.com/paymentserver/PaymentMethodCountry/Christmas Island')
insert into #countryMap (shortName, enumName) values ('46', 'metratech.com/paymentserver/PaymentMethodCountry/Colombia')
insert into #countryMap (shortName, enumName) values ('47', 'metratech.com/paymentserver/PaymentMethodCountry/Comoros')
insert into #countryMap (shortName, enumName) values ('48', 'metratech.com/paymentserver/PaymentMethodCountry/Congo')
insert into #countryMap (shortName, enumName) values ('49', 'metratech.com/paymentserver/PaymentMethodCountry/Cook Islands')
insert into #countryMap (shortName, enumName) values ('50', 'metratech.com/paymentserver/PaymentMethodCountry/Costa Rica')
insert into #countryMap (shortName, enumName) values ('51', 'metratech.com/paymentserver/PaymentMethodCountry/Croatia')
insert into #countryMap (shortName, enumName) values ('52', 'metratech.com/paymentserver/PaymentMethodCountry/Cuba')
insert into #countryMap (shortName, enumName) values ('53', 'metratech.com/paymentserver/PaymentMethodCountry/Cyprus')
insert into #countryMap (shortName, enumName) values ('54', 'metratech.com/paymentserver/PaymentMethodCountry/Czech Republic')
insert into #countryMap (shortName, enumName) values ('55', 'metratech.com/paymentserver/PaymentMethodCountry/Denmark')
insert into #countryMap (shortName, enumName) values ('57', 'metratech.com/paymentserver/PaymentMethodCountry/Djibouti')
insert into #countryMap (shortName, enumName) values ('58', 'metratech.com/paymentserver/PaymentMethodCountry/Dominica')
insert into #countryMap (shortName, enumName) values ('59', 'metratech.com/paymentserver/PaymentMethodCountry/Dominican Republic')
insert into #countryMap (shortName, enumName) values ('60', 'metratech.com/paymentserver/PaymentMethodCountry/Ecuador')
insert into #countryMap (shortName, enumName) values ('61', 'metratech.com/paymentserver/PaymentMethodCountry/Egypt')
insert into #countryMap (shortName, enumName) values ('62', 'metratech.com/paymentserver/PaymentMethodCountry/El Salvador')
insert into #countryMap (shortName, enumName) values ('63', 'metratech.com/paymentserver/PaymentMethodCountry/Equatorial Guinea')
insert into #countryMap (shortName, enumName) values ('64', 'metratech.com/paymentserver/PaymentMethodCountry/Eritrea')
insert into #countryMap (shortName, enumName) values ('65', 'metratech.com/paymentserver/PaymentMethodCountry/Estonia')
insert into #countryMap (shortName, enumName) values ('66', 'metratech.com/paymentserver/PaymentMethodCountry/Ethiopia')
insert into #countryMap (shortName, enumName) values ('67', 'metratech.com/paymentserver/PaymentMethodCountry/Faeroe Islands')
insert into #countryMap (shortName, enumName) values ('68', 'metratech.com/paymentserver/PaymentMethodCountry/Falkland Islands')
insert into #countryMap (shortName, enumName) values ('69', 'metratech.com/paymentserver/PaymentMethodCountry/Fiji Islands')
insert into #countryMap (shortName, enumName) values ('70', 'metratech.com/paymentserver/PaymentMethodCountry/Finland')
insert into #countryMap (shortName, enumName) values ('71', 'metratech.com/paymentserver/PaymentMethodCountry/France')
insert into #countryMap (shortName, enumName) values ('72', 'metratech.com/paymentserver/PaymentMethodCountry/French Antilles')
insert into #countryMap (shortName, enumName) values ('73', 'metratech.com/paymentserver/PaymentMethodCountry/French Guiana')
insert into #countryMap (shortName, enumName) values ('74', 'metratech.com/paymentserver/PaymentMethodCountry/French Polynesia')
insert into #countryMap (shortName, enumName) values ('75', 'metratech.com/paymentserver/PaymentMethodCountry/Gabon')
insert into #countryMap (shortName, enumName) values ('76', 'metratech.com/paymentserver/PaymentMethodCountry/Gambia')
insert into #countryMap (shortName, enumName) values ('77', 'metratech.com/paymentserver/PaymentMethodCountry/Georgia')
insert into #countryMap (shortName, enumName) values ('78', 'metratech.com/paymentserver/PaymentMethodCountry/Germany')
insert into #countryMap (shortName, enumName) values ('79', 'metratech.com/paymentserver/PaymentMethodCountry/Ghana')
insert into #countryMap (shortName, enumName) values ('80', 'metratech.com/paymentserver/PaymentMethodCountry/Gibraltar')
insert into #countryMap (shortName, enumName) values ('81', 'metratech.com/paymentserver/PaymentMethodCountry/Grenada')
insert into #countryMap (shortName, enumName) values ('82', 'metratech.com/paymentserver/PaymentMethodCountry/Greece')
insert into #countryMap (shortName, enumName) values ('83', 'metratech.com/paymentserver/PaymentMethodCountry/Greenland')
insert into #countryMap (shortName, enumName) values ('84', 'metratech.com/paymentserver/PaymentMethodCountry/Guadeloupe')
insert into #countryMap (shortName, enumName) values ('85', 'metratech.com/paymentserver/PaymentMethodCountry/Guam')
insert into #countryMap (shortName, enumName) values ('87', 'metratech.com/paymentserver/PaymentMethodCountry/Guatemala')
insert into #countryMap (shortName, enumName) values ('88', 'metratech.com/paymentserver/PaymentMethodCountry/Guinea')
insert into #countryMap (shortName, enumName) values ('89', 'metratech.com/paymentserver/PaymentMethodCountry/Guinea-Bissau')
insert into #countryMap (shortName, enumName) values ('90', 'metratech.com/paymentserver/PaymentMethodCountry/Guyana')
insert into #countryMap (shortName, enumName) values ('91', 'metratech.com/paymentserver/PaymentMethodCountry/Haiti')
insert into #countryMap (shortName, enumName) values ('92', 'metratech.com/paymentserver/PaymentMethodCountry/Honduras')
insert into #countryMap (shortName, enumName) values ('93', 'metratech.com/paymentserver/PaymentMethodCountry/Hong Kong')
insert into #countryMap (shortName, enumName) values ('94', 'metratech.com/paymentserver/PaymentMethodCountry/Hungary')
insert into #countryMap (shortName, enumName) values ('95', 'metratech.com/paymentserver/PaymentMethodCountry/Iceland')
insert into #countryMap (shortName, enumName) values ('96', 'metratech.com/paymentserver/PaymentMethodCountry/India')
insert into #countryMap (shortName, enumName) values ('97', 'metratech.com/paymentserver/PaymentMethodCountry/Indonesia')
insert into #countryMap (shortName, enumName) values ('98', 'metratech.com/paymentserver/PaymentMethodCountry/Iran')
insert into #countryMap (shortName, enumName) values ('99', 'metratech.com/paymentserver/PaymentMethodCountry/Iraq')
insert into #countryMap (shortName, enumName) values ('100', 'metratech.com/paymentserver/PaymentMethodCountry/Ireland')
insert into #countryMap (shortName, enumName) values ('101', 'metratech.com/paymentserver/PaymentMethodCountry/Israel')
insert into #countryMap (shortName, enumName) values ('102', 'metratech.com/paymentserver/PaymentMethodCountry/Italy')
insert into #countryMap (shortName, enumName) values ('103', 'metratech.com/paymentserver/PaymentMethodCountry/Ivory Coast')
insert into #countryMap (shortName, enumName) values ('104', 'metratech.com/paymentserver/PaymentMethodCountry/Jamaica')
insert into #countryMap (shortName, enumName) values ('105', 'metratech.com/paymentserver/PaymentMethodCountry/Japan')
insert into #countryMap (shortName, enumName) values ('106', 'metratech.com/paymentserver/PaymentMethodCountry/Jordan')
insert into #countryMap (shortName, enumName) values ('227', 'metratech.com/paymentserver/PaymentMethodCountry/Kazakhstan')
insert into #countryMap (shortName, enumName) values ('107', 'metratech.com/paymentserver/PaymentMethodCountry/Kenya')
insert into #countryMap (shortName, enumName) values ('108', 'metratech.com/paymentserver/PaymentMethodCountry/Kiribati')
insert into #countryMap (shortName, enumName) values ('110', 'metratech.com/paymentserver/PaymentMethodCountry/Kuwait')
insert into #countryMap (shortName, enumName) values ('230', 'metratech.com/paymentserver/PaymentMethodCountry/Kyrgyzstan')
insert into #countryMap (shortName, enumName) values ('111', 'metratech.com/paymentserver/PaymentMethodCountry/Laos')
insert into #countryMap (shortName, enumName) values ('112', 'metratech.com/paymentserver/PaymentMethodCountry/Latvia')
insert into #countryMap (shortName, enumName) values ('113', 'metratech.com/paymentserver/PaymentMethodCountry/Lebanon')
insert into #countryMap (shortName, enumName) values ('114', 'metratech.com/paymentserver/PaymentMethodCountry/Lesotho')
insert into #countryMap (shortName, enumName) values ('115', 'metratech.com/paymentserver/PaymentMethodCountry/Liberia')
insert into #countryMap (shortName, enumName) values ('116', 'metratech.com/paymentserver/PaymentMethodCountry/Libya')
insert into #countryMap (shortName, enumName) values ('117', 'metratech.com/paymentserver/PaymentMethodCountry/Liechtenstein')
insert into #countryMap (shortName, enumName) values ('118', 'metratech.com/paymentserver/PaymentMethodCountry/Lithuania')
insert into #countryMap (shortName, enumName) values ('119', 'metratech.com/paymentserver/PaymentMethodCountry/Luxembourg')
insert into #countryMap (shortName, enumName) values ('120', 'metratech.com/paymentserver/PaymentMethodCountry/Macau')
insert into #countryMap (shortName, enumName) values ('121', 'metratech.com/paymentserver/PaymentMethodCountry/Macedonia')
insert into #countryMap (shortName, enumName) values ('122', 'metratech.com/paymentserver/PaymentMethodCountry/Madagascar')
insert into #countryMap (shortName, enumName) values ('123', 'metratech.com/paymentserver/PaymentMethodCountry/Malawi')
insert into #countryMap (shortName, enumName) values ('124', 'metratech.com/paymentserver/PaymentMethodCountry/Malaysia')
insert into #countryMap (shortName, enumName) values ('125', 'metratech.com/paymentserver/PaymentMethodCountry/Maldives')
insert into #countryMap (shortName, enumName) values ('126', 'metratech.com/paymentserver/PaymentMethodCountry/Mali Republic')
insert into #countryMap (shortName, enumName) values ('127', 'metratech.com/paymentserver/PaymentMethodCountry/Malta')
insert into #countryMap (shortName, enumName) values ('132', 'metratech.com/paymentserver/PaymentMethodCountry/Marshall Islands')
insert into #countryMap (shortName, enumName) values ('133', 'metratech.com/paymentserver/PaymentMethodCountry/Mauritius')
insert into #countryMap (shortName, enumName) values ('134', 'metratech.com/paymentserver/PaymentMethodCountry/Mauritania')
insert into #countryMap (shortName, enumName) values ('135', 'metratech.com/paymentserver/PaymentMethodCountry/Mayotte Island')
insert into #countryMap (shortName, enumName) values ('136', 'metratech.com/paymentserver/PaymentMethodCountry/Mexico')
insert into #countryMap (shortName, enumName) values ('137', 'metratech.com/paymentserver/PaymentMethodCountry/Micronesia')
insert into #countryMap (shortName, enumName) values ('138', 'metratech.com/paymentserver/PaymentMethodCountry/Moldova')
insert into #countryMap (shortName, enumName) values ('139', 'metratech.com/paymentserver/PaymentMethodCountry/Monaco')
insert into #countryMap (shortName, enumName) values ('140', 'metratech.com/paymentserver/PaymentMethodCountry/Mongolia')
insert into #countryMap (shortName, enumName) values ('141', 'metratech.com/paymentserver/PaymentMethodCountry/MontSerrat')
insert into #countryMap (shortName, enumName) values ('142', 'metratech.com/paymentserver/PaymentMethodCountry/Morocco')
insert into #countryMap (shortName, enumName) values ('143', 'metratech.com/paymentserver/PaymentMethodCountry/Mozambique')
insert into #countryMap (shortName, enumName) values ('144', 'metratech.com/paymentserver/PaymentMethodCountry/Myanmar')
insert into #countryMap (shortName, enumName) values ('145', 'metratech.com/paymentserver/PaymentMethodCountry/Namibia')
insert into #countryMap (shortName, enumName) values ('146', 'metratech.com/paymentserver/PaymentMethodCountry/Nauru')
insert into #countryMap (shortName, enumName) values ('147', 'metratech.com/paymentserver/PaymentMethodCountry/Nepal')
insert into #countryMap (shortName, enumName) values ('148', 'metratech.com/paymentserver/PaymentMethodCountry/Netherlands')
insert into #countryMap (shortName, enumName) values ('149', 'metratech.com/paymentserver/PaymentMethodCountry/Netherlands Antilles')
insert into #countryMap (shortName, enumName) values ('150', 'metratech.com/paymentserver/PaymentMethodCountry/New Caledonia')
insert into #countryMap (shortName, enumName) values ('151', 'metratech.com/paymentserver/PaymentMethodCountry/New Zealand')
insert into #countryMap (shortName, enumName) values ('152', 'metratech.com/paymentserver/PaymentMethodCountry/Nicaragua')
insert into #countryMap (shortName, enumName) values ('153', 'metratech.com/paymentserver/PaymentMethodCountry/Niger Republic')
insert into #countryMap (shortName, enumName) values ('154', 'metratech.com/paymentserver/PaymentMethodCountry/Nigeria')
insert into #countryMap (shortName, enumName) values ('155', 'metratech.com/paymentserver/PaymentMethodCountry/Niue')
insert into #countryMap (shortName, enumName) values ('231', 'metratech.com/paymentserver/PaymentMethodCountry/Norfolk Island')
insert into #countryMap (shortName, enumName) values ('156', 'metratech.com/paymentserver/PaymentMethodCountry/Norway')
insert into #countryMap (shortName, enumName) values ('228', 'metratech.com/paymentserver/PaymentMethodCountry/North Korea')
insert into #countryMap (shortName, enumName) values ('157', 'metratech.com/paymentserver/PaymentMethodCountry/Oman')
insert into #countryMap (shortName, enumName) values ('158', 'metratech.com/paymentserver/PaymentMethodCountry/Pakistan')
insert into #countryMap (shortName, enumName) values ('159', 'metratech.com/paymentserver/PaymentMethodCountry/Palau')
insert into #countryMap (shortName, enumName) values ('226', 'metratech.com/paymentserver/PaymentMethodCountry/Palestine')
insert into #countryMap (shortName, enumName) values ('160', 'metratech.com/paymentserver/PaymentMethodCountry/Panama')
insert into #countryMap (shortName, enumName) values ('161', 'metratech.com/paymentserver/PaymentMethodCountry/Papua New Guinea')
insert into #countryMap (shortName, enumName) values ('162', 'metratech.com/paymentserver/PaymentMethodCountry/Paraguay')
insert into #countryMap (shortName, enumName) values ('163', 'metratech.com/paymentserver/PaymentMethodCountry/Peru')
insert into #countryMap (shortName, enumName) values ('164', 'metratech.com/paymentserver/PaymentMethodCountry/Philippines')
insert into #countryMap (shortName, enumName) values ('165', 'metratech.com/paymentserver/PaymentMethodCountry/Poland')
insert into #countryMap (shortName, enumName) values ('166', 'metratech.com/paymentserver/PaymentMethodCountry/Portugal')
insert into #countryMap (shortName, enumName) values ('167', 'metratech.com/paymentserver/PaymentMethodCountry/Puerto Rico')
insert into #countryMap (shortName, enumName) values ('168', 'metratech.com/paymentserver/PaymentMethodCountry/Qatar')
insert into #countryMap (shortName, enumName) values ('169', 'metratech.com/paymentserver/PaymentMethodCountry/Reunion Island')
insert into #countryMap (shortName, enumName) values ('170', 'metratech.com/paymentserver/PaymentMethodCountry/Romania')
insert into #countryMap (shortName, enumName) values ('232', 'metratech.com/paymentserver/PaymentMethodCountry/Russia')
insert into #countryMap (shortName, enumName) values ('171', 'metratech.com/paymentserver/PaymentMethodCountry/Rwanda')
insert into #countryMap (shortName, enumName) values ('173', 'metratech.com/paymentserver/PaymentMethodCountry/San Marino')
insert into #countryMap (shortName, enumName) values ('174', 'metratech.com/paymentserver/PaymentMethodCountry/Sao Tome')
insert into #countryMap (shortName, enumName) values ('175', 'metratech.com/paymentserver/PaymentMethodCountry/Saudi Arabia')
insert into #countryMap (shortName, enumName) values ('176', 'metratech.com/paymentserver/PaymentMethodCountry/Senegal Republic')
insert into #countryMap (shortName, enumName) values ('177', 'metratech.com/paymentserver/PaymentMethodCountry/Serbia/Montenegro')
insert into #countryMap (shortName, enumName) values ('178', 'metratech.com/paymentserver/PaymentMethodCountry/Seychelles Islands')
insert into #countryMap (shortName, enumName) values ('179', 'metratech.com/paymentserver/PaymentMethodCountry/Sierra Leone')
insert into #countryMap (shortName, enumName) values ('180', 'metratech.com/paymentserver/PaymentMethodCountry/Singapore')
insert into #countryMap (shortName, enumName) values ('181', 'metratech.com/paymentserver/PaymentMethodCountry/Slovakia')
insert into #countryMap (shortName, enumName) values ('182', 'metratech.com/paymentserver/PaymentMethodCountry/Slovenia')
insert into #countryMap (shortName, enumName) values ('183', 'metratech.com/paymentserver/PaymentMethodCountry/Solomon Islands')
insert into #countryMap (shortName, enumName) values ('233', 'metratech.com/paymentserver/PaymentMethodCountry/Somalia')
insert into #countryMap (shortName, enumName) values ('184', 'metratech.com/paymentserver/PaymentMethodCountry/South Africa')
insert into #countryMap (shortName, enumName) values ('229', 'metratech.com/paymentserver/PaymentMethodCountry/South Korea')
insert into #countryMap (shortName, enumName) values ('185', 'metratech.com/paymentserver/PaymentMethodCountry/Spain')
insert into #countryMap (shortName, enumName) values ('186', 'metratech.com/paymentserver/PaymentMethodCountry/Sri Lanka')
insert into #countryMap (shortName, enumName) values ('187', 'metratech.com/paymentserver/PaymentMethodCountry/St Helena')
insert into #countryMap (shortName, enumName) values ('188', 'metratech.com/paymentserver/PaymentMethodCountry/St. Kitts/Nevis')
insert into #countryMap (shortName, enumName) values ('189', 'metratech.com/paymentserver/PaymentMethodCountry/St. Lucia')
insert into #countryMap (shortName, enumName) values ('190', 'metratech.com/paymentserver/PaymentMethodCountry/St. Pierre/Miquelon')
insert into #countryMap (shortName, enumName) values ('191', 'metratech.com/paymentserver/PaymentMethodCountry/St. Vincent/Grenadines')
insert into #countryMap (shortName, enumName) values ('234', 'metratech.com/paymentserver/PaymentMethodCountry/Sudan')
insert into #countryMap (shortName, enumName) values ('192', 'metratech.com/paymentserver/PaymentMethodCountry/Suriname')
insert into #countryMap (shortName, enumName) values ('193', 'metratech.com/paymentserver/PaymentMethodCountry/Swaziland')
insert into #countryMap (shortName, enumName) values ('194', 'metratech.com/paymentserver/PaymentMethodCountry/Sweden')
insert into #countryMap (shortName, enumName) values ('195', 'metratech.com/paymentserver/PaymentMethodCountry/Switzerland')
insert into #countryMap (shortName, enumName) values ('196', 'metratech.com/paymentserver/PaymentMethodCountry/Syria')
insert into #countryMap (shortName, enumName) values ('197', 'metratech.com/paymentserver/PaymentMethodCountry/Thailand')
insert into #countryMap (shortName, enumName) values ('198', 'metratech.com/paymentserver/PaymentMethodCountry/Taiwan')
insert into #countryMap (shortName, enumName) values ('235', 'metratech.com/paymentserver/PaymentMethodCountry/Tajikistan')
insert into #countryMap (shortName, enumName) values ('199', 'metratech.com/paymentserver/PaymentMethodCountry/Tanzania')
insert into #countryMap (shortName, enumName) values ('236', 'metratech.com/paymentserver/PaymentMethodCountry/Togo')
insert into #countryMap (shortName, enumName) values ('200', 'metratech.com/paymentserver/PaymentMethodCountry/Tonga Islands')
insert into #countryMap (shortName, enumName) values ('201', 'metratech.com/paymentserver/PaymentMethodCountry/Tongolese Republic')
insert into #countryMap (shortName, enumName) values ('202', 'metratech.com/paymentserver/PaymentMethodCountry/Trinidad/Tobago')
insert into #countryMap (shortName, enumName) values ('203', 'metratech.com/paymentserver/PaymentMethodCountry/Tunisia')
insert into #countryMap (shortName, enumName) values ('204', 'metratech.com/paymentserver/PaymentMethodCountry/Turkey')
insert into #countryMap (shortName, enumName) values ('237', 'metratech.com/paymentserver/PaymentMethodCountry/Turkmenistan')
insert into #countryMap (shortName, enumName) values ('205', 'metratech.com/paymentserver/PaymentMethodCountry/Turks/Caicos Islands')
insert into #countryMap (shortName, enumName) values ('206', 'metratech.com/paymentserver/PaymentMethodCountry/Tuvalu')
insert into #countryMap (shortName, enumName) values ('207', 'metratech.com/paymentserver/PaymentMethodCountry/US Virgin Islands')
insert into #countryMap (shortName, enumName) values ('208', 'metratech.com/paymentserver/PaymentMethodCountry/USA')
insert into #countryMap (shortName, enumName) values ('209', 'metratech.com/paymentserver/PaymentMethodCountry/Uganda')
insert into #countryMap (shortName, enumName) values ('210', 'metratech.com/paymentserver/PaymentMethodCountry/Ukraine')
insert into #countryMap (shortName, enumName) values ('211', 'metratech.com/paymentserver/PaymentMethodCountry/United Arab Emirates')
insert into #countryMap (shortName, enumName) values ('212', 'metratech.com/paymentserver/PaymentMethodCountry/United Kingdom')
insert into #countryMap (shortName, enumName) values ('213', 'metratech.com/paymentserver/PaymentMethodCountry/Uruguay')
insert into #countryMap (shortName, enumName) values ('238', 'metratech.com/paymentserver/PaymentMethodCountry/Uzbekistan')
insert into #countryMap (shortName, enumName) values ('214', 'metratech.com/paymentserver/PaymentMethodCountry/Vanuatu')
insert into #countryMap (shortName, enumName) values ('215', 'metratech.com/paymentserver/PaymentMethodCountry/Vatican City')
insert into #countryMap (shortName, enumName) values ('216', 'metratech.com/paymentserver/PaymentMethodCountry/Venezuela')
insert into #countryMap (shortName, enumName) values ('217', 'metratech.com/paymentserver/PaymentMethodCountry/Vietnam')
insert into #countryMap (shortName, enumName) values ('218', 'metratech.com/paymentserver/PaymentMethodCountry/Wallis/Futuna Islands')
insert into #countryMap (shortName, enumName) values ('219', 'metratech.com/paymentserver/PaymentMethodCountry/Western Samoa')
insert into #countryMap (shortName, enumName) values ('220', 'metratech.com/paymentserver/PaymentMethodCountry/Yemen')
insert into #countryMap (shortName, enumName) values ('221', 'metratech.com/paymentserver/PaymentMethodCountry/Zaire')
insert into #countryMap (shortName, enumName) values ('222', 'metratech.com/paymentserver/PaymentMethodCountry/Zimbabwe')
insert into #countryMap (shortName, enumName) values ('223', 'metratech.com/paymentserver/PaymentMethodCountry/Zambia')
GO

-- Lock the table so that we can do our work in peace
select * from t_ps_creditcard with(TABLOCKX) where 0 = 1
GO

-- Insert data into new t_ps_payment_instrument table
INSERT INTO t_ps_payment_instrument (id_payment_instrument, n_payment_method_type, nm_account_number, nm_first_name, nm_middle_name, nm_last_name, nm_address1, nm_address2, nm_city, nm_state, nm_zip, id_country)
select
	tpc.id_payment_instrument,
	ccEnum.id_enum_data,
	nm_ccnum,
	case when CHARINDEX(' ', nm_customer) > 0 then
			substring(nm_customer, 0, CHARINDEX(' ', nm_customer))
		else nm_customer end as nm_first_name,
		case when CHARINDEX(' ', nm_customer) > 0 and
			CHARINDEX(' ', nm_customer, CHARINDEX(' ', nm_customer) + 1) > 0 then
			substring(nm_customer, CHARINDEX(' ', nm_customer) + 1, CHARINDEX(' ', nm_customer, CHARINDEX(' ', nm_customer) + 1) - (CHARINDEX(' ', nm_customer) + 1))
		else '' end as nm_middle_name,
		case when CHARINDEX(' ', nm_customer) > 0 then
			case when CHARINDEX(' ', nm_customer, CHARINDEX(' ', nm_customer) + 1) > 0 then
				substring(nm_customer, CHARINDEX(' ', nm_customer, CHARINDEX(' ', nm_customer) + 1) + 1, len(nm_customer))
			else
				substring(nm_customer, CHARINDEX(' ', nm_customer) + 1, len(nm_customer))
			end
		else
			nm_customer end as nm_last_name,
	nm_address,
	'', --nm_address2
	nm_city,
	nm_state,
	nm_zip,
	countryEnum.id_enum_data
from
	t_ps_creditcard2 tpc
	inner join
	#countryMap on nm_country = shortName
	inner join
	t_enum_data countryEnum on enumName = countryEnum.nm_enum_data,
	t_enum_data ccEnum	
where
	ccEnum.nm_enum_data = 'metratech.com/paymentserver/PaymentType/Credit Card'
GO

drop table #countryMap
GO

-- Insert data into new t_ps_credit_card table
INSERT INTO t_ps_credit_card (id_payment_instrument, n_credit_card_type, nm_expirationdt, nm_expirationdt_format, nm_startdate, nm_issuernumber)
select
	id_payment_instrument,
        enum_map.id_enum_data_new,
	nm_expdate,
	id_expdatef,
	nm_startdate,
	nm_issuernumber
from
	t_ps_creditcard2,
	(
        select old.id_enum_data id_enum_data_old, new.id_enum_data id_enum_data_new
        from 
            (
            select 
              'metratech.com/paymentserver/CreditCardType/American Express' nm_old,
              'metratech.com/CreditCardType/American Express' nm_new
            union
            select
              'metratech.com/paymentserver/CreditCardType/Discover',
              'metratech.com/CreditCardType/Discover'
            union
            select
              'metratech.com/paymentserver/CreditCardType/Visa',
              'metratech.com/CreditCardType/Visa'
            union
            select
              'metratech.com/paymentserver/CreditCardType/MasterCard',
              'metratech.com/CreditCardType/Master Card'
            union
            select
              'metratech.com/paymentserver/CreditCardType/Diners Club',
              'metratech.com/CreditCardType/Diners Club'
            union 
            select
              'metratech.com/paymentserver/CreditCardType/JCB',
              'metratech.com/CreditCardType/JCB'
            union
            select
              'metratech.com/paymentserver/CreditCardType/Maestro',
              'metratech.com/CreditCardType/Maestro'          
            ) name_map
            LEFT OUTER JOIN t_enum_data old ON old.nm_enum_data = name_map.nm_old
            LEFT OUTER JOIN t_enum_data new ON new.nm_enum_data = name_map.nm_new
        ) enum_map
where
  enum_map.id_enum_data_old = id_creditCardType
GO

ALTER TABLE %%NETMETER%%..t_payment_instrument ALTER COLUMN tx_hash nvarchar(255) NULL
GO

INSERT INTO %%NETMETER%%..t_payment_instrument
(
      id_payment_instrument,
      id_acct,
      n_payment_method_type,
      nm_truncd_acct_num,
      tx_hash,
      id_creditcard_type,
      n_account_type,
      nm_exp_date,
      nm_exp_date_format,
      nm_first_name,
      nm_middle_name,
      nm_last_name,
      nm_address1,
      nm_address2,
      nm_city,
      nm_state,
      nm_zip,
      id_country,
      id_priority,
      n_max_charge_per_cycle,
      dt_created
)
SELECT 
      tppi.id_payment_instrument,
      tpc.id_acc, --id_acct
      (	select id_enum_data 
        from %%NETMETER%%..t_enum_data 
        where nm_enum_data = 'metratech.com/paymentserver/PaymentType/Credit Card'
      ),  --tppi.n_payment_method_type,
      '************'+tpc.nm_lastfourdigits, --nm_truncd_acct_num
      NULL, --tx_hash, use tool to populate
      enum_map.id_enum_data_new,  -- id_creditcard_type
      NULL, --n_account_type
      tpcc.nm_expirationdt,
      tpcc.nm_expirationdt_format,
      tppi.nm_first_name,
      tppi.nm_middle_name,
      tppi.nm_last_name,
      tppi.nm_address1,
      tppi.nm_address2,
      tppi.nm_city,
      tppi.nm_state,
      tppi.nm_zip,
      tppi.id_country,
      CASE
        WHEN (tpc.nm_primary = 'Y') THEN 1
        ELSE 2
      END , --id_priority
      NULL, -- n_max_charge_per_cycle
      getdate() --dt_created
FROM t_ps_payment_instrument tppi, t_ps_credit_card tpcc, t_ps_creditcard2 tpc,
	(
        select old.id_enum_data id_enum_data_old, new.id_enum_data id_enum_data_new
        from 
            (
            select 
              'metratech.com/paymentserver/CreditCardType/American Express' nm_old,
              'metratech.com/CreditCardType/American Express' nm_new
            union
            select
              'metratech.com/paymentserver/CreditCardType/Discover',
              'metratech.com/CreditCardType/Discover'
            union
            select
              'metratech.com/paymentserver/CreditCardType/Visa',
              'metratech.com/CreditCardType/Visa'
            union
            select
              'metratech.com/paymentserver/CreditCardType/MasterCard',
              'metratech.com/CreditCardType/Master Card'
            union
            select
              'metratech.com/paymentserver/CreditCardType/Diners Club',
              'metratech.com/CreditCardType/Diners Club'
            union 
            select
              'metratech.com/paymentserver/CreditCardType/JCB',
              'metratech.com/CreditCardType/JCB'
            union
            select
              'metratech.com/paymentserver/CreditCardType/Maestro',
              'metratech.com/CreditCardType/Maestro'          
            ) name_map
            LEFT OUTER JOIN t_enum_data old ON old.nm_enum_data = name_map.nm_old
            LEFT OUTER JOIN %%NETMETER%%..t_enum_data new ON new.nm_enum_data = name_map.nm_new
        ) enum_map
WHERE tppi.id_payment_instrument = tpcc.id_payment_instrument
  AND tpc.id_payment_instrument = tppi.id_payment_instrument
  AND enum_map.id_enum_data_old = id_creditCardType

GO
-- Update id_acct in t_payment_instrument with temp acct ID from MetraPay
-- This prevents having to create one when migrating NetMeter..t_payment_instrument_puid_xref
-- and allows this same value to be retrieved in the new t_ps_creditcard view created below
UPDATE %%NETMETER%%..t_payment_instrument set id_acct = id_acc
from
	t_ps_creditcard2 pscc
where
	pscc.id_payment_instrument = t_payment_instrument.id_payment_instrument
	and
	t_payment_instrument.id_acct is NULL
GO

update %%NETMETER%%..t_payment_instrument set id_priority = tmpId
from
	(select id_payment_instrument, id_priority, ROW_NUMBER() over (partition by id_acct order by id_priority) as tmpId 
	   from %%NETMETER%%..t_payment_instrument) t
where
	t_payment_instrument.id_payment_instrument = t.id_payment_instrument
	

DROP TABLE t_ps_creditcard2
GO

-- Rename the table to preserve the data if need be
EXECUTE sp_rename N'dbo.t_ps_creditcard', N't_ps_creditcard_old', 'OBJECT' 
GO

COMMIT