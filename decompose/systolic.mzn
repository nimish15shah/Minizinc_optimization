int : N;
int : V;
int : V_internal_last;
int : V_leaf_start;
set of int: VERTICES= 1..V;

array[1..V_internal_last] of VERTICES: pred_0;
array[1..V_internal_last] of VERTICES: pred_1;

array [1..N, 1..N] of var 0..V_internal_last: mapped_v;
array [1..N, 1..N] of var VERTICES: mapped_e;
array [1..N, 1..N] of var bool: pe_active;

var int: total_active_pe;

constraint forall (x in 2..N) (
    forall (y in 2..N) (
      if (mapped_v[x, y] != 0) then
        ((mapped_e[ x-1, y] = pred_0 [mapped_v [x, y]]) \/ (mapped_e [x, y-1] = pred_0 [mapped_v [x, y]] )) /\
        ((mapped_e[ x-1, y] = pred_1 [mapped_v [x, y]]) \/ (mapped_e [x, y-1] = pred_1 [mapped_v [x, y]] )) /\
        (mapped_e[ x, y] = mapped_v [ x, y])
      else
        mapped_e [x, y] = mapped_e [x-1, y] \/
        mapped_e [x, y] = mapped_e [x, y-1]
      endif
    )
  );

% first row of systolic array
constraint forall (x in 2..N) (
    if (mapped_v[x, 1] != 0) then
      ((mapped_e[ x-1, 1] = pred_0 [mapped_v [x, 1]]) \/ (mapped_e[ x-1, 1] = pred_1 [mapped_v [x, 1]])) /\
      (mapped_e[ x, 1] = mapped_v [ x, 1])
    endif
  );

% first column of systolic array
constraint forall (y in 2..N) (
    if (mapped_v[1, y] != 0) then
      ((mapped_e[ 1, y-1] = pred_0 [mapped_v [1, y]]) \/ (mapped_e[ 1, y-1] = pred_1 [mapped_v [1, y]])) /\
      (mapped_e[ 1, y] = mapped_v [ 1, y])
    endif
  );
 
% activity indicator
constraint forall (x in 1..N) (
    forall (y in 1..N) (
      pe_active[x, y] = (mapped_v[x, y] != 0)
    )
  );
constraint mapped_v[1, 1] = mapped_e [1,1];

% symmetry break
constraint mapped_v[1, 1] != 0;

% diagonal symmetry break
constraint sum([pe_active[x, y] | x in 2..N, y in 1..x]) <= 
           sum([pe_active[x, y] | y in 2..N, x in 1..y]);

% if all the "previous" nodes in the row and column of a node at (x, y) and at (x-1, y-1) are free (including (x-1, y-1)), use (x-1, y-1) instead of x,y
constraint forall (x in 2..N) (
    forall (y in 2..N) (
      pe_active[x, y] <= (
        sum([pe_active[x, curr_y] | curr_y in 1..y-1]) +
        sum([pe_active[x-1, curr_y] | curr_y in 1..y-1]) +
        sum([pe_active[curr_x, y] | curr_x in 1..x-1]) +
        sum([pe_active[curr_x, y-1] | curr_x in 1..x-1])
      )
    )
  );
 

include "alldifferent_except_0.mzn";
constraint alldifferent_except_0(mapped_v);

constraint total_active_pe = sum(pe_active);

solve maximize total_active_pe;

%output ["total_active_pe = \(total_active_pe) \n",
%  "pe_active = \(pe_active)\n",
%  "mapped_v = \(mapped_v)\n",
%  "mapped_v [1,1] = \(mapped_v [1,1])\n",
%  "mapped_v [1,2] = \(mapped_v [1,2])\n",
%  "mapped_e = \(mapped_e)\n",
%  "mapped_e [1,1] = \(mapped_e [1,1])\n",
%  "mapped_e [1,2] = \(mapped_e [1,2])\n",
%  ];
