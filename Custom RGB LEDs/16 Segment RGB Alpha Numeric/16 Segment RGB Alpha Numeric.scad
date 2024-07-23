$fn=50;
$t=true;        //Abbreviation
$angle=45;
$wth=.5;        //Wall Thickness
$l=25;          //Length
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
    translate([0,0,-$ledpcbh*3]) rotate([0,0,90]) cube([$ledw,$ledl,$ledpcbh], center=$t);
    difference() {
        translate([0,0,$ledpcbh]) rotate([0,0,90]) cylinder(h=$ledl*1.5,r1=2,r2=$ledhf-.15, center=$t);
        
        translate([0,$ledw+.22,$ledpcbh]) rotate([90,0,0]) cube([$ledl*1.5,$ledw*5,$ledpcbh*3], center=$t);
        translate([0,-$ledw-.22,$ledpcbh]) rotate([90,0,0]) cube([$ledl*1.5,$ledw*5,$ledpcbh*3], center=$t);
    }
}

module A_half() {
    difference() {
        union() {
            cube([$gl,$ol,$od], center=$t);
            translate([0,-$ol/4,1]) rotate([-4,0,0]) cube([$gl,$ol/2,$od+2], center=$t);
            translate([0,$ol/4,1]) rotate([4,0,0]) cube([$gl,$ol/2,$od+2], center=$t);
        }
        translate([-1.3,-.5,0]) rotate([0,0,-$angle-$slant]) cube([1.5,.6,$od+.1], center=$t);
        translate([1.3,-.5,0]) rotate([0,0,$angle-$slant]) cube([1.5,.6,$od+.1], center=$t);
    }
}

module G_half() {
    difference() {
        union() {
            cube([$gl,$ol,$od], center=$t);
            translate([0,-$ol/4,1]) rotate([-4,0,0]) cube([$gl,$ol/2,$od+2], center=$t);
            translate([0,$ol/4,1]) rotate([4,0,0]) cube([$gl,$ol/2,$od+2], center=$t);
        }
        translate([-1.3,-.5,0]) rotate([0,0,-$angle]) cube([1.3,.6,$od+.1], center=$t);
        translate([-1.3,.5,0]) rotate([0,0,$angle]) cube([1.3,.6,$od+.1], center=$t);
        translate([1.3,-.5,0]) rotate([0,0,$angle]) cube([1.3,.6,$od+.1], center=$t);
        translate([1.3,.5,0]) rotate([0,0,-$angle]) cube([1.3,.6,$od+.1], center=$t);
    }
}

module J() {
    difference() {
        union () {
            cube([$jl,$ol,$od], center=$t);
            translate([0,-$ol/4,1]) rotate([-4,0,0]) cube([$jl,$ol/2,$od+2], center=$t);
            translate([0,$ol/4,1]) rotate([4,0,0]) cube([$jl,$ol/2,$od+2], center=$t);
        }
        translate([-($jl/2)+.1,-.5,0]) rotate([0,0,-$angle+$slant]) cube([1.3,.5,$od+.1], center=$t);
        translate([-($jl/2)+.1,.5,0]) rotate([0,0,$angle]) cube([1.3,.5,$od+.1], center=$t);
        translate([($jl/2)-.1,-.5,0]) rotate([0,0,$angle-$slant]) cube([1.3,.5,$od+.1], center=$t);
        translate([($jl/2)-.1,.5,0]) rotate([0,0,-$angle+$slant*1.5]) cube([1.5,.6,$od+.1], center=$t);
    }
}

module B() {   
    difference() {
        union() {
            cube([$ol,$bl,$od], center=$t);
            translate([-$ol/4,0,1]) rotate([0,4,0]) cube([$ol/2,$bl,$od+2], center=$t);
            translate([$ol/4,0,1]) rotate([0,-2,0]) cube([$ol/2,$bl,$od+2], center=$t);
        }
        translate([-.5,-($bl/2)-.1,0]) rotate([0,0,-$angle+$slant/2]) cube([1.6,1,$od+.1], center=$t);
        translate([-.5,($bl/2)+.1,0]) rotate([0,0,-$angle-$slant/2]) cube([1,1.6,$od+.1], center=$t);
    }
}

module F() {
    mirror([180,0,0]) B();
}

module K() {
    difference() {
        union() {
            cube([$ol,$kl,$od], center=$t);
            translate([-$ol/4,0,1]) rotate([0,4,0]) cube([$ol/2,$kl,$od+2], center=$t);
            translate([$ol/4,0,1]) rotate([0,-4,0]) cube([$ol/2,$kl,$od+2], center=$t);
        }
        translate([-.3,-($kl/2)-.1,0]) rotate([0,0,-($angle*1.22)+($slant/2)-5]) cube([3.5,1.2,$od+.1], center=$t);
        translate([.6,($kl/2)-.15,0]) rotate([0,0,($angle/1.45)+($slant/2)-1.5]) cube([1.5,3,$od+.1], center=$t);
    }
}

