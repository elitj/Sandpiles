# Sandpiles

Imagine a tall pile of sand balanced precariously in a narrow column over a flat surface.
The pile will be unstable, sending a wave of grains of sand propagating outward. The base of
the pile will enlarge, reducing the slope of its upper surface until the pile stabilizes and sand
stops moving. This is not to say the sand is far from instability. A single extra grain placed
in an arbitrary location might be enough to cause another chain reaction through part or all
of the pile.

Although physical grains of sand move continuously into an infinity of possible states, in
certain circumstances it may be warranted to consider a discrete model with a finite number
of positions. A 1987 paper, "Self-Organized Criticality: An explanation of the 1/f noise", by 
Bak, Tang and Weisenfeld proposed such a model, which has since developed into the abelian 
sandpile. The authors use the model as an explanatory framework for the widespread phenomenon of
"pink noise," where power spectral density and noise frequency are more or less inversely 
related.  Later contributions by Dhar and many others have expanded and generalized the theory.

The scripts here allow the modeling and display of abelian sandpiles on various tessellating 
grids.  Further, certain optimizations can be made when both the grid and the initial 
configuration share one or more symmetries.  These optimizations have been made in 
wedge_hex_grid.sage and wedge_square_grid.sage.  
