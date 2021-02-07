a = 13.8
b = 14
b_ = 14.03
c = 25
E_oxide = 1.9e5
E_metal = 1.9e5
nu_oxide = 0.3
nu_metal = 0.3
CTE_oxide = 2.1e-5
CTE_metal = 1.4e-5
T_ref = '${fparse 580+273}'
T_fin = '${fparse 480+273}'
end_time = 10

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [refined]
    type = AnnularMeshGenerator
    dmin = 0
    dmax = 90
    rmin = ${a}
    rmax = ${b_}
    nr = 5
    nt = 160
  []
  [coarse]
    type = AnnularMeshGenerator
    dmin = 0
    dmax = 90
    rmin = ${b_}
    rmax = ${c}
    nr = 40
    nt = 160
  []
  [stitch]
    type = StitchedMeshGenerator
    inputs = 'refined coarse'
    stitch_boundaries_pairs = 'rmax rmin'
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [scalar_strain_zz]
    order = FIRST
    family = SCALAR
  []
[]

[AuxVariables]
  [interface]
  []
  [temperature]
    [InitialCondition]
      type = ConstantIC
      value = ${T_ref}
    []
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
[]

[XFEM]
  qrule = volfrac
  output_cut_plane = true
  minimum_weight_multiplier = 0.00
[]

[UserObjects]
  [gps]
    type = GeneralizedPlaneStrainUserObject
  []
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
    function = 'r:=sqrt(x^2+y^2); r-${b}'
  []
  [temperature]
    type = FunctionAux
    variable = temperature
    function = '${T_ref}+t*(${T_fin}-${T_ref})/${end_time}'
  []
  [stress_xx]
    type = RankTwoAux
    variable = 'stress_xx'
    rank_two_tensor = 'stress'
    index_i = 0
    index_j = 0
  []
  [stress_yy]
    type = RankTwoAux
    variable = 'stress_yy'
    rank_two_tensor = 'stress'
    index_i = 1
    index_j = 1
  []
  [stress_zz]
    type = RankTwoAux
    variable = 'stress_zz'
    rank_two_tensor = 'stress'
    index_i = 2
    index_j = 2
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
    component = 0
    use_displaced_mesh = true
  []
  [solid_y]
    type = StressDivergenceTensors
    variable = 'disp_y'
    component = 1
    use_displaced_mesh = true
  []
  [solid_xz]
    type = GeneralizedPlaneStrainOffDiag
    variable = 'disp_x'
    scalar_out_of_plane_strain = 'scalar_strain_zz'
  []
  [solid_yz]
    type = GeneralizedPlaneStrainOffDiag
    variable = 'disp_y'
    scalar_out_of_plane_strain = 'scalar_strain_zz'
  []
[]

[Constraints]
  [disp_x_constraint]
    type = XFEMSingleVariableConstraint
    variable = 'disp_x'
    geometric_cut_userobject = 'cut'
    alpha = 1e10
    use_displaced_mesh = true
    use_penalty = true
  []
  [disp_y_constraint]
    type = XFEMSingleVariableConstraint
    variable = 'disp_y'
    geometric_cut_userobject = 'cut'
    alpha = 1e10
    use_displaced_mesh = true
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
[]

[Materials]
  # oxide
  [eigenstrain_oxide]
    type = ComputeThermalExpansionEigenstrain
    base_name = oxide
    stress_free_temperature = ${T_ref}
    temperature = temperature
    thermal_expansion_coeff = ${CTE_oxide}
    eigenstrain_name = 'thermal_eigenstrain'
  []
  [elasticity_tensor_oxide]
    type = ComputeIsotropicElasticityTensor
    base_name = oxide
    youngs_modulus = ${E_oxide}
    poissons_ratio = ${nu_oxide}
  []
  [strain_oxide]
    type = ComputePlaneFiniteStrain
    base_name = oxide
    scalar_out_of_plane_strain = scalar_strain_zz
    eigenstrain_names = 'thermal_eigenstrain'
  []
  [stress_oxide]
    type = ComputeFiniteStrainElasticStress
    base_name = oxide
  []
  # metal
  [elasticity_tensor_metal]
    type = ComputeIsotropicElasticityTensor
    base_name = metal
    youngs_modulus = ${E_metal}
    poissons_ratio = ${nu_metal}
  []
  [eigenstrain_metal]
    type = ComputeThermalExpansionEigenstrain
    base_name = metal
    stress_free_temperature = ${T_ref}
    temperature = temperature
    thermal_expansion_coeff = ${CTE_metal}
    eigenstrain_name = 'thermal_eigenstrain'
  []
  [strain_metal]
    type = ComputePlaneFiniteStrain
    base_name = metal
    scalar_out_of_plane_strain = scalar_strain_zz
    eigenstrain_names = 'thermal_eigenstrain'
  []
  [stress_metal]
    type = ComputeFiniteStrainElasticStress
    base_name = metal
  []
  # bimaterial
  [combined_eigenstrain]
    type = LevelSetBiMaterialRankTwo
    levelset_positive_base = 'metal'
    levelset_negative_base = 'oxide'
    level_set_var = 'interface'
    prop_name = thermal_eigenstrain
  []
  [combined_stress]
    type = LevelSetBiMaterialRankTwo
    levelset_positive_base = 'metal'
    levelset_negative_base = 'oxide'
    level_set_var = 'interface'
    prop_name = stress
  []
  [combined_C]
    type = LevelSetBiMaterialRankFour
    levelset_positive_base = 'metal'
    levelset_negative_base = 'oxide'
    level_set_var = 'interface'
    prop_name = elasticity_tensor
  []
  [combined_Jacobian]
    type = LevelSetBiMaterialRankFour
    levelset_positive_base = 'metal'
    levelset_negative_base = 'oxide'
    level_set_var = 'interface'
    prop_name = Jacobian_mult
  []
[]

[VectorPostprocessors]
  [rr]
    type = LineValueSampler
    variable = 'stress_xx'
    start_point = '${a} 0 0'
    end_point = '${c} 0 0'
    num_points = 120
    sort_by = x
  []
  [tt]
    type = LineValueSampler
    variable = 'stress_yy'
    start_point = '${a} 0 0'
    end_point = '16 0 0'
    num_points = 120
    sort_by = x
  []
  [zz]
    type = LineValueSampler
    variable = 'stress_zz'
    start_point = '${a} 0 0'
    end_point = '16 0 0'
    num_points = 120
    sort_by = x
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

  dt = 0.5
  end_time = ${end_time}

  max_xfem_update = 1
[]

[Outputs]
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  print_linear_residuals = false
  [csv]
    type = CSV
    file_base = 'output/stress'
    execute_on = 'FINAL'
  []
[]
