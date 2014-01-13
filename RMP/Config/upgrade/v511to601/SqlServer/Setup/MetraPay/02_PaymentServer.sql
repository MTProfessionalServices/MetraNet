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
	nm_startdate,
	nm_issuernumber,
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

insert into #countryMap (shortName, enumName) values ('AF', 'metratech.com/paymentserver/PaymentMethodCountry/Afghanistan')
insert into #countryMap (shortName, enumName) values ('AL', 'metratech.com/paymentserver/PaymentMethodCountry/Albania')
insert into #countryMap (shortName, enumName) values ('DZ', 'metratech.com/paymentserver/PaymentMethodCountry/Algeria')
insert into #countryMap (shortName, enumName) values ('AS', 'metratech.com/paymentserver/PaymentMethodCountry/American Samoa')
insert into #countryMap (shortName, enumName) values ('AD', 'metratech.com/paymentserver/PaymentMethodCountry/Andorra')
insert into #countryMap (shortName, enumName) values ('AO', 'metratech.com/paymentserver/PaymentMethodCountry/Angola')
insert into #countryMap (shortName, enumName) values ('AI', 'metratech.com/paymentserver/PaymentMethodCountry/Anguilla')
insert into #countryMap (shortName, enumName) values ('AQ', 'metratech.com/paymentserver/PaymentMethodCountry/Antarctica')
insert into #countryMap (shortName, enumName) values ('AG', 'metratech.com/paymentserver/PaymentMethodCountry/Antigua')
insert into #countryMap (shortName, enumName) values ('AR', 'metratech.com/paymentserver/PaymentMethodCountry/Argentina')
insert into #countryMap (shortName, enumName) values ('AM', 'metratech.com/paymentserver/PaymentMethodCountry/Armenia')
insert into #countryMap (shortName, enumName) values ('AW', 'metratech.com/paymentserver/PaymentMethodCountry/Aruba')
insert into #countryMap (shortName, enumName) values ('AU', 'metratech.com/paymentserver/PaymentMethodCountry/Australia')
insert into #countryMap (shortName, enumName) values ('AT', 'metratech.com/paymentserver/PaymentMethodCountry/Austria')
insert into #countryMap (shortName, enumName) values ('AZ', 'metratech.com/paymentserver/PaymentMethodCountry/Azerbaijan')
insert into #countryMap (shortName, enumName) values ('BS', 'metratech.com/paymentserver/PaymentMethodCountry/Bahamas')
insert into #countryMap (shortName, enumName) values ('BH', 'metratech.com/paymentserver/PaymentMethodCountry/Bahrain')
insert into #countryMap (shortName, enumName) values ('BD', 'metratech.com/paymentserver/PaymentMethodCountry/Bangladesh')
insert into #countryMap (shortName, enumName) values ('BB', 'metratech.com/paymentserver/PaymentMethodCountry/Barbados')
insert into #countryMap (shortName, enumName) values ('BY', 'metratech.com/paymentserver/PaymentMethodCountry/Belarus')
insert into #countryMap (shortName, enumName) values ('BE', 'metratech.com/paymentserver/PaymentMethodCountry/Belgium')
insert into #countryMap (shortName, enumName) values ('BZ', 'metratech.com/paymentserver/PaymentMethodCountry/Belize')
insert into #countryMap (shortName, enumName) values ('BJ', 'metratech.com/paymentserver/PaymentMethodCountry/Benin')
insert into #countryMap (shortName, enumName) values ('BM', 'metratech.com/paymentserver/PaymentMethodCountry/Bermuda')
insert into #countryMap (shortName, enumName) values ('BT', 'metratech.com/paymentserver/PaymentMethodCountry/Bhutan')
insert into #countryMap (shortName, enumName) values ('BO', 'metratech.com/paymentserver/PaymentMethodCountry/Bolivia')
insert into #countryMap (shortName, enumName) values ('BA', 'metratech.com/paymentserver/PaymentMethodCountry/Bosnia/Hercegovina')
insert into #countryMap (shortName, enumName) values ('BW', 'metratech.com/paymentserver/PaymentMethodCountry/Botswana')
insert into #countryMap (shortName, enumName) values ('BR', 'metratech.com/paymentserver/PaymentMethodCountry/Brazil')
insert into #countryMap (shortName, enumName) values ('VG', 'metratech.com/paymentserver/PaymentMethodCountry/British Virgin Islands')
insert into #countryMap (shortName, enumName) values ('BN', 'metratech.com/paymentserver/PaymentMethodCountry/Brunei')
insert into #countryMap (shortName, enumName) values ('BG', 'metratech.com/paymentserver/PaymentMethodCountry/Bulgaria')
insert into #countryMap (shortName, enumName) values ('BF', 'metratech.com/paymentserver/PaymentMethodCountry/Burkina Faso')
insert into #countryMap (shortName, enumName) values ('BI', 'metratech.com/paymentserver/PaymentMethodCountry/Burundi')
insert into #countryMap (shortName, enumName) values ('KH', 'metratech.com/paymentserver/PaymentMethodCountry/Cambodia')
insert into #countryMap (shortName, enumName) values ('CM', 'metratech.com/paymentserver/PaymentMethodCountry/Cameroon')
insert into #countryMap (shortName, enumName) values ('CA', 'metratech.com/paymentserver/PaymentMethodCountry/Canada')
insert into #countryMap (shortName, enumName) values ('CV', 'metratech.com/paymentserver/PaymentMethodCountry/Cape Verde Islands')
insert into #countryMap (shortName, enumName) values ('KY', 'metratech.com/paymentserver/PaymentMethodCountry/Cayman Islands')
insert into #countryMap (shortName, enumName) values ('CF', 'metratech.com/paymentserver/PaymentMethodCountry/Central African Republic')
insert into #countryMap (shortName, enumName) values ('TD', 'metratech.com/paymentserver/PaymentMethodCountry/Chad Republic')
insert into #countryMap (shortName, enumName) values ('CL', 'metratech.com/paymentserver/PaymentMethodCountry/Chile')
insert into #countryMap (shortName, enumName) values ('CN', 'metratech.com/paymentserver/PaymentMethodCountry/China')
insert into #countryMap (shortName, enumName) values ('CX', 'metratech.com/paymentserver/PaymentMethodCountry/Christmas Island')
insert into #countryMap (shortName, enumName) values ('CO', 'metratech.com/paymentserver/PaymentMethodCountry/Colombia')
insert into #countryMap (shortName, enumName) values ('KM', 'metratech.com/paymentserver/PaymentMethodCountry/Comoros')
insert into #countryMap (shortName, enumName) values ('CG', 'metratech.com/paymentserver/PaymentMethodCountry/Congo')
insert into #countryMap (shortName, enumName) values ('CK', 'metratech.com/paymentserver/PaymentMethodCountry/Cook Islands')
insert into #countryMap (shortName, enumName) values ('CR', 'metratech.com/paymentserver/PaymentMethodCountry/Costa Rica')
insert into #countryMap (shortName, enumName) values ('HR', 'metratech.com/paymentserver/PaymentMethodCountry/Croatia')
insert into #countryMap (shortName, enumName) values ('CU', 'metratech.com/paymentserver/PaymentMethodCountry/Cuba')
insert into #countryMap (shortName, enumName) values ('CY', 'metratech.com/paymentserver/PaymentMethodCountry/Cyprus')
insert into #countryMap (shortName, enumName) values ('CZ', 'metratech.com/paymentserver/PaymentMethodCountry/Czech Republic')
insert into #countryMap (shortName, enumName) values ('DK', 'metratech.com/paymentserver/PaymentMethodCountry/Denmark')
insert into #countryMap (shortName, enumName) values ('DJ', 'metratech.com/paymentserver/PaymentMethodCountry/Djibouti')
insert into #countryMap (shortName, enumName) values ('DM', 'metratech.com/paymentserver/PaymentMethodCountry/Dominica')
insert into #countryMap (shortName, enumName) values ('DO', 'metratech.com/paymentserver/PaymentMethodCountry/Dominican Republic')
insert into #countryMap (shortName, enumName) values ('EC', 'metratech.com/paymentserver/PaymentMethodCountry/Ecuador')
insert into #countryMap (shortName, enumName) values ('EG', 'metratech.com/paymentserver/PaymentMethodCountry/Egypt')
insert into #countryMap (shortName, enumName) values ('SV', 'metratech.com/paymentserver/PaymentMethodCountry/El Salvador')
insert into #countryMap (shortName, enumName) values ('GQ', 'metratech.com/paymentserver/PaymentMethodCountry/Equatorial Guinea')
insert into #countryMap (shortName, enumName) values ('ER', 'metratech.com/paymentserver/PaymentMethodCountry/Eritrea')
insert into #countryMap (shortName, enumName) values ('EE', 'metratech.com/paymentserver/PaymentMethodCountry/Estonia')
insert into #countryMap (shortName, enumName) values ('ET', 'metratech.com/paymentserver/PaymentMethodCountry/Ethiopia')
insert into #countryMap (shortName, enumName) values ('FO', 'metratech.com/paymentserver/PaymentMethodCountry/Faeroe Islands')
insert into #countryMap (shortName, enumName) values ('FK', 'metratech.com/paymentserver/PaymentMethodCountry/Falkland Islands')
insert into #countryMap (shortName, enumName) values ('FJ', 'metratech.com/paymentserver/PaymentMethodCountry/Fiji Islands')
insert into #countryMap (shortName, enumName) values ('FI', 'metratech.com/paymentserver/PaymentMethodCountry/Finland')
insert into #countryMap (shortName, enumName) values ('FR', 'metratech.com/paymentserver/PaymentMethodCountry/France')
insert into #countryMap (shortName, enumName) values ('TF', 'metratech.com/paymentserver/PaymentMethodCountry/French Antilles')
insert into #countryMap (shortName, enumName) values ('GF', 'metratech.com/paymentserver/PaymentMethodCountry/French Guiana')
insert into #countryMap (shortName, enumName) values ('PF', 'metratech.com/paymentserver/PaymentMethodCountry/French Polynesia')
insert into #countryMap (shortName, enumName) values ('GA', 'metratech.com/paymentserver/PaymentMethodCountry/Gabon')
insert into #countryMap (shortName, enumName) values ('GM', 'metratech.com/paymentserver/PaymentMethodCountry/Gambia')
insert into #countryMap (shortName, enumName) values ('GE', 'metratech.com/paymentserver/PaymentMethodCountry/Georgia')
insert into #countryMap (shortName, enumName) values ('DE', 'metratech.com/paymentserver/PaymentMethodCountry/Germany')
insert into #countryMap (shortName, enumName) values ('GH', 'metratech.com/paymentserver/PaymentMethodCountry/Ghana')
insert into #countryMap (shortName, enumName) values ('GI', 'metratech.com/paymentserver/PaymentMethodCountry/Gibraltar')
insert into #countryMap (shortName, enumName) values ('GD', 'metratech.com/paymentserver/PaymentMethodCountry/Grenada')
insert into #countryMap (shortName, enumName) values ('GR', 'metratech.com/paymentserver/PaymentMethodCountry/Greece')
insert into #countryMap (shortName, enumName) values ('GL', 'metratech.com/paymentserver/PaymentMethodCountry/Greenland')
insert into #countryMap (shortName, enumName) values ('GP', 'metratech.com/paymentserver/PaymentMethodCountry/Guadeloupe')
insert into #countryMap (shortName, enumName) values ('GU', 'metratech.com/paymentserver/PaymentMethodCountry/Guam')
insert into #countryMap (shortName, enumName) values ('GT', 'metratech.com/paymentserver/PaymentMethodCountry/Guatemala')
insert into #countryMap (shortName, enumName) values ('GN', 'metratech.com/paymentserver/PaymentMethodCountry/Guinea')
insert into #countryMap (shortName, enumName) values ('GW', 'metratech.com/paymentserver/PaymentMethodCountry/Guinea-Bissau')
insert into #countryMap (shortName, enumName) values ('GY', 'metratech.com/paymentserver/PaymentMethodCountry/Guyana')
insert into #countryMap (shortName, enumName) values ('HT', 'metratech.com/paymentserver/PaymentMethodCountry/Haiti')
insert into #countryMap (shortName, enumName) values ('HN', 'metratech.com/paymentserver/PaymentMethodCountry/Honduras')
insert into #countryMap (shortName, enumName) values ('HK', 'metratech.com/paymentserver/PaymentMethodCountry/Hong Kong')
insert into #countryMap (shortName, enumName) values ('HU', 'metratech.com/paymentserver/PaymentMethodCountry/Hungary')
insert into #countryMap (shortName, enumName) values ('IS', 'metratech.com/paymentserver/PaymentMethodCountry/Iceland')
insert into #countryMap (shortName, enumName) values ('IN', 'metratech.com/paymentserver/PaymentMethodCountry/India')
insert into #countryMap (shortName, enumName) values ('ID', 'metratech.com/paymentserver/PaymentMethodCountry/Indonesia')
insert into #countryMap (shortName, enumName) values ('IR', 'metratech.com/paymentserver/PaymentMethodCountry/Iran')
insert into #countryMap (shortName, enumName) values ('IQ', 'metratech.com/paymentserver/PaymentMethodCountry/Iraq')
insert into #countryMap (shortName, enumName) values ('IE', 'metratech.com/paymentserver/PaymentMethodCountry/Ireland')
insert into #countryMap (shortName, enumName) values ('IL', 'metratech.com/paymentserver/PaymentMethodCountry/Israel')
insert into #countryMap (shortName, enumName) values ('IT', 'metratech.com/paymentserver/PaymentMethodCountry/Italy')
insert into #countryMap (shortName, enumName) values ('CI', 'metratech.com/paymentserver/PaymentMethodCountry/Ivory Coast')
insert into #countryMap (shortName, enumName) values ('JM', 'metratech.com/paymentserver/PaymentMethodCountry/Jamaica')
insert into #countryMap (shortName, enumName) values ('JP', 'metratech.com/paymentserver/PaymentMethodCountry/Japan')
insert into #countryMap (shortName, enumName) values ('JO', 'metratech.com/paymentserver/PaymentMethodCountry/Jordan')
insert into #countryMap (shortName, enumName) values ('KZ', 'metratech.com/paymentserver/PaymentMethodCountry/Kazakhstan')
insert into #countryMap (shortName, enumName) values ('KE', 'metratech.com/paymentserver/PaymentMethodCountry/Kenya')
insert into #countryMap (shortName, enumName) values ('KI', 'metratech.com/paymentserver/PaymentMethodCountry/Kiribati')
insert into #countryMap (shortName, enumName) values ('KW', 'metratech.com/paymentserver/PaymentMethodCountry/Kuwait')
insert into #countryMap (shortName, enumName) values ('KG', 'metratech.com/paymentserver/PaymentMethodCountry/Kyrgyzstan')
insert into #countryMap (shortName, enumName) values ('lA', 'metratech.com/paymentserver/PaymentMethodCountry/Laos')
insert into #countryMap (shortName, enumName) values ('LV', 'metratech.com/paymentserver/PaymentMethodCountry/Latvia')
insert into #countryMap (shortName, enumName) values ('LB', 'metratech.com/paymentserver/PaymentMethodCountry/Lebanon')
insert into #countryMap (shortName, enumName) values ('LS', 'metratech.com/paymentserver/PaymentMethodCountry/Lesotho')
insert into #countryMap (shortName, enumName) values ('LR', 'metratech.com/paymentserver/PaymentMethodCountry/Liberia')
insert into #countryMap (shortName, enumName) values ('LY', 'metratech.com/paymentserver/PaymentMethodCountry/Libya')
insert into #countryMap (shortName, enumName) values ('LI', 'metratech.com/paymentserver/PaymentMethodCountry/Liechtenstein')
insert into #countryMap (shortName, enumName) values ('LT', 'metratech.com/paymentserver/PaymentMethodCountry/Lithuania')
insert into #countryMap (shortName, enumName) values ('LU', 'metratech.com/paymentserver/PaymentMethodCountry/Luxembourg')
insert into #countryMap (shortName, enumName) values ('MO', 'metratech.com/paymentserver/PaymentMethodCountry/Macau')
insert into #countryMap (shortName, enumName) values ('MK', 'metratech.com/paymentserver/PaymentMethodCountry/Macedonia')
insert into #countryMap (shortName, enumName) values ('MG', 'metratech.com/paymentserver/PaymentMethodCountry/Madagascar')
insert into #countryMap (shortName, enumName) values ('MW', 'metratech.com/paymentserver/PaymentMethodCountry/Malawi')
insert into #countryMap (shortName, enumName) values ('MY', 'metratech.com/paymentserver/PaymentMethodCountry/Malaysia')
insert into #countryMap (shortName, enumName) values ('MV', 'metratech.com/paymentserver/PaymentMethodCountry/Maldives')
insert into #countryMap (shortName, enumName) values ('ML', 'metratech.com/paymentserver/PaymentMethodCountry/Mali Republic')
insert into #countryMap (shortName, enumName) values ('MT', 'metratech.com/paymentserver/PaymentMethodCountry/Malta')
insert into #countryMap (shortName, enumName) values ('MH', 'metratech.com/paymentserver/PaymentMethodCountry/Marshall Islands')
insert into #countryMap (shortName, enumName) values ('MU', 'metratech.com/paymentserver/PaymentMethodCountry/Mauritius')
insert into #countryMap (shortName, enumName) values ('MR', 'metratech.com/paymentserver/PaymentMethodCountry/Mauritania')
insert into #countryMap (shortName, enumName) values ('YT', 'metratech.com/paymentserver/PaymentMethodCountry/Mayotte Island')
insert into #countryMap (shortName, enumName) values ('MX', 'metratech.com/paymentserver/PaymentMethodCountry/Mexico')
insert into #countryMap (shortName, enumName) values ('FM', 'metratech.com/paymentserver/PaymentMethodCountry/Micronesia')
insert into #countryMap (shortName, enumName) values ('MD', 'metratech.com/paymentserver/PaymentMethodCountry/Moldova')
insert into #countryMap (shortName, enumName) values ('MC', 'metratech.com/paymentserver/PaymentMethodCountry/Monaco')
insert into #countryMap (shortName, enumName) values ('MN', 'metratech.com/paymentserver/PaymentMethodCountry/Mongolia')
insert into #countryMap (shortName, enumName) values ('MS', 'metratech.com/paymentserver/PaymentMethodCountry/MontSerrat')
insert into #countryMap (shortName, enumName) values ('MA', 'metratech.com/paymentserver/PaymentMethodCountry/Morocco')
insert into #countryMap (shortName, enumName) values ('MZ', 'metratech.com/paymentserver/PaymentMethodCountry/Mozambique')
insert into #countryMap (shortName, enumName) values ('MM', 'metratech.com/paymentserver/PaymentMethodCountry/Myanmar')
insert into #countryMap (shortName, enumName) values ('NA', 'metratech.com/paymentserver/PaymentMethodCountry/Namibia')
insert into #countryMap (shortName, enumName) values ('NR', 'metratech.com/paymentserver/PaymentMethodCountry/Nauru')
insert into #countryMap (shortName, enumName) values ('NP', 'metratech.com/paymentserver/PaymentMethodCountry/Nepal')
insert into #countryMap (shortName, enumName) values ('NL', 'metratech.com/paymentserver/PaymentMethodCountry/Netherlands')
insert into #countryMap (shortName, enumName) values ('AN', 'metratech.com/paymentserver/PaymentMethodCountry/Netherlands Antilles')
insert into #countryMap (shortName, enumName) values ('NC', 'metratech.com/paymentserver/PaymentMethodCountry/New Caledonia')
insert into #countryMap (shortName, enumName) values ('NZ', 'metratech.com/paymentserver/PaymentMethodCountry/New Zealand')
insert into #countryMap (shortName, enumName) values ('NI', 'metratech.com/paymentserver/PaymentMethodCountry/Nicaragua')
insert into #countryMap (shortName, enumName) values ('NE', 'metratech.com/paymentserver/PaymentMethodCountry/Niger Republic')
insert into #countryMap (shortName, enumName) values ('NG', 'metratech.com/paymentserver/PaymentMethodCountry/Nigeria')
insert into #countryMap (shortName, enumName) values ('NU', 'metratech.com/paymentserver/PaymentMethodCountry/Niue')
insert into #countryMap (shortName, enumName) values ('NF', 'metratech.com/paymentserver/PaymentMethodCountry/Norfolk Island')
insert into #countryMap (shortName, enumName) values ('NO', 'metratech.com/paymentserver/PaymentMethodCountry/Norway')
insert into #countryMap (shortName, enumName) values ('KP', 'metratech.com/paymentserver/PaymentMethodCountry/North Korea')
insert into #countryMap (shortName, enumName) values ('OM', 'metratech.com/paymentserver/PaymentMethodCountry/Oman')
insert into #countryMap (shortName, enumName) values ('PK', 'metratech.com/paymentserver/PaymentMethodCountry/Pakistan')
insert into #countryMap (shortName, enumName) values ('PW', 'metratech.com/paymentserver/PaymentMethodCountry/Palau')
insert into #countryMap (shortName, enumName) values ('PS', 'metratech.com/paymentserver/PaymentMethodCountry/Palestine')
insert into #countryMap (shortName, enumName) values ('PA', 'metratech.com/paymentserver/PaymentMethodCountry/Panama')
insert into #countryMap (shortName, enumName) values ('PG', 'metratech.com/paymentserver/PaymentMethodCountry/Papua New Guinea')
insert into #countryMap (shortName, enumName) values ('PY', 'metratech.com/paymentserver/PaymentMethodCountry/Paraguay')
insert into #countryMap (shortName, enumName) values ('PE', 'metratech.com/paymentserver/PaymentMethodCountry/Peru')
insert into #countryMap (shortName, enumName) values ('PH', 'metratech.com/paymentserver/PaymentMethodCountry/Philippines')
insert into #countryMap (shortName, enumName) values ('PL', 'metratech.com/paymentserver/PaymentMethodCountry/Poland')
insert into #countryMap (shortName, enumName) values ('PT', 'metratech.com/paymentserver/PaymentMethodCountry/Portugal')
insert into #countryMap (shortName, enumName) values ('PR', 'metratech.com/paymentserver/PaymentMethodCountry/Puerto Rico')
insert into #countryMap (shortName, enumName) values ('QA', 'metratech.com/paymentserver/PaymentMethodCountry/Qatar')
insert into #countryMap (shortName, enumName) values ('RE', 'metratech.com/paymentserver/PaymentMethodCountry/Reunion Island')
insert into #countryMap (shortName, enumName) values ('RO', 'metratech.com/paymentserver/PaymentMethodCountry/Romania')
insert into #countryMap (shortName, enumName) values ('RU', 'metratech.com/paymentserver/PaymentMethodCountry/Russia')
insert into #countryMap (shortName, enumName) values ('RW', 'metratech.com/paymentserver/PaymentMethodCountry/Rwanda')
insert into #countryMap (shortName, enumName) values ('SM', 'metratech.com/paymentserver/PaymentMethodCountry/San Marino')
insert into #countryMap (shortName, enumName) values ('ST', 'metratech.com/paymentserver/PaymentMethodCountry/Sao Tome')
insert into #countryMap (shortName, enumName) values ('SA', 'metratech.com/paymentserver/PaymentMethodCountry/Saudi Arabia')
insert into #countryMap (shortName, enumName) values ('SN', 'metratech.com/paymentserver/PaymentMethodCountry/Senegal Republic')
insert into #countryMap (shortName, enumName) values ('ME', 'metratech.com/paymentserver/PaymentMethodCountry/Serbia/Montenegro')
insert into #countryMap (shortName, enumName) values ('SC', 'metratech.com/paymentserver/PaymentMethodCountry/Seychelles Islands')
insert into #countryMap (shortName, enumName) values ('SL', 'metratech.com/paymentserver/PaymentMethodCountry/Sierra Leone')
insert into #countryMap (shortName, enumName) values ('SG', 'metratech.com/paymentserver/PaymentMethodCountry/Singapore')
insert into #countryMap (shortName, enumName) values ('SK', 'metratech.com/paymentserver/PaymentMethodCountry/Slovakia')
insert into #countryMap (shortName, enumName) values ('SI', 'metratech.com/paymentserver/PaymentMethodCountry/Slovenia')
insert into #countryMap (shortName, enumName) values ('SB', 'metratech.com/paymentserver/PaymentMethodCountry/Solomon Islands')
insert into #countryMap (shortName, enumName) values ('SO', 'metratech.com/paymentserver/PaymentMethodCountry/Somalia')
insert into #countryMap (shortName, enumName) values ('ZA', 'metratech.com/paymentserver/PaymentMethodCountry/South Africa')
insert into #countryMap (shortName, enumName) values ('KR', 'metratech.com/paymentserver/PaymentMethodCountry/South Korea')
insert into #countryMap (shortName, enumName) values ('ES', 'metratech.com/paymentserver/PaymentMethodCountry/Spain')
insert into #countryMap (shortName, enumName) values ('LK', 'metratech.com/paymentserver/PaymentMethodCountry/Sri Lanka')
insert into #countryMap (shortName, enumName) values ('SH', 'metratech.com/paymentserver/PaymentMethodCountry/St Helena')
insert into #countryMap (shortName, enumName) values ('KN', 'metratech.com/paymentserver/PaymentMethodCountry/St. Kitts/Nevis')
insert into #countryMap (shortName, enumName) values ('LC', 'metratech.com/paymentserver/PaymentMethodCountry/St. Lucia')
insert into #countryMap (shortName, enumName) values ('PM', 'metratech.com/paymentserver/PaymentMethodCountry/St. Pierre/Miquelon')
insert into #countryMap (shortName, enumName) values ('VC', 'metratech.com/paymentserver/PaymentMethodCountry/St. Vincent/Grenadines')
insert into #countryMap (shortName, enumName) values ('SD', 'metratech.com/paymentserver/PaymentMethodCountry/Sudan')
insert into #countryMap (shortName, enumName) values ('SR', 'metratech.com/paymentserver/PaymentMethodCountry/Suriname')
insert into #countryMap (shortName, enumName) values ('SZ', 'metratech.com/paymentserver/PaymentMethodCountry/Swaziland')
insert into #countryMap (shortName, enumName) values ('SE', 'metratech.com/paymentserver/PaymentMethodCountry/Sweden')
insert into #countryMap (shortName, enumName) values ('CH', 'metratech.com/paymentserver/PaymentMethodCountry/Switzerland')
insert into #countryMap (shortName, enumName) values ('SY', 'metratech.com/paymentserver/PaymentMethodCountry/Syria')
insert into #countryMap (shortName, enumName) values ('TH', 'metratech.com/paymentserver/PaymentMethodCountry/Thailand')
insert into #countryMap (shortName, enumName) values ('TW', 'metratech.com/paymentserver/PaymentMethodCountry/Taiwan')
insert into #countryMap (shortName, enumName) values ('TJ', 'metratech.com/paymentserver/PaymentMethodCountry/Tajikistan')
insert into #countryMap (shortName, enumName) values ('TZ', 'metratech.com/paymentserver/PaymentMethodCountry/Tanzania')
insert into #countryMap (shortName, enumName) values ('TG', 'metratech.com/paymentserver/PaymentMethodCountry/Togo')
insert into #countryMap (shortName, enumName) values ('TO', 'metratech.com/paymentserver/PaymentMethodCountry/Tonga Islands')
insert into #countryMap (shortName, enumName) values ('201', 'metratech.com/paymentserver/PaymentMethodCountry/Tongolese Republic')
insert into #countryMap (shortName, enumName) values ('TT', 'metratech.com/paymentserver/PaymentMethodCountry/Trinidad/Tobago')
insert into #countryMap (shortName, enumName) values ('TN', 'metratech.com/paymentserver/PaymentMethodCountry/Tunisia')
insert into #countryMap (shortName, enumName) values ('TR', 'metratech.com/paymentserver/PaymentMethodCountry/Turkey')
insert into #countryMap (shortName, enumName) values ('TM', 'metratech.com/paymentserver/PaymentMethodCountry/Turkmenistan')
insert into #countryMap (shortName, enumName) values ('TC', 'metratech.com/paymentserver/PaymentMethodCountry/Turks/Caicos Islands')
insert into #countryMap (shortName, enumName) values ('TV', 'metratech.com/paymentserver/PaymentMethodCountry/Tuvalu')
insert into #countryMap (shortName, enumName) values ('VI', 'metratech.com/paymentserver/PaymentMethodCountry/US Virgin Islands')
insert into #countryMap (shortName, enumName) values ('US', 'metratech.com/paymentserver/PaymentMethodCountry/USA')
insert into #countryMap (shortName, enumName) values ('USA', 'metratech.com/paymentserver/PaymentMethodCountry/USA')
insert into #countryMap (shortName, enumName) values ('UG', 'metratech.com/paymentserver/PaymentMethodCountry/Uganda')
insert into #countryMap (shortName, enumName) values ('UA', 'metratech.com/paymentserver/PaymentMethodCountry/Ukraine')
insert into #countryMap (shortName, enumName) values ('AE', 'metratech.com/paymentserver/PaymentMethodCountry/United Arab Emirates')
insert into #countryMap (shortName, enumName) values ('GB', 'metratech.com/paymentserver/PaymentMethodCountry/United Kingdom')
insert into #countryMap (shortName, enumName) values ('UY', 'metratech.com/paymentserver/PaymentMethodCountry/Uruguay')
insert into #countryMap (shortName, enumName) values ('UZ', 'metratech.com/paymentserver/PaymentMethodCountry/Uzbekistan')
insert into #countryMap (shortName, enumName) values ('VU', 'metratech.com/paymentserver/PaymentMethodCountry/Vanuatu')
insert into #countryMap (shortName, enumName) values ('VA', 'metratech.com/paymentserver/PaymentMethodCountry/Vatican City')
insert into #countryMap (shortName, enumName) values ('VE', 'metratech.com/paymentserver/PaymentMethodCountry/Venezuela')
insert into #countryMap (shortName, enumName) values ('VN', 'metratech.com/paymentserver/PaymentMethodCountry/Vietnam')
insert into #countryMap (shortName, enumName) values ('WF', 'metratech.com/paymentserver/PaymentMethodCountry/Wallis/Futuna Islands')
insert into #countryMap (shortName, enumName) values ('WS', 'metratech.com/paymentserver/PaymentMethodCountry/Western Samoa')
insert into #countryMap (shortName, enumName) values ('YE', 'metratech.com/paymentserver/PaymentMethodCountry/Yemen')
insert into #countryMap (shortName, enumName) values ('CD', 'metratech.com/paymentserver/PaymentMethodCountry/Zaire')
insert into #countryMap (shortName, enumName) values ('ZW', 'metratech.com/paymentserver/PaymentMethodCountry/Zimbabwe')
insert into #countryMap (shortName, enumName) values ('ZM', 'metratech.com/paymentserver/PaymentMethodCountry/Zambia')
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
	null, --nm_address2
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
	case 
		 WHEN EXISTS(
		                SELECT id_enum_data
		                FROM   t_enum_data
		                WHERE  nm_enum_data = 
		                       'metratech.com/paymentserver/CreditCardType/Visa'
		                       AND id_enum_data = id_creditcardtype
		            ) THEN (
		                       SELECT id_enum_data
		                       FROM   t_enum_data
		                       WHERE  nm_enum_data = 
		                              'metratech.com/CreditCardType/Visa'
		                   )
		 WHEN EXISTS(
		                SELECT id_enum_data
		                FROM   t_enum_data
		                WHERE  nm_enum_data = 
		                       'metratech.com/paymentserver/CreditCardType/MasterCard'
		                       AND id_enum_data = id_creditcardtype
		            ) THEN (
		                       SELECT id_enum_data
		                       FROM   t_enum_data
		                       WHERE  nm_enum_data = 
		                              'metratech.com/CreditCardType/Master Card'
		                   )
		 WHEN EXISTS(
		                SELECT id_enum_data
		                FROM   t_enum_data
		                WHERE  nm_enum_data = 
		                       'metratech.com/paymentserver/CreditCardType/American Express'
		                       AND id_enum_data = id_creditcardtype
		            ) THEN (
		                       SELECT id_enum_data
		                       FROM   t_enum_data
		                       WHERE  nm_enum_data = 
		                              'metratech.com/CreditCardType/American Express'
		                   )
		 WHEN EXISTS(
		                SELECT id_enum_data
		                FROM   t_enum_data
		                WHERE  nm_enum_data = 
		                       'metratech.com/paymentserver/CreditCardType/Discover'
		                       AND id_enum_data = id_creditcardtype
		            ) THEN (
		                       SELECT id_enum_data
		                       FROM   t_enum_data
		                       WHERE  nm_enum_data = 
		                              'metratech.com/CreditCardType/Discover'
		                   )
	end,
	nm_expdate,
	id_expdatef,
	nm_startdate,
	nm_issuernumber
