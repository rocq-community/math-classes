Require
  MathClasses.interfaces.naturals MathClasses.theory.naturals MathClasses.implementations.peano_naturals MathClasses.theory.integers.
From Coq Require Import BinInt Ring Arith NArith ZArith ZBinary.
Require Import
  MathClasses.interfaces.abstract_algebra MathClasses.interfaces.integers
  MathClasses.implementations.natpair_integers MathClasses.implementations.stdlib_binary_naturals
  MathClasses.interfaces.additional_operations MathClasses.interfaces.orders
  MathClasses.implementations.nonneg_integers_naturals.

(* canonical names: *)
#[global]
Instance Z_equiv: Equiv Z := eq.
#[global]
Instance Z_plus: Plus Z := Zplus.
#[global]
Instance Z_0: Zero Z := 0%Z.
#[global]
Instance Z_1: One Z := 1%Z.
#[global]
Instance Z_mult: Mult Z := Zmult.
#[global]
Instance Z_negate: Negate Z := Z.opp.
  (* some day we'd like to do this with [Existing Instance] *)

#[global]
Instance: Ring Z.
Proof.
  repeat (split; try apply _); repeat intro.
           now apply Zplus_assoc.
          now apply Zplus_0_r.
         now apply Zplus_opp_l.
        now apply Zplus_opp_r.
       now apply Zplus_comm.
      now apply Zmult_assoc.
     now apply Zmult_1_l.
    now apply Zmult_1_r.
   now apply Zmult_comm.
  now apply Zmult_plus_distr_r.
Qed.

(* misc: *)
#[global]
Instance: ∀ x y : Z, Decision (x = y) := Z.eq_dec.

Add Ring Z: (rings.stdlib_ring_theory Z).

(* * Embedding N into Z *)
#[global]
Instance inject_N_Z: Cast N Z := Z_of_N.

#[global]
Instance: SemiRing_Morphism Z_of_N.
Proof.
  repeat (split; try apply _).
   exact Znat.Z_of_N_plus.
  exact Znat.Z_of_N_mult.
Qed.

#[global]
Instance: Injective Z_of_N.
Proof.
  repeat (split; try apply _).
  intros x y E. now apply Znat.Z_of_N_eq_iff.
Qed.

(* SRpair N and Z are isomorphic *)
Definition Npair_to_Z (x : SRpair N) : Z := ('pos x - 'neg x)%mc.

#[global]
Instance: Proper (=) Npair_to_Z.
Proof.
  intros [xp xn] [yp yn] E; do 2 red in E; unfold Npair_to_Z; simpl in *.
  apply (right_cancellation (+) ('yn + 'xn)); ring_simplify.
  now rewrite <-?rings.preserves_plus, E, commutativity.
Qed.

#[global]
Instance: SemiRing_Morphism Npair_to_Z.
Proof.
  repeat (split; try apply _).
   intros [xp xn] [yp yn].
   change ('(xp + yp) - '(xn + yn) = 'xp - 'xn + ('yp - 'yn)).
   rewrite ?rings.preserves_plus. ring.
  intros [xp xn] [yp yn].
  change ('(xp * yp + xn * yn) - '(xp * yn + xn * yp) = ('xp - 'xn) * ('yp - 'yn)).
  rewrite ?rings.preserves_plus, ?rings.preserves_mult. ring.
Qed.

#[global]
Instance: Injective Npair_to_Z.
Proof.
  split; try apply _.
  intros [xp xn] [yp yn] E.
  unfold Npair_to_Z in E. do 2 red. simpl in *.
  apply (injective (cast N Z)).
  rewrite ?rings.preserves_plus.
  apply (right_cancellation (+) ('xp - 'xn)). rewrite E at 1. ring.
Qed.

#[global]
Instance Z_to_Npair: Inverse Npair_to_Z := λ x,
  match x with
  | Z0 => C 0 0
  | Zpos p => C (Npos p) 0
  | Zneg p => C 0 (Npos p)
  end.

#[global]
Instance: Surjective Npair_to_Z.
Proof. split; try apply _. intros [|?|?] ? E; now rewrite <-E. Qed. 

#[global]
Instance: Bijective Npair_to_Z := {}.

#[global]
Instance: SemiRing_Morphism Z_to_Npair.
Proof. change (SemiRing_Morphism (Npair_to_Z⁻¹)). split; apply _. Qed.

#[global]
Instance: IntegersToRing Z := integers.retract_is_int_to_ring Npair_to_Z.
#[global]
Instance: Integers Z := integers.retract_is_int Npair_to_Z.

#[global]
Instance Z_le: Le Z := Z.le.
#[global]
Instance Z_lt: Lt Z := Z.lt.

#[global]
Instance: SemiRingOrder Z_le.
Proof.
  assert (PartialOrder Z_le).
   repeat (split; try apply _).
   exact Zorder.Zle_antisym.
  rapply rings.from_ring_order.
   repeat (split; try apply _).
   intros x y E. now apply Zorder.Zplus_le_compat_l.
  intros x E y F. now apply Zorder.Zmult_le_0_compat.
Qed.

#[global]
Instance: TotalRelation Z_le.
Proof.
  intros x y.
  destruct (Zorder.Zle_or_lt x y); intuition.
  right. now apply Zorder.Zlt_le_weak.
Qed.

#[global]
Instance: FullPseudoSemiRingOrder Z_le Z_lt.
Proof.
  rapply semirings.dec_full_pseudo_srorder.
  split.
   intro. split. now apply Zorder.Zlt_le_weak. now apply Zorder.Zlt_not_eq.
  intros [E1 E2]. destruct (Zorder.Zle_lt_or_eq _ _ E1). easy. now destruct E2.
Qed.

(* * Embedding of the Peano naturals into [Z] *)
#[global]
Instance inject_nat_Z: Cast nat Z := Z_of_nat.

#[global]
Instance: SemiRing_Morphism Z_of_nat.
Proof.
  repeat (split; try apply _).
   exact Znat.inj_plus.
  exact Znat.inj_mult.
Qed.

(* absolute value *)
#[global]
Program Instance Z_abs_nat: IntAbs Z nat := λ x,
  match x with
  | Z0 => inl (0:nat)
  | Zpos p => inl (nat_of_P p)
  | Zneg p => inr (nat_of_P p)
  end.
Next Obligation. reflexivity. Qed.
Next Obligation. now rewrite <-(naturals.to_semiring_unique Z_of_nat), Znat.Z_of_nat_of_P. Qed.
Next Obligation. now rewrite <-(naturals.to_semiring_unique Z_of_nat), Znat.Z_of_nat_of_P. Qed.

#[global]
Program Instance Z_abs_N: IntAbs Z N := λ x,
  match x with
  | Z0 => inl (0:N)
  | Zpos p => inl (Npos p)
  | Zneg p => inr (Npos p)
  end.
Next Obligation. reflexivity. Qed.
Next Obligation. now rewrite <-(naturals.to_semiring_unique Z_of_N). Qed.
Next Obligation. now rewrite <-(naturals.to_semiring_unique Z_of_N). Qed.

(* Efficient nat_pow *)
#[global]
Program Instance Z_pow: Pow Z (Z⁺) := Z.pow.

#[global]
Instance: NatPowSpec Z (Z⁺) Z_pow.
Proof.
  split; unfold pow, Z_pow.
    intros x1 y1 E1 [x2 Ex2] [y2 Ey2] E2.
    unfold equiv, sig_equiv in E2.
    simpl in *. now rewrite E1, E2.
   intros. now apply Z.pow_0_r.
  intros x n.
  rewrite rings.preserves_plus, rings.preserves_1.
  rewrite <-(Z.pow_1_r x) at 2. apply Z.pow_add_r.
   auto with zarith.
  now destruct n.
Qed.

#[global]
Instance Z_Npow: Pow Z N := λ x n, Z.pow x ('n).

#[global]
Instance: NatPowSpec Z N Z_Npow.
Proof.
  split; unfold pow, Z_Npow.
    solve_proper.
   intros. now apply Z.pow_0_r.
  intros x n.
  rewrite rings.preserves_plus, rings.preserves_1.
  rewrite <-(Z.pow_1_r x) at 2. apply Z.pow_add_r.
   auto with zarith.
  now destruct n.
Qed.

(* Efficient shiftl *)
#[global]
Program Instance Z_shiftl: ShiftL Z (Z⁺) := Z.shiftl.

#[global]
Instance: ShiftLSpec Z (Z⁺) Z_shiftl.
Proof.
  apply shiftl_spec_from_nat_pow.
  intros x [n En].
  apply Z.shiftl_mul_pow2.
  now apply En.
Qed.

#[global]
Instance Z_Nshiftl: ShiftL Z N := λ x n, Z.shiftl x ('n).

#[global]
Instance: ShiftLSpec Z N Z_Nshiftl.
Proof.
  apply shiftl_spec_from_nat_pow.
  intros x n.
  apply Z.shiftl_mul_pow2.
  now destruct n.
Qed.

#[global]
Program Instance Z_abs: Abs Z := Z.abs.
Next Obligation.
  split; intros E.
   now apply Z.abs_eq.
  now apply Z.abs_neq.
Qed.

#[global]
Instance Z_div: DivEuclid Z := Z.div.
#[global]
Instance Z_mod: ModEuclid Z := Z.modulo.

#[global]
Instance: EuclidSpec Z _ _.
Proof.
  split; try apply _.
     exact Z.div_mod.
    intros x y Ey. destruct (Z_mod_remainder x y); intuition.
   now intros [].
  now intros [].
Qed.
