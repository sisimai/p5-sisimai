package Sisimai::Test::Values;

our $Minus = [-1, -2, -1e1, -1e2];
our $False = [0, "0", "", undef, ()];
our $Zeros = [
    0, 0.0, 00_00, -0, +0, 0e0, 0e1, 0e-1, 0b0000, 0x0, 00, 000, 0000,
    0<<0, 0<<1, 0>>0, 0>>1, 0%1, "0", '0', q( ), qq( ),
];
our $ESCChars = ["\a", "a\b", "\t", "\n", "\f", "\r", "\0","\e"];
our $CTLChars = [
    "\c@", "\cA", "\cB", "\cC", "\cD", "\cE", "\cF", "\cG", "a\cH", "\cI", 
    "\cJ", "\cK", "\cL", "\cM", "\cN", "\cO", "\cP", "\cQ", "\cR", "\cS",
    "\cT", "\cU", "\cV", "\cW", "\cX", "\cY", "\cZ", "\c[", "\c\\", "\c]",
    "\c^", "\c_", "\c?",
];

1;
