shopt -s expand_aliases		# Make sure aliases work in non-interactive shells

# Check if mawk exist, otherwise create alias
if ! command -v mawk &> /dev/null
then
	alias mawk="awk"
fi

# Loop over smet files and correct coordinates
for f in ./output/*smet
do
	# Obtain longitude, latitude
	c=($(mawk '{if(/easting/) {lon=$NF}; if(/northing/) {lat=$NF}; if(/\[DATA\]/) {print lon, lat; exit}}' ${f}))
	# Convert longitude, latitude to easting, northing
	c2=($(echo ${c[*]} | gdaltransform -s_srs EPSG:4326 -t_srs EPSG:3413))
	# Insert corrected coordinates
	mawk -v lon=${c[0]} -v lat=${c[1]} -v east=${c2[0]} -v north=${c2[1]} '{if(/latitude/) {printf "latitude         = %f\n", lat} else if(/longitude/) {printf "longitude        = %f\n", lon} else if(/easting/) {printf "easting          = %f\n", east} else if(/northing/) {printf "northing         = %f\n", north} else {print}}' ${f} > ${f}.tmp
	mv ${f}.tmp ${f}
done
