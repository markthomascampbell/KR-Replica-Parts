$fn=50;
$t=true;        //Abbreviation
$angle=45;
$wth=.5;        //Wall Thickness
$l=21.15;       //Length
$w=12.55;       //Width
$h=7.7;         //Height
$slant=4;       //Slant of segments in degrees
$slo=0.453;     //Slant offset
$ow=5;          //LED Opening Width
$oiw=3.5;       //LED Opening Inside Width
$ol=1.1;        //LED Opening length
$os=.5;         //LED Opening Spacing
$ols=$ol+$os;   //Distance per LED
$olso=$ols/2;   //Offset for Center
$od=6;          //LED Opening Depth
$al=2.82;       //A half length
$bl=5.9437;     //B length
$gl=$al;        //G half length
$ledl=3.4;      //LED Length
$ledw=1.2;      //LED Width
$ledhf=.6;      //Flat LED Height
$ledhr=1;       //Round LED Height/diameter
$ledpcbh=.48;   //LED PCB Height

/* Display layout
        A
    ==========
  ||          ||
  ||          ||
F ||          || B
  ||          ||
  ||    G     ||
    ==========
  ||          ||
  ||          ||
B ||(mirrored)|| F (mirrored)
  ||          ||
  ||          ||
    ==========    o DP
        A (mirrored)
*/

module LEDConduit() {
    translate([0,0,-$ledpcbh*3]) rotate([0,0,90]) cube([$ledw,$ledl,$ledpcbh], center=$t);
    difference() {
        translate([0,0,$ledpcbh]) rotate([0,0,90]) cylinder(h=$ledl*1.5,r1=2,r2=$ledhf-.15, center=$t);
        translate([0,$ledw+.12,$ledpcbh]) rotate([90,0,0]) cube([$ledl*1.5,$ledw*5,$ledpcbh*3], center=$t);
        translate([0,-$ledw-.12,$ledpcbh]) rotate([90,0,0]) cube([$ledl*1.5,$ledw*5,$ledpcbh*3], center=$t);
    }
}

module A() {
    difference() {
        union() {
            cube([$gl*2.4,$ol,$od], center=$t);
            translate([0,-.5,-1.4]) rotate([-5,0,0]) cube([$gl*2.4-1.8,$ol-.5,$od-1], center=$t);
            translate([0,.5,-1.4]) rotate([5,0,0]) cube([$gl*2.4-1.8,$ol-.5,$od-1], center=$t);
        }
        translate([-3.1,-.4,0]) rotate([0,0,-$angle-$slant]) cube([1.6,.6,$od], center=$t);
        translate([3.1,-.4,0]) rotate([0,0,$angle-$slant]) cube([1.6,.6,$od], center=$t);
    }
}

module G() {
    difference() {
        union() {
            cube([$gl*2+1,$ol,$od], center=$t);
            translate([0,-.5,-1.4]) rotate([-5,0,0]) cube([$gl*2.4-1.8,$ol-.5,$od-1], center=$t);
            translate([0,.5,-1.4]) rotate([5,0,0]) cube([$gl*2.4-1.8,$ol-.5,$od-1], center=$t);
        }
        translate([-3.2,-.5,0]) rotate([0,0,-$angle-$slant]) cube([1.1,.4,$od], center=$t);
        translate([-3.1,.5,0]) rotate([0,0,$angle-$slant]) cube([1.1,.4,$od], center=$t);
        translate([3.1,-.5,0]) rotate([0,0,$angle]) cube([1,.4,$od], center=$t);
        translate([3.1,.5,0]) rotate([0,0,-$angle]) cube([1,.4,$od], center=$t);
    }
}

module B() {   
    difference() {
        union() {
            cube([$ol,$bl,$od], center=$t);
            translate([.5,0,-1.4]) rotate([-5,0,90]) cube([$gl*2.4-2.4,$ol-.5,$od-1], center=$t);
            translate([-.5,0,-1.4]) rotate([5,0,90]) cube([$gl*2.4-2.4,$ol-.5,$od-1], center=$t);
        }
        translate([-.6,-($bl/2)-.1,0]) rotate([0,0,-$angle]) cube([1.2,1,$od+.1], center=$t);
        translate([.7,-($bl/2)-.1,0]) rotate([0,0,-$angle]) cube([1.2,1,$od+.1], center=$t);
        translate([-.5,($bl/2)+.1,0]) rotate([0,0,-$angle]) cube([1,1.2,$od+.1], center=$t);
        translate([.9,($bl/2)+.1,0]) rotate([0,0,-$angle]) cube([1,1.2,$od+.1], center=$t);
    }
}

module F() {
    rotate([0,0,180]) B();
}

module DP() {
    cylinder(h=$od,r=$ol/2, center=$t);
}

module TopOpenings() {      //Arrange & Consolidate top half segments
    translate([0,0,$h/3]) G();                                                                  //LED G
    difference() {
        union() {
            translate([$gl+$os*1.8,$bl/2+$os/2,$h/3]) rotate([0,0,-$slant]) B();                //LED B
            translate([-($gl+$os*1.8)+$slo,$bl/2+$os/2,$h/3]) rotate([0,0,-$slant]) F();        //LED F
            translate([0.4,$bl+$os-.3,$h/3]) A();                                               //LED A
        }
        translate([$gl+$os*3,$bl+$os,$h/3]) rotate([0,0,-$angle]) cube([3,1,$od+1], center=$t);
        translate([-($gl+$os+.2),$bl+$os,$h/3]) rotate([0,0,$angle]) cube([3,1,$od], center=$t);
    }
    
}

module BottomOpenings() {       //Duplicate top half segments & mirror to make bottom half
    rotate([0,0,180]) TopOpenings();
}

module DigitOpenings() {        //Combine Top & Bottom with DP to make a full digit
    TopOpenings();
    BottomOpenings();
    translate([($gl+$os)/2+3.2,-($bl+$os),$h/3]) DP();
    translate([($gl+$os)/2+3.2,-($bl+$os),0]) rotate([0,0,90]) LEDConduit();
}

module Casing() {
    difference() {
        cube([$w,$l,$h], center=$t);                                        //Main casing
        translate([0,0,-$wth*2]) cube([$w-$wth,$l-$wth,$h], center=$t);     //Hollow out casing
    }
    translate([0,0,1.9]) cube([$w-1.3,$l-5,3.9], center=$t);     //Add 
}


difference() {                  //Bring it all together
    Casing();
    DigitOpenings();
}