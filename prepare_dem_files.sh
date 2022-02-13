#
# ERA5 DEM
#

# Remove time dimension from DEM
ncwa -a time ./orig/geopotential_ERA5.nc geopotential_ERA5.nc

# Overwrite longitudes, to match era5_summer_climatologies.nc (i.e., west longitudes are denoted by negative values, instead of values >180)
ee="$(awk 'BEGIN {for(j=-74; j<=-12; j+=0.25) {print j}}' | awk 'BEGIN {printf "ncap2 -s \"longitude(:)={"} {if(NR>1) {printf ","}; printf "%f", $1} END {printf "}\""}') geopotential_ERA5.nc geopotential_ERA51.nc"
eval ${ee}

cp geopotential_ERA51.nc geopotential_ERA5.nc
rm geopotential_ERA5[0-9].nc




#
# Target DEM (1km)
#
gdal_translate -of AAIGrid -a_srs EPSG:3413 NETCDF:./orig/1km-ISMIP6.nc:SRF tgt_DEM.asc
