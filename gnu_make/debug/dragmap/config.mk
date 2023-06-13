BOOST_LIBRARIES := system filesystem date_time thread iostreams regex program_options

ifneq (,$(BOOST_ROOT))
BOOST_INCLUDEDIR?=$(BOOST_ROOT)/include
BOOST_LIBRARYDIR?=$(BOOST_ROOT)/lib
endif # ifneq (,$(BOOST_ROOT))

ifneq (,$(BOOST_INCLUDEDIR))
CPPFLAGS += -I $(BOOST_INCLUDEDIR)
endif

ifneq (,$(BOOST_LIBRARYDIR))
LDFLAGS += -L $(BOOST_LIBRARYDIR)
endif
LDFLAGS += $(BOOST_LIBRARIES:%=-lboost_%)
