/*=========================================================================
 
Program:   Medical Imaging & Transferfunctioneraction Toolkit
Module:    $RCSfile: mitkPropertyManager.cpp,v $
Language:  C++
Date:      $Date$
Version:   $Revision: 1.12 $
 
Copyright (c) German Cancer Research Center, Division of Medical and
Biological Informatics. All rights reserved.
See MITKCopyright.txt or http://www.mitk.org/copyright.html for details.
 
This software is distributed WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.  See the above copyright notices for more information.
 
=========================================================================*/

#ifndef mitkTransferFunctionPropertySerializer_h_included
#define mitkTransferFunctionPropertySerializer_h_included

#include "mitkBasePropertySerializer.h"

#include "mitkTransferFunctionProperty.h"

namespace mitk
{

class SceneSerialization_EXPORT TransferFunctionPropertySerializer : public BasePropertySerializer
{
  public:
    
    mitkClassMacro( TransferFunctionPropertySerializer, BasePropertySerializer );
    itkNewMacro(Self);

    virtual TiXmlElement* Serialize()
    {
      if (const TransferFunctionProperty* prop = dynamic_cast<const TransferFunctionProperty*>(m_Property.GetPointer()))
      {
        TransferFunction* transferfunction = prop->GetValue();
        if (!transferfunction) 
          return NULL;

        TiXmlElement* element = new TiXmlElement("TransferFunction");

        // serialize scalar opacity function
        TiXmlElement* scalarOpacityPointlist = new TiXmlElement( "ScalarOpacity" );

        TransferFunction::ControlPoints scalarOpacityPoints = transferfunction->GetScalarOpacityPoints();
        for ( TransferFunction::ControlPoints::iterator iter = scalarOpacityPoints.begin();
          iter != scalarOpacityPoints.end();
          ++iter )
        {
          TiXmlElement* pointel = new TiXmlElement("point");
          pointel->SetDoubleAttribute("x", iter->first);
          pointel->SetDoubleAttribute("y", iter->second);
          scalarOpacityPointlist->LinkEndChild( pointel );
        }
        element->LinkEndChild( scalarOpacityPointlist );
        // serialize gradient opacity function
        TiXmlElement* gradientOpacityPointlist = new TiXmlElement( "GradientOpacity" );
        TransferFunction::ControlPoints gradientOpacityPoints = transferfunction->GetGradientOpacityPoints();
        for ( TransferFunction::ControlPoints::iterator iter = gradientOpacityPoints.begin();
          iter != gradientOpacityPoints.end();
          ++iter )
        {
          TiXmlElement* pointel = new TiXmlElement("point");
          pointel->SetDoubleAttribute("x", iter->first);
          pointel->SetDoubleAttribute("y", iter->second);
          gradientOpacityPointlist->LinkEndChild( pointel );
        }
        element->LinkEndChild( gradientOpacityPointlist );

        // serialize color function
        vtkColorTransferFunction* ctf = transferfunction->GetColorTransferFunction();
        if (ctf == NULL)
          return NULL;
        TiXmlElement* pointlist = new TiXmlElement("Color");
        for (int i = 0; i < ctf->GetSize(); i++ )
        {
          double myVal[6];
          ctf->GetNodeValue(i, myVal);
          TiXmlElement* pointel = new TiXmlElement("point");
          pointel->SetDoubleAttribute("x", myVal[0]);
          pointel->SetDoubleAttribute("r", myVal[1]);
          pointel->SetDoubleAttribute("g", myVal[2]);
          pointel->SetDoubleAttribute("b", myVal[3]);
          pointel->SetDoubleAttribute("midpoint", myVal[4]);
          pointel->SetDoubleAttribute("sharpness", myVal[5]);
          pointlist->LinkEndChild( pointel );
        }
        element->LinkEndChild( pointlist );
        return element;
      }
      else return NULL;
    }
  protected:
    TransferFunctionPropertySerializer() {}
    virtual ~TransferFunctionPropertySerializer() {}
};
} // namespace
// important to put this into the GLOBAL namespace (because it starts with 'namespace mitk')
MITK_REGISTER_SERIALIZER(TransferFunctionPropertySerializer);
#endif
