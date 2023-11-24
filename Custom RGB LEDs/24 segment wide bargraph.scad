$fn=50;
$t=true;        //Abbreviation
$wth=1;         //Wall Thickness
$l=116;         //Length
$w=7;           //Width
$h=8;           //Height
$ow=4;          //LED Opening Width
$oiw=3.5;       //LED Opening Inside Width
$ol=2;          //LED Opening length
$os=.25;        //LED Opening Spacing
$ols=$ow+$os;   //Distance per LED
$olso=6;      //Offset for Center
$od=4;          //LED Opening Depth

module ledopening() {
    rotate([0,0,90]) cube([$ow,$ol,$wth*4], center=$t);
}

module ledconduit() {
    difference() {
        cube([$ol+1, $ow+$os*2, $h/2], center=$t);
        cube([$ol, $ow, $h/2], center=$t);
    }
    translate([($w/2)-$wth+.25,0,0]) cube([.5,$ols,$h/2], center=$t);
    translate([-($w/2)+$wth-.25,0,0]) cube([.5,$ols,$h/2], center=$t);
}

difference() {
    cube([$w,$l,$h], center=$t);
    translate([0,0,-$wth*2]) cube([$w-$wth,$l-$wth,$h], center=$t);
    translate([0,$olso,$h/2]) ledopening();         //LED #6
    translate([0,-$olso,$h/2]) ledopening();        //LED #7
    translate([0,$olso+$ols,$h/2]) ledopening();    //LED #5
    translate([0,-$olso-$ols,$h/2]) ledopening();   //LED #8
    translate([0,$olso+$ols*2,$h/2]) ledopening();  //LED #4
    translate([0,-$olso-$ols*2,$h/2]) ledopening(); //LED #9
    translate([0,$olso+$ols*3,$h/2]) ledopening();  //LED #3
    translate([0,-$olso-$ols*3,$h/2]) ledopening(); //LED #10
    translate([0,$olso+$ols*4,$h/2]) ledopening();  //LED #2
    translate([0,-$olso-$ols*4,$h/2]) ledopening(); //LED #11
    translate([0,$olso+$ols*5,$h/2]) ledopening();  //LED #1
    translate([0,-$olso-$ols*5,$h/2]) ledopening(); //LED #12
    translate([0,$olso+$ols*6,$h/2]) ledopening();  //LED #1
    translate([0,-$olso-$ols*6,$h/2]) ledopening(); //LED #12
    translate([0,$olso+$ols*7,$h/2]) ledopening();  //LED #1
    translate([0,-$olso-$ols*7,$h/2]) ledopening(); //LED #12
    translate([0,$olso+$ols*8,$h/2]) ledopening();  //LED #1
    translate([0,-$olso-$ols*8,$h/2]) ledopening(); //LED #12
    translate([0,$olso+$ols*9,$h/2]) ledopening();  //LED #1
    translate([0,-$olso-$ols*9,$h/2]) ledopening(); //LED #12
    translate([0,$olso+$ols*10,$h/2]) ledopening();  //LED #1
    translate([0,-$olso-$ols*10,$h/2]) ledopening(); //LED #12
    translate([0,$olso+$ols*11,$h/2]) ledopening();  //LED #1
    translate([0,-$olso-$ols*11,$h/2]) ledopening(); //LED #12
}
//translate([0,$olso,$h]) ledconduit();
translate([0,$olso,1]) ledconduit();                //LED Conduit #6
translate([0,-$olso,1]) ledconduit();               //LED Conduit #7
translate([0,$olso+$ols,1]) ledconduit();           //LED Conduit #5
translate([0,-$olso-$ols,1]) ledconduit();          //LED Conduit #8
translate([0,$olso+$ols*2,1]) ledconduit();         //LED Conduit #4
translate([0,-$olso-$ols*2,1]) ledconduit();        //LED Conduit #9
translate([0,$olso+$ols*3,1]) ledconduit();         //LED Conduit #3
translate([0,-$olso-$ols*3,1]) ledconduit();        //LED Conduit #10
translate([0,$olso+$ols*4,1]) ledconduit();         //LED Conduit #2
translate([0,-$olso-$ols*4,1]) ledconduit();        //LED Conduit #11
translate([0,$olso+$ols*5,1]) ledconduit();         //LED Conduit #1
translate([0,-$olso-$ols*5,1]) ledconduit();        //LED Conduit #12
translate([0,$olso+$ols*6,1]) ledconduit();         //LED Conduit #1
translate([0,-$olso-$ols*6,1]) ledconduit();        //LED Conduit #12
translate([0,$olso+$ols*7,1]) ledconduit();         //LED Conduit #1
translate([0,-$olso-$ols*7,1]) ledconduit();        //LED Conduit #12
translate([0,$olso+$ols*8,1]) ledconduit();         //LED Conduit #1
translate([0,-$olso-$ols*8,1]) ledconduit();        //LED Conduit #12
translate([0,$olso+$ols*9,1]) ledconduit();         //LED Conduit #1
translate([0,-$olso-$ols*9,1]) ledconduit();        //LED Conduit #12
translate([0,$olso+$ols*10,1]) ledconduit();         //LED Conduit #1
translate([0,-$olso-$ols*10,1]) ledconduit();        //LED Conduit #12
translate([0,$olso+$ols*11,1]) ledconduit();         //LED Conduit #1
translate([0,-$olso-$ols*11,1]) ledconduit();        //LED Conduit #12