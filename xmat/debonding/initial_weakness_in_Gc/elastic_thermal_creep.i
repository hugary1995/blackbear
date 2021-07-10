# geometry
a = 14
b = 17
c = 25
H = 30

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

# fracture properties
psic = 0.016
# Gc = 0.025
l = 0.0625
ep0 = 5e-6
beta = 0.2

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[MultiApps]
  [ref_temp]
    type = FullSolveMultiApp
    input_files = 'ref_temp.i'
    app_type = BlackBearApp
    execute_on = 'INITIAL'
    cli_args = 'a=${a};b=${b};c=${c};H=${H};kappa_oxide=${kappa_oxide};kappa_metal=${kappa_metal};h_g'
               'as=${h_gas};h_steam=${h_steam}'
  []
  [fracture]
    type = TransientMultiApp
    input_files = 'fracture.i'
    cli_args = 'a=${a};b=${b};c=${c};H=${H};psic=${psic};l=${l};ep0=${ep0};beta=${beta};'
    execute_on = 'INITIAL TIMESTEP_END'
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
  [from_d]
    type = MultiAppMeshFunctionTransfer
    multi_app = fracture
    direction = from_multiapp
    variable = d
    source_variable = d
  []
  [to_psie_active]
    type = MultiAppMeshFunctionTransfer
    multi_app = fracture
    direction = to_multiapp
    variable = psie_active
    source_variable = psie_active
  []
  [to_ep_active]
    type = MultiAppMeshFunctionTransfer
    multi_app = fracture
    direction = to_multiapp
    variable = effective_creep_strain
    source_variable = effective_creep_strain
  []
[]

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

[Functions]
  [CTE_oxide]
    type = PiecewiseLinear
    format = columns
    data_file = '../gold/CTE_oxide.csv'
  []
  [CTE_metal]
    type = PiecewiseLinear
    format = columns
    data_file = '../gold/CTE_metal.csv'
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
  [Gc]
    type = PiecewiseMultilinear
    data_file = '../gold/Gc.txt'
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [temp]
  []
[]

[AuxVariables]
  [interface]
  []
  [ref_temp]
  []
  [temp_in_K]
  []
  [d]
  []
  [Gc]
    order = CONSTANT
    family = MONOMIAL
    [InitialCondition]
      type = FunctionIC
      function = 'Gc'
    []
  []
[]

[AuxKernels]
  [temp_in_K]
    type = ParsedAux
    variable = 'temp_in_K'
    args = 'temp'
    function = 'temp + 273.15'
  []
[]

[Kernels]
  [solid_x]
    type = StressDivergenceRZTensors
    variable = 'disp_x'
    temperature = 'temp'
    eigenstrain_names = 'thermal_eigenstrain'
    use_finite_deform_jacobian = true
    component = 0
    use_displaced_mesh = true
  []
  [solid_y]
    type = StressDivergenceRZTensors
    variable = 'disp_y'
    temperature = 'temp'
    eigenstrain_names = 'thermal_eigenstrain'
    use_finite_deform_jacobian = true
    component = 1
    use_displaced_mesh = true
  []
  [conduction]
    type = HeatConduction
    variable = 'temp'
  []
[]

[BCs]
  [fixed_y]
    type = DirichletBC
    variable = 'disp_y'
    boundary = 'top_oxide top_metal bottom_oxide bottom_metal'
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
  [fracture_properties]
    type = GenericConstantMaterial
    prop_names = 'l psic'
    prop_values = '${l} ${psic}'
    block = 0
  []
  [Gc]
    type = ParsedMaterial
    f_name = Gc
    function = 'Gc'
    args = 'Gc'
    block = 0
  []
  [degradation]
    type = ParsedMaterial
    f_name = g
    args = d
    function = (1-d)^p/((1-d)^p+(Gc/psic*xi/c0/l)*d*(1+a2*d+a2*a3*d^2))*(1-eta)+eta
    constant_names = 'p xi c0 a2 a3 eta'
    constant_expressions = '2 1 ${fparse 8/3} 1 0 1e-3'
    material_property_names = 'Gc psic l'
    block = 0
  []
  [crack_geometric_function]
    type = DerivativeParsedMaterial
    f_name = w
    args = 'd'
    function = 'd'
    derivative_order = 2
    block = 0
  []
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
    type = ComputeAxisymmetricRZIncrementalStrain
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
    outputs = exodus
    output_properties = 'effective_creep_strain'
  []
  [stress_oxide]
    type = PFFComputeMultipleInelasticStress
    inelastic_models = 'creep_oxide'
    degradation_function = g
    block = 0
    outputs = exodus
    output_properties = 'stress elastic_strain psie_active'
  []
  [gc]
    type = ParsedMaterial
    f_name = gc
    function = '1-(1-beta)*(1-exp(-effective_creep_strain/ep0))'
    constant_names = 'beta ep0'
    constant_expressions = '${beta} ${ep0}'
    material_property_names = 'effective_creep_strain'
    block = 0
    outputs = exodus
    output_properties = 'gc'
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
    constant_on = SUBDOMAIN
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
    type = ComputeAxisymmetricRZIncrementalStrain
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
  [years]
    type = FunctionValuePostprocessor
    function = 't/86400/360'
  []
  [solution_change]
    type = SolutionChangeNorm
    variable = 'disp_x disp_y d'
    block = 0
    outputs = none
  []
[]

[VectorPostprocessors]
  [bcs]
    type = CSVReader
    csv_file = '../gold/BC.csv'
    header = true
  []
[]

[Dampers]
  [ejd]
    type = ElementJacobianDamper
    max_increment = 0.1
    min_damping = 0
    use_displaced_mesh = true
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
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
    file_name = '../gold/BC.csv'
    header = true
  []
  end_time = 15555645

  max_xfem_update = 1

  fixed_point_max_its = 50
  fixed_point_abs_tol = 1e-6
  fixed_point_rel_tol = 1e-6
  accept_on_max_fixed_point_iteration = true
[]

[Outputs]
  print_linear_residuals = false
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  [exodus]
    type = Exodus
    file_base = 'output/elastic_thermal_creep'
    interval = 1
  []
[]
