// thickness of oxide
t = 3;

// inner radius
Ri = 14;

// outer radius
Ro = 25;

// height
H = 30;

// Oxide element size
ev = 0.0625;
Nv = Ceil(H/ev/2)+1;
eh = 0.0625;
Nh = Ceil(t/eh/2)+1;

// Metal element size
e = 5;

Point(1) = {Ri, 0, 0, 1};
Point(2) = {Ri, H, 0, 1};
Point(3) = {Ro, H, 0, e};
Point(4) = {Ro, 0, 0, e};

Point(5) = {Ri+t, H, 0, 1};
Point(6) = {Ri+t, 0, 0, 1};

Line(1) = {1, 2};
Line(2) = {2, 5};
Line(3) = {5, 3};
Line(4) = {3, 4};
Line(5) = {4, 6};
Line(6) = {6, 1};
Line(7) = {5, 6};

Line Loop(1) = {1, 2, 7, 6};
Line Loop(2) = {-7, 3, 4, 5};

Plane Surface(1) = {1};
Plane Surface(2) = {2};

Transfinite Line {1, -7} = Nv;
Transfinite Line {2, -6} = Nh;
Transfinite Surface {1};

Recombine Surface {1, 2};

Physical Surface("all") = {1, 2};
Physical Line("left") = {1};
Physical Line("top_oxide") = {2};
Physical Line("top_metal") = {3};
Physical Line("right") = {4};
Physical Line("bottom_oxide") = {6};
Physical Line("bottom_metal") = {5};
