//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PFFComputeMultipleInelasticStress.h"

registerMooseObject("BlackBearApp", PFFComputeMultipleInelasticStress);

InputParameters
PFFComputeMultipleInelasticStress::validParams()
{
  InputParameters params = ComputeMultipleInelasticStress::validParams();

  params.addParam<MaterialPropertyName>(
      "strain_energy_density",
      "psie",
      "Name of the strain energy density computed by this material model");
  params.addParam<MaterialPropertyName>(
      "degradation_function", "g", "The in-plane degradation function");
  return params;
}

PFFComputeMultipleInelasticStress::PFFComputeMultipleInelasticStress(
    const InputParameters & parameters)
  : ComputeMultipleInelasticStress(parameters),
    // The strain energy density
    _psie_name(_base_name + getParam<MaterialPropertyName>("strain_energy_density")),
    _psie_active(declareProperty<Real>(_psie_name + "_active")),

    // The degradation function
    _g_name(_base_name + getParam<MaterialPropertyName>("degradation_function")),
    _g(getMaterialProperty<Real>(_g_name))
{
}

void
PFFComputeMultipleInelasticStress::computeQpStress()
{
  ComputeMultipleInelasticStress::computeQpStress();

  // Isotropic elasticity is assumed and should be enforced
  const Real lambda = _elasticity_tensor[_qp](0, 0, 1, 1);
  const Real mu = _elasticity_tensor[_qp](0, 1, 0, 1);
  const Real k = lambda + 2.0 * mu / LIBMESH_DIM;

  RankTwoTensor I2(RankTwoTensor::initIdentity);
  RankFourTensor I2I2 = I2.outerProduct(I2);

  RankTwoTensor strain0dev = _elastic_strain[_qp].deviatoric();
  RankTwoTensor strain0vol = _elastic_strain[_qp] - strain0dev;
  Real strain0tr = _elastic_strain[_qp].trace();
  Real strain0tr_neg = std::min(strain0tr, 0.0);
  Real strain0tr_pos = strain0tr - strain0tr_neg;
  RankTwoTensor stress0neg = k * strain0tr_neg * I2;
  RankTwoTensor stress0pos = _elasticity_tensor[_qp] * _elastic_strain[_qp] - stress0neg;
  RankTwoTensor strain0dev2 = strain0dev * strain0dev;

  _psie_active[_qp] = 0.5 * k * strain0tr_pos * strain0tr_pos + mu * strain0dev2.trace();

  _stress[_qp] = stress0pos * _g[_qp] + stress0neg;

  RankFourTensor Jacobian_neg;
  if (strain0tr < 0)
    Jacobian_neg = k * I2I2;
  RankFourTensor Jacobian_pos = _elasticity_tensor[_qp] - Jacobian_neg;
  _Jacobian_mult[_qp] = _g[_qp] * Jacobian_pos + Jacobian_neg;
}
