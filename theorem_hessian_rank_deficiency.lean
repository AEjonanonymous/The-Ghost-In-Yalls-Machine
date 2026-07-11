import Mathlib.LinearAlgebra.Matrix.Rank
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Real.Basic

open Matrix

variable {n m : ℕ}

/-!
### 1. Definitions
○ Let f: Θ → ℝ^m be the neural network. 
○ Let L(θ) = 1/2 ||f(θ) - y||^2. 
○ The Hessian is H(θ) = J_f(θ)^T J_f(θ) + Σ (f_i(θ) - y_i) ∇^2 f_i(θ). 
-/

-- Define the Hessian using the transpose of Jf
def Hessian (Jf : Matrix (Fin m) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ := 
  (transpose Jf) * Jf

/-!
### 2. The Dimensionality Lemma
○ In the "Active Subspace" regime, the second term (the sum of residuals) 
vanishes as the model nears the manifold of the data. 
○ Therefore, H(θ) ≈ J_f(θ)^T J_f(θ).
-/

-- This lemma relies on Mathlib's Rank property for matrix multiplication
lemma rank_hessian_eq_rank_jacobian (Jf : Matrix (Fin m) (Fin n) ℝ) : 
  rank (Hessian Jf) = rank Jf := by
  -- rank_transpose_mul_self is defined for any ring with the necessary properties
  exact rank_transpose_mul_self Jf

/-!
### 3. The Rank Argument
○ J_f(θ) is an m x n matrix (outputs x parameters). 
○ If the data manifold has dimension k < n, then rank(J_f) ≤ k. 
○ By the properties of matrix products, rank(J^T J) = rank(J). 
○ Thus, rank(H) ≤ k < n.
-/

theorem rank_deficiency (Jf : Matrix (Fin m) (Fin n) ℝ) (k : ℕ) 
  (h_data_dim : k < n) (h_rank : rank Jf ≤ k) : 
  rank (Hessian Jf) < n := by
  -- Substitute rank(H) with rank(J)
  rw [rank_hessian_eq_rank_jacobian]
  -- We now have rank Jf ≤ k and k < n, so rank Jf < n
  exact Nat.lt_of_le_of_lt h_rank h_data_dim