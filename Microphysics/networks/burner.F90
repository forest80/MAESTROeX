module burner_module

  use bl_types
  use bl_constants_module
  use network
  use eos_module
#ifndef SDC
  use actual_burner_module
#else
  use integrator_module
#endif
  use burn_type_module

  logical :: burner_initialized = .false.

contains

  subroutine burner_init() bind(C, name="burner_init")

    implicit none

#ifdef SDC
    call integrator_init()
#else
    call actual_burner_init()
#endif

    burner_initialized = .true.

  end subroutine burner_init



#ifndef SDC
  subroutine burner(state_in, state_out, dt)

    !$acc routine seq

    implicit none

    type (burn_t), intent(inout) :: state_in
    type (burn_t), intent(inout) :: state_out
    double precision, intent(in) :: dt

    double precision :: time

    time = 0.d0

    ! Make sure the network and burner have been initialized.

#ifndef ACC
    if (.NOT. network_initialized) then
       call bl_error("ERROR in burner: must initialize network first.")
    endif

    if (.NOT. burner_initialized) then
       call bl_error("ERROR in burner: must initialize burner first.")
    endif
#endif

    ! Initialize the final state by assuming it does not change.

    state_out = state_in

    ! Do the burning.

    call actual_burner(state_in, state_out, dt, time)

  end subroutine burner
#endif

end module burner_module
