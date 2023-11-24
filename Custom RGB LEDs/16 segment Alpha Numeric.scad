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
$ol=0.906;      //LED Opening length
$os=.5;         //LED Opening Spacing
$ols=$ol+$os;   //Distance per LED
$olso=$ols/2;   //Offset for Center
$od=6;          //LED Opening Depth
$al=2.82;       //A half length
$bl=5.9437;     //B length
$cl=$bl;        //C length
$dl=$al;        //D half length
$el=$bl;        //E length
$fl=$bl;        //F length
$gl=$al;        //G half length
$jl=5.673;      //J length
$kl=4.5;        //K length
$ledl=3.4;      //LED Length
$ledw=1.2;      //LED Width
$ledhf=.6;      //Flat LED Height
$ledhr=1;       //Round LED Height/diameter
$ledpcbh=.48;   //LED PCB Height

/* Display layout
     A1    A2
    ====  ====
  ||\\ J||J //||
  || \\ || // ||
F || H\\||//K || B
  ||   \||/   ||
  || G1 || G2 ||
    ====  ====
  ||    ||    ||
  ||   /||\   ||
E || L//||\\N || C
  || // || \\ ||
  ||// M||M \\||
    ====  ====    o DP
     D1    D2
*/

module FlatLED() {
    translate([0,0,$ledpcbh/2]) rotate([0,0,90]) cube([$ledw,2,$ledhf], center=$t);
    translate([0,0,-$ledpcbh/2]) rotate([0,0,90]) cube([$ledw,$ledl,$ledpcbh], center=$t);
}

module RoundLED() {
    difference() {
        rotate([90,0,0]) cylinder(h=$ledw,r=$ledhr, center=$t);
        translate([0,0,-$ledhr/2]) cube([$ledl,$ledw,$ledhr], center=$t);
    }
    translate([0,0,-$ledpcbh/2]) rotate([0,0,90]) cube([$ledw,$ledl,$ledpcbh], center=$t);
}

module LEDConduit() {
    //translate([0,0,$ledpcbh/2]) rotate([0,0,90]) cube([$ledw,2,$ledhf], center=$t);
    translate([0,0,-$ledpcbh*3]) rotate([0,0,90]) cube([$ledw,$ledl,$ledpcbh], center=$t);
    difference() {
        translate([0,0,$ledpcbh]) rotate([0,0,90]) cylinder(h=$ledl*1.5,r1=2,r2=$ledhf-.15, center=$t);
        
        translate([0,$ledw+.12,$ledpcbh]) rotate([90,0,0]) cube([$ledl*1.5,$ledw*5,$ledpcbh*3], center=$t);
        translate([0,-$ledw-.12,$ledpcbh]) rotate([90,0,0]) cube([$ledl*1.5,$ledw*5,$ledpcbh*3], center=$t);
    }
    //translate([$ledw*2-.9,0,$ledpcbh]) rotate([0,46,0]) cube([$ledl,$ledw,$ledpcbh], center=$t);
    //translate([-$ledw*2+.9,0,$ledpcbh]) rotate([0,-46,0]) cube([$ledl,$ledw,$ledpcbh], center=$t);
}

module A_half() {
    difference() {
        cube([$gl,$ol,$od], center=$t);
        translate([-1.2,-.4,0]) rotate([0,0,-$angle-$slant]) cube([1.5,.4,$od], center=$t);
        translate([1.2,-.4,0]) rotate([0,0,$angle-$slant]) cube([1,.4,$od], center=$t);
    }
    translate([.1,0,-$od/2.4]) RoundLED();
}

module G_half() {
    difference() {
        cube([$gl,$ol,$od], center=$t);
        translate([-1.2,-.5,0]) rotate([0,0,-$angle]) cube([1,.4,$od], center=$t);
        translate([-1.2,.5,0]) rotate([0,0,$angle]) cube([1,.4,$od], center=$t);
        translate([1.2,-.5,0]) rotate([0,0,$angle]) cube([1,.4,$od], center=$t);
        translate([1.2,.5,0]) rotate([0,0,-$angle]) cube([1,.4,$od], center=$t);
    }
    translate([.1,0,-$od/2.4]) RoundLED();
    //translate([0,0,-$od/2.4]) RoundLED();
}

module J() {
    difference() {
        cube([$jl,$ol,$od], center=$t);
        translate([-($jl/2)+.2,-.5,0]) rotate([0,0,-$angle+$slant]) cube([1,.4,$od], center=$t);
        translate([-($jl/2)+.2,.5,0]) rotate([0,0,$angle]) cube([1,.4,$od], center=$t);
        translate([($jl/2)-.2,-.5,0]) rotate([0,0,$angle-$slant]) cube([1,.4,$od], center=$t);
        translate([($jl/2)-.3,.5,0]) rotate([0,0,-$angle+$slant*1.5]) cube([1.2,.4,$od], center=$t);
    }
    //translate([.3,0,-$od/2.4]) RoundLED();
    translate([0,0,-$od/2.4]) rotate([0,0,$slant]) RoundLED();
    translate([0,0,-$od/2.4]) rotate([0,0,$slant]) LEDConduit();
}

