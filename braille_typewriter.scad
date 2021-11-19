/**
Run get_deps.sh to clone dependencies into a linked folder in your home directory.
*/

use <deps.link/BOSL/nema_steppers.scad>
use <deps.link/BOSL/joiners.scad>
use <deps.link/BOSL/shapes.scad>
use <deps.link/erhannisScad/misc.scad>
use <deps.link/erhannisScad/auto_lid.scad>
use <deps.link/scadFluidics/common.scad>
use <deps.link/quickfitPlate/blank_plate.scad>
use <deps.link/getriebe/Getriebe.scad>
use <deps.link/gearbox/gearbox.scad>

$FOREVER = 1000;
DUMMY = false;
$fn = DUMMY ? 10 : 120;


DOT_SIZE = 1.44;
PEG_SIZE = 1;
DOT_SPACING = 2.34;

NEGATIVE_PLATE_SIZE = 10;

module dot() {
    difference() {
        cube(10,center=true);
        crotate([0,0,180]) crotate([0,0,90]) rx(60) OZm();
    }
}

module negativePlate() {
    difference() {
        tz(DOT_SIZE/2) cube([NEGATIVE_PLATE_SIZE, NEGATIVE_PLATE_SIZE, 2.5], center=true);
        for (x = [-0.5, 0.5]*DOT_SPACING) {
            for (y = [-1,0,1]*DOT_SPACING) {
                //translate([x, y, DOT_SIZE]) sphere(d=DOT_SIZE);
                translate([x, y, 0]) dot();
            }
        }
    }
}

CLAW_T = DOT_SIZE;
CLAW_ID = 60;
CUT_DEPTH = 5;
BUTTON_D = 15;

GRID_T = 0.5;
GRID_H = 35;

GRID_S = 125+DOT_SPACING+10;
GRID_F = 3;

module claw(ID=CLAW_ID) {
    tz(DOT_SIZE/2) rx(-90)
    translate([DOT_SIZE,DOT_SIZE,0]/2) rx(90)
    linear_extrude(height=CLAW_T) {
        BID = ID+5;
        difference() {
            union() {
                tx(BID/2-DOT_SIZE) circle(d=BID);
                tx(5) difference() {
                    square([BUTTON_D, ID/2+10]);
                    translate([BUTTON_D/2-CLAW_T/2,ID/2+10-CUT_DEPTH]) square([CLAW_T, CUT_DEPTH]);
                }
            }
            tx(ID/2) circle(d=ID);
            ty(-$FOREVER/2) square($FOREVER,center=true);
            // Peg cutoff
            tx(ID/2) square([$FOREVER, GRID_H/GRID_F]);
        }
        // Peg
        Y = GRID_H/GRID_F;
        SXI = sqrt(((ID/2)*(ID/2))-(Y*Y))+ID/2;
        SXO = sqrt((((ID+5)/2)*((ID+5)/2))-(Y*Y))+((ID+5)/2)-DOT_SIZE;
        tx(SXI) square([SXO-SXI, Y]);
    }
}

module button() {
    //TODO
    cylinder(d=BUTTON_D,h=CLAW_T);
    intersection() {
        difference() {
            tz(CUT_DEPTH+CLAW_T) cube([CLAW_T,BUTTON_D,2*CUT_DEPTH],center=true);
            tz(2*CUT_DEPTH+CLAW_T) rz(90) cube([CLAW_T,BUTTON_D,2*CUT_DEPTH],center=true);
        }
        tz(CLAW_T) cylinder(d1=BUTTON_D,d2=CLAW_T*2.5,h=2*CUT_DEPTH);
    }
}

module showClaw() {
    claw();
    tx(5+DOT_SIZE/2+BUTTON_D/2) ty(CLAW_T+CLAW_ID/2+10) rx(90) button();
}

module clawSet() {
    difference() {
        union() {
            // NE
            tx(DOT_SPACING/2) ty(DOT_SPACING) rz(60) ty(DOT_SIZE/2) rx(90) showClaw();
            // NW 
            tx(-DOT_SPACING/2) ty(DOT_SPACING) rz(120) ty(DOT_SIZE/2) rx(90) showClaw();
            // E
            tx(DOT_SPACING/2) ty(DOT_SIZE/2) rx(90) showClaw();
            // W
            tx(-DOT_SPACING/2) rz(180) ty(DOT_SIZE/2) rx(90) showClaw();
            // SE
            tx(DOT_SPACING/2) ty(-DOT_SPACING) rz(-60) ty(DOT_SIZE/2) rx(90) showClaw();
            // SW
            tx(-DOT_SPACING/2) ty(-DOT_SPACING) rz(-120) ty(DOT_SIZE/2) rx(90) showClaw();
        }
        negativePlate();
    }
}

