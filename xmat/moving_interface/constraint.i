[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [refined]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 50
    ny = 50
  []
[]

[XFEM]
  qrule = volfrac
  output_cut_plane = true
[]

[UserObjects]
  [cut]
    type = LevelSetCutUserObject
    level_set_var = phi
    heal_always = true
  []
[]

[Variables]
  [disp_x]
  []
[]

[AuxVariables]
  [phi]
  []
  [disp_y]
  []
[]

[AuxKernels]
  [phi]
    type = FunctionAux
    variable = phi
    function = 'x-0.1-t+0.05*sin(5*pi*(y+t))+0.025*cos(8*pi*(y+2*t))'
  []
[]

[Kernels]
  [diff]
    type = Diffusion
    variable = 'disp_x'
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = disp_x
    boundary = 'left'
    value = 0
  []
  [right]
    type = DirichletBC
    variable = disp_x
    boundary = 'right'
    value = 0.2
  []
[]

[Constraints]
  [disp_x_constraint]
    type = XFEMSingleVariableConstraint
    variable = 'disp_x'
    geometric_cut_userobject = 'cut'
    alpha = 100
    # use_displaced_mesh = true
    use_penalty = true
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true
  nl_rel_tol = 1e-06
  nl_abs_tol = 1e-08

  dt = 0.01
  end_time = 0.8

  max_xfem_update = 1
[]

[Outputs]
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  print_linear_residuals = false
  [exo]
    type = Exodus
    file_base = 'output/constraint'
  []
[]
