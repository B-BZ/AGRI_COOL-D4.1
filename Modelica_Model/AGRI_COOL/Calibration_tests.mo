within AGRI_COOL;
package Calibration_tests
  model Chiller_Static
    "Agri-Cool system with open-loop night control logic"


    //extends Modelica.Icons.Example;
    extends Components.Base_Classes.Medium_Definition;
    parameter Real QCo_flow_nominalx1(max = 0) = -3250 "Design cooling flow rate (<=0)" annotation(
      Dialog(group = "Nominal condition"), experiment( CalibrationParamter=true));
    //parameter Modelica.Units.SI.Power QCoo_flow_nominal=-3000;
    parameter Modelica.Units.SI.Temperature T_aCoWat_nominal(min = 273.15, displayUnit = "degC") = 273.15 + 1 "Cooling water inlet temperature at nominal conditions" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.Temperature T_bCoWat_nominal(min = 273.15, displayUnit = "degC") = 273.15 + 5 "Cooling water outlet temperature at nominal conditions" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.Temperature T_aLoaCo_nominal(min = 273.15, displayUnit = "degC") = 273.15 + 5 "Load side inlet temperature at nominal conditions in cooling mode" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.Temperature T_bLoaCo_nominal(min = 273.15, displayUnit = "degC") = 273.15 + 10 "Load side outlet temperature at nominal conditions in cooling mode" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.MassFlowRate mLoaCo_flow_nominal(min = 0) = 2500/1005/(T_bLoaCo_nominal - T_aLoaCo_nominal) "Load side mass flow rate at nominal conditions" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.HeatFlowRate QCo_flow_nominal(max = 0) = -3250 "Design cooling flow rate (<=0)" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.MassFlowRate mChilWat_flow_nominal(min = 0) = 0.5 "water side mass flow rate at nominal conditions" annotation(
      Dialog(group = "Nominal condition"));
    parameter Real facMul = 1 "Multiplier factor";
    parameter Integer nLoa = 1 "Number of served loads" annotation(
      Evaluate = true);
    ////
    parameter Modelica.Units.SI.PressureDifference dpNominal_CheckValve(displayUnit = "Pa") = 5000 "Load side pressure drop" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.PressureDifference dpNominal_fanCoil(displayUnit = "Pa") = 20000 "Load side pressure drop" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.PressureDifference dpNominal_conj(displayUnit = "Pa") = 2000 "Load side pressure drop" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.PressureDifference dpNominal_3way(displayUnit = "Pa") = 40000 "Load side pressure drop" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.PressureDifference dpNominal_PCM(displayUnit = "Pa") = 25000 "Load side pressure drop" annotation(
      Dialog(group = "Nominal condition"));
    parameter Modelica.Units.SI.PressureDifference dpNominal_Total_P01 = (dpNominal_CheckValve + 2*dpNominal_fanCoil + 2*dpNominal_conj + dpNominal_3way) "Total load side pressure drop";
    ////
    Components.Chiller.TwoCircuitChiller twoCircuitChiller(redeclare package Medium_Evap = Medium_HTF, redeclare package Medium_Cond = Medium_Air,
      Q_nom_Cool=QCo_flow_nominalx1,
      mChilWat_flow_nominal=0.4168,
      QCoo_flow_nominal2=QCo_flow_nominalx1,
      QCoo_flow_nominal1=QCo_flow_nominalx1)                                                                                                                                                annotation(
      Placement(transformation(extent={{-66,-40},{-16,22}})));
    Modelica.Blocks.Sources.Constant const(k=0.13)
      annotation (Placement(transformation(extent={{-176,-36},{-156,-16}})));
    Buildings.Fluid.Sources.MassFlowSource_T boundary(
      redeclare package Medium = Medium_HTF,
      m_flow=0.052,
      use_T_in=true,
      T=264.15,
      nPorts=1) annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={102,-10})));
    Buildings.Fluid.Sources.Boundary_pT bou(redeclare package Medium = Medium_HTF,
        nPorts=1)
      annotation (Placement(transformation(extent={{-186,2},{-166,22}})));
    Buildings.Fluid.Sources.MassFlowSource_T boundary1(
      redeclare package Medium = Medium_Air,
      m_flow=1.46,
      T=308.15,
      nPorts=2) annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={-160,66})));
    Buildings.Fluid.Sources.Boundary_pT bou1(redeclare package Medium =
          Medium_Air, nPorts=2)
      annotation (Placement(transformation(extent={{-2,46},{18,66}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_002(redeclare package Medium
        = Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)                                                                           annotation(
      Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=180,
          origin={-116,-12})));
  equation
    connect(const.y, twoCircuitChiller.ySet_C2) annotation (Line(points={{-155,
            -26},{-80,-26},{-80,-20.16},{-68,-20.16}},
                                                  color={0,0,127}));
    connect(const.y, twoCircuitChiller.ySet_C1) annotation (Line(points={{-155,
            -26},{-106,-26},{-106,-33.8},{-68,-33.8}},
                                                  color={0,0,127}));
    connect(twoCircuitChiller.Evap_inlet_C1, boundary.ports[1]) annotation (Line(
          points={{-15.5,-9},{-15.5,-10},{92,-10}}, color={0,127,255}));
    connect(boundary1.ports[1], twoCircuitChiller.Cond_Inlet_C2) annotation (Line(
          points={{-170,67},{-176,67},{-176,32},{-59.5,32},{-59.5,22}}, color={0,127,
            255}));
    connect(boundary1.ports[2], twoCircuitChiller.Cond_Inlet_C1) annotation (Line(
          points={{-170,65},{-176,65},{-176,32},{-53,32},{-53,22}}, color={0,127,255}));
    connect(twoCircuitChiller.Cond_outlet_C2, bou1.ports[1]) annotation (Line(
          points={{-36.5,22},{-36.5,40},{24,40},{24,55},{18,55}}, color={0,127,255}));
    connect(twoCircuitChiller.Cond_outlet_C1, bou1.ports[2]) annotation (Line(
          points={{-30,22},{-30,40},{24,40},{24,57},{18,57}}, color={0,127,255}));
    connect(twoCircuitChiller.Evap_outlet_C2, TIT_002.port_a) annotation (Line(
          points={{-66,-10.86},{-100,-10.86},{-100,-12},{-106,-12}}, color={0,127,
            255}));
    connect(TIT_002.port_b, bou.ports[1]) annotation (Line(points={{-126,-12},{-150,
            -12},{-150,12},{-166,12}}, color={0,127,255}));
    annotation(
      Icon(coordinateSystem(preserveAspectRatio = false, extent={{-220,-120},{140,
              120}}),                                                                          graphics = {Rectangle(extent = {{-776, 118}, {138, -320}}, lineColor = {0, 140, 72}, fillColor = {0, 140, 72}, fillPattern = FillPattern.Solid), Rectangle(extent = {{-746, 94}, {104, -294}}, lineColor = {0, 140, 72}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-726, 88}, {84, -276}}, textColor = {0, 140, 72}, textString = "System_OL", textStyle = {TextStyle.Bold})}),
      Diagram(coordinateSystem(preserveAspectRatio = false, extent={{-220,-120},{140,
              120}})),
      experiment(StopTime=3600, __Dymola_Algorithm="Dassl"));
  end Chiller_Static;
end Calibration_tests;
