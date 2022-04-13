
int : N;
int: N_tot= pow(2, N) - 1;

int : V;
int : V_internal_last;
int : V_leaf_start;
set of int: VERTICES= 1..V;

array[1..V_internal_last] of VERTICES: pred_0;
array[1..V_internal_last] of VERTICES: pred_1;

array [1..N_tot] of var 0..V_internal_last: mapped_v;
array [1..N_tot] of var VERTICES: mapped_e;
array [1..N_tot] of var bool: pe_active;

var int: total_active_pe;

constraint forall (d in 0..(N-2)) (
    forall (x in (pow(2, d))..(pow(2, d + 1) - 1)) (
      if (mapped_v[x] != 0) then
        ((mapped_e[2*x] = pred_0 [mapped_v [x]]) \/ (mapped_e [2*x + 1] = pred_0 [mapped_v [x]] )) /\
        ((mapped_e[2*x] = pred_1 [mapped_v [x]]) \/ (mapped_e [2*x + 1] = pred_1 [mapped_v [x]] )) /\
        (mapped_e[x] = mapped_v [x])
      else
        mapped_e [x] = mapped_e [2*x] \/
        mapped_e [x] = mapped_e [2*x + 1]
      endif
    )
  );

% activity indicator
constraint forall (x in 1..N_tot) (
    pe_active[x] = (mapped_v[x] != 0)
  );

% bottom most layer
constraint forall (x in (pow(2, N-1))..(pow(2, N) - 1)) (
    if (mapped_v[x] != 0) then
      (mapped_e[x] = mapped_v [x])
    endif
  );

% symmetry break
constraint mapped_v[pow(2, N-1)] != 0;

% layer-wise symmetry: A layer cannot have active nodes if all the nodes in the previous layer are empty
% TODO

% Vertical symmetry: There sould be more active nodes on the right half of tree than the other part

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