from
	t_ps_creditcard2
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
	case 
		 WHEN EXISTS(
		                SELECT id_enum_data
		                FROM   t_enum_data
		                WHERE  nm_enum_data = 
		                       'metratech.com/paymentserver/CreditCardType/Visa'
		                       AND id_enum_data = id_creditcardtype
		            ) THEN (
		                       SELECT id_enum_data
		                       FROM   %%NETMETER%%..t_enum_data
		                       WHERE  nm_enum_data = 
		                              'metratech.com/CreditCardType/Visa'
		                   )
		 WHEN EXISTS(
		                SELECT id_enum_data
		                FROM   t_enum_data
		                WHERE  nm_enum_data = 
		                       'metratech.com/paymentserver/CreditCardType/MasterCard'
		                       AND id_enum_data = id_creditcardtype
		            ) THEN (
		                       SELECT id_enum_data
		                       FROM   %%NETMETER%%..t_enum_data
		                       WHERE  nm_enum_data = 
		                              'metratech.com/CreditCardType/Master Card'
		                   )
		 WHEN EXISTS(
		                SELECT id_enum_data
		                FROM   t_enum_data
		                WHERE  nm_enum_data = 
		                       'metratech.com/paymentserver/CreditCardType/American Express'
		                       AND id_enum_data = id_creditcardtype
		            ) THEN (
		                       SELECT id_enum_data
		                       FROM   %%NETMETER%%..t_enum_data
		                       WHERE  nm_enum_data = 
		                              'metratech.com/CreditCardType/American Express'
		                   )
		 WHEN EXISTS(
		                SELECT id_enum_data
		                FROM   t_enum_data
		                WHERE  nm_enum_data = 
		                       'metratech.com/paymentserver/CreditCardType/Discover'
		                       AND id_enum_data = id_creditcardtype
		            ) THEN (
		                       SELECT id_enum_data
		                       FROM   %%NETMETER%%..t_enum_data
		                       WHERE  nm_enum_data = 
		                              'metratech.com/CreditCardType/Discover'
		                   )
	end, -- tpcc.n_credit_card_type, -- id_creditcard_type
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
FROM t_ps_payment_instrument tppi, t_ps_credit_card tpcc, t_ps_creditcard2 tpc
WHERE tppi.id_payment_instrument = tpcc.id_payment_instrument
  AND tpc.id_payment_instrument = tppi.id_payment_instrument

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
	(select id_payment_instrument, id_priority, ROW_NUMBER() over (order by id_priority) as tmpId 
	   from %%NETMETER%%..t_payment_instrument) t
where
	t_payment_instrument.id_payment_instrument = t.id_payment_instrument
	

DROP TABLE t_ps_creditcard2
GO

-- Rename the table to preserve the data if need be
EXECUTE sp_rename N'dbo.t_ps_creditcard', N't_ps_creditcard_old', 'OBJECT' 
GO

COMMIT