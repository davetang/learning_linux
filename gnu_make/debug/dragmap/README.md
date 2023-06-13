# README

Trying to build [DRAGMAP](https://github.com/Illumina/DRAGMAP) using updated
[Boost libraries](https://www.boost.org/). But the building process seems to be
using the outdated system Boost libraries in `/usr/include/boost/`. This is because I keep getting these errors:

    /usr/include/boost/program_options/detail/value_semantic.hpp:170: undefined reference to `boost::program_options::validate(boost::any&, std::vector<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, std::allocator<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > > > const&, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >*, int)'

Here I examine the behaviour of the following environment variables:

* `BOOST_ROOT`
* `BOOST_INCLUDEDIR`
* `BOOST_LIBRARYDIR`

The required Boost libraries are:

    BOOST_LIBRARIES := system filesystem date_time thread iostreams regex program_options

They reside in `/usr/include/boost169/boost/`; for example:

    /usr/include/boost169/boost/system
    /usr/include/boost169/boost/filesystem

Use `./run.sh` to run all the test scripts.
