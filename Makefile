all: bearing-plate.stl compound-pulley.stl

clean:
	rm -f *.stl

%.stl: %.scad
	openscad -o $@ $<
