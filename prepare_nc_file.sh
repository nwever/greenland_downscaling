# Add x and y dimension
ncap2 -s 'x=array(1.,1.,$x);y=array(1.,1.,$y); time=array(1,1,$z)' ./orig/era5_summer_climatologies.nc era5_summer_climatologies1.nc

# Repopulate with correct values (note latitudes count down, i.e., the grids are vertically swapped!)
ee="$(awk 'BEGIN {for(i=85; i>=59; i-=0.25) {print i}}' | awk 'BEGIN {printf "ncap2 -s \"y(:)={"} {if(NR>1) {printf ","}; printf "%f", $1} END {printf "}\""}') era5_summer_climatologies1.nc era5_summer_climatologies2.nc"
eval ${ee}
ee="$(awk 'BEGIN {for(j=-74; j<=-12; j+=0.25) {print j}}' | awk 'BEGIN {printf "ncap2 -s \"x(:)={"} {if(NR>1) {printf ","}; printf "%f", $1} END {printf "}\""}') era5_summer_climatologies2.nc era5_summer_climatologies3.nc"
eval ${ee}


# Delete variables longitude and latitude
ncks -x -v longitude,latitude era5_summer_climatologies3.nc era5_summer_climatologies4.nc
# Rename dimensions x and y to longitude and latitute, respectively, and z to time
ncrename -d x,longitude -d y,latitude -d z,time era5_summer_climatologies4.nc era5_summer_climatologies5.nc
# Rename variables x and y to longitude and latitute, respectively
ncrename -v x,longitude -v y,latitude era5_summer_climatologies5.nc era5_summer_climatologies6.nc


# Repopulate longitude and latitude with correct values again. Somehow the previous ncrename deleted the values (note latitudes count down, i.e., the grids are vertically swapped!)
ee="$(awk 'BEGIN {for(i=85; i>=59; i-=0.25) {print i}}' | awk 'BEGIN {printf "ncap2 -s \"latitude(:)={"} {if(NR>1) {printf ","}; printf "%f", $1} END {printf "}\""}') era5_summer_climatologies6.nc era5_summer_climatologies7.nc"
eval ${ee}
ee="$(awk 'BEGIN {for(j=-74; j<=-12; j+=0.25) {print j}}' | awk 'BEGIN {printf "ncap2 -s \"longitude(:)={"} {if(NR>1) {printf ","}; printf "%f", $1} END {printf "}\""}') era5_summer_climatologies7.nc era5_summer_climatologies8.nc"
eval ${ee}

# Now reorder such that time is the first dimension, and swap latitudes, such that they are in increasing order
ncpdq -a "time,-latitude,longitude" era5_summer_climatologies8.nc era5_summer_climatologies9.nc 

# Now add reference time, defined as 2018-08-01T00:00
cdo -s -setreftime,'2010-08-01','00:00',days -setcalendar,standard era5_summer_climatologies9.nc era5_summer_climatologies10.nc

# Set time steps appropriately, such that the years are mapped to days between 2010-08-01 and 2010-08-18.
ee="$(awk 'BEGIN {for(t=0; j<18; j++) {print j}}' | awk 'BEGIN {printf "ncap2 -s \"time(:)={"} {if(NR>1) {printf ","}; printf "%f", $1} END {printf "}\""}') era5_summer_climatologies10.nc era5_summer_climatologies11.nc"
eval ${ee}


# Cleanup
mv era5_summer_climatologies11.nc era5_summer_climatologies.nc
rm era5_summer_climatologies[0-9].nc
rm era5_summer_climatologies[0-9][0-9].nc
