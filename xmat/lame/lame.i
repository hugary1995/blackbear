[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [gmg]
    type = AnnularMeshGenerator
    dmin = 0
    dmax = 90
    nr = ${nr}
    nt = ${nt}
    rmin = 1
    rmax = 4
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
    heal_always = true
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [interface]
  []
  [disp_r]
  []
  [disp_t]
  []
  [stress_rr]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_tt]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [interface]
    type = FunctionAux
    variable = interface
    function = 'if(t<10,sqrt(x^2+y^2)-2,sqrt(x^2+y^2)-2-0.1001*(t-10))'
  []
  [stress_rr]
    type = CylindricalRankTwoAux
    variable = 'stress_rr'
    center_point = '0 0 0'
    rank_two_tensor = 'stress'
    index_i = 0
    index_j = 0
  []
  [stress_tt]
    type = CylindricalRankTwoAux
    variable = 'stress_tt'
    center_point = '0 0 0'
    rank_two_tensor = 'stress'
    index_i = 1
    index_j = 1
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
[]

[Constraints]
  [disp_x_constraint]
    type = XFEMSingleVariableConstraint
    variable = 'disp_x'
    geometric_cut_userobject = 'cut'
    alpha = 1e6
    use_penalty = true
    use_displaced_mesh = true
  []
  [disp_y_constraint]
    type = XFEMSingleVariableConstraint
    variable = 'disp_y'
    geometric_cut_userobject = 'cut'
    alpha = 1e6
    use_penalty = true
    use_displaced_mesh = true
  []
[]

[BCs]
  [Pressure]
    [inner]
      boundary = 'rmin'
      function = '10*t'
    []
    [outer]
      boundary = 'rmax'
      function = '5*t'
    []
  []
  [symmetry_y]
    type = DirichletBC
    variable = 'disp_y'
    value = 0
    boundary = 'dmin'
  []
  [symmetry_x]
    type = DirichletBC
    variable = 'disp_x'
    value = 0
    boundary = 'dmax'
  []
[]

[Materials]
  [elasticity_tensor_1]
    type = ComputeIsotropicElasticityTensor
    shear_modulus = 1e3
    poissons_ratio = 0.3
    base_name = block1
  []
  [strain_1]
    type = ComputeFiniteStrain
    base_name = block1
  []
  [stress_1]
    type = ComputeFiniteStrainElasticStress
    base_name = block1
  []
  [elasticity_tensor_2]
    type = ComputeIsotropicElasticityTensor
    shear_modulus = 2e3
    poissons_ratio = 0.3
    base_name = block2
  []
  [strain_2]
    type = ComputeFiniteStrain
    base_name = block2
  []
  [stress_2]
    type = ComputeFiniteStrainElasticStress
    base_name = block2
  []
  # bimaterial
  [combined_stress]
    type = LevelSetBiMaterialRankTwo
    levelset_negative_base = 'block1'
    levelset_positive_base = 'block2'
    level_set_var = 'interface'
    prop_name = stress
  []
  [combined_Jacobian_mult]
    type = LevelSetBiMaterialRankFour
    levelset_negative_base = 'block1'
    levelset_positive_base = 'block2'
    level_set_var = 'interface'
    prop_name = Jacobian_mult
  []
[]

[VectorPostprocessors]
  [u_r]
    type = NodalValueSampler
    variable = 'disp_x'
    boundary = dmin
    sort_by = x
  []
  [stress_rr]
    type = LineValueSampler
    variable = 'stress_rr'
    num_points = 1000
    start_point = '1 0 0'
    end_point = '4 0 0'
    sort_by = x
  []
  [stress_tt]
    type = LineValueSampler
    variable = 'stress_tt'
    num_points = 1000
    start_point = '1 0 0'
    end_point = '4 0 0'
    sort_by = x
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist'
  automatic_scaling = true

  # controls for nonlinear iterations
  nl_rel_tol = 1e-06
  nl_abs_tol = 1e-08

  dt = 1
  end_time = 20

  max_xfem_update = 1
[]

[Outputs]
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  print_linear_residuals = false
  [exodus]
    type = Exodus
    file_base = 'output/visualize_nr_${nr}_nt_${nt}'
  []
  [csv]
    type = CSV
    file_base = 'output/data_nr_${nr}_nt_${nt}'
  []
[]
