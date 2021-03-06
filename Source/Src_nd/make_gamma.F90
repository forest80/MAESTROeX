! compute gamma1 for the full state.


module make_gamma_module

  use amrex_mempool_module, only : bl_allocate, bl_deallocate
  use eos_type_module
  use eos_module
  use network, only: nspec
  use meth_params_module, only: rho_comp, temp_comp, spec_comp, pi_comp, use_pprime_in_tfromp
  use base_state_geometry_module, only: max_radial_level, nr_fine
  use fill_3d_data_module, only: put_1d_array_on_cart_sphr

  implicit none

  private

  public :: make_gamma

contains

  subroutine make_gamma(lev, lo, hi, &
       gamma, g_lo, g_hi, &
       scal,  s_lo, s_hi, nc_s, &
       p0) bind(C,name="make_gamma")

    integer         , intent (in   ) :: lev, lo(3), hi(3)
    integer         , intent (in   ) :: g_lo(3), g_hi(3)
    integer         , intent (in   ) :: s_lo(3), s_hi(3), nc_s
    double precision, intent (inout) :: gamma(g_lo(1):g_hi(1),g_lo(2):g_hi(2),g_lo(3):g_hi(3))
    double precision, intent (in   ) :: scal (s_lo(1):s_hi(1),s_lo(2):s_hi(2),s_lo(3):s_hi(3),nc_s)
    double precision, intent (in   ) :: p0(0:max_radial_level,0:nr_fine-1)

    ! local variables
    integer :: i, j, k, r

    integer :: pt_index(3)
    type (eos_t) :: eos_state

    do k = lo(3), hi(3)
       do j = lo(2), hi(2)
          do i = lo(1), hi(1)

#if (AMREX_SPACEDIM == 1)
             r = i
#elif (AMREX_SPACEDIM == 2)
             r = j
#elif (AMREX_SPACEDIM == 3)
             r = k
#endif

             eos_state%rho = scal(i,j,k,rho_comp)
             if (use_pprime_in_tfromp) then
                eos_state%p = p0(lev,r) + scal(i,j,k,pi_comp)
             else
                eos_state%p = p0(lev,r)
             endif
             eos_state%T     = scal(i,j,k,temp_comp)
             eos_state%xn(:) = scal(i,j,k,spec_comp:spec_comp+nspec-1)/eos_state%rho

             pt_index(:) = (/i, j, k/)

             ! dens, pres, and xmass are inputs
             call eos(eos_input_rp, eos_state, pt_index)

             gamma(i,j,k) = eos_state%gam1

          end do
       end do
    end do

  end subroutine make_gamma

  subroutine make_gamma_sphr(lo, hi, &
       gamma, g_lo, g_hi, &
       scal,  s_lo, s_hi, nc_s, &
       p0, dx, &
       r_cc_loc, r_edge_loc, &
       cc_to_r, ccr_lo, ccr_hi) bind(C, name="make_gamma_sphr")

    integer         , intent(in   ) :: lo(3), hi(3)
    integer         , intent(in   ) :: g_lo(3), g_hi(3)
    integer         , intent(in   ) :: s_lo(3), s_hi(3), nc_s
    double precision, intent(inout) :: gamma(g_lo(1):g_hi(1),g_lo(2):g_hi(2),g_lo(3):g_hi(3))
    double precision, intent(in   ) :: scal (s_lo(1):s_hi(1),s_lo(2):s_hi(2),s_lo(3):s_hi(3),nc_s)
    double precision, intent(in   ) :: p0(0:max_radial_level,0:nr_fine-1)
    double precision, intent(in   ) :: dx(3)
    double precision, intent(in   ) :: r_cc_loc(0:max_radial_level,0:nr_fine-1)
    double precision, intent(in   ) :: r_edge_loc(0:max_radial_level,0:nr_fine)
    integer         , intent(in   ) :: ccr_lo(3), ccr_hi(3)
    double precision, intent(in   ) :: cc_to_r(ccr_lo(1):ccr_hi(1), &
         ccr_lo(2):ccr_hi(2),ccr_lo(3):ccr_hi(3))

    ! local variables
    integer :: i, j, k

    double precision, pointer :: p0_cart(:,:,:,:)

    integer :: pt_index(3)
    type (eos_t) :: eos_state

    call bl_allocate(p0_cart,lo,hi,1)
    call put_1d_array_on_cart_sphr(lo,hi,p0_cart,lo,hi,1,p0,dx,0,0,r_cc_loc,r_edge_loc, &
         cc_to_r,ccr_lo,ccr_hi)

    do k = lo(3), hi(3)
       do j = lo(2), hi(2)
          do i = lo(1), hi(1)

             eos_state%rho   = scal(i,j,k,rho_comp)
             if (use_pprime_in_tfromp) then
                eos_state%p     = p0_cart(i,j,k,1) + scal(i,j,k,pi_comp)
             else
                eos_state%p     = p0_cart(i,j,k,1)
             endif
             eos_state%T     = scal(i,j,k,temp_comp)
             eos_state%xn(:) = scal(i,j,k,spec_comp:spec_comp+nspec-1)/eos_state%rho

             pt_index(:) = (/i, j, k/)

             ! dens, pres, and xmass are inputs
             call eos(eos_input_rp, eos_state, pt_index)

             gamma(i,j,k) = eos_state%gam1

          end do
       end do
    end do

    call bl_deallocate(p0_cart)

  end subroutine make_gamma_sphr

end module make_gamma_module
