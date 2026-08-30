import Lake
open Lake DSL

package «TheGhostInYallsMachine» where

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

@[default_target]
lean_lib «theorem_hessian_rank_deficiency» where
  srcDir := "."

lean_lib «OPN-Proof2» where
  srcDir := "."
