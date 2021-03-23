E = 1.9e5
nu = 0.3

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [cube]
    type = GeneratedMeshGenerator
    dim = 3
  []
  [pin]
    type = ExtraNodesetGenerator
    input = cube
    new_boundary = 'pin'
    coord = '0 0 0'
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [temp]
    initial_condition = 600
  []
  [temp_in_K]
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [total_strain_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [creep_strain_yy]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [stress_yy]
    type = RankTwoAux
    variable = 'stress_yy'
    rank_two_tensor = 'stress'
    index_i = 1
    index_j = 1
    execute_on = 'TIMESTEP_END'
  []
  [total_strain_yy]
    type = RankTwoAux
    variable = 'total_strain_yy'
    rank_two_tensor = 'total_strain'
    index_i = 1
    index_j = 1
    execute_on = 'TIMESTEP_END'
  []
  [temp_in_K]
    type = ParsedAux
    variable = 'temp_in_K'
    args = 'temp'
    function = 'temp + 273.15'
  []
[]

[Kernels]
  [solid_x]
    type = StressDivergenceTensors
    variable = 'disp_x'
    component = 0
    use_displaced_mesh = true
  []
  [solid_y]
    type = StressDivergenceTensors
    variable = 'disp_y'
    component = 1
    use_displaced_mesh = true
  []
  [solid_z]
    type = StressDivergenceTensors
    variable = 'disp_z'
    component = 2
    use_displaced_mesh = true
  []
[]

[BCs]
  [xfix]
    type = DirichletBC
    variable = 'disp_x'
    boundary = 'pin'
    value = 0
  []
  [yfix]
    type = DirichletBC
    variable = 'disp_y'
    boundary = 'bottom'
    value = 0
  []
  [zfix]
    type = DirichletBC
    variable = 'disp_z'
    boundary = 'pin'
    value = 0
  []
  [yforce]
    type = FunctionNeumannBC
    variable = disp_y
    boundary = top
    function = 't/186624000*50'
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = ${E}
    poissons_ratio = ${nu}
  []
  [strain]
    type = ComputeFiniteStrain
  []
  [stress]
    type = ComputeFiniteStrainElasticStress
  []
[]

[Postprocessors]
  [stress]
    type = ElementAverageValue
    variable = 'stress_yy'
  []
  [total_strain]
    type = ElementAverageValue
    variable = 'total_strain_yy'
  []
  [creep_strain]
    type = ElementAverageValue
    variable = 'creep_strain_yy'
  []
[]

[Executioner]
  type = Transient
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu      '
  automatic_scaling = true
  # line_search = none

  nl_rel_tol = 1e-06
  nl_abs_tol = 1e-06

  dt = 186624
  end_time = 186624000
[]

[Outputs]
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  print_linear_residuals = false
  exodus = true
  csv = true
[]
