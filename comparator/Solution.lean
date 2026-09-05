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
  rank (Hessian Jf) = rank Jf := 
  rank_transpose_mul_self Jf

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
  rw [rank_hessian_eq_rank_jacobian]
  exact Nat.lt_of_le_of_lt h_rank h_data_dim

/-!
### 4. The Inevitable Conclusion
○ Since rank(H) < n, the Hessian has a non-trivial kernel (a "Ghost Grid").
○ Gradient flow \dot{\theta} = -\nabla L(\theta) is driven by the eigenvalues of H.
○ Eigenvectors corresponding to the zero/near-zero eigenvalues (the kernel) do not contribute to the reduction of loss.
○ Therefore, the gradient flow is mathematically forced to exist only in the span of the eigenvectors of H with non-zero eigenvalues.
-/

theorem null_space_junction (Jf : Matrix (Fin m) (Fin n) ℝ) (v : Fin n → ℝ) 
  (h_kernel : Jf *ᵥ v = 0) : 
  Hessian Jf *ᵥ v = 0 := by
  unfold Hessian
  ext i
  dsimp [Matrix.mulVec, dotProduct]
  
  -- Expand the definition of Hessian matrix product
  have h_sum : ∑ j, (Jfᵀ * Jf) i j * v j = ∑ k, Jf k i * (Jf *ᵥ v) k := by
    calc ∑ j, (Jfᵀ * Jf) i j * v j
      _ = ∑ j, (∑ k, Jfᵀ i k * Jf k j) * v j := by
          refine Finset.sum_congr rfl (fun j _ => ?_)
          rw [Matrix.mul_apply]
      _ = ∑ j, ∑ k, (Jfᵀ i k * Jf k j) * v j := by
          refine Finset.sum_congr rfl (fun j _ => ?_)
          exact Finset.sum_mul _ _ (v j)
      _ = ∑ j, ∑ k, Jf k i * Jf k j * v j := by
          refine Finset.sum_congr rfl (fun j _ => ?_)
          refine Finset.sum_congr rfl (fun k _ => ?_)
          rw [Matrix.transpose_apply, mul_assoc]
      _ = ∑ k, ∑ j, Jf k i * (Jf k j * v j) := by
          rw [Finset.sum_comm]
          refine Finset.sum_congr rfl (fun k _ => Finset.sum_congr rfl (fun j _ => by ring))
      _ = ∑ k, Jf k i * ∑ j, Jf k j * v j := by
          refine Finset.sum_congr rfl (fun k _ => ?_)
          exact (Finset.mul_sum _ _ _).symm
      _ = ∑ k, Jf k i * (Jf *ᵥ v) k := by
          refine Finset.sum_congr rfl (fun k _ => ?_)
          congr 1

  rw [h_sum]
  have h_k_zero (k : Fin m) : (Jf *ᵥ v) k = 0 := by 
    rw [h_kernel]
    rfl
  simp_rw [h_k_zero, mul_zero, Finset.sum_const_zero]