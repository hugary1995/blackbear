T_gas = '${fparse 1100}'
T_steam = '${fparse 530}'

[Mesh]
  use_displaced_mesh = false
  [refined]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = '${fparse b-eps}'
    xmax = '${fparse b+eps}'
    ymin = 0
    ymax = 5
    nx = 10 # hx = 2*eps/10 = 0.04
    ny = 125 # hy = 5/125 = 0.04
  []
  [coarse]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = '${fparse b+eps}'
    xmax = ${c}
    ymin = 0
    ymax = 5
    nx = 10
    ny = 20
  []
  [stitch]
    type = StitchedMeshGenerator
    inputs = 'refined coarse'
    stitch_boundaries_pairs = 'right left'
  []
  [left]
    type = SubdomainBoundingBoxGenerator
    input = 'stitch'
    block_id = 0
    bottom_left = '${fparse b-eps} 0 0'
    top_right = '${b} 5 0'
  []
  [right]
    type = SubdomainBoundingBoxGenerator
    input = 'left'
    block_id = 1
    bottom_left = '${b} 0 0'
    top_right = '${c} 5 0'
  []
[]

[Variables]
  [temp]
  []
[]

[AuxVariables]
  [interface]
  []
[]

[XFEM]
  qrule = volfrac
  output_cut_plane = true
[]

[UserObjects]
  [cut]
    type = LevelSetCutUserObject
    level_set_var = interface
    heal_always = false
  []
[]

[AuxKernels]
  [interface]
    type = FunctionAux
    variable = interface
    function = 'x-${b}-0.01'
  []
[]

[Kernels]
  [conduction]
    type = HeatConduction
    variable = 'temp'
  []
[]

[Constraints]
  [temp_constraint]
    type = XFEMSingleVariableConstraint
    variable = 'temp'
    geometric_cut_userobject = 'cut'
    alpha = 1e4
    use_penalty = true
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
    prop_names = 'oxide_thermal_conductivity'
    prop_values = '${kappa_oxide}'
  []
  # metal
  [thermal_metal]
    type = GenericConstantMaterial
    prop_names = 'metal_thermal_conductivity'
    prop_values = '${kappa_metal}'
  []
  # bimaterial
  [combined_k]
    type = LevelSetBiMaterialReal
    levelset_positive_base = 'metal'
    levelset_negative_base = 'oxide'
    level_set_var = 'interface'
    prop_name = thermal_conductivity
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
