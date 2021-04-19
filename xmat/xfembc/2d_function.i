refinement = 0

[XFEM]
  output_cut_plane = true
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    xmax = 2
    nx = '${fparse int(2^refinement+1)}'
    ny = 1
  []
  [left]
    type = SubdomainBoundingBoxGenerator
    input = gmg
    block_id = 0
    bottom_left = '0 0 0'
    top_right = '1 1 0'
  []
  [right]
    type = SubdomainBoundingBoxGenerator
    input = left
    block_id = 1
    bottom_left = '1 0 0'
    top_right = '2 1 0'
  []
[]

[UserObjects]
  [cut]
    type = LevelSetCutUserObject
    level_set_var = phi
    negative_id = 0
    positive_id = 1
  []
  [esm]
    type = GeometricCutElementSubdomainModifier
    geometric_cut_userobject = cut
    apply_initial_conditions = false
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Functions]
  [solution]
    type = ParsedFunction
    value = 'x^3+3*x^2+x+5'
  []
  [flux]
    type = ParsedFunction
    value = '3*x^2+6*x+1'
  []
  [source]
    type = ParsedFunction
    value = '-6*x-6'
  []
[]

[Variables]
  [temp]
  []
[]

[AuxVariables]
  [phi]
  []
  [solution]
  []
[]

[AuxKernels]
  [phi]
    type = FunctionAux
    variable = phi
    function = 'x-1'
    execute_on = 'INITIAL LINEAR TIMESTEP_END'
  []
  [solution]
    type = FunctionAux
    variable = solution
    function = solution
  []
[]

[Kernels]
  [heat_conduction]
    type = MatDiffusion
    variable = temp
    diffusivity = 1
  []
  [heat]
    type = BodyForce
    variable = temp
    function = source
  []
[]

[BCs]
  [fix_T_left]
    type = FunctionDirichletBC
    variable = temp
    boundary = 'left right'
    function = solution
  []
[]

[DiracKernels]
  [right]
    type = XFEMFunctionNeumannBC
    variable = temp
    geometric_cut_userobject = cut
    function = flux
  []
[]

[Postprocessors]
  [error]
    type = ElementL2Error
    variable = temp
    function = solution
    block = 0
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  num_steps = 1
  nl_abs_tol = 1e-12
  nl_rel_tol = 1e-08

  automatic_scaling = true
  max_xfem_update = 1
  abort_on_solve_fail = true
[]

[Outputs]
  exodus = true
[]
