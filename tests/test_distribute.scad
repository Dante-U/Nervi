include <../src/_core/distribute.scad>

test_segmentsCrossing();

module test_segmentsCrossing() {

	mask = square([10, 6], center=true);
	segs = segmentsCrossing(origin=LEFT, mask=mask, spacing=1.5, dir=VERTICAL);
	#stroke(segs, width=0.2);	

}