module clawSetFlat() {
    // NE
    DY = 25;
    ty(0*DY) rx(-90) ty(-DOT_SIZE/2) rz(-60) ty(-DOT_SPACING) tx(-DOT_SPACING/2) difference() {
        tx(DOT_SPACING/2) ty(DOT_SPACING) rz(60) ty(DOT_SIZE/2) rx(90) claw();
        negativePlate();
    }
    // NW
    ty(1*DY) rx(-90) ty(-DOT_SIZE/2) rz(-120) ty(-DOT_SPACING) tx(DOT_SPACING/2) difference() {
        tx(-DOT_SPACING/2) ty(DOT_SPACING) rz(120) ty(DOT_SIZE/2) rx(90) claw();
        negativePlate();
    }
    // E
    ty(2*DY) rx(-90) ty(-DOT_SIZE/2) tx(-DOT_SPACING/2) difference() {
        tx(DOT_SPACING/2) ty(DOT_SIZE/2) rx(90) claw();
        negativePlate();
    }
    // W
    ty(3*DY) rx(-90) ty(-DOT_SIZE/2) rz(-180) tx(DOT_SPACING/2) difference() {
        tx(-DOT_SPACING/2) rz(180) ty(DOT_SIZE/2) rx(90) claw();
        negativePlate();
    }
    // SE
    ty(4*DY) rx(-90) ty(-DOT_SIZE/2) rz(60) ty(DOT_SPACING) tx(-DOT_SPACING/2) difference() {
        tx(DOT_SPACING/2) ty(-DOT_SPACING) rz(-60) ty(DOT_SIZE/2) rx(90) claw();
        negativePlate();
    }
    // SW
    ty(5*DY) rx(-90) ty(-DOT_SIZE/2) rz(120) ty(DOT_SPACING) tx(DOT_SPACING/2) difference() {
        tx(-DOT_SPACING/2) ty(-DOT_SPACING) rz(-120) ty(DOT_SIZE/2) rx(90) claw();
        negativePlate();
    }
}

module grid() {
    S = GRID_S;
    F = GRID_F;
    CAP_L = 14;
    intersection() {
        difference() {
            union() {
                linear_extrude(height=GRID_H) {
                    channel([0,S/2],[0,-S/2],d=GRID_T);
                    
                    channel([-S/2,DOT_SPACING/2],[S/2,DOT_SPACING/2],d=GRID_T);
                    channel([-S/2,-DOT_SPACING/2],[S/2,-DOT_SPACING/2],d=GRID_T);
                    channel([-S/2,0],[-S/2+CAP_L,0],d=DOT_SPACING);
                    channel([S/2,0],[S/2-CAP_L,0],d=DOT_SPACING);
                    
                    cmirror([0,1,0]) cmirror([1,0,0]) intersection() {
                        translate([DOT_SPACING/2,DOT_SPACING,0]) rz(60) {
                            channel([-S/2,DOT_SPACING/2],[S/2,DOT_SPACING/2],d=GRID_T);
                            channel([-S/2,-DOT_SPACING/2],[S/2,-DOT_SPACING/2],d=GRID_T);            
                            channel([-S/2,0],[-S/2+CAP_L,0],d=DOT_SPACING);
                            channel([S/2,0],[S/2-CAP_L,0],d=DOT_SPACING);
                        }
                        QXpYp([0,DOT_SPACING/2]);
                    }
                }
                // Outer shell
                difference() {
                    cylinder(d=S,h=$FOREVER,$fn=6);
                    cylinder(d=S-GRID_T*2*2,h=$FOREVER,$fn=6);
                }
            }
            difference() {
                tz(GRID_H/F) cylinder(d=$FOREVER, h=$FOREVER);
                cylinder(d1=GRID_H*2,d2=0,h=GRID_H);
            }
            clawSet();
        }
        cylinder(d=S,h=$FOREVER,$fn=6);
    }
}

//negativePlate();
//grid();
//clawSet();
//clawSetFlat();
//claw();
//button(); //x6
//dot();

grid();
clawSet();

//// Print these
//negativePlate();
//grid();
//clawSetFlat();
//button(); //x6
