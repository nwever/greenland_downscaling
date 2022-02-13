// gcc -O3 -o extract_grids.out extract_grids.cc -I ./meteoio/ -rdynamic -lstdc++ -ldl -L./meteoio/lib/ -lmeteoio -ldl
// LD_LIBRARY_PATH=./meteoio/lib/ ./extract_grids.out io_interpol2d.ini 2010-08-01 2010-08-17 24
#include <iostream>
#include <string.h>
#include <map>
#include <vector>
#include <meteoio/MeteoIO.h>

using namespace mio; //The MeteoIO namespace is called mio

void real_main(int argc, char** argv)
{
	std::string cfgfile = "";
	cfgfile = argv[1];
	Config cfg(cfgfile);
	const double TZ = cfg.get("TIME_ZONE", "Input");

	double Tstep;
	IOUtils::convertString(Tstep, argv[4]);
	Tstep /= 24.; //convert to sampling rate in days

	Date d_start, d_end;
	IOUtils::convertString(d_start, argv[2], TZ);
	IOUtils::convertString(d_end, argv[3], TZ);

	IOManager io(cfg);
	std::cout << "Powered by MeteoIO " << getLibVersion() << "\n";
	std::cout << "Reading data from " << d_start.toString(Date::ISO) << " to " << d_end.toString(Date::ISO) << "\n";

	Timer timer;
	timer.start();

	DEMObject dem;
	//dem.setUpdatePpt(DEMObject::SLOPE);
	io.readDEM(dem);

	Grid2DObject grid;
	for (Date d=d_start; d<=d_end; d+=Tstep) { //time loop
		std::cout << d.toString(Date::ISO) << "\n";

		io.getMeteoData(d, dem, "TA", grid);
		std::cout << "Writing output data (TA)" << std::endl;
		io.write2DGrid(grid, mio::MeteoGrids::TA, d);
	}

	//io.getMeteoData(d_start, d_end, vecMeteo); //This would be the call that does NOT resample the data, instead of the above "for" loop

	//In both case, we write the data out
	timer.stop();
	std::cout << "Done!! in " << timer.getElapsed() << " s" << std::endl;
}

int main(int argc, char** argv)
{
	if(argc!=5) {
		std::cout << "Invalid number of arguments! Please provide ini-file, a date range and a sampling rate (in hours)\n";
		std::cerr << "Usage: extract_grids.out <ini-file> <startdate> <enddate> <interval>\n";
		exit(0);
	}

	try {
		real_main(argc, argv);
	} catch(const std::exception &e) {
		std::cerr << e.what();
		exit(1);
	}
	return 0;
}


