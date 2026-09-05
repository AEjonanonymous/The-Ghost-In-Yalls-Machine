import Lake
open Lake DSL

package «TheGhostInYallsMachine» where

require mathlib from git 
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.31.0"

@[default_target]
lean_lib «Challenge» where
  srcDir := "."

lean_lib «Solution» where
  srcDir := "."