module B() {   
    difference() {
        cube([$ol,$bl,$od], center=$t);
        translate([-.5,-($bl/2)-.1,0]) rotate([0,0,-$angle+$slant/2]) cube([1,1,$od], center=$t);
        translate([-.5,($bl/2)+.1,0]) rotate([0,0,-$angle-$slant/2]) cube([1,1,$od], center=$t);
    }
    //translate([0,0,-$od/2.4]) rotate([0,0,90]) RoundLED();
    //translate([0,0,-$od/2.4]) rotate([0,0,90]) LEDConduit();
}

module F() {
    //rotate([0,180,0]) B();
    mirror([0,180,0]) B();
}

module K() {
    difference() {
        cube([$ol,$kl,$od], center=$t);
        translate([-.3,-($kl/2)-.1,0]) rotate([0,0,-($angle*1.22)+($slant/2)-5]) cube([3,1.2,$od], center=$t);
        translate([.6,($kl/2)-.15,0]) rotate([0,0,($angle/1.45)+($slant/2)-1.5]) cube([1.5,3,$od], center=$t);
    }
    translate([0,0,-$od/2.4]) rotate([0,0,126]) RoundLED();
    translate([0,0,-$od/2.4]) rotate([0,0,126]) LEDConduit();
}

module H() {
    //rotate([0,180,$slant/2]) K();
    mirror([0,180,0]) {
        difference() {
            cube([$ol,$kl,$od], center=$t);
            translate([-.3,-($kl/2)-.1,0]) rotate([0,0,-($angle*1.22)+($slant/2)-5]) cube([3,1.2,$od], center=$t);
            translate([.6,($kl/2)-.15,0]) rotate([0,0,($angle/1.45)+($slant/2)-1.5]) cube([1.5,3,$od], center=$t);
        }
        translate([0,0,-$od/2.4]) rotate([0,0,118]) RoundLED();
        translate([0,0,-$od/2.4]) rotate([0,0,118]) LEDConduit();
    }
}

module DP() {
    cylinder(h=$od,r=$ol/2, center=$t);
}

module TopOpenings() {              //Arrange & Consolidate top half segments
    translate([-($gl+$os)/2,0,$h/3]) G_half();                                          //LED G1
    translate([($gl+$os)/2,0,$h/3]) G_half();                                           //LED G2
    translate([$gl+$os*1.8,$bl/2+$os/2,$h/3]) rotate([0,0,-$slant]) B();                //LED B
    translate([$gl+$os*1.8,$bl/2+$os/1.5,0.1]) rotate([0,0,90]) { RoundLED(); LEDConduit(); }
    translate([-($gl+$os*1.8)+0.453,$bl/2+$os/2,$h/3]) rotate([0,0,-$slant]) F();       //LED F
    translate([-($gl+$os*1.8)+0.453,$bl/2+$os/1.5,0.1]) rotate([0,0,90]) { RoundLED(); LEDConduit(); }
    translate([-($gl+$os)/2+0.453,$bl+$os,$h/3]) mirror([180,0,0]) A_half();            //LED A1
    translate([($gl+$os)/2+0.453,$bl+$os,$h/3]) A_half();                               //LED A2
    translate([$slo/4+.1,$jl/2+$os,$h/3]) rotate([0,0,90-$slant]) J();                  //LED J
    translate([$slo/4+1.85,$kl/1.6+$os,$h/3]) rotate([0,0,-$angle/1.4-$slant]) K();     //LED K
    translate([-($slo/4+1.45),$kl/1.6+$os,$h/3]) rotate([0,0,$angle/1.4-$slant]) H();   //LED H
}

module BottomOpenings() {           //Duplicate top half segments & mirror to make bottom half
    rotate([0,0,180]) TopOpenings();
}

module DigitOpenings() {    //Combine Top & Bottom with DP to make a full digit
    TopOpenings();
    BottomOpenings();
    translate([($gl+$os)/2+3.2,-($bl+$os),$h/3]) DP();
    translate([($gl+$os)/2+3.2,-($bl+$os),0]) rotate([0,0,90]) RoundLED();
    translate([($gl+$os)/2+3.2,-($bl+$os),0]) rotate([0,0,90]) LEDConduit();
}

module Casing() {
    difference() {
        cube([$w,$l,$h], center=$t);                                        //Main casing
        translate([0,0,-$wth*2]) cube([$w-$wth,$l-$wth,$h], center=$t);     //Hollow out casing
    }
    //translate([0,0,$w/5]) cube([$w-1.5,$l-7,2], center=$t);     //Add 
    translate([0,0,1.9]) cube([$w-1.3,$l-5,3.9], center=$t);     //Add 
}



difference() {          //Bring it all together
    Casing();
    DigitOpenings();                                                    //Digit openings
}
//translate([-($gl+$os)/2,0,0]) rotate([0,0,90]) FlatLED();                           //LED G1
//translate([0,0,-$od]) LEDConduit();
//translate([0,0,-$od]) RoundLED();
//DigitOpenings();                                                    //Digit openings