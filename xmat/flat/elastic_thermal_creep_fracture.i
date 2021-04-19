# geometry
b = 14
c = 25
eps = 0.2

# oxide parameters
E_oxide = 1.2e5
nu_oxide = 0.24
kappa_oxide = 3
Gc = 0.1
l = 0.25
psic = 0.05

# metal parameters
E_metal = 1.9e5
nu_metal = 0.3
kappa_metal = 30

# boundary condition
h_gas = 0.1
h_steam = 2.8

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[MultiApps]
  [ref_temp]
    type = FullSolveMultiApp
    input_files = 'ref_temp.i'
    app_type = BlackBearApp
    execute_on = 'INITIAL'
    cli_args = 'b=${b};c=${c};eps=${eps};kappa_oxide=${kappa_oxide};kappa_metal=${kappa_metal};h_gas='
               '${h_gas};h_steam=${h_steam}'
  []
[]

[Transfers]
  [from_temp]
    type = MultiAppMeshFunctionTransfer
    direction = from_multiapp
    multi_app = ref_temp
    source_variable = temp
    variable = ref_temp
    execute_on = 'INITIAL'
  []
[]

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

[Functions]
  [CTE_oxide]
    type = PiecewiseLinear
    format = columns
    data_file = 'gold/CTE_oxide.csv'
  []
  [CTE_metal]
    type = PiecewiseLinear
    format = columns
    data_file = 'gold/CTE_metal.csv'
  []
  [T_gas]
    type = VectorPostprocessorFunction
    vectorpostprocessor_name = 'bcs'
    argument_column = 'time'
    value_column = 'T_gas'
  []
  [T_steam]
    type = VectorPostprocessorFunction
    vectorpostprocessor_name = 'bcs'
    argument_column = 'time'
    value_column = 'T_steam'
  []
  [p_gas]
    type = VectorPostprocessorFunction
    vectorpostprocessor_name = 'bcs'
    argument_column = 'time'
    value_column = 'p_gas'
  []
  [p_steam]
    type = VectorPostprocessorFunction
    vectorpostprocessor_name = 'bcs'
    argument_column = 'time'
    value_column = 'p_steam'
  []
  [dt]
    type = VectorPostprocessorFunction
    vectorpostprocessor_name = 'bcs'
    argument_column = 'time'
    value_column = 'dt'
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [temp]
  []
  [scalar_strain_zz]
    order = FIRST
    family = SCALAR
  []
[]

