T_gas = '${fparse 1100}'
T_steam = '${fparse 530}'

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../gold/plate.msh'
  []
  [oxide]
    type = SubdomainBoundingBoxGenerator
    input = fmg
    bottom_left = '${a} 0 0'
    top_right = '${b} ${H} 0'
    block_id = 0
  []
  [metal]
    type = SubdomainBoundingBoxGenerator
    input = oxide
    bottom_left = '${b} 0 0'
    top_right = '${c} ${H} 0'
    block_id = 1
  []
[]

[Problem]
  coord_type = RZ
[]

[Variables]
  [temp]
  []
[]

[AuxVariables]
  [interface]
  []
[]

[AuxKernels]
  [interface]
    type = FunctionAux
    variable = interface
    function = 'x-${b}'
  []
[]

[Kernels]
  [conduction]
    type = HeatConduction
    variable = 'temp'
  []
[]

[BCs]
  [convection_inner]
    type = ConvectiveHeatFluxBC
    variable = 'temp'
    boundary = 'left'
    T_infinity = ${T_steam}
    heat_transfer_coefficient = ${h_steam}
  []
  [convection_outer]
    type = ConvectiveHeatFluxBC
    variable = 'temp'
    boundary = 'right'
    T_infinity = ${T_gas}
    heat_transfer_coefficient = ${h_gas}
  []
[]

[Materials]
  # oxide
  [thermal_oxide]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity'
    prop_values = '${kappa_oxide}'
    block = 0
  []
  # metal
  [thermal_metal]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity'
    prop_values = '${kappa_metal}'
    block = 1
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  # line_search = none

  nl_rel_tol = 1e-06
  nl_abs_tol = 1e-08

  num_steps = 1

  max_xfem_update = 1
[]

[Outputs]
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  print_linear_residuals = false
[]
