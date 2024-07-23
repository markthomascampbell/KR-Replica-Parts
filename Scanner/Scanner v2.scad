// 32mm tall, 25mm deep and 520mm across the back and 525 across the front, V is ~10 degree angle
$w=545;             //bar total width
$h=30;              //bar height 32 or 30; 25.4=1"
$d=40;              //bar depth originally 25
$a=5;               //bar angle
$dd=-4.5;           //divider position depth
$off=($w/4)-1.52;   //center position for each bar half
$t=true;            //shorthand
$r=4.11;            //diameter of circle openings
$oh=$w/16;          //spacing for holes in between dividers
$fn=100;            //how many flat surfaces to make a circle with
$sh=10.16;          //Screw offset from center, .8 distance between holes
$sr=2;              //Screw diameter
$red=4;             //Rabbit Ear depth
$reh=$h-4;          //Rabbit Ear height
//$rew=$
$rcd=19;            //Rear cover depth
$roff=$d;           //Rear cover distance from main bar
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
/*module concave () {
    difference () {
        translate ([4,-15,0]) rotate([0,0,$a]) cube([($w/8)-2,$d,$h-4], center=$t);
        minkowski() {
            translate([2,-28,0]) rotate([0,0,$a-10]) cube([($w/8)-33,$d,$h-26], center=$t);
            sphere(12);
        }
        minkowski() {
            translate([8,-28,0]) rotate([0,0,$a+10]) cube([($w/8)-33,$d,$h-26], center=$t);
            sphere(12);
        }
        minkowski() {
            translate([4,-24,0]) rotate([0,0,$a]) cube([($w/8)-35,$d,$h-26], center=$t);
            sphere(12);
        }
    }
    minkowski() {
            translate([8,-24,0]) rotate([0,-1,$a]) cube([($w/8)-33,$d,$h-26], center=$t);
            sphere(12);
    }
}*/

module barhalf () {
    union () {
        difference() {
            union () {
                cube([$w/2,$d,$h], center=$t); //half of main bar
                //translate([($w/4)+($w/40),-10.49,0]) cube([$w/20,4,$h-4], center=$t); //rabbit ears
                translate([($w/4)+($w/40),(-$d/2)+($red/2),0]) cube([$w/20,$red,$reh], center=$t); //rabbit ears
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
            translate([-$oh*3,0,0])rotate([90,0,0])cylinder(h=8,r=$r,center=$t);//LED hole 4,5
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
        cube([$w/2,$rcd,$h], center=$t); //main cover
        //translate([-2,-4,0]) cube([($w/2)-4,$d-$loff,$h-6], center=$t); //hollow the cover
        translate([-2,-4,0]) cube([($w/2)-4,$rcd,$h-6], center=$t); //hollow the cover
        translate([0,-$loff-1,$h/2])cube([$w/2,$loff,4], center=$t); //top lip of rear cover
        translate([0,-$loff-1,-$h/2])cube([$w/2,$loff,4], center=$t); //bottom lip of rear cover
        translate([$w/4,-$loff-1,0])cube([4,$loff,$h], center=$t); //side lip of rear cover
    }
    
}
//translate ([($w/8)-($w/16),-$d,0]) concave ();
difference () {
    union () {  //build main bar
        difference () {
            union() {  //merge two halves of the bar together
                rotate([0,0,$a])translate([$off,0,0]) barhalf ();                   //right side
                rotate([0,0,-$a])mirror([1,0,0])translate([$off,0,0]) barhalf ();   //left side
            }
            translate([0,-3,0]) cube([4.6,$d-1.5,$h-4], center=$t); //widen center divider
        }
        translate ([0,$dd-.4,0]) divider (); //center divider 4
    }
    //translate([$w/2,0,0]) cube([$w,$d*6,$h], center=$t); //cut in half, remove for full bar
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
        rotate([90,0,-$a])translate([-$w/2+12,0,-($h*1.6)])cylinder(h=8,r=$r+1,center=$t);//wire hole
        //translate([$w/2,0,0]) cube([$w,$d*6,$h], center=$t); //cut in half, remove for full bar
    }
}