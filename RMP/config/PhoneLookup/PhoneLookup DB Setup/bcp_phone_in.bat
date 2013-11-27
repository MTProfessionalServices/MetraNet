bcp phone_device in phone_device.txt  -U nmdbo -P nmdbo -S . -c -t"|" -C RAW
bcp phone_country in phone_country.txt  -U nmdbo -P nmdbo -S . -c -t"|" -C RAW

rem bcp phone_region in phone_region.txt  -U nmdbo -P nmdbo -S . -c -t"|" -C RAW

bcp phone_region in phone_region_Germany.txt  -U nmdbo -P nmdbo -S . -c -t"|" -C RAW
bcp phone_region in phone_region_France.txt  -U nmdbo -P nmdbo -S . -c -t"|" -C RAW
bcp phone_region in phone_region_Belgium.txt  -U nmdbo -P nmdbo -S . -c -t"|" -C RAW
bcp phone_region in phone_region_NANP.txt  -U nmdbo -P nmdbo -S . -c -t"|" -C RAW
bcp phone_region in phone_region_Ireland.txt  -U nmdbo -P nmdbo -S . -c -t"|" -C RAW