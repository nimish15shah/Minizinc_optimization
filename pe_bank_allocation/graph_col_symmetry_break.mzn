
include "globals.mzn"; 

int: MAX_COL=3;

var 0..MAX_COL: e_1_8;
var 0..MAX_COL: e_1_9;
var 0..MAX_COL: e_2_7;
var 0..MAX_COL: e_2_9;
var 0..MAX_COL: e_3_6;
var 0..MAX_COL: e_3_8;
var 0..MAX_COL: e_4_6;
var 0..MAX_COL: e_4_7;
var 0..MAX_COL: e_5_6;
var 0..MAX_COL: e_5_7;
var 0..MAX_COL: e_5_8;
var 0..MAX_COL: e_5_9;
var 0..MAX_COL: e_6_3;
var 0..MAX_COL: e_6_4;
var 0..MAX_COL: e_6_5;
var 0..MAX_COL: e_7_2;
var 0..MAX_COL: e_7_4;
var 0..MAX_COL: e_7_5;
var 0..MAX_COL: e_8_1;
var 0..MAX_COL: e_8_3;
var 0..MAX_COL: e_8_5;
var 0..MAX_COL: e_9_1;
var 0..MAX_COL: e_9_2;
var 0..MAX_COL: e_9_5;

array[1..9] of var 0..MAX_COL: r_1= [0, 0, 0, 0, 0, 0, 0, e_1_8, e_1_9];
array[1..9] of var 0..MAX_COL: r_2= [0, 0, 0, 0, 0, 0, e_2_7, 0, e_2_9];
array[1..9] of var 0..MAX_COL: r_3= [0, 0, 0, 0, 0, e_3_6, 0, e_3_8, 0];
array[1..9] of var 0..MAX_COL: r_4= [0, 0, 0, 0, 0, e_4_6, e_4_7, 0, 0];
array[1..9] of var 0..MAX_COL: r_5= [0, 0, 0, 0, 0, e_5_6, e_5_7, e_5_8, e_5_9];
array[1..9] of var 0..MAX_COL: r_6= [0, 0, e_6_3, e_6_4, e_6_5, 0, 0, 0, 0];
array[1..9] of var 0..MAX_COL: r_7= [0, e_7_2, 0, e_7_4, e_7_5, 0, 0, 0, 0];
array[1..9] of var 0..MAX_COL: r_8= [e_8_1, 0, e_8_3, 0, e_8_5, 0, 0, 0, 0];
array[1..9] of var 0..MAX_COL: r_9= [e_9_1, e_9_2, 0, 0, e_9_5, 0, 0, 0, 0];


constraint alldifferent_except_0(r_1);
constraint alldifferent_except_0(r_2);
constraint alldifferent_except_0(r_3);
constraint alldifferent_except_0(r_4);
constraint alldifferent_except_0(r_5);
constraint alldifferent_except_0(r_6);
constraint alldifferent_except_0(r_7);
constraint alldifferent_except_0(r_8);
constraint alldifferent_except_0(r_9);

%constraint lex_greater(reverse(r_2), reverse(r_1));
%constraint lex_greater(reverse(r_3), reverse(r_2));
%constraint lex_greater(reverse(r_4), reverse(r_3));
%constraint lex_greater(reverse(r_5), reverse(r_4));
%constraint lex_greater(reverse(r_6), reverse(r_5));
%constraint lex_greater(reverse(r_7), reverse(r_6));
%constraint lex_greater(reverse(r_8), reverse(r_7));
%constraint lex_greater(reverse(r_9), reverse(r_8));
%

%constraint e_9_1= 1;

%constraint lex_greater(r_2, r_1);
%constraint lex_greater(r_3, r_2);
%constraint lex_greater(r_4, r_3);
%constraint lex_greater(r_5, r_4);
%constraint lex_greater(r_6, r_5);
%constraint lex_greater(r_7, r_6);
%constraint lex_greater(r_8, r_7);
%constraint lex_greater(r_9, r_8);

%constraint seq_precede_chain([
%e_1_8,
%e_1_9,
%e_2_7,
%e_2_9,
%e_3_6,
%e_3_8,
%e_4_6,
%e_4_7,
%e_5_6,
%e_5_7,
%e_5_8,
%e_5_9,
%e_6_3,
%e_6_4,
%e_6_5,
%e_7_2,
%e_7_4,
%e_7_5,
%e_8_1,
%e_8_3,
%e_8_5,
%e_9_1,
%e_9_2,
%e_9_5 
%  ]);

var int: obj= sum(r_1) + 
  sum(r_2) +
  sum(r_3) +
  sum(r_4) +
  sum(r_5) +
  sum(r_6) +
  sum(r_7) +
  sum(r_8) +
  sum(r_9);

solve maximize obj;

output [
    "r_1= \(r_1) \n",
    "r_2= \(r_2) \n",
    "r_3= \(r_3) \n",
    "r_4= \(r_4) \n",
    "r_5= \(r_5) \n",
    "r_6= \(r_6) \n",
    "r_7= \(r_7) \n",
    "r_8= \(r_8) \n",
    "r_9= \(r_9) \n",
    "obj = \(obj) \n"
  ];
