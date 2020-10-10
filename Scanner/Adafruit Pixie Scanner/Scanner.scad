// 32mm tall, 25mm deep and 520mm across the back and 525 across the front, V is ~10 degree angle
$w=545;             //bar total width
$h=30;              //bar height
$d=25;              //bar depth
$a=5;               //bar angle
$dd=-4.5;           //divider position depth
$off=($w/4)-1.52;   //center position for each bar half
$t=true;            //shorthand
$r=4.11;            //diameter of circle openings
$oh=$w/16;          //spacing for holes in between dividers
$fn=50;             //how many flat surfaces to make a circle with
$sh=10.16;          //Screw offset from center, .8 distance between holes
$sr=2;              //Screw diameter
$roff=30;           //Rear cover distance from main bar
$loff=6;            //depth of lip on rear cover

module divider () {
    union () {
        rotate([0,0,$a])translate([-1,1,0])cube([2,$d-10,$h], center=$t); //flange out left
        rotate([0,0,-$a])translate([1,1,0])cube([2,$d-10,$h], center=$t); //flange out right
        translate([0,-.15,0]) cube([2.855,$d-11.8,$h], center=$t); //smooth out front of divider
        translate([0,1.85,0]) cube([2.855,$d-11.8,$h], center=$t); //smooth out rear of divider
    }
}
module screwset () {
    translate([0,0,$sh])rotate([90,0,0])cylinder(h=8,r=$sr,center=$t);  //upper screw hole
    translate([0,0,-$sh])rotate([90,0,0])cylinder(h=8,r=$sr,center=$t); //lower screw hole
}
module barhalf () {
    union () {
        difference() {
            union () {
                cube([$w/2,$d,$h], center=$t); //half of main bar
                translate([($w/4)+($w/40),-10.49,0]) cube([$w/20,4,$h-4], center=$t); //rabbit ears
            }
            //translate([0,-4,0]) cube([($w/2)-4,$d,$h-4], center=$t);
            translate([-1,0,0]) cube([($w/2)-2,$d,$h-4], center=$t); //hollow the bar
        }
        translate ([0,$dd,0]) divider ();       //dividers 2,6
        translate ([$w/8,$dd,0]) divider ();    //dividers 1,7
        translate ([-$w/8,$dd,0]) divider ();   //dividers 3,5
        difference (){
            translate ([0,3,0]) cube([($w/2),1,$h], center=$t); //backend divider
            // Holes for LEDs
            translate([$oh,0,0])rotate([90,0,0])cylinder(h=8,r=$r,center=$t);   //LED hole 2,7
            translate([-$oh,0,0])rotate([90,0,0])cylinder(h=8,r=$r,center=$t);  //LED hole 3,6
            translate([$oh*3,0,0])rotate([90,0,0])cylinder(h=8,r=$r,center=$t); //LED hole 1,8
            translate([-$oh*3,0,0])rotate([90,0,0])cylinder(h=8,r=$r,center=$t);//LED hold 4,5
            // Holes for LED screwmounts
            translate([$oh,0,0])screwset();     //screw hole set 2,7
            translate([-$oh,0,0])screwset();    //screw hole set 3,6
            translate([$oh*3,0,0])screwset();   //screw hole set 1,8
            translate([-$oh*3,0,0])screwset();  //screw hole set 4,5
        }
    }
}
module rearhalf () {
    difference () {
        cube([$w/2,$d-$loff,$h], center=$t); //main cover
        translate([-2,-4,0]) cube([($w/2)-4,$d-$loff,$h-6], center=$t); //hollow the cover
        translate([0,-$loff-1,$h/2])cube([$w/2,$loff,4], center=$t); //top lip of rear cover
        translate([0,-$loff-1,-$h/2])cube([$w/2,$loff,4], center=$t); //bottom lip of rear cover
        translate([$w/4,-$loff-1,0])cube([4,$loff,$h], center=$t); //side lip of rear cover
    }
    
}

difference () {
    union () {  //build main bar
        difference () {
            union() {
                rotate([0,0,$a])translate([$off,0,0]) barhalf ();                   //right side
                rotate([0,0,-$a])mirror([1,0,0])translate([$off,0,0]) barhalf ();   //left side
            }
            translate([0,-3,0]) cube([4.6,$d-1.5,$h-4], center=$t); //widen center divider
        }
        translate ([0,$dd-.4,0]) divider (); //center divider 4
    }
    //translate([$w/2,0,0]) cube([$w,$d*6,$h], center=$t); //uncomment to cut main bar in half, for printing
}
union () {  //build rear cover
    difference () {
        union () {
            rotate([0,0,$a])translate([$off,$roff,0]) rearhalf ();                   //right side
            rotate([0,0,-$a])mirror([1,0,0])translate([$off,$roff,0]) rearhalf ();   //left side
            
        }
        //The following lines smooth the inner lip to fit snug
        rotate([0,0,-$a])translate([-4,$roff-10.5,0]) cube([10,2,$h],center=$t);
        rotate([0,0,$a])translate([4,$roff-10.5,0]) cube([10,2,$h],center=$t);
        rotate([0,0,-$a])translate([-5,$roff-($loff/2)-2,$h/2]) cube([10,2,4],center=$t);
        rotate([0,0,$a])translate([5,$roff-($loff/2)-2,$h/2]) cube([10,2,4],center=$t);
        rotate([0,0,-$a])translate([-5,$roff-($loff/2)-2,-$h/2]) cube([10,2,4],center=$t);
        rotate([0,0,$a])translate([5,$roff-($loff/2)-2,-$h/2]) cube([10,2,4],center=$t);
        rotate([90,0,-$a])translate([-$w/2+12,0,-($h+8)])cylinder(h=8,r=$r+1,center=$t);//wire hole
        //translate([$w/2,0,0]) cube([$w,$d*6,$h], center=$t); //uncomment to cut rear cover in half, for printing
    }
}
