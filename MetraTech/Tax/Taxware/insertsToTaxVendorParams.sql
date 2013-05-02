CREATE TABLE [dbo].[t_tax_input_444](
	[id_tax_charge] [int] NOT NULL,
	[id_acc] [int] NOT NULL,
	[amount] [numeric](22, 10) NOT NULL,
	[invoice_date] [datetime] NOT NULL,
	[product_code] [varchar](255) NOT NULL,
	[customer_name] [varchar](255) NOT NULL,
	[customer_code] [int] NOT NULL,
	[location_of_service_code] [int] NOT NULL,
	[bill_to_address] [varchar](255) NOT NULL,
	[bill_to_city] [varchar](255) NOT NULL,
	[bill_to_state_province] [varchar](255) NOT NULL,
	[bill_to_postal_code] [varchar](16) NOT NULL,
	[bill_to_country] [varchar](255) NOT NULL,
	[bill_to_location_code] [varchar](255) NOT NULL,
	[bill_to_geo_code] [varchar](255) NOT NULL,
	[ship_to_address] [varchar](255) NOT NULL,
	[ship_to_city] [varchar](255) NOT NULL,
	[ship_to_state_province] [varchar](255) NOT NULL,
	[ship_to_postal_code] [varchar](16) NOT NULL,
	[ship_to_country] [varchar](255) NOT NULL,
	[ship_to_location_code] [varchar](255) NOT NULL,
	[ship_to_geo_code] [varchar](255) NOT NULL,
	[good_or_service_code] [varchar](255) NOT NULL,
	[sku] [varchar](255) NOT NULL,
	[currency] [varchar](16) NOT NULL,
    [is_implied_tax] [int] NOT NULL,
    [round_alg] [varchar](255) NOT NULL,
    [round_digits] [int] NOT NULL
)

INSERT INTO NetMeter.dbo.t_tax_input_444
    (id_tax_charge, id_acc, amount, 
    invoice_date, product_code, customer_name,
    customer_code, location_of_service_code, bill_to_address, 
    bill_to_city, bill_to_state_province, bill_to_postal_code, 
    bill_to_country, bill_to_location_code, bill_to_geo_code, 
    ship_to_address, ship_to_city, ship_to_state_province, 
    ship_to_postal_code, ship_to_country, ship_to_location_code,
    ship_to_geo_code, good_or_service_code, sku, 
    currency, is_implied_tax, round_alg, round_digits)
    VALUES
    (444222002, 10101, 444.02, 
    GETDATE(), 'unused', 'The North West Company International Inc.1',
    11497, 31667, '550 West 64th Avenue,',
    'Anchorage', 'AK', '99518',
    'UNITED STATES', 0, 0,
    '550 West 64th Avenue,', 'Anchorage', 'AK', 
    '99518', 'UNITED STATES', 0,
    0, 2038024, 60400003100, 
    'USD', 0, 'bank', 1)

INSERT INTO NetMeter.dbo.t_tax_input_444
    (id_tax_charge, id_acc, amount, 
    invoice_date, product_code, customer_name,
    customer_code, location_of_service_code, bill_to_address, 
    bill_to_city, bill_to_state_province, bill_to_postal_code, 
    bill_to_country, bill_to_location_code, bill_to_geo_code, 
    ship_to_address, ship_to_city, ship_to_state_province, 
    ship_to_postal_code, ship_to_country, ship_to_location_code,
    ship_to_geo_code, good_or_service_code, sku, 
    currency, is_implied_tax, round_alg, round_digits)
    VALUES
    (555333002, 20202, 444.02, 
    GETDATE(), 'unused', 'Virage Logic',
    9187, 25304, '47100 Bayside Parkway',
    'Freemont', 'CA', '94538',
    'UNITED STATES', 0, 0,
    '47100 Bayside Parkway', 'Freemont', 'CA', 
    '94538', 'UNITED STATES', 0,
    0, 2038024, 60400003100, 
    'USD', 0, 'bank', 1)


INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'id_tax_charge', 'Integer', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'id_acc', 'Integer', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'amount', 'Decimal', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'invoice_date', 'DateTime', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'product_code', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'customer_name', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'customer_code', 'Integer', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'location_of_service_code', 'Integer', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'bill_to_address', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'bill_to_city', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'bill_to_state_province', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'bill_to_postal_code', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'bill_to_country', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'bill_to_location_code', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'bill_to_geo_code', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'ship_to_address', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'ship_to_city', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'ship_to_state_province', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'ship_to_postal_code', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'ship_to_country', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'ship_to_location_code', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'ship_to_geo_code', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'good_or_service_code', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'sku', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'currency', 'String', '333444', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'is_implied_tax', 'Integer', '0', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'round_alg', 'String', 'none', 'TBD');
INSERT INTO NetMeter.dbo.t_tax_vendor_params (id_vendor, tx_canonical_name, tx_type, tx_default, tx_description) VALUES (2, 'round_digits', 'Integer', '0', 'TBD');
