//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ComputeMultipleInelasticStress.h"

class PFFComputeMultipleInelasticStress : public ComputeMultipleInelasticStress
{
public:
  static InputParameters validParams();

  PFFComputeMultipleInelasticStress(const InputParameters & parameters);

protected:
  virtual void computeQpStress() override;

  // @{ Strain energy density and its derivative w/r/t damage
  const MaterialPropertyName _psie_name;
  MaterialProperty<Real> & _psie_active;
  // @}

  // @{ The degradation function and its derivative w/r/t damage
  const MaterialPropertyName _g_name;
  const MaterialProperty<Real> & _g;
  // @}
};
