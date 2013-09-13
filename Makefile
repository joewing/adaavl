
all:
	gnatmake -O2 -gnaty3aAbdhikmnpr -we main

clean:
	rm *.o *.ali main