module H() {
    mirror([0,180,0]) {
        difference() {
            union() {
                cube([$ol,$kl,$od], center=$t);
                translate([-$ol/4,0,1]) rotate([0,4,0]) cube([$ol/2,$kl,$od+2], center=$t);
                translate([$ol/4,0,1]) rotate([0,-4,0]) cube([$ol/2,$kl,$od+2], center=$t);
            }
            translate([-.3,-($kl/2)-.1,0]) rotate([0,0,-($angle*1.22)+($slant/2)-5]) cube([4,1.2,$od+.1], center=$t);
            translate([.6,($kl/2)-.15,0]) rotate([0,0,($angle/1.45)+($slant/2)-1.5]) cube([1.5,3,$od+.1], center=$t);
        }
    }
}

module DP() {
    cylinder(h=$od,r=$ol/2, center=$t);
}

module TopOpenings() {              //Arrange & Consolidate top half segments
    translate([-($gl+$os)/2,0,$h/3]) G_half();                                          //LED G1
    translate([($gl+$os)/2,0,$h/3]) G_half();                                           //LED G2
    translate([$gl+$os*1.8,$bl/2+$os/2,$h/3]) rotate([0,0,-$slant]) B();                //LED B
    translate([-($gl+$os*1.8)+0.453,$bl/2+$os/2,$h/3]) rotate([0,0,-$slant]) F();       //LED F
    translate([-($gl+$os)/2+0.453,$bl+$os-.1,$h/3]) mirror([180,0,0]) A_half();         //LED A1
    translate([($gl+$os)/2+0.453,$bl+$os-.1,$h/3]) A_half();                            //LED A2
    translate([$slo/4+.1,$jl/2+$os-.1,$h/3]) rotate([0,0,90-$slant]) J();               //LED J
    translate([$slo/4+1.85,$kl/1.7+$os,$h/3]) rotate([0,0,-$angle/1.4-$slant]) K();     //LED K
    translate([-($slo/4+1.45),$kl/1.7+$os,$h/3]) rotate([0,0,$angle/1.4-$slant]) H();   //LED H
}

module BottomOpenings() {           //Duplicate top half segments & mirror to make bottom half
    rotate([0,0,180]) TopOpenings();
}

module DigitOpenings() {            //Combine Top & Bottom with DP to make a full digit
    TopOpenings();
    BottomOpenings();
    translate([($gl+$os)/2+3,-($bl+$os),$h/3]) DP();
    translate([($gl+$os)/2+3,-($bl+$os),0]) rotate([0,0,90]) FlatLED();
    translate([($gl+$os)/2+3,-($bl+$os),0]) rotate([0,0,90]) LEDConduit();
}

module Casing() {
    difference() {
        cube([$w,$l,$h], center=$t);                                                    //Main casing
        translate([0,0,-$wth*2]) cube([$w-$wth,$l-$wth,$h], center=$t);                 //Hollow out casing
    }
    //translate([0,0,1.9]) cube([$w-1.3,$l-5,3.9], center=$t);     //Add 
    translate([0,0,1.9]) cube([$w-1.3,16,3.9], center=$t);     //Add 
}

module FullDigit() {
    difference() {                  //Bring it all together
        Casing();
        DigitOpenings();
    }
}

module FullDigitL() {
    difference() {                  //Bring it all together
        Casing();
        DigitOpenings();
        translate([$w*.605,0,0]) cube([4,$l,$h], center=$t);
    }
}

module FullDigitC() {
    difference() {                  //Bring it all together
        Casing();
        DigitOpenings();
        translate([$w*.605,0,0]) cube([4,$l,$h], center=$t);
        translate([-$w*.55,0,0]) cube([4,$l,$h], center=$t);
    }
}

module FullDigitR() {
    difference() {                  //Bring it all together
        Casing();
        DigitOpenings();
        translate([-$w*.55,0,0]) cube([4,$l,$h], center=$t);
    }
}

$DigitDivider=2.5;
$ZOffset=-4;    //.1 for measuring inside, -4 for measuring outside, 3.9 for rear outer edge

translate([($w-$DigitDivider)/2,0,$ZOffset]) FullDigitC();      // Digit 6
translate([-($w-$DigitDivider)/2,0,$ZOffset]) FullDigitC();     // Digit 5
translate([($w-$DigitDivider)*1.5,0,$ZOffset]) FullDigitC();    // Digit 7
translate([-($w-$DigitDivider)*1.5,0,$ZOffset]) FullDigitC();   // Digit 4
translate([($w-$DigitDivider)*2.5,0,$ZOffset]) FullDigitC();    // Digit 8
translate([-($w-$DigitDivider)*2.5,0,$ZOffset]) FullDigitC();   // Digit 3
translate([($w-$DigitDivider)*3.5,0,$ZOffset]) FullDigitC();    // Digit 9
translate([-($w-$DigitDivider)*3.5,0,$ZOffset]) FullDigitC();   // Digit 2
translate([($w-$DigitDivider)*4.5,0,$ZOffset]) FullDigitR();    // Digit 10
translate([-($w-$DigitDivider)*4.5,0,$ZOffset]) FullDigitL();   // Digit 1
