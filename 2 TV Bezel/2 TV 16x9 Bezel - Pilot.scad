$fn=50;
$t=true; //abbreviation
$h1=5; //height of outer tv frame surface
$h2=5; //height of inner tv frame surface
$off=65; //offsets of tv frames/openings
$of2=1.5875; //offset for Uctronics 5" touch screen
$bx=129; //width of raised bezel
$by=101; //height of raised bezel
$o1=8; //outer position for angled openings
$o2=84; //outer position for angled openings
$i1=6; //inner position for angled openings
$i2=82; //inner position for angled openings
$vw=108.744; //width of tv viewing surface
$vh=65.0875; //height of tv viewing surface
$th=76.2; //height of tv total surface
$tw=120.65; //width of tv total surface
$hw=114.3/2; //width of mounting holes
$hh=90.4875/2; //height of mounting holes
$po=23.5; // pi area offset from mounting holes
$ph=58/2; // pi mounting holes length
$pw=49/2; // pi mounting holes width
$pv=85-($hw-10); //gap value of usbspacing
$hdmiw=50; //pi stand hdmi slot width
$hdmid=25; //pi stand hdmi slot depth
$screwd=3; $screwh=5; // screw hole dimensions
$slotv=57; //screwslot vertical offset
$sloth=105; //screwslot horizontal offset
/*  viewable screen:    65.0875mm h x 108.744mm w
    total screen:       76.2mm h x 120.65mm w
    borders:            top: 3.175mm, bottom & side: 6.35mm
    hole spacing:       90.4875mm h x 114.3mm w  1/8" hole
    tab:                5/16" h x 7/32" w  depth from front: 1/8"
    Pi mnt holes:       2.5mm D, 49mm w x 58mm h, 23.5mm offset
*/
module tvframe() {
    difference() {
        difference() {
            translate([0,0,$h1]) cube([$bx,$by,$h1+4], center=$t); //raised bezel
            translate([0,0,$h1]) cube([$vw,$vh,12], center=$t); //TV Opening
            //the below 4 cubes shape the outside corners of raised bezel
            rotate([0,0,45]) translate([-$o1,$o2,$h1]) cube([20,20,12], center=$t);
            rotate([0,0,45]) translate([$o1,-$o2,$h1]) cube([20,20,12], center=$t);
            rotate([0,0,45]) translate([-$o2,$o1,$h1]) cube([20,20,12], center=$t);
            rotate([0,0,45]) translate([$o2,-$o1,$h1]) cube([20,20,12], center=$t);
        }
        difference() {
            //inside raised bezel
            translate([0,0,$h2]) cube([$bx-5,$by-5,$h1+4], center=$t);
            //the below 4 cubes shape the inside corners of raised bezel
            rotate([0,0,45]) translate([-$i1,$i2,$h2]) cube([30,20,12], center=$t);
            rotate([0,0,45]) translate([$i1,-$i2,$h2]) cube([30,20,12], center=$t);
            rotate([0,0,45]) translate([-$i2,$i1,$h2]) cube([20,30,12], center=$t);
            rotate([0,0,45]) translate([$i2,-$i1,$h2]) cube([20,30,12], center=$t);
        }
    }
}
module rearinsert() {
    union() {
        translate([0,-$of2,-$h1+1]) cube([$tw,$th,6], center=$t); //rear insert
        translate([-$tw/2,0,-$h1+1]) cube([18.8,$th-11,6], center=$t); //usb clearance
        translate([-$tw/3+5,$th/2,-$h1+1]) cube([20,14,6], center=$t); //hdmi clearance
        //screw holes
        translate([$hw,$hh,-$h1]) cylinder(d=$screwd, h=$screwh);
        translate([-$hw,$hh,-$h1]) cylinder(d=$screwd, h=$screwh);
        translate([$hw,-$hh,-$h1]) cylinder(d=$screwd, h=$screwh);
        translate([-$hw,-$hh,-$h1]) cylinder(d=$screwd, h=$screwh);
    }
}
module screwslot() {
    minkowski() {
        cube([45,1,6], center=$t);
        sphere(2);
    }
}
module screwmount() {
    difference() {
        cylinder(d=$screwd*2,h=$screwh*2.5);
        cylinder(d=$screwd,h=$screwh*3);
    }
}
module pistand(){
    union() {
        difference() {
            minkowski(){
                difference(){
                    cube([$hw*2,$hh*2,4], center=$t); // main pi stand
                    translate([($hw-$ph*2)-$po+5-($pv/2),0,0]) cube([$pv,$pw*2+12,8], center=$t); //usb  port gap
                    translate([$hw,0,0]) cube([10,25,8], center=$t); //sd card slot
                    translate([$hw-.5-($hdmiw/2),-$pw-($hdmid/2),0]) cube([$hdmiw,$hdmid,8], center=$t); //hdmi slot
                }
                sphere(4);
            }
            translate([0,0,-4]) cube([$hw*2+8,$hh*2+8,4], center=$t); //flatten top
            translate([0,0,4]) cube([$hw*2+8,$hh*2+8,4], center=$t); //flatten bottom
            //pi stand mount holes
            translate([$hw,$hh,-4]) cylinder(d=$screwd, h=$screwh*2); 
            translate([-$hw,$hh,-4]) cylinder(d=$screwd, h=$screwh*2);
            translate([$hw,-$hh,-4]) cylinder(d=$screwd, h=$screwh*2);
            translate([-$hw,-$hh,-4]) cylinder(d=$screwd, h=$screwh*2);
            //pi mount holes
            translate([$hw,$pw,-4]) cylinder(d=$screwd, h=$screwh*2);
            translate([$hw-$ph*2,$pw,-4]) cylinder(d=$screwd, h=$screwh*2);
            translate([$hw,-$pw,-4]) cylinder(d=$screwd, h=$screwh*2);
            translate([$hw-$ph*2,-$pw,-4]) cylinder(d=$screwd, h=$screwh*2);
        }
        //pi stand mount pegs
        translate([$hw,$hh,0]) screwmount();
        translate([-$hw,$hh,0]) screwmount();
        translate([$hw,-$hh,0]) screwmount();
        translate([-$hw,-$hh,0]) screwmount();
    }
}
difference() {
    union() {
        difference() {
            minkowski(){
                cube([263,124,6], center=$t); //main panel
                sphere(3);
            }
            translate([0,0,4.5]) cube([280,140,6], center=$t); //flatten front
            translate([0,0,-6]) cube([280,140,6], center=$t); //flatten rear
            translate([-$off,0,0]) cube([$vw,$vh,6], center=$t); //L tv opening
            translate([$off,0,0]) cube([$vw,$vh,6], center=$t); //R tv opening
            translate([0,$slotv,0]) screwslot(); //upper center screwslot
            translate([0,-$slotv,0]) screwslot(); //lower center screwslot
            translate([$sloth,$slotv,0]) screwslot(); //lower right screwslot
            translate([$sloth,-$slotv,0]) screwslot(); //lower right screwslot
            translate([-$sloth,$slotv,0]) screwslot(); //upper left screwslot
            translate([-$sloth,-$slotv,0]) screwslot(); //lower left screwslot
            translate([$off,0,0]) rearinsert(); //R rear insert
            translate([-$off,0,0]) rearinsert(); //L rear insert
        }
        translate([-$off,0,0]) tvframe(); //left TV frame
        translate([$off,0,0]) tvframe(); //right TV frame
    }
}
translate([$off,120,-1]) pistand();
translate([-$off,120,-1]) pistand();