$fn=50;
$t=true;        //Abbreviation
$wth=.5;        //Wall Thickness
$l=20;          //Length
$w=10;          //Width
$h=8;           //Height
$ow=5;          //LED Opening Width
$oiw=3.5;       //LED Opening Inside Width
$ol=2;          //LED Opening length
$os=.5;         //LED Opening Spacing
$ols=$ol+$os;   //Distance per LED
$olso=$ols/2;   //Offset for Center
$od=4;          //LED Opening Depth

module ledopening() {
    cube([$ow,$ol,$wth*4], center=$t);
}

module ledconduit() {
    difference() {
        difference() {
            rotate([0,0,45]) cylinder($h/2, $oiw-.5, $ow-1, $fn=4, center=$t);
            translate([0,3.751,0]) cube([$ow*2,$ow,$ow], center=$t);
            translate([0,-3.751,0]) cube([$ow*2,$ow,$ow], center=$t);
        }
        difference() {
            rotate([0,0,45]) translate([0,0,1]) cylinder($h/2, $oiw-1, $ow-1, $fn=4, center=$t);
            translate([0,3.5,1]) cube([$ow*2,$ow,$ow], center=$t);
            translate([0,-3.5,.51]) cube([$ow*2,$ow,$ow], center=$t);
        }
        translate([0,0,-1]) cube([$ow-$olso,$ol,$h/4], center=$t);
    }
    translate([4.5,0,0]) cube([.5,2.5,4], center=$t);
    translate([-4.5,0,0]) cube([.5,2.5,4], center=$t);
}

difference() {
    cube([$w,$l,$h], center=$t);
    translate([0,0,-$wth*2]) cube([$w-$wth,$l-$wth,$h], center=$t);
    translate([0,$olso,$h/2]) ledopening();         //LED #4
    translate([0,-$olso,$h/2]) ledopening();        //LED #5
    translate([0,$olso+$ols,$h/2]) ledopening();    //LED #3
    translate([0,-$olso-$ols,$h/2]) ledopening();   //LED #6
    translate([0,$olso+$ols*2,$h/2]) ledopening();  //LED #2
    translate([0,-$olso-$ols*2,$h/2]) ledopening(); //LED #7
    translate([0,$olso+$ols*3,$h/2]) ledopening();  //LED #1
    translate([0,-$olso-$ols*3,$h/2]) ledopening(); //LED #8
}
//translate([0,$olso,$h]) ledconduit();
translate([0,$olso,1]) ledconduit();                //LED Conduit #4
translate([0,-$olso,1]) ledconduit();               //LED Conduit #5
translate([0,$olso+$ols,1]) ledconduit();           //LED Conduit #3
translate([0,-$olso-$ols,1]) ledconduit();          //LED Conduit #6
translate([0,$olso+$ols*2,1]) ledconduit();         //LED Conduit #2
translate([0,-$olso-$ols*2,1]) ledconduit();        //LED Conduit #7
translate([0,$olso+$ols*3,1]) ledconduit();         //LED Conduit #1
translate([0,-$olso-$ols*3,1]) ledconduit();        //LED Conduit #8