include <MCAD/units/metric.scad>
include <scad-utils/transformations.scad>

use <MCAD/shapes/polyhole.scad>
use <MCAD/shapes/boxes.scad>
use <MCAD/array/along_curve.scad>

plate_size = [95, 68, 5];
rounding_r = 4;

screw_holes = [[7, 8], [7, 8 + 53]];
bearing_holes = [[45, 13], [45, 55]];
spacer_elevation = 7;
pillar_elevation = 6 + spacer_elevation;

screw_size = M4;
clearance = 0.3;

bearing_od = 16;
bearing_thickness = 5;

$fs = 0.4;
$fa = 1;

function translations (coord_list) = [
    for (coord = coord_list)
    translation (coord)
];

module bearing_hole ()
{
    translate ([0, 0, -epsilon])
    mcad_polyhole (d = bearing_od, h = 1000);
}

module screw_hole ()
{
    translate ([0, 0, -epsilon])
    mcad_polyhole (d = screw_size + clearance, h = 1000);
}

module spacer ()
{
    cylinder (d = screw_size + 6, h = spacer_elevation + epsilon);
}

module pillar ()
{
    cylinder (r = rounding_r, h = pillar_elevation + epsilon);
}

module plate ()
{
    translate ([0, 0, pillar_elevation])
    mcad_rounded_box (plate_size, radius = rounding_r, sidesonly = true);

    translate ([0, 0, pillar_elevation - spacer_elevation])
    mcad_multiply (translations (screw_holes), keep_original = false)
    spacer ();

    mcad_multiply (
        [
            for (y = [rounding_r, plate_size[1] - rounding_r])
            translation ([plate_size[0] - rounding_r, y])
        ],
        keep_original = false
    )
    pillar ();
}

translate ([0, 0, plate_size[2] + pillar_elevation])
rotate (180, X)
difference () {
    plate ();

    mcad_multiply (translations (bearing_holes), keep_original = false)
    bearing_hole ();

    mcad_multiply (translations (screw_holes), keep_original = false)
    screw_hole ();
}
