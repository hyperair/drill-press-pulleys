include <MCAD/units/metric.scad>
include <scad-utils/transformations.scad>

use <MCAD/shapes/polyhole.scad>
use <MCAD/shapes/boxes.scad>
use <MCAD/array/along_curve.scad>
use <MCAD/fasteners/nuts_and_bolts.scad>

plate_size = [95, 68, 5];
rounding_r = 4;

mounting_screw_holes = [[7, 8], [7, 8 + 53]];
bearing_holes = [[45, 13], [45, 55]];
spacer_elevation = 7;
pillar_elevation = 6 + spacer_elevation;

mounting_screw_size = M4;
clearance = 0.3;

bearing_od = 16;
bearing_thickness = 5;
bearing_rim_width = 1;
bearing_ridge_thickness = 1;

min_wall_thickness = 4;

bearing_screw_size = M3;

// automatically calculated
bearing_cap_screw_separation = (bearing_od + min_wall_thickness * 2 +
    bearing_screw_size);
bearing_screw_holes = [
    [-bearing_cap_screw_separation / 2, 0],
    [bearing_cap_screw_separation / 2, 0]
];

bearing_plate_depth = plate_size[2] - bearing_ridge_thickness;
bearing_depth_in_cap = bearing_thickness - bearing_plate_depth;
bearing_cap_thickness = bearing_ridge_thickness + bearing_depth_in_cap;

$fs = 0.4;
$fa = 1;

function translations (coord_list) = [
    for (coord = coord_list)
    translation (coord)
];

module bearing_hole ()
{
    translate ([0, 0, bearing_ridge_thickness])
    mcad_polyhole (d = bearing_od, h = 1000);

    translate ([0, 0, -epsilon])
    mcad_polyhole (d = bearing_od - 2 * bearing_rim_width, h = 1000);
}

module bearing_screw_holes ()
{
    mcad_multiply (translations (bearing_screw_holes), keep_original = false)
    translate ([0, 0, -epsilon])
    mcad_polyhole (d = bearing_screw_size + clearance, h = 1000);
}

module bearing_nut_holes ()
{
    mcad_multiply (translations (bearing_screw_holes), keep_original = false)
    translate ([0, 0, -epsilon])
    mcad_nut_hole (size = bearing_screw_size);
}

module mounting_screw_hole ()
{
    translate ([0, 0, -epsilon])
    mcad_polyhole (d = mounting_screw_size + clearance, h = 1000);
}

module spacer ()
{
    cylinder (d = mounting_screw_size + 6, h = spacer_elevation + epsilon);
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
    mcad_multiply (translations (mounting_screw_holes), keep_original = false)
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

module bearing_cap ()
{
    difference () {
        linear_extrude (height = bearing_cap_thickness)
        offset (r = -2)
        offset (r = 2)
        union () {
            circle (d = bearing_od + min_wall_thickness);

            hull () {

                mcad_multiply (translations (bearing_screw_holes),
                    keep_original = false)
                circle (d = bearing_screw_size + min_wall_thickness * 2);
            }
        }

        // bearing hole
        translate ([0, 0, -epsilon]) {
            mcad_polyhole (d = bearing_od, h = bearing_depth_in_cap + epsilon);
            mcad_polyhole (d = bearing_od - bearing_rim_width * 2,
                h = 1000);
        }

        bearing_screw_holes ();
    }
}

translate ([0, 0, plate_size[2] + pillar_elevation])
rotate (180, X)
difference () {
    plate ();

    translate ([0, 0, pillar_elevation])
    mcad_multiply (translations (bearing_holes), keep_original = false) {
        bearing_hole ();
        bearing_screw_holes ();
        bearing_nut_holes ();
    }

    mcad_multiply (translations (mounting_screw_holes), keep_original = false)
    mounting_screw_hole ();
}

translate ([0, bearing_od, bearing_cap_thickness])
mcad_linear_multiply (
    no = 2,
    separation = bearing_cap_screw_separation + min_wall_thickness * 2 + 10,
    axis = X
)
rotate (180, X)
bearing_cap ();
