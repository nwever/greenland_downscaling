# greenland_downscaling
Downscaling temperature to 1km digital elevation model


Preparation:
============
Tools needed:
- gdal (gdaltransform)
- cdo
- nco
- meteoio (git submodule)

After compiling meteoio, compile the program extract_grid.cc:
```
gcc -O3 -o extract_grids.out extract_grids.cc -I ./meteoio/ -rdynamic -lstdc++ -ldl -L./meteoio/lib/ -lmeteoio -ldl
```

Steps to reproduce:
===================
The source netcdf files are in the folder ./orig/
Create a folder ./output/ and ./output_grids/

Step 1:
=======
Run:
```
bash prepare_nc_file.sh
```
This will reformat the netcdf file such that they can be read by MeteoIO. This includes adding latitude/longitude dimensions and variables, as well as adding a time dimension to map the 18 years in the dataset to the period 2010-08-01 to 2010-08-18.

Step 2:
=======
Run:
```
bash prepare_dem_files.sh
```
This will reformat the netcdf file with the DEM, which for example removes the time dimensions (there is only one time step containing the DEM).

Step 3:
=======
```
Run: ./meteoio/bin/meteoio_timeseries -c io_createsmet.ini -b 2010-08-01T00:00 -e 2010-08-18T00:00 -s 1440
```
This generates a *smet file for each grid point
Takes ~20 seconds

Step 4:
=======
Run:
```
bash correct_smet_files.sh
```
This script corrects the coordinates. We tricked meteoio in assuming that longitude is easting, and latitude is northing, which means that the coordinates in the smet files are not properly reported. 
Takes around 30-40 minutes

Step 5:
=======
Run:
```
bash create_stn_list.sh > station.lst
```
This formats a list of the "stations" (i.e., the ERA5 grid points) to interpolate

Step 6:
=======
Run:
```
LD_LIBRARY_PATH=./meteoio/lib/ ./extract_grids.out io_interpol2d.ini 2010-08-01 2010-08-01 24
```
This will interpolate the grids
Takes around 150 minutes per time step

### Alternatively: ###
The file to_exec.lst contains a list of commands to generate the grids year-by-year.
1) Run in parallel by executing: ```parallel < to_exec.lst```
2) On HPC systems, use the job manager script job.sbatch, which will execute to_exec.lst in parallel using job arrays.

Step 7:
=======
Run:
```
bash rename_output.sh
```
Rename the output grids from the period 2010-08-01 to 2010-08-18, which was pragmatically used to do the processing, to the corresponding year.
