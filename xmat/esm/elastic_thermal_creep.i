# geometry
a = 13.8
b = 14
c = 25
eps = 0.03
b_eps = '${fparse b+eps}'

# oxide parameters
E_oxide = 1.2e5
nu_oxide = 0.24
kappa_oxide = 3

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
    cli_args = 'a=${a};b=${b};b_eps=${b_eps};c=${c};kappa_oxide=${kappa_oxide};kappa_metal=${kappa_me'
               'tal};h_gas=${h_gas};h_steam=${h_steam}'
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
  [refined]
    type = AnnularMeshGenerator
    dmin = 0
    dmax = 90
    rmin = ${a}
    rmax = ${b_eps}
    nr = 5
    nt = 80
  []
  [coarse]
    type = AnnularMeshGenerator
    dmin = 0
    dmax = 90
    rmin = ${b_eps}
    rmax = ${c}
    nr = 40
    nt = 80
  []
  [stitch]
    type = StitchedMeshGenerator
    inputs = 'refined coarse'
    stitch_boundaries_pairs = 'rmax rmin'
  []
  [left]
    type = SubdomainBoundingBoxGenerator
    input = 'stitch'
    block_id = 0
    bottom_left = '0 0 0'
    top_right = '${b} ${c} 0'
  []
  [right]
    type = SubdomainBoundingBoxGenerator
    input = 'left'
    block_id = 1
    bottom_left = '${b} 0 0'
    top_right = '${c} ${c} 0'
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
  [interface]
  []
  [ref_temp]
  []
  [temp_in_K]
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

[XFEM]
  qrule = volfrac
  output_cut_plane = true
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
    type = CutElementSubdomainModifier
    geometric_cut_userobject = cut
    apply_initial_conditions = false
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[AuxKernels]
  [interface]
    type = FunctionAux
    variable = interface
    function = 'r:=sqrt(x^2+y^2); r-${b}'
    execute_on = 'INITIAL LINEAR TIMESTEP_END'
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
    boundary = 'dmax'
    value = 0
  []
  [fixed_y]
    type = DirichletBC
    variable = 'disp_y'
    boundary = 'dmin'
    value = 0
  []
  [convection_left]
    type = ConvectiveHeatFluxBC
    variable = 'temp'
    boundary = 'rmin'
    T_infinity = T_steam
    heat_transfer_coefficient = ${h_steam}
  []
  [convection_right]
    type = ConvectiveHeatFluxBC
    variable = 'temp'
    boundary = 'rmax'
    T_infinity = T_gas
    heat_transfer_coefficient = ${h_gas}
  []
  [Pressure]
    [gas]
      boundary = 'rmax'
      function = p_gas
    []
    [steam]
      boundary = 'rmin'
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
    type = ComputePlaneFiniteStrain
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
    type = ComputePlaneFiniteStrain
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
    point = '${b_eps} 0 0'
  []
  [metal_creep_strain_tt]
    type = PointValue
    variable = 'creep_strain_yy'
    point = '${b_eps} 0 0'
  []
  [metal_creep_strain_zz]
    type = PointValue
    variable = 'creep_strain_zz'
    point = '${b_eps} 0 0'
  []
  [oxide_creep_strain_rr]
    type = PointValue
    variable = 'creep_strain_xx'
    point = '${fparse (a+b)/2} 0 0'
  []
  [oxide_creep_strain_tt]
    type = PointValue
    variable = 'creep_strain_yy'
    point = '${fparse (a+b)/2} 0 0'
  []
  [oxide_creep_strain_zz]
    type = PointValue
    variable = 'creep_strain_zz'
    point = '${fparse (a+b)/2} 0 0'
  []
  [oxide_stress_rr]
    type = PointValue
    variable = 'stress_xx'
    point = '${fparse (a+b)/2} 0 0'
  []
  [oxide_stress_tt]
    type = PointValue
    variable = 'stress_yy'
    point = '${fparse (a+b)/2} 0 0'
  []
  [oxide_stress_zz]
    type = PointValue
    variable = 'stress_zz'
    point = '${fparse (a+b)/2} 0 0'
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
  [stress_rr]
    type = LineValueSampler
    variable = 'stress_xx'
    start_point = '${a} 0 0'
    end_point = '${c} 0 0'
    num_points = 120
    sort_by = x
  []
  [stress_tt]
    type = LineValueSampler
    variable = 'stress_yy'
    start_point = '${a} 0 0'
    end_point = '${c} 0 0'
    num_points = 120
    sort_by = x
  []
  [stress_zz]
    type = LineValueSampler
    variable = 'stress_zz'
    start_point = '${a} 0 0'
    end_point = '${c} 0 0'
    num_points = 120
    sort_by = x
  []
  [temp]
    type = LineValueSampler
    variable = 'temp'
    start_point = '${a} 0 0'
    end_point = '${c} 0 0'
    num_points = 120
    sort_by = x
  []
  [creep_strain_rr]
    type = LineValueSampler
    variable = 'creep_strain_xx'
    start_point = '${a} 0 0'
    end_point = '${c} 0 0'
    num_points = 120
    sort_by = x
  []
  [creep_strain_tt]
    type = LineValueSampler
    variable = 'creep_strain_yy'
    start_point = '${a} 0 0'
    end_point = '${c} 0 0'
    num_points = 120
    sort_by = x
  []
  [creep_strain_zz]
    type = LineValueSampler
    variable = 'creep_strain_zz'
    start_point = '${a} 0 0'
    end_point = '${c} 0 0'
    num_points = 120
    sort_by = x
  []
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       strumpack                    '
  automatic_scaling = true

  l_max_its = 1000
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
  hide = 'scalar_strain_zz'
  [exodus]
    type = Exodus
    file_base = 'output/elastic_thermal_creep'
    interval = 5
  []
  [csv]
    type = CSV
    file_base = 'output/elastic_thermal_creep'
    execute_postprocessors_on = 'INITIAL TIMESTEP_END'
    execute_vector_postprocessors_on = 'FINAL'
  []
[]
