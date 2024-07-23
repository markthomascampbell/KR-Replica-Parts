$fn=50;
$t=true;        //Abbreviation
$wth=.5;        //Wall Thickness
$l=40;          //Length
$w=30;          //Width
$h=8;           //Height
$ow=5;          //LED Opening Width
$oiw=3.5;       //LED Opening Inside Width
$ol=2;          //LED Opening length
$os=.5;         //LED Opening Spacing
$ols=$ol+$os;   //Distance per LED
$olso=$ols/2;   //Offset for Center
$olsho=$olso+$ols;  //Offset for conduit walls
$od=4;          //LED Opening Depth

module ledopening() {
    cube([$ow,$ol,$wth*4], center=$t);
}

module 3ledopening() {
    ledopening();
    translate([10,0,0]) ledopening();
    translate([-10,0,0]) ledopening();
}

module ledconduit() {
    difference() {
        difference() {
            rotate([0,0,45]) cylinder($h/2, $oiw-.5, $ow-1, $fn=4, center=$t);
            translate([0,$olsho+.001,0]) cube([$ow*2,$ow,$ow], center=$t);
            translate([0,-$olsho-.001,0]) cube([$ow*2,$ow,$ow], center=$t);
        }
        difference() {
            rotate([0,0,45]) translate([0,0,1]) cylinder($h/2, $oiw-1, $ow-1, $fn=4, center=$t);
            translate([0,3.5,1]) cube([$ow*2,$ow,$ow], center=$t);
            translate([0,-3.5,.51]) cube([$ow*2,$ow,$ow], center=$t);
        }
        translate([0,0,-1]) cube([$ow-$olso,$ol,$h/4], center=$t);
    }
    //translate([10,0,0]) cube([.5,2.5,4], center=$t);
    //translate([-10,0,0]) cube([.5,2.5,4], center=$t);
}

module 3ledconduit() {
    ledconduit();
    translate([10,0,0]) ledconduit();
    translate([-10,0,0]) ledconduit();
}

difference() {
    cube([$w,$l,$h], center=$t);
    translate([0,0,-$wth*2]) cube([$w-$wth,$l-$wth,$h], center=$t);
    translate([0,$olso,$h/2]) 3ledopening();         //LED #8
    translate([0,-$olso,$h/2]) 3ledopening();        //LED #9
    translate([0,$olso+$ols,$h/2]) 3ledopening();    //LED #7
    translate([0,-$olso-$ols,$h/2]) 3ledopening();   //LED #10
    translate([0,$olso+$ols*2,$h/2]) 3ledopening();  //LED #6
    translate([0,-$olso-$ols*2,$h/2]) 3ledopening(); //LED #11
    translate([0,$olso+$ols*3,$h/2]) 3ledopening();  //LED #5
    translate([0,-$olso-$ols*3,$h/2]) 3ledopening(); //LED #12
    translate([0,$olso+$ols*4,$h/2]) 3ledopening();  //LED #4
    translate([0,-$olso-$ols*4,$h/2]) 3ledopening(); //LED #13
    translate([0,$olso+$ols*5,$h/2]) 3ledopening();  //LED #3
    translate([0,-$olso-$ols*5,$h/2]) 3ledopening(); //LED #14
    translate([0,$olso+$ols*6,$h/2]) 3ledopening();  //LED #2
    translate([0,-$olso-$ols*6,$h/2]) 3ledopening(); //LED #15
    translate([0,$olso+$ols*7,$h/2]) 3ledopening();  //LED #1
    translate([0,-$olso-$ols*7,$h/2]) 3ledopening(); //LED #16
}
//translate([0,$olso,$h]) 3ledconduit();
translate([0,$olso,1]) 3ledconduit();                //LED Conduit #8
translate([0,-$olso,1]) 3ledconduit();               //LED Conduit #9
translate([0,$olso+$ols,1]) 3ledconduit();           //LED Conduit #7
translate([0,-$olso-$ols,1]) 3ledconduit();          //LED Conduit #10
translate([0,$olso+$ols*2,1]) 3ledconduit();         //LED Conduit #6
translate([0,-$olso-$ols*2,1]) 3ledconduit();        //LED Conduit #11
translate([0,$olso+$ols*3,1]) 3ledconduit();         //LED Conduit #5
translate([0,-$olso-$ols*3,1]) 3ledconduit();        //LED Conduit #12
translate([0,$olso+$ols*4,1]) 3ledconduit();         //LED Conduit #4
translate([0,-$olso-$ols*4,1]) 3ledconduit();        //LED Conduit #13
translate([0,$olso+$ols*5,1]) 3ledconduit();         //LED Conduit #3
translate([0,-$olso-$ols*5,1]) 3ledconduit();        //LED Conduit #14
translate([0,$olso+$ols*6,1]) 3ledconduit();         //LED Conduit #2
translate([0,-$olso-$ols*6,1]) 3ledconduit();        //LED Conduit #15
translate([0,$olso+$ols*7,1]) 3ledconduit();         //LED Conduit #1
translate([0,-$olso-$ols*7,1]) 3ledconduit();        //LED Conduit #16