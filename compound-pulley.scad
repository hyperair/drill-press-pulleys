include <MCAD/units/metric.scad>
use <MCAD/general/facets.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/shapes/cylinder.scad>

$fs = 0.4;
$fa = 1;

function slice (v, start, end = undef) = [
    for (i = [0 : len (v) - 1])
    if (i >= start && (end == undef || i < end))
    v[i]
];

function pairwise (v) = [
    for (i = [0 : len (v) - 2])
    [v[i], v[i + 1]]
];

function last (v) = v[len (v) - 1];

module compound_pulley (belt_thickness, diameters, bore_d = 0,
    setscrew_positions = [],
    wall_thickness = 1
)
{
    pulley_height = belt_thickness + wall_thickness * 2;
    fillet_r = wall_thickness * 0.5;

    if (len (diameters) > 0)
    {
        pulley (
            belt_thickness = belt_thickness,
            d = diameters[0],
            wall_thickness = wall_thickness,
            bore_d = bore_d
        );

        translate ([0, 0, pulley_height])
        compound_pulley (
            belt_thickness = belt_thickness,
            diameters = slice (diameters, 1),
            bore_d = bore_d
        );

        if (abs (diameters[0] - last (diameters)) >= fillet_r * 2)
        translate ([0, 0, pulley_height])
        cylinder_fillet (fillet_r = fillet_r,
            base_r = min (diameters[0], last (diameters)) / 2 - epsilon);
    }
}

module pulley (belt_thickness, d, wall_thickness, bore_d)
{
    overall_thickness = belt_thickness + wall_thickness * 2;
    pulley_max_d = d + belt_thickness / 2;

    difference () {
        rotate_extrude ()
        difference () {
            square ([d / 2, overall_thickness]);

            translate ([d / 2, overall_thickness / 2])
            circle (d = belt_thickness);
        }

        translate ([0, 0, -epsilon])
        mcad_polyhole (d = bore_d, h = overall_thickness + epsilon * 2);
    }
}

module cylinder_fillet (fillet_r, base_r)
{
    rotate_extrude ()
    difference () {
        translate ([base_r, -fillet_r])
        square ([fillet_r, fillet_r * 2]);

        for (i = [1, -1])
        translate ([base_r + fillet_r, i * fillet_r])
        circle (r = fillet_r);
    }
}

difference () {
    compound_pulley (belt_thickness = 3.2, diameters = [34.5, 17], bore_d = 5);

    translate ([0, 0, -epsilon])
    mcad_rounded_cylinder (d = 9, h = 5, round_r2 = 0.5);
}