[AuxVariables]
  [c]
  []
  [interface]
  []
  [ref_temp]
  []
  [temp_in_K]
  []
  [bounds_dummy]
  []
  [max_principal_strain]
    order = CONSTANT
    family = MONOMIAL
  []
  [max_principal_stress]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_zz]
    order = CONSTANT
    family = MONOMIAL
  []
  [creep_strain_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [creep_strain_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [creep_strain_zz]
    order = CONSTANT
    family = MONOMIAL
  []
[]

# [Bounds]
#   [irreversibility]
#     type = VariableOldValueBoundsAux
#     variable = bounds_dummy
#     bounded_variable = c
#     bound_type = lower
#   []
#   [upper_bound]
#     type = ConstantBoundsAux
#     variable = bounds_dummy
#     bounded_variable = c
#     bound_value = 1
#     bound_type = upper
#   []
# []

[XFEM]
  qrule = volfrac
  output_cut_plane = true
  minimum_weight_multiplier = 1e-3
[]

[UserObjects]
  [gps]
    type = GeneralizedPlaneStrainUserObject
  []
  [cut]
    type = LevelSetCutUserObject
    level_set_var = interface
    negative_id = 0
    positive_id = 1
    heal_always = true
  []
  [subdomain_modifier]
    type = GeometricCutElementSubdomainModifier
    geometric_cut_userobject = cut
    apply_initial_conditions = false
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[AuxKernels]
  [interface]
    type = FunctionAux
    variable = interface
    function = 'x-${b}-1.468e-5*sqrt(t)-0.01'
    execute_on = 'INITIAL LINEAR TIMESTEP_END'
  []
  [max_principal_strain]
    type = RankTwoScalarAux
    variable = 'max_principal_strain'
    rank_two_tensor = elastic_strain
    scalar_type = MaxPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [max_principal_stress]
    type = RankTwoScalarAux
    variable = 'max_principal_stress'
    rank_two_tensor = stress
    scalar_type = MaxPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [stress_xx]
    type = RankTwoAux
    variable = 'stress_xx'
    rank_two_tensor = 'stress'
    index_i = 0
    index_j = 0
    execute_on = 'TIMESTEP_END'
  []
  [stress_yy]
    type = RankTwoAux
    variable = 'stress_yy'
    rank_two_tensor = 'stress'
    index_i = 1
    index_j = 1
    execute_on = 'TIMESTEP_END'
  []
  [stress_zz]
    type = RankTwoAux
    variable = 'stress_zz'
    rank_two_tensor = 'stress'
    index_i = 2
    index_j = 2
    execute_on = 'TIMESTEP_END'
  []
  [creep_strain_xx]
    type = RankTwoAux
    variable = 'creep_strain_xx'
    rank_two_tensor = 'creep_strain'
    index_i = 0
    index_j = 0
    execute_on = 'TIMESTEP_END'
  []
  [creep_strain_yy]
    type = RankTwoAux
    variable = 'creep_strain_yy'
    rank_two_tensor = 'creep_strain'
    index_i = 1
    index_j = 1
    execute_on = 'TIMESTEP_END'
  []
  [creep_strain_zz]
    type = RankTwoAux
    variable = 'creep_strain_zz'
    rank_two_tensor = 'creep_strain'
    index_i = 2
    index_j = 2
    execute_on = 'TIMESTEP_END'
  []
  [temp_in_K]
    type = ParsedAux
    variable = 'temp_in_K'
    args = 'temp'
    function = 'temp + 273.15'
  []
[]

[ScalarKernels]
  [solid_z]
    type = GeneralizedPlaneStrain
    variable = 'scalar_strain_zz'
    generalized_plane_strain = 'gps'
  []
[]

[Kernels]
  [solid_x]
    type = StressDivergenceTensors
    variable = 'disp_x'
    temperature = 'temp'
    eigenstrain_names = 'thermal_eigenstrain'
    use_finite_deform_jacobian = true
    component = 0
    use_displaced_mesh = true
  []
  [solid_y]
    type = StressDivergenceTensors
    variable = 'disp_y'
    temperature = 'temp'
    eigenstrain_names = 'thermal_eigenstrain'
    use_finite_deform_jacobian = true
    component = 1
    use_displaced_mesh = true
  []
  [solid_xz]
    type = GeneralizedPlaneStrainOffDiag
    variable = 'disp_x'
    scalar_out_of_plane_strain = 'scalar_strain_zz'
    temperature = 'temp'
    eigenstrain_names = 'thermal_eigenstrain'
    use_displaced_mesh = true
  []
  [solid_yz]
    type = GeneralizedPlaneStrainOffDiag
    variable = 'disp_y'
    scalar_out_of_plane_strain = 'scalar_strain_zz'
    temperature = 'temp'
    eigenstrain_names = 'thermal_eigenstrain'
    use_displaced_mesh = true
  []
  [conduction]
    type = HeatConduction
    variable = 'temp'
  []
  # [ACBulk]
  #   type = AllenCahn
  #   variable = c
  #   f_name = F
  # []
  # [ACInterface]
  #   type = ACInterface
  #   variable = c
  #   kappa_name = kappa
  #   mob_name = L
  # []
  # [solid_x_offdiag]
  #   type = PhaseFieldFractureMechanicsOffDiag
  #   variable = disp_x
  #   c = c
  #   component = 0
  # []
  # [solid_y_offdiag]
  #   type = PhaseFieldFractureMechanicsOffDiag
  #   variable = disp_y
  #   c = c
  #   component = 1
  # []
[]

[Constraints]
  [disp_x_constraint]
    type = XFEMSingleVariableConstraint
    variable = 'disp_x'
    geometric_cut_userobject = 'cut'
    alpha = 1e10
    # use_displaced_mesh = true
    use_penalty = true
  []
  [disp_y_constraint]
    type = XFEMSingleVariableConstraint
    variable = 'disp_y'
    geometric_cut_userobject = 'cut'
    alpha = 1e10
    # use_displaced_mesh = true
    use_penalty = true
  []
  [temp_constraint]
    type = XFEMSingleVariableConstraint
    variable = 'temp'
    geometric_cut_userobject = 'cut'
    alpha = 1e4
    # use_displaced_mesh = true
    use_penalty = true
  []
[]

[BCs]
  [fixed_x]
    type = DirichletBC
    variable = 'disp_x'
    boundary = 'right'
    value = 0
  []
  [fixed_y]
    type = DirichletBC
    variable = 'disp_y'
    boundary = 'top bottom'
    value = 0
  []
  [convection_left]
    type = ConvectiveHeatFluxBC
    variable = 'temp'
    boundary = 'left'
    T_infinity = T_steam
    heat_transfer_coefficient = ${h_steam}
  []
  [convection_right]
    type = ConvectiveHeatFluxBC
    variable = 'temp'
    boundary = 'right'
    T_infinity = T_gas
    heat_transfer_coefficient = ${h_gas}
  []
  [Pressure]
    [gas]
      boundary = 'right'
      function = p_gas
    []
    [steam]
      boundary = 'left'
      function = p_steam
    []
  []
[]

[Materials]
  [environment]
    type = GenericFunctionMaterial
    prop_names = 'T_gas T_steam'
    prop_values = 'T_gas T_steam'
    constant_on = SUBDOMAIN
  []
  # fracture
  [fracture_oxide]
    type = GenericConstantMaterial
    prop_names = 'Gc l c0'
    prop_values = '${Gc} ${l} 3.141593'
    block = 0
  []
  [fracture_metal]
    type = GenericConstantMaterial
    prop_names = 'Gc l c0'
    prop_values = '1e3 ${l} 3.141593'
    block = 1
  []
  [mobility]
    type = ParsedMaterial
    f_name = L
    material_property_names = 'Gc'
    function = '1/Gc'
    constant_on = SUBDOMAIN
  []
  [interface_coef]
    type = ParsedMaterial
    f_name = kappa
    material_property_names = 'Gc l c0'
    function = '2*Gc*l/c0'
    constant_on = SUBDOMAIN
  []
  [degradation]
    type = DerivativeParsedMaterial
    f_name = g
    args = 'c'
    function = '(1-c)^2*(1-eta)+eta'
    constant_names = 'eta'
    constant_expressions = '1e-6'
    derivative_order = 2
  []
  [crack_geometric_function]
    type = DerivativeParsedMaterial
    f_name = w
    args = 'c'
    material_property_names = 'Gc l c0'
    function = 'c^2*Gc/c0/l'
    derivative_order = 2
  []
  # [degradation]
  #   type = DerivativeParsedMaterial
  #   f_name = g
  #   args = 'c'
  #   function = '(1-c)^p/((1-c)^p+(Gc/psic*xi/c0/l)*c*(1+a2*c+a2*a3*c^2))*(1-eta)+eta'
  #   constant_names = 'psic p xi a2 a3 eta'
  #   constant_expressions = '${psic} 2 2 -0.5 0 1e-6'
  #   material_property_names = 'Gc c0 l'
  #   derivative_order = 2
  # []
  # [crack_geometric_function]
  #   type = DerivativeParsedMaterial
  #   f_name = w
  #   args = 'c'
  #   material_property_names = 'Gc l c0'
  #   function = '(2*c-c^2)*Gc/c0/l'
  #   derivative_order = 2
  # []
  [free_energy]
    type = DerivativeParsedMaterial
    f_name = F
    args = 'c'
    material_property_names = 'w(c) E_el(c)'
    function = 'w+E_el'
    derivative_order = 2
  []
  [pff]
    type = PhaseFieldFractureStrainSpectralSplit
    c = c
    degradation_function = g
    elastic_energy = E_el
    use_old_elastic_energy = true
  []
  # oxide
  [thermal_oxide]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity'
    prop_values = '${kappa_oxide}'
    block = 0
  []
  [eigenstrain_oxide]
    type = ComputeInstantaneousThermalExpansionFunctionEigenstrain
    stress_free_temperature = ref_temp
    temperature = temp
    thermal_expansion_function = CTE_oxide
    eigenstrain_name = 'thermal_eigenstrain'
    block = 0
  []
  [elasticity_tensor_oxide]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = ${E_oxide}
    poissons_ratio = ${nu_oxide}
    block = 0
  []
  [strain_oxide]
    type = ComputePlaneIncrementalStrain
    scalar_out_of_plane_strain = scalar_strain_zz
    eigenstrain_names = 'thermal_eigenstrain'
    block = 0
  []
  [creep_oxide]
    type = PowerLawCreepStressUpdate
    coefficient = 8.5875e7
    n_exponent = 3
    activation_energy = 4.2162e8
    gas_constant = 8.3143e3
    temperature = 'temp_in_K'
    block = 0
  []
  [stress_oxide]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'creep_oxide'
    damage_model = 'pff'
    block = 0
  []
  # metal
  [thermal_metal]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity'
    prop_values = '${kappa_metal}'
    block = 1
  []
  [elasticity_tensor_metal]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = ${E_metal}
    poissons_ratio = ${nu_metal}
    block = 1
  []
  [eigenstrain_metal]
    type = ComputeInstantaneousThermalExpansionFunctionEigenstrain
    stress_free_temperature = ref_temp
    temperature = temp
    thermal_expansion_function = CTE_metal
    eigenstrain_name = 'thermal_eigenstrain'
    block = 1
  []
  [strain_metal]
    type = ComputePlaneIncrementalStrain
    scalar_out_of_plane_strain = scalar_strain_zz
    eigenstrain_names = 'thermal_eigenstrain'
    block = 1
  []
  [creep_metal]
    type = PowerLawCreepStressUpdate
    coefficient = 2.3e6
    n_exponent = 5.06
    activation_energy = 4e8
    gas_constant = 8.3143e3
    temperature = 'temp_in_K'
    block = 1
  []
  [stress_metal]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'creep_metal'
    block = 1
  []
[]

[Postprocessors]
  [metal_creep_strain_rr]
    type = PointValue
    variable = 'creep_strain_xx'
    point = '${fparse b+eps} 0 0'
  []
  [metal_creep_strain_tt]
    type = PointValue
    variable = 'creep_strain_yy'
    point = '${fparse b+eps} 0 0'
  []
  [metal_creep_strain_zz]
    type = PointValue
    variable = 'creep_strain_zz'
    point = '${fparse b+eps} 0 0'
  []
  [oxide_creep_strain_rr]
    type = PointValue
    variable = 'creep_strain_xx'
    point = '${b} 0 0'
  []
  [oxide_creep_strain_tt]
    type = PointValue
    variable = 'creep_strain_yy'
    point = '${b} 0 0'
  []
  [oxide_creep_strain_zz]
    type = PointValue
    variable = 'creep_strain_zz'
    point = '${b} 0 0'
  []
  [oxide_stress_rr]
    type = PointValue
    variable = 'stress_xx'
    point = '${b} 0 0'
  []
  [oxide_stress_tt]
    type = PointValue
    variable = 'stress_yy'
    point = '${b} 0 0'
  []
  [oxide_stress_zz]
    type = PointValue
    variable = 'stress_zz'
    point = '${b} 0 0'
  []
  [damage]
    type = ElementIntegralVariablePostprocessor
    variable = c
  []
  [years]
    type = FunctionValuePostprocessor
    function = 't/86400/360'
  []
  [days]
    type = FunctionValuePostprocessor
    function = 't/86400'
  []
[]

[VectorPostprocessors]
  [bcs]
    type = CSVReader
    csv_file = 'gold/BC.csv'
    header = true
  []
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  automatic_scaling = true

  l_max_its = 200
  nl_rel_tol = 1e-06
  nl_abs_tol = 1e-06
  nl_forced_its = 1

  [TimeStepper]
    type = CSVTimeSequenceStepper
    file_name = 'gold/BC.csv'
    header = true
  []
  # num_steps = 300
  end_time = 188092800

  max_xfem_update = 1
[]

[Outputs]
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  print_linear_residuals = false
  hide = 'scalar_strain_zz'
  file_base = 'output/elastic_thermal_creep_fracture'
  [exodus]
    type = Exodus
    interval = 1
  []
  [csv]
    type = CSV
    execute_postprocessors_on = 'INITIAL TIMESTEP_END'
    execute_vector_postprocessors_on = 'FINAL'
  []
[]
