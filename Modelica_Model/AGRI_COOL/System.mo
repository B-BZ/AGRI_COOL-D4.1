within AGRI_COOL;
package System

  model System_OL_NightCTRL
    "Agri-Cool system with open-loop night control logic"
    //extends Modelica.Icons.Example;
    extends Components.Base_Classes.Medium_Definition;

  parameter Modelica.Units.SI.Temperature T_aCoWat_nominal(
      min=273.15,
      displayUnit="degC") = 273.15 + 1
      "Cooling water inlet temperature at nominal conditions"    annotation (Dialog(group="Nominal condition"));
    parameter Modelica.Units.SI.Temperature T_bCoWat_nominal(
      min=273.15,
     displayUnit="degC") = 273.15 + 5
      "Cooling water outlet temperature at nominal conditions"
      annotation (Dialog(group="Nominal condition"));
    parameter Modelica.Units.SI.Temperature T_aLoaCo_nominal(
      min=273.15,
      displayUnit="degC") = 273.15 + 5
      "Load side inlet temperature at nominal conditions in cooling mode"
      annotation (Dialog(group="Nominal condition"));
    parameter Modelica.Units.SI.Temperature T_bLoaCo_nominal(
      min=273.15,
      displayUnit="degC") = 273.15 + 10
      "Load side outlet temperature at nominal conditions in cooling mode"
      annotation (Dialog(group="Nominal condition"));
    parameter Modelica.Units.SI.MassFlowRate mLoaCo_flow_nominal(min=0) =
      2500/1005/(T_bLoaCo_nominal - T_aLoaCo_nominal)
      "Load side mass flow rate at nominal conditions"
      annotation (Dialog(group="Nominal condition"));

    parameter Modelica.Units.SI.HeatFlowRate QCo_flow_nominal=
        -2500  "Design cooling flow rate (<=0)"
      annotation (Dialog(group="Nominal condition"));
   parameter Modelica.Units.SI.MassFlowRate mChilWat_flow_nominal(min=0) =
      0.5
      "water side mass flow rate at nominal conditions"
      annotation (Dialog(group="Nominal condition"));

    parameter Real facMul=1
      "Multiplier factor";
     parameter Integer nLoa=1
      "Number of served loads"
      annotation (Evaluate=true);

      ////
       parameter Modelica.Units.SI.PressureDifference dpNominal_CheckValve(displayUnit="Pa")=
         5000 "Load side pressure drop"
      annotation (Dialog(group="Nominal condition"));
      parameter Modelica.Units.SI.PressureDifference dpNominal_fanCoil(displayUnit="Pa")=
         20000 "Load side pressure drop"
      annotation (Dialog(group="Nominal condition"));
          parameter Modelica.Units.SI.PressureDifference dpNominal_conj(displayUnit="Pa")=
         2000 "Load side pressure drop"
      annotation (Dialog(group="Nominal condition"));
              parameter Modelica.Units.SI.PressureDifference dpNominal_3way(displayUnit="Pa")=
         40000 "Load side pressure drop"
         annotation (Dialog(group="Nominal condition"));
     parameter Modelica.Units.SI.PressureDifference dpNominal_PCM( displayUnit="Pa")=
         25000 "Load side pressure drop"
      annotation (Dialog(group="Nominal condition"));

    parameter Modelica.Units.SI.PressureDifference dpNominal_Total_P01 =
    (dpNominal_CheckValve + 2*dpNominal_fanCoil + 2*dpNominal_conj + dpNominal_3way)
    "Total load side pressure drop";    ////

    Components.Cold_Room.ColdROOM_V01 coldROOM_V01(
      redeclare package Medium_CR = Medium_Air,
      nPortsAir=7,
      T_start_CR=288.15)
      annotation (Placement(transformation(extent={{36,6},{56,26}})));
    Buildings.BoundaryConditions.WeatherData.ReaderTMY3 Mogadishu(
      filNam=ModelicaServices.ExternalReferences.loadResource(
          "modelica://AGRI_COOL/Inputs/SOM_BN_Mogadishu.Intl.AP.632600_TMYx.2009-2023.mos"),
      computeWetBulbTemperature=false,
      HInfHorSou=Buildings.BoundaryConditions.Types.DataSource.Parameter,
      HSou=Buildings.BoundaryConditions.Types.RadiationDataSource.Input_HGloHor_HDifHor)
      annotation (Placement(transformation(extent={{88,88},{108,108}})));
    Components.Cooling_Loads.Infiltration_load.Infiltration_ZoneFlow infiltration(
        redeclare package Medium_CR = Medium_Air)
      annotation (Placement(transformation(extent={{16,68},{36,88}})));
    Components.Cooling_Loads.Integrated.Loads_enhanced
                                              loads_enhanced(
                                                    n=2,
      m_Initial_T1=0,
      T_Initial_T1=298.15,
      m_Initial_T2=0,
      T_Initial_T2=283.15,
      T_source=298.15)
      annotation (Placement(transformation(extent={{-22,12},{2,32}})));
    Modelica.Blocks.Sources.Constant Zero(k=0) "No radiation"
      annotation (Placement(transformation(extent={{58,68},{78,88}})));
    Buildings.Fluid.Sources.Outside           out(redeclare package Medium =
          Medium_Air, nPorts=4)
      annotation (Placement(transformation(extent={{-84,80},{-64,100}})));
    Modelica.Blocks.Sources.Pulse m_in(
      amplitude=0.2777778,
      width=2.0833333,
      period(displayUnit="h") = 86400,
      offset=0,
      startTime(displayUnit="h") = 28800)
      annotation (Placement(transformation(extent={{-64,8},{-44,28}})));
    Modelica.Blocks.Sources.CombiTimeTable Infiltration(
      table=[0,0.01; 8*3600,0.01; 8*3600,0.05; 9*3600,0.05; 9*3600,0.01; 17*
          3600,0.01; 17*3600,0.05; 18*3600,0.05; 18*3600,0.01; 24*3600,0.01; 32
          *3600,0.01; 32*3600,0.05; 33*3600,0.05; 33*3600,0.01; 41*3600,0.01;
          41*3600,0.05; 42*3600,0.05; 42*3600,0.01; 48*3600,0.01],
      columns={2},
      extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic)
      annotation (Placement(transformation(extent={{-14,46},{6,66}})));
    Buildings.Controls.OBC.CDL.Reals.Sources.Constant TSet_Room(k=273.15 + 5, y(
          final unit="K", displayUnit="degC")) "Temperature set point"
      annotation (Placement(transformation(extent={{-50,-32},{-26,-8}})));
    Components.Unit_Cooler.FanCoil EVAP01(
      T_aCoWat_nominal=T_aCoWat_nominal,
      T_bCoWat_nominal=278.15,
      T_aLoaCo_nominal=285.15,
      T_bLoaCo_nominal=278.15,
      mLoaCo_flow_nominal=0.37,
      mChilWat_flow_nominal=0.15,
      QCo_flow_nominal=-5000,
      w_aLoaCoo_nominal=0.005,
      dpNominal_ChilWat_fanCoil=dpNominal_fanCoil)
      annotation (Placement(transformation(extent={{28,-164},{66,-130}})));
    Components.Unit_Cooler.FanCoil EVAP02(
      nightMode=true,
      T_aCoWat_nominal=T_aCoWat_nominal,
      T_bCoWat_nominal=278.15,
      T_aLoaCo_nominal=285.15,
      T_bLoaCo_nominal=278.15,
      mLoaCo_flow_nominal=0.37,
      mChilWat_flow_nominal=0.15,
      QCo_flow_nominal=-5000,
      w_aLoaCoo_nominal=0.005,
      dpNominal_ChilWat_fanCoil=dpNominal_fanCoil)
      annotation (Placement(transformation(extent={{24,-46},{62,-12}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_IE1(redeclare package Medium =
          Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-2,-166},{18,-146}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_OE1(redeclare package Medium =
          Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{102,-166},{82,-146}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_IE2(redeclare package Medium =
          Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-22,-80},{-2,-60}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_OE2(redeclare package Medium =
          Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{70,-50},{90,-30}})));
    Buildings.Fluid.FixedResistances.Junction jun(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
      m_flow_nominal={mChilWat_flow_nominal,-mChilWat_flow_nominal,-
          mChilWat_flow_nominal},
      dp_nominal={dpNominal_conj,-dpNominal_conj,-dpNominal_conj})
      annotation (Placement(transformation(extent={{-28,-146},{-8,-166}})));
    Buildings.Fluid.Movers.SpeedControlled_y P01(redeclare package Medium =
          Medium_HTF, redeclare Buildings.Fluid.Movers.Data.Generic per(
          pressure(V_flow={0.00014,0.00028,0.00056,0.00083,0.00111,0.00139,
              0.00167,0.00194}, dp={59000,58500,58000,55000,47000,40000,30000,
              20000}), power(V_flow={0.00014,0.00028,0.00056,0.00083,0.00111,
              0.00139,0.00167,0.00194}, P={60,70,90,100,102,105,105,105})))
      annotation (Placement(transformation(extent={{-96,-166},{-76,-146}})));
    Buildings.Fluid.Sensors.Pressure PIT_010(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-76,-156},{-56,-176}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_010(redeclare package Medium =
          Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-124,-164},{-104,-144}})));
    Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear ThreeAV02(
      redeclare package Medium = Medium_HTF,
      m_flow_nominal=mChilWat_flow_nominal,
      dpValve_nominal=dpNominal_3way)
      annotation (Placement(transformation(extent={{-152,-146},{-132,-166}})));
    Buildings.Fluid.FixedResistances.Junction jun1(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
      m_flow_nominal={mChilWat_flow_nominal,-mChilWat_flow_nominal,
          mChilWat_flow_nominal},
      dp_nominal={dpNominal_conj,-dpNominal_conj,dpNominal_conj})
      annotation (Placement(transformation(extent={{-42,-58},{-62,-38}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_011(redeclare package Medium =
          Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-70,-54},{-90,-34}})));
    Buildings.Fluid.Sensors.Pressure PIT_011(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-116,-44},{-96,-24}})));
    Buildings.Fluid.FixedResistances.Junction jun2(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
      m_flow_nominal={mChilWat_flow_nominal,-mChilWat_flow_nominal,-
          mChilWat_flow_nominal},
      dp_nominal={dpNominal_conj,-dpNominal_conj,-dpNominal_conj})
      annotation (Placement(transformation(extent={{-126,-54},{-146,-34}})));
    Buildings.Fluid.Sensors.MassFlowRate FIT_002(redeclare package Medium =
          Medium_HTF) annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-174,-96})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_009(redeclare package Medium =
          Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-184,-166},{-164,-146}})));
    Buildings.Fluid.Sensors.MassFlowRate FIT_003(redeclare package Medium =
          Medium_HTF) annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=180,
          origin={-204,-156})));
    Components.Decoupler_Tank.AixLib_Fluid_Storage_StorageDetailed
                                         storageDetailed(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
      redeclare package MediumHC1 = Medium_HTF,
      redeclare package MediumHC2 = Medium_HTF,
      m1_flow_nominal=mChilWat_flow_nominal,
      m2_flow_nominal=mChilWat_flow_nominal,
      useHeatingCoil1=false,
      useHeatingCoil2=false,
      useHeatingRod=false,
      TStart=fill(2 + 273.15, storageDetailed.n),
      redeclare AGRI_COOL.Components.Decoupler_Tank.AixLib.DataBase.Storage.Generic_New_2000l   data(
        hTank=0.95,
        hLowerPortDemand=0.18,
        hUpperPortDemand=0.8,
        hLowerPortSupply=0.18,
        hUpperPortSupply=0.8,
        hHC1Up=0.2,
        hHC2Up=0.2,
        hHR=0.1,
        dTank=0.45,
        sIns=0.05,
        lambdaIns=0.034,
        hTS1=0.25,
        hTS2=0.7),
      redeclare model HeatTransfer =
          AGRI_COOL.Components.Decoupler_Tank.AixLib.Fluid.Storage.BaseClasses.HeatTransferBuoyancyWetter)
      "data is rewritten_ doble check please"
      annotation (Placement(transformation(extent={{-218,-102},{-234,-82}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_006(redeclare package Medium =
          Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-276,-166},{-256,-146}})));
    Buildings.Fluid.Sensors.MassFlowRate FIT_001(redeclare package Medium =
          Medium_HTF) annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=180,
          origin={-280,-46})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_001(redeclare package Medium =
          Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-308,-56},{-328,-36}})));
    Buildings.Fluid.Sensors.Pressure PIT_001(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-336,-46},{-356,-26}})));
    Buildings.Fluid.Movers.SpeedControlled_y P02(redeclare package Medium =
          Medium_HTF, redeclare Buildings.Fluid.Movers.Data.Generic per(
          pressure(V_flow={0,0.00019444,0.00027778,0.00036111,0.00044444,
              0.00052778,0.00061111,0.00066667}, dp={355122,351198,343350,
              326673,299205,262908,216801,173637}), power(V_flow={0.000195,
              0.000278,0.000417,0.000556,0.000667}, P={335,375,450,480,480})))
      annotation (Placement(transformation(extent={{-374,-56},{-394,-36}})));
    Components.Chiller.TwoCircuitChiller twoCircuitChiller(redeclare package
        Medium_Evap = Medium_HTF, redeclare package Medium_Cond = Medium_Air,
      mChilWat_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-486,-130},{-436,-68}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_002(redeclare package Medium =
          Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-394,-164},{-374,-144}})));
    Buildings.Fluid.Sensors.Pressure PIT_002(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-398,-154},{-418,-134}})));
    Buildings.Fluid.Storage.Ice.Tank PCM01(
      redeclare package Medium = Medium_HTF,
      m_flow_nominal=mChilWat_flow_nominal,
      show_T=true,
      dp_nominal=dpNominal_PCM,
      T_start=273.15,
      SOC_start=1,
      per=UNIP_Per1,
      energyDynamicsHex=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
      tauHex=30)
      annotation (Placement(transformation(extent={{-420,-242},{-400,-222}})));
    Buildings.Fluid.Storage.Ice.Tank PCM02(
      redeclare package Medium = Medium_HTF,
      m_flow_nominal=mChilWat_flow_nominal,
      show_T=true,
      dp_nominal=dpNominal_PCM,
      T_start=273.15,
      SOC_start=1,
      per=UNIP_Per1,
      tauHex=30)
      annotation (Placement(transformation(extent={{-424,-300},{-404,-280}})));
    Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear ThreeAV01(
      redeclare package Medium = Medium_HTF,
      portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Leaving,
      portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Entering,
      portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
      m_flow_nominal=mChilWat_flow_nominal,
      dpValve_nominal=dpNominal_3way)
      annotation (Placement(transformation(extent={{-330,-164},{-350,-144}})));
    Buildings.Fluid.Sensors.Pressure PIT_003(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-346,-194},{-366,-174}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_003(redeclare package Medium =
          Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-388,-202},{-408,-182}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_004(redeclare package Medium =
          Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-372,-242},{-352,-222}})));
    Buildings.Fluid.Sensors.Pressure PIT_004(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-320,-232},{-340,-212}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_005(redeclare package Medium =
          Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-374,-300},{-354,-280}})));
    Buildings.Fluid.Sensors.Pressure PIT_005(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-320,-290},{-340,-270}})));
    Buildings.Fluid.Sensors.MassFlowRate FIT_004(redeclare package Medium =
          Medium_HTF) annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=270,
          origin={-302,-220})));
    Buildings.Fluid.FixedResistances.Junction jun3(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
      m_flow_nominal={mChilWat_flow_nominal,-mChilWat_flow_nominal,
          mChilWat_flow_nominal},
      dp_nominal={dpNominal_conj,-dpNominal_conj,dpNominal_conj})
      annotation (Placement(transformation(extent={{-312,-166},{-292,-146}})));
    Buildings.Fluid.Sources.MassFlowSource_WeatherData bou(redeclare package
        Medium = Medium_Air,
      m_flow=3.43,           nPorts=2)
      annotation (Placement(transformation(extent={{-534,-36},{-514,-16}})));
    Components.PV.PvPanels pvPanels(nPV=20)
      annotation (Placement(transformation(extent={{-732,-14},{-700,10}})));
    Buildings.BoundaryConditions.WeatherData.ReaderTMY3 Mogadishu1(filNam=
          ModelicaServices.ExternalReferences.loadResource(
          "modelica://AGRI_COOL/Inputs/SOM_BN_Mogadishu.Intl.AP.632600_TMYx.2009-2023.mos"),
        computeWetBulbTemperature=false)
      annotation (Placement(transformation(extent={{-766,6},{-746,26}})));
    Components.Battery.equipmentLoad equipmentLoad
      annotation (Placement(transformation(extent={{-640,-90},{-580,-42}})));
     Components.Battery.supCapDis supCapDis(
      capacityModule=(2*3.6*3.6e6)/1600,
      Vmax=58,
      Vnom=51.8,
      Imax=4*100)
      annotation (Placement(transformation(extent={{-658,-164},{-582,-122}})));
    Modelica.Blocks.Math.Sum sum1(nin=3)
      annotation (Placement(transformation(extent={{-704,-82},{-684,-62}})));
    Modelica.Blocks.Sources.RealExpression Fan_Pump(y=P02.P + P01.P + EVAP01.fan.P
           + EVAP02.fan.P)
      annotation (Placement(transformation(extent={{-770,-92},{-750,-72}})));
    Modelica.Blocks.Sources.RealExpression PLC(y=0.1*Fan_Pump.y)
      annotation (Placement(transformation(extent={{-770,-114},{-750,-94}})));
    Components.LTES.Performance_Based.EnergyPlus_UNIP UNIP_Per
      annotation (Placement(transformation(extent={{-470,-296},{-450,-276}})));
    Modelica.Blocks.Sources.Constant const4(k=273.15 + 1)
      annotation (Placement(transformation(extent={{-246,-242},{-226,-222}})));
    Buildings.Fluid.Storage.ExpansionVessel expVes(redeclare package Medium =
          Medium_HTF, V_start(displayUnit="l") = 0.02)
                                    "Expansion vessel"
      annotation (Placement(transformation(extent={{-326,-92},{-306,-72}})));
    Buildings.Controls.OBC.CDL.Reals.PIDWithReset con3WayValve(
      final k=2,
      final Ti=10,
      controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
      yMax=1,
      yMin=0,
      final reverseActing=false) "PI controller"
      annotation (Placement(transformation(extent={{-210,-228},{-190,-208}})));
    Modelica.Blocks.Sources.BooleanExpression booleanExpression
      annotation (Placement(transformation(extent={{-246,-272},{-226,-252}})));
    Buildings.Fluid.Sensors.RelativePressure senRelPre(redeclare package Medium =
          Medium_HTF) annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=90,
          origin={-72,-92})));
    Buildings.Controls.OBC.CDL.Reals.PIDWithReset conP01(
      final k=1e-3,
      final Ti(displayUnit="s") = 20,
      controllerType=AGRI_COOL.Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
      yMax=1,
      yMin=0,
      final reverseActing=true) "PI controller"
      annotation (Placement(transformation(extent={{-100,-118},{-84,-102}})));
    Modelica.Blocks.Sources.BooleanExpression booleanExpression1
      annotation (Placement(transformation(extent={{-128,-134},{-108,-114}})));
    Modelica.Blocks.Sources.Constant const5(k=0.08*dpNominal_Total_P01)
      annotation (Placement(transformation(extent={{-132,-100},{-112,-80}})));
    Buildings.Controls.OBC.CDL.Reals.PIDWithReset conP02(
      final k=1,
      final Ti=10,
      controllerType=AGRI_COOL.Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
      yMax=1,
      yMin=0,
      final reverseActing=true) "PI controller"
      annotation (Placement(transformation(extent={{-384,20},{-368,36}})));
    Modelica.Blocks.Sources.BooleanExpression booleanExpression2
      annotation (Placement(transformation(extent={{-422,2},{-402,22}})));
    Modelica.Blocks.Sources.Constant const6(k=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-424,32},{-404,52}})));
    Components.Controls.CompressorStepController compressorStepController
      annotation (Placement(transformation(extent={{-672,-298},{-616,-242}})));
    Modelica.Blocks.Sources.RealExpression pvPanels_G(y=pvPanels.pv[1].panel.G)
      annotation (Placement(transformation(extent={{-776,-296},{-734,-266}})));
    Modelica.Blocks.Math.BooleanToReal booleanToReal(realTrue=0, realFalse=1)
      annotation (Placement(transformation(extent={{-506,-266},{-486,-246}})));
    Components.Controls.TempSocConditionHys tempSocCondition
      annotation (Placement(transformation(extent={{-710,-204},{-690,-184}})));
    Modelica.Blocks.Logical.Switch CompSignalEnable annotation (Placement(
          transformation(extent={{-10,-10},{10,10}}, origin={-620,-202})));
    Modelica.Blocks.Sources.Constant const2(k=0)
      annotation (Placement(transformation(extent={{-738,-260},{-718,-240}})));
    Modelica.Blocks.Sources.RealExpression HTFTemp(y=TIT_001.T)
      annotation (Placement(transformation(extent={{-820,-208},{-778,-178}})));
    Modelica.Blocks.Continuous.FirstOrder  firstOrder(T=5)
      annotation (Placement(transformation(extent={{-560,-172},{-540,-152}})));
    Components.Controls.OutOfRangeDetector outOfRangeDetector
      annotation (Placement(transformation(extent={{-560,-272},{-540,-252}})));
    Modelica.Blocks.Continuous.FirstOrder firstOrder2(T(displayUnit="s") = 5)
      annotation (Placement(transformation(extent={{-470,-206},{-450,-186}})));
    Buildings.Fluid.Sensors.RelativeHumidity senRelHum_CR(redeclare package
        Medium = Medium_Air, warnAboutOnePortConnection=false)
      annotation (Placement(transformation(extent={{146,14},{166,34}})));
    Buildings.Fluid.FixedResistances.CheckValve cheVal(
      redeclare package Medium = Medium_HTF,
      m_flow_nominal=mChilWat_flow_nominal,
      dpValve_nominal=dpNominal_CheckValve)
      annotation (Placement(transformation(extent={{-52,-164},{-36,-148}})));

    parameter Buildings.Fluid.Storage.Ice.Data.Tank.Generic UNIP_Per1(
      mIce_max=365,
      coeCha={1.76953858E-04,0,0,0,0,0},
      dtCha=10,
      coeDisCha={5.54E-05,-1.45679E-04,9.28E-05,1.126122E-03,-1.1012E-03,3.00544E-04},
      dtDisCha=10) "Tank performance data"
      annotation (Placement(transformation(extent={{-506,-308},{-486,-288}})));

    Buildings.Fluid.FixedResistances.Pipe pip(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
      m_flow_nominal=mChilWat_flow_nominal,
      dp_nominal(displayUnit="Pa") = 1000,
      thicknessIns(displayUnit="mm") = 0.02,
      lambdaIns=0.025,
      length=1)
      annotation (Placement(transformation(extent={{-250,-166},{-230,-146}})));
    Buildings.Fluid.FixedResistances.Pipe pip1(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
      m_flow_nominal=mChilWat_flow_nominal,
      dp_nominal(displayUnit="Pa") = 1000,
      thicknessIns(displayUnit="mm") = 0.02,
      lambdaIns=0.025,
      length=1)
      annotation (Placement(transformation(extent={{-178,-54},{-198,-34}})));
    Buildings.Utilities.Psychrometrics.X_pTphi x_pTphi(use_p_in=false)
      annotation (Placement(transformation(extent={{162,46},{182,66}})));
    Modelica.Blocks.Sources.CombiTimeTable Infiltration1(
      table=[0,0; 8*3600,0; 8*3600,1; 9*3600,1; 9*3600,0; 17*3600,0; 17*3600,1;
          18*3600,1; 18*3600,0; 24*3600,0; 32*3600,0; 32*3600,1; 33*3600,1; 33*
          3600,0; 41*3600,0; 41*3600,1; 42*3600,1; 42*3600,0; 48*3600,0],
      columns={2},
      extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic)
      annotation (Placement(transformation(extent={{-60,38},{-40,58}})));
    Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature T_amb
      annotation (Placement(transformation(extent={{-190,80},{-170,100}})));
    Buildings.BoundaryConditions.WeatherData.Bus weaBus1
               "Weather data bus"
      annotation (Placement(transformation(extent={{-152,82},{-132,102}})));
    Modelica.Blocks.Sources.Pulse m_out(
      amplitude=0.2777778,
      width=2.0833333,
      period(displayUnit="h") = 86400,
      offset=0,
      startTime(displayUnit="h") = 61200)
      annotation (Placement(transformation(extent={{-120,-2},{-100,18}})));
    Modelica.Blocks.Sources.RealExpression pvPanels_G1(y=pvPanels.pv[1].panel.G)
      annotation (Placement(transformation(extent={{182,-108},{140,-78}})));
  equation
    connect(Mogadishu.weaBus, coldROOM_V01.weaBus1) annotation (Line(
        points={{108,98},{116,98},{116,44},{51.4,44},{51.4,26}},
        color={255,204,51},
        thickness=0.5));
    connect(Zero.y,Mogadishu. HGloHor_in) annotation (Line(points={{79,78},{79,
            80},{87,80},{87,85}},
                              color={0,0,127}));
    connect(Zero.y,Mogadishu. HDifHor_in) annotation (Line(points={{79,78},{79,
            80},{87,80},{87,88.5}},
                                  color={0,0,127}));
    connect(Mogadishu.weaBus, infiltration.weaBus1) annotation (Line(
        points={{108,98},{116,98},{116,44},{52,44},{52,100},{16,100},{16,83}},
        color={255,204,51},
        thickness=0.5));
    connect(Mogadishu.weaBus, out.weaBus) annotation (Line(
        points={{108,98},{116,98},{116,44},{52,44},{52,100},{-56,100},{-56,108},
            {-92,108},{-92,90.2},{-84,90.2}},
        color={255,204,51},
        thickness=0.5));
    connect(loads_enhanced.port1, coldROOM_V01.heaPorAir1) annotation (Line(
          points={{2.2,22.8},{22,22.8},{22,-2},{62,-2},{62,17.6},{56,17.6}},
          color={191,0,0}));
    connect(coldROOM_V01.T_in_CR, loads_enhanced.T_in_K1) annotation (Line(
          points={{56.8,23.2},{62,23.2},{62,36},{8,36},{8,42},{-22.8,42},{-22.8,
            31.2}}, color={0,0,127}));
    connect(m_in.y, loads_enhanced.m_In1) annotation (Line(points={{-43,18},{-43,
            18.2},{-22.6,18.2}}, color={0,0,127}));
    connect(loads_enhanced.Q_people1, coldROOM_V01.Q_People) annotation (Line(
          points={{2.4,27.8},{26,27.8},{26,21.2},{35.4,21.2}}, color={0,0,127}));
    connect(infiltration.port_a_out, out.ports[1]) annotation (Line(points={{16,78},
            {8,78},{8,88.5},{-64,88.5}}, color={0,127,255}));
    connect(infiltration.port_b_out, out.ports[2]) annotation (Line(points={{16,70},
            {16,40},{-28,40},{-28,89.5},{-64,89.5}},
                                         color={0,127,255}));
    connect(TSet_Room.y, EVAP01.TSetCoo) annotation (Line(points={{-23.6,-20},{
            4,-20},{4,-139.229},{28.475,-139.229}},                     color={
            0,0,127}));
    connect(TSet_Room.y, EVAP02.TSetCoo) annotation (Line(points={{-23.6,-20},{
            -23.6,-21.2286},{24.475,-21.2286}}, color={0,0,127}));
    connect(coldROOM_V01.T_in_CR, EVAP02.TColdRoom) annotation (Line(points={{56.8,
            23.2},{90,23.2},{90,-12},{-16,-12},{-16,-31.4286},{24.2375,-31.4286}},
                        color={0,0,127}));
    connect(coldROOM_V01.T_in_CR, EVAP01.TColdRoom) annotation (Line(points={{56.8,
            23.2},{64,23.2},{64,28},{112,28},{112,-176},{28.2375,-176},{28.2375,
            -149.429}},         color={0,0,127}));
    connect(EVAP02.port_aLoa, coldROOM_V01.ports_Air_CR[4]) annotation (Line(
          points={{62,-15.8857},{68,-15.8857},{68,2},{36,2},{36,9.7}}, color={0,
            127,255}));
    connect(coldROOM_V01.ports_Air_CR[5], EVAP02.port_bLoa) annotation (Line(
          points={{36,10.0857},{20,10.0857},{20,-15.4},{23.7625,-15.4}}, color=
            {0,127,255}));
    connect(EVAP01.port_aLoa, coldROOM_V01.ports_Air_CR[6]) annotation (Line(
          points={{66,-133.886},{80,-133.886},{80,-60},{100,-60},{100,-16},{88,
            -16},{88,4},{36,4},{36,10.4714}}, color={0,127,255}));
    connect(EVAP01.port_bLoa, coldROOM_V01.ports_Air_CR[7]) annotation (Line(
          points={{27.7625,-133.4},{27.7625,-136},{16,-136},{16,-60},{100,-60},
            {100,-16},{88,-16},{88,4},{36,4},{36,10.8571}}, color={0,127,255}));
    connect(infiltration.port_b_env, coldROOM_V01.ports_Air_CR[1]) annotation (
        Line(points={{36,83},{40,83},{40,76},{48,76},{48,40},{100,40},{100,-16},
            {88,-16},{88,4},{36,4},{36,8.54286}}, color={0,127,255}));
    connect(infiltration.port_b_in, coldROOM_V01.ports_Air_CR[2]) annotation (
        Line(points={{36.2,78},{40,78},{40,76},{48,76},{48,40},{100,40},{100,
            -16},{88,-16},{88,4},{36,4},{36,8.92857}}, color={0,127,255}));
    connect(infiltration.port_a_in, coldROOM_V01.ports_Air_CR[3]) annotation (
        Line(points={{36,70},{36,76},{48,76},{48,40},{100,40},{100,-16},{82,-16},{
            82,-2},{36,-2},{36,9.31429}},color={0,127,255}));
    connect(TIT_IE1.port_b, EVAP01.port_aChiWat) annotation (Line(points={{18,-156},
            {20,-156},{20,-157.929},{28.2375,-157.929}},       color={0,127,255}));
    connect(EVAP02.port_aChiWat, TIT_IE2.port_b) annotation (Line(points={{24.2375,
            -39.9286},{8,-39.9286},{8,-70},{-2,-70}},         color={0,127,255}));
    connect(EVAP02.port_bChiWat, TIT_OE2.port_a) annotation (Line(points={{62,
            -39.6857},{66,-39.6857},{66,-40},{70,-40}}, color={0,127,255}));
    connect(TIT_IE1.port_a, jun.port_2)
      annotation (Line(points={{-2,-156},{-8,-156}},  color={0,127,255}));
    connect(jun.port_3, TIT_IE2.port_a) annotation (Line(points={{-18,-146},{-18,-88},
            {-32,-88},{-32,-70},{-22,-70}},
                                 color={0,127,255}));
    connect(P01.port_b, PIT_010.port)
      annotation (Line(points={{-76,-156},{-66,-156}}, color={0,127,255}));
    connect(P01.port_a, TIT_010.port_b)
      annotation (Line(points={{-96,-156},{-102,-156},{-102,-154},{-104,-154}},
                                                        color={0,127,255}));
    connect(TIT_010.port_a, ThreeAV02.port_2)
      annotation (Line(points={{-124,-154},{-130,-154},{-130,-156},{-132,-156}},
                                                         color={0,127,255}));
    connect(TIT_OE2.port_b, jun1.port_1) annotation (Line(points={{90,-40},{94,-40},
            {94,-48},{-42,-48}},      color={0,127,255}));
    connect(TIT_OE1.port_a, jun1.port_3) annotation (Line(points={{102,-156},{
            108,-156},{108,-112},{-52,-112},{-52,-58}}, color={0,127,255}));
    connect(jun1.port_2, TIT_011.port_a)
      annotation (Line(points={{-62,-48},{-66,-48},{-66,-44},{-70,-44}},
                                                     color={0,127,255}));
    connect(TIT_011.port_b, PIT_011.port)
      annotation (Line(points={{-90,-44},{-106,-44}}, color={0,127,255}));
    connect(PIT_011.port, jun2.port_1)
      annotation (Line(points={{-106,-44},{-126,-44}}, color={0,127,255}));
    connect(ThreeAV02.port_3, FIT_002.port_b) annotation (Line(points={{-142,-146},
            {-142,-120},{-174,-120},{-174,-106}},       color={0,127,255}));
    connect(jun2.port_3, FIT_002.port_a)
      annotation (Line(points={{-136,-54},{-136,-80},{-174,-80},{-174,-86}},
                                                       color={0,127,255}));
    connect(ThreeAV02.port_1, TIT_009.port_b)
      annotation (Line(points={{-152,-156},{-164,-156}}, color={0,127,255}));
    connect(TIT_009.port_a, FIT_003.port_b)
      annotation (Line(points={{-184,-156},{-194,-156}}, color={0,127,255}));
    connect(storageDetailed.fluidportBottom1, FIT_003.port_a) annotation (Line(
          points={{-223.3,-102.2},{-223.3,-156},{-214,-156}}, color={0,127,255}));
    connect(storageDetailed.fluidportTop2, FIT_001.port_a) annotation (Line(
          points={{-228.5,-81.9},{-228.5,-46},{-270,-46}}, color={0,127,255}));
    connect(FIT_001.port_b, TIT_001.port_a)
      annotation (Line(points={{-290,-46},{-308,-46}}, color={0,127,255}));
    connect(TIT_001.port_b, PIT_001.port)
      annotation (Line(points={{-328,-46},{-346,-46}}, color={0,127,255}));
    connect(PIT_001.port, P02.port_a)
      annotation (Line(points={{-346,-46},{-374,-46}}, color={0,127,255}));
    connect(P02.port_b, twoCircuitChiller.Evap_inlet_C1) annotation (Line(
          points={{-394,-46},{-418,-46},{-418,-99},{-435.5,-99}}, color={0,127,
            255}));
    connect(twoCircuitChiller.Evap_outlet_C2, PIT_002.port) annotation (Line(
          points={{-486,-100.86},{-504,-100.86},{-504,-160},{-428,-160},{-428,-164},
            {-408,-164},{-408,-154}},
                    color={0,127,255}));
    connect(PIT_002.port, TIT_002.port_a) annotation (Line(points={{-408,-154},{-394,
            -154}},                               color={0,127,255}));
    connect(ThreeAV01.port_3, PIT_003.port) annotation (Line(points={{-340,-164},{
            -340,-176},{-356,-176},{-356,-194}},  color={0,127,255}));
    connect(PIT_003.port, TIT_003.port_a) annotation (Line(points={{-356,-194},{-352,
            -194},{-352,-196},{-380,-196},{-380,-192},{-388,-192}},
                                      color={0,127,255}));
    connect(TIT_003.port_b, PCM01.port_a) annotation (Line(points={{-408,-192},
            {-424,-192},{-424,-196},{-434,-196},{-434,-232},{-420,-232}}, color
          ={0,127,255}));
    connect(PCM01.port_b, TIT_004.port_a)
      annotation (Line(points={{-400,-232},{-372,-232}}, color={0,127,255}));
    connect(TIT_004.port_b, PIT_004.port)
      annotation (Line(points={{-352,-232},{-330,-232}}, color={0,127,255}));
    connect(PIT_004.port, PCM02.port_a) annotation (Line(points={{-330,-232},{
            -332,-232},{-332,-262},{-436,-262},{-436,-290},{-424,-290}}, color=
            {0,127,255}));
    connect(PCM02.port_b, TIT_005.port_a)
      annotation (Line(points={{-404,-290},{-374,-290}}, color={0,127,255}));
    connect(TIT_005.port_b, PIT_005.port)
      annotation (Line(points={{-354,-290},{-330,-290}}, color={0,127,255}));
    connect(PIT_005.port, FIT_004.port_a) annotation (Line(points={{-330,-290},
            {-332,-290},{-332,-300},{-302,-300},{-302,-230}}, color={0,127,255}));
    connect(TIT_006.port_a, jun3.port_2)
      annotation (Line(points={{-276,-156},{-292,-156}}, color={0,127,255}));
    connect(FIT_004.port_b, jun3.port_3)
      annotation (Line(points={{-302,-210},{-302,-166}}, color={0,127,255}));
    connect(twoCircuitChiller.Cond_outlet_C2, out.ports[3]) annotation (Line(
          points={{-456.5,-68},{-456.5,76},{-64,76},{-64,90.5}}, color={0,127,
            255}));
    connect(twoCircuitChiller.Cond_outlet_C1, out.ports[4]) annotation (Line(
          points={{-450,-68},{-430,-68},{-430,64},{-64,64},{-64,91.5}}, color={
            0,127,255}));
    connect(Mogadishu.weaBus, bou.weaBus) annotation (Line(
        points={{108,98},{116,98},{116,44},{52,44},{52,100},{-56,100},{-56,108},
            {-140,108},{-140,112},{-544,112},{-544,-25.8},{-534,-25.8}},
        color={255,204,51},
        thickness=0.5));
    connect(bou.ports[1], twoCircuitChiller.Cond_Inlet_C2) annotation (Line(
          points={{-514,-27},{-500,-27},{-500,-36},{-479.5,-36},{-479.5,-68}},
          color={0,127,255}));
    connect(bou.ports[2], twoCircuitChiller.Cond_Inlet_C1) annotation (Line(
          points={{-514,-25},{-473,-25},{-473,-68}}, color={0,127,255}));
    connect(Mogadishu1.weaBus, pvPanels.weaBus) annotation (Line(
        points={{-746,16},{-740,16},{-740,6.9},{-727.5,6.9}},
        color={255,204,51},
        thickness=0.5));
    connect(pvPanels.P_total, equipmentLoad.pTotal) annotation (Line(points={{-702.4,
            -2.2},{-652,-2.2},{-652,-46.6},{-636.6,-46.6}},          color={0,0,
            127}));
    connect(pvPanels.P_total, supCapDis.pTotal) annotation (Line(points={{-702.4,-2.2},
            {-653.4,-2.2},{-653.4,-126.8}},                            color={0,
            0,127}));
    connect(equipmentLoad.IsinkLoad, supCapDis.iLoad) annotation (Line(points={{-598.5,
            -45.1},{-598.5,-32},{-656,-32},{-656,-88},{-676,-88},{-676,-134.6},{-653.8,
            -134.6}},        color={0,0,127}));
    connect(sum1.y, supCapDis.PLoadSW) annotation (Line(points={{-683,-72},{-672,-72},
            {-672,-143.6},{-653,-143.6}},
                      color={0,0,127}));
    connect(supCapDis.vSupCap, equipmentLoad.vSupCap) annotation (Line(points={{-584.1,
            -125.1},{-584.1,-104},{-568,-104},{-568,-87.6},{-580.2,-87.6}},
                                                                        color={
            0,0,127}));
    connect(EVAP01.port_bChiWat, TIT_OE1.port_b) annotation (Line(points={{66,
            -157.686},{66,-156},{82,-156}},
                                  color={0,127,255}));
    connect(P02.port_a, expVes.port_a) annotation (Line(points={{-374,-46},{-368,-46},
            {-368,-88},{-340,-88},{-340,-100},{-316,-100},{-316,-92}}, color={0,127,
            255}));
    connect(const4.y, con3WayValve.u_s) annotation (Line(points={{-225,-232},{
            -222,-232},{-222,-218},{-212,-218}},        color={0,0,127}));
    connect(TIT_010.T, con3WayValve.u_m) annotation (Line(points={{-114,-143},{
            -116,-143},{-116,-240},{-200,-240},{-200,-230}},        color={0,0,127}));
    connect(booleanExpression.y, con3WayValve.trigger) annotation (Line(points={{-225,
            -262},{-225,-264},{-206,-264},{-206,-230}}, color={255,0,255}));
    connect(P01.port_b, senRelPre.port_a) annotation (Line(points={{-76,-156},{-76,
            -102},{-72,-102}}, color={0,127,255}));
    connect(senRelPre.port_b, TIT_011.port_b) annotation (Line(points={{-72,-82},{
            -72,-64},{-100,-64},{-100,-44},{-90,-44}}, color={0,127,255}));
    connect(booleanExpression1.y, conP01.trigger) annotation (Line(points={{-107,-124},
            {-104,-124},{-104,-119.6},{-96.8,-119.6}}, color={255,0,255}));
    connect(senRelPre.p_rel, conP01.u_m) annotation (Line(points={{-81,-92},{-92,-92},
            {-92,-76},{-56,-76},{-56,-132},{-92,-132},{-92,-119.6}}, color={0,0,127}));
    connect(const5.y, conP01.u_s) annotation (Line(points={{-111,-90},{-111,-100},
            {-101.6,-100},{-101.6,-110}}, color={0,0,127}));
    connect(booleanExpression2.y, conP02.trigger) annotation (Line(points={{-401,12},
            {-401,14},{-392,14},{-392,18.4},{-380.8,18.4}},   color={255,0,255}));
    connect(const6.y, conP02.u_s) annotation (Line(points={{-403,42},{-404,42},{-404,
            28},{-385.6,28}},
                            color={0,0,127}));
    connect(pvPanels_G.y, compressorStepController.G) annotation (Line(points={
            {-731.9,-281},{-688,-281},{-688,-270},{-674.8,-270}}, color={0,0,
            127}));
    connect(FIT_001.m_flow, conP02.u_m) annotation (Line(points={{-280,-35},{-280,
            -16},{-376,-16},{-376,18.4}},
                                    color={0,0,127}));
    connect(TIT_002.port_b, ThreeAV01.port_2)
      annotation (Line(points={{-374,-154},{-350,-154}}, color={0,127,255}));
    connect(ThreeAV01.port_1, jun3.port_1) annotation (Line(points={{-330,-154},
            {-328,-156},{-312,-156}}, color={0,127,255}));
    connect(Fan_Pump.y, sum1.u[1]) annotation (Line(points={{-749,-82},{-712,
            -82},{-712,-72.6667},{-706,-72.6667}},
                                             color={0,0,127}));
    connect(twoCircuitChiller.Power, sum1.u[2]) annotation (Line(points={{-434.5,
            -86.6},{-424,-86.6},{-424,-56},{-568,-56},{-568,-32},{-596,-32},{
            -596,-28},{-712,-28},{-712,-72},{-706,-72}},           color={0,0,
            127}));
    connect(Fan_Pump.y, equipmentLoad.P_L) annotation (Line(points={{-749,-82},
            {-749,-84},{-712,-84},{-712,-72},{-716,-72},{-716,-56},{-672,-56},{
            -672,-48},{-660,-48},{-660,-71.6},{-640.2,-71.6}}, color={0,0,127}));
    connect(PLC.y, sum1.u[3]) annotation (Line(points={{-749,-104},{-716,-104},
            {-716,-84},{-712,-84},{-712,-71.3333},{-706,-71.3333}}, color={0,0,
            127}));
    connect(PCM02.SOC,tempSocCondition. SOC) annotation (Line(points={{-403,-294},
            {-403,-296},{-396,-296},{-396,-324},{-788,-324},{-788,-216},{-720,-216},
            {-720,-198.6},{-710.6,-198.6}},                   color={0,0,127}));
    connect(const2.y,CompSignalEnable. u3) annotation (Line(points={{-717,-250},{-717,
            -252},{-684,-252},{-684,-210},{-632,-210}}, color={0,0,127}));
    connect(HTFTemp.y,tempSocCondition. T_HTG) annotation (Line(points={{-775.9,-193},
            {-772,-192.6},{-710.6,-192.6}},       color={0,0,127}));
    connect(compressorStepController.freqNorm,CompSignalEnable. u1) annotation (
       Line(points={{-613.2,-270},{-613.2,-272},{-604,-272},{-604,-220},{-640,-220},
            {-640,-194},{-632,-194}},
                    color={0,0,127}));
    connect(tempSocCondition.y, CompSignalEnable.u2) annotation (Line(points={{-689.8,
            -194.4},{-644,-194.4},{-644,-202},{-632,-202}}, color={255,0,255}));
    connect(CompSignalEnable.y, firstOrder.u) annotation (Line(points={{-609,-202},
            {-609,-204},{-572,-204},{-572,-162},{-562,-162}}, color={0,0,127}));
    connect(firstOrder.y, twoCircuitChiller.ySet_C2) annotation (Line(points={{-539,
            -162},{-539,-164},{-508,-164},{-508,-110.16},{-488,-110.16}}, color={0,
            0,127}));
    connect(firstOrder.y, twoCircuitChiller.ySet_C1) annotation (Line(points={{-539,
            -162},{-539,-164},{-508,-164},{-508,-123.8},{-488,-123.8}}, color={0,0,
            127}));
    connect(compressorStepController.freqNorm, outOfRangeDetector.u) annotation (
        Line(points={{-613.2,-270},{-613.2,-272},{-604,-272},{-604,-262},{-562,-262}},
          color={0,0,127}));
    connect(outOfRangeDetector.y, booleanToReal.u) annotation (Line(points={{-539,
            -262},{-539,-264},{-516,-264},{-516,-256},{-508,-256}}, color={255,0,255}));
    connect(booleanToReal.y, firstOrder2.u) annotation (Line(points={{-485,-256},{
            -476,-256},{-476,-216},{-480,-216},{-480,-196},{-472,-196}}, color={0,
            0,127}));
    connect(coldROOM_V01.ports_Air_CR[1], senRelHum_CR.port) annotation (Line(
          points={{36,8.54286},{36,4},{88,4},{88,-16},{100,-16},{100,32},{136,32},
            {136,8},{156,8},{156,14}}, color={0,127,255}));
    connect(PIT_010.port, cheVal.port_a)
      annotation (Line(points={{-66,-156},{-52,-156}}, color={0,127,255}));
    connect(cheVal.port_b, jun.port_1)
      annotation (Line(points={{-36,-156},{-28,-156}}, color={0,127,255}));
    connect(Infiltration.y[1], infiltration.mAB) annotation (Line(points={{7,56},
            {8,56},{8,64},{15,64},{15,74.6}}, color={0,0,127}));
    connect(Infiltration.y[1], infiltration.mBA) annotation (Line(points={{7,56},
            {36.6,56},{36.6,74.6}}, color={0,0,127}));
    connect(firstOrder2.y, ThreeAV01.y) annotation (Line(points={{-449,-196},{-440,
            -196},{-440,-172},{-368,-172},{-368,-132},{-340,-132},{-340,-142}},
          color={0,0,127}));
    connect(con3WayValve.y, ThreeAV02.y) annotation (Line(points={{-188,-218},{
            -188,-220},{-142,-220},{-142,-168}}, color={0,0,127}));
    connect(conP01.y, P01.y) annotation (Line(points={{-82.4,-110},{-82.4,-112},
            {-72,-112},{-72,-140},{-80,-140},{-80,-136},{-86,-136},{-86,-144}},
          color={0,0,127}));
    connect(TIT_006.port_b, pip.port_a)
      annotation (Line(points={{-256,-156},{-250,-156}}, color={0,127,255}));
    connect(pip.port_b, storageDetailed.fluidportBottom2) annotation (Line(points
          ={{-230,-156},{-228.3,-156},{-228.3,-102.1}}, color={0,127,255}));
    connect(jun2.port_2, pip1.port_a)
      annotation (Line(points={{-146,-44},{-178,-44}}, color={0,127,255}));
    connect(pip1.port_b, storageDetailed.fluidportTop1) annotation (Line(points={{
            -198,-44},{-223.2,-44},{-223.2,-81.9}}, color={0,127,255}));
    connect(conP02.y, P02.y) annotation (Line(points={{-366.4,28},{-360,28},{-360,
            -20},{-384,-20},{-384,-34}}, color={0,0,127}));
    connect(coldROOM_V01.T_in_CR, x_pTphi.T) annotation (Line(points={{56.8,
            23.2},{64,23.2},{64,28},{140,28},{140,56},{160,56}}, color={0,0,127}));
    connect(senRelHum_CR.phi, x_pTphi.phi) annotation (Line(points={{167,24},{
            158,24},{158,42},{148,42},{148,50},{160,50}}, color={0,0,127}));
    connect(Infiltration1.y[1], loads_enhanced.t_people1) annotation (Line(
          points={{-39,48},{-32,48},{-32,22.2},{-22.6,22.2}}, color={0,0,127}));
    connect(Mogadishu.weaBus, weaBus1) annotation (Line(
        points={{108,98},{116,98},{116,44},{52,44},{52,100},{-56,100},{-56,108},{-144,
            108},{-144,92},{-142,92}},
        color={255,204,51},
        thickness=0.5));
    connect(T_amb.T, weaBus1.TDryBul) annotation (Line(points={{-192,90},{-200,90},
            {-200,112},{-144,112},{-144,92.05},{-141.95,92.05}},
                                                 color={0,0,127}), Text(
        string="%second",
        index=1,
        extent={{-6,3},{-6,3}},
        horizontalAlignment=TextAlignment.Right));
    connect(m_out.y, loads_enhanced.m_Out1) annotation (Line(points={{-99,8},{-72,
            8},{-72,0},{-32,0},{-32,14},{-23,14}}, color={0,0,127}));
    connect(pvPanels_G1.y, EVAP02.PVDayNight) annotation (Line(points={{137.9,
            -93},{108,-93},{108,-25.8429},{69.125,-25.8429}}, color={0,0,127}));
    connect(pvPanels_G1.y, EVAP01.PVDayNight) annotation (Line(points={{137.9,
            -93},{120,-93},{120,-94},{73.125,-94},{73.125,-143.843}}, color={0,
            0,127}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-780,
              -320},{140,120}}), graphics={
          Rectangle(
            extent={{-776,118},{138,-320}},
            lineColor={0,140,72},
            fillColor={0,140,72},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-746,94},{104,-294}},
            lineColor={0,140,72},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Text(
            extent={{-726,88},{84,-276}},
            textColor={0,140,72},
            textString="System_OL",
            textStyle={TextStyle.Bold})}),                         Diagram(
          coordinateSystem(preserveAspectRatio=false, extent={{-780,-320},{140,
              120}})),
      experiment(StopTime=2592000, __Dymola_Algorithm="Dassl"));
  end System_OL_NightCTRL;

  model System_CL_NightCTRL
    "Agri-Cool system with closed-loop night control logic"
    //extends Modelica.Icons.Example;
    extends Components.Base_Classes.Medium_Definition;

  parameter Modelica.Units.SI.Temperature T_aCoWat_nominal(
      min=273.15,
      displayUnit="degC") = 273.15 + 1
      "Cooling water inlet temperature at nominal conditions"    annotation (Dialog(group="Nominal condition"));
    parameter Modelica.Units.SI.Temperature T_bCoWat_nominal(
      min=273.15,
     displayUnit="degC") = 273.15 + 5
      "Cooling water outlet temperature at nominal conditions"
      annotation (Dialog(group="Nominal condition"));
    parameter Modelica.Units.SI.Temperature T_aLoaCo_nominal(
      min=273.15,
      displayUnit="degC") = 273.15 + 5
      "Load side inlet temperature at nominal conditions in cooling mode"
      annotation (Dialog(group="Nominal condition"));
    parameter Modelica.Units.SI.Temperature T_bLoaCo_nominal(
      min=273.15,
      displayUnit="degC") = 273.15 + 10
      "Load side outlet temperature at nominal conditions in cooling mode"
      annotation (Dialog(group="Nominal condition"));
    parameter Modelica.Units.SI.MassFlowRate mLoaCo_flow_nominal(min=0) =
      2500/1005/(T_bLoaCo_nominal - T_aLoaCo_nominal)
      "Load side mass flow rate at nominal conditions"
      annotation (Dialog(group="Nominal condition"));

    parameter Modelica.Units.SI.HeatFlowRate QCo_flow_nominal=
        -2500  "Design cooling flow rate (<=0)"
      annotation (Dialog(group="Nominal condition"));
   parameter Modelica.Units.SI.MassFlowRate mChilWat_flow_nominal(min=0) =
      0.5
      "water side mass flow rate at nominal conditions"
      annotation (Dialog(group="Nominal condition"));

    parameter Real facMul=1
      "Multiplier factor";
     parameter Integer nLoa=1
      "Number of served loads"
      annotation (Evaluate=true);

      ////
       parameter Modelica.Units.SI.PressureDifference dpNominal_CheckValve(displayUnit="Pa")=
         5000 "Load side pressure drop"
      annotation (Dialog(group="Nominal condition"));
      parameter Modelica.Units.SI.PressureDifference dpNominal_fanCoil(displayUnit="Pa")=
         20000 "Load side pressure drop"
      annotation (Dialog(group="Nominal condition"));
          parameter Modelica.Units.SI.PressureDifference dpNominal_conj(displayUnit="Pa")=
         2000 "Load side pressure drop"
      annotation (Dialog(group="Nominal condition"));
              parameter Modelica.Units.SI.PressureDifference dpNominal_3way(displayUnit="Pa")=
         40000 "Load side pressure drop"
         annotation (Dialog(group="Nominal condition"));
     parameter Modelica.Units.SI.PressureDifference dpNominal_PCM( displayUnit="Pa")=
         25000 "Load side pressure drop"
      annotation (Dialog(group="Nominal condition"));

    parameter Modelica.Units.SI.PressureDifference dpNominal_Total_P01 =
    (dpNominal_CheckValve + 2*dpNominal_fanCoil + 2*dpNominal_conj + dpNominal_3way)
    "Total load side pressure drop";    ////

    Components.Cold_Room.ColdROOM_V01 coldROOM_V01(
      redeclare package Medium_CR = Medium_Air,
      nPortsAir=7,
      T_start_CR=288.15)
      annotation (Placement(transformation(extent={{36,6},{56,26}})));
    Buildings.BoundaryConditions.WeatherData.ReaderTMY3 Mogadishu(
      filNam=ModelicaServices.ExternalReferences.loadResource(
          "modelica://AGRI_COOL/Inputs/SOM_BN_Mogadishu.Intl.AP.632600_TMYx.2009-2023.mos"),
      computeWetBulbTemperature=false,
      HInfHorSou=Buildings.BoundaryConditions.Types.DataSource.Parameter,
      HSou=Buildings.BoundaryConditions.Types.RadiationDataSource.Input_HGloHor_HDifHor)
      annotation (Placement(transformation(extent={{88,88},{108,108}})));
    Components.Cooling_Loads.Infiltration_load.Infiltration_ZoneFlow infiltration(
        redeclare package Medium_CR = Medium_Air)
      annotation (Placement(transformation(extent={{16,68},{36,88}})));
    Components.Cooling_Loads.Integrated.Loads_enhanced
                                              loads_enhanced(
                                                    n=2,
      m_Initial_T1=0,
      T_Initial_T1=298.15,
      m_Initial_T2=0,
      T_Initial_T2=283.15,
      T_source=298.15)
      annotation (Placement(transformation(extent={{-22,12},{2,32}})));
    Modelica.Blocks.Sources.Constant Zero(k=0) "No radiation"
      annotation (Placement(transformation(extent={{58,68},{78,88}})));
    Buildings.Fluid.Sources.Outside           out(redeclare package Medium =
          Medium_Air, nPorts=4)
      annotation (Placement(transformation(extent={{-84,80},{-64,100}})));
    Modelica.Blocks.Sources.Pulse m_in(
      amplitude=0.2777778,
      width=2.0833333,
      period(displayUnit="h") = 86400,
      offset=0,
      startTime(displayUnit="h") = 28800)
      annotation (Placement(transformation(extent={{-64,8},{-44,28}})));
    Modelica.Blocks.Sources.CombiTimeTable Infiltration(
      table=[0,0.01; 8*3600,0.01; 8*3600,0.05; 9*3600,0.05; 9*3600,0.01; 17*
          3600,0.01; 17*3600,0.05; 18*3600,0.05; 18*3600,0.01; 24*3600,0.01; 32
          *3600,0.01; 32*3600,0.05; 33*3600,0.05; 33*3600,0.01; 41*3600,0.01;
          41*3600,0.05; 42*3600,0.05; 42*3600,0.01; 48*3600,0.01],
      columns={2},
      extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic)
      annotation (Placement(transformation(extent={{-14,46},{6,66}})));
    Buildings.Controls.OBC.CDL.Reals.Sources.Constant TSet_Room(k=273.15 + 5, y(
          final unit="K", displayUnit="degC")) "Temperature set point"
      annotation (Placement(transformation(extent={{-50,-32},{-26,-8}})));
    Components.Unit_Cooler.FanCoil_closedLoop
                                   EVAP01(
      T_aCoWat_nominal=T_aCoWat_nominal,
      T_bCoWat_nominal=278.15,
      T_aLoaCo_nominal=285.15,
      T_bLoaCo_nominal=278.15,
      mLoaCo_flow_nominal=0.37,
      mChilWat_flow_nominal=0.15,
      QCo_flow_nominal=-5000,
      w_aLoaCoo_nominal=0.005,
      dpNominal_ChilWat_fanCoil=dpNominal_fanCoil)
      annotation (Placement(transformation(extent={{28,-164},{66,-130}})));
    Components.Unit_Cooler.FanCoil_closedLoop
                                   EVAP02(
      T_aCoWat_nominal=T_aCoWat_nominal,
      T_bCoWat_nominal=278.15,
      T_aLoaCo_nominal=285.15,
      T_bLoaCo_nominal=278.15,
      mLoaCo_flow_nominal=0.37,
      mChilWat_flow_nominal=0.15,
      QCo_flow_nominal=-5000,
      w_aLoaCoo_nominal=0.005,
      dpNominal_ChilWat_fanCoil=dpNominal_fanCoil)
      annotation (Placement(transformation(extent={{24,-46},{62,-12}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_IE1(redeclare package Medium
        = Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-2,-166},{18,-146}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_OE1(redeclare package Medium
        = Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{102,-166},{82,-146}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_IE2(redeclare package Medium
        = Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-22,-80},{-2,-60}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_OE2(redeclare package Medium
        = Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{70,-50},{90,-30}})));
    Buildings.Fluid.FixedResistances.Junction jun(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
      m_flow_nominal={mChilWat_flow_nominal,-mChilWat_flow_nominal,-
          mChilWat_flow_nominal},
      dp_nominal={dpNominal_conj,-dpNominal_conj,-dpNominal_conj})
      annotation (Placement(transformation(extent={{-28,-146},{-8,-166}})));
    Buildings.Fluid.Movers.SpeedControlled_y P01(redeclare package Medium =
          Medium_HTF, redeclare Buildings.Fluid.Movers.Data.Generic per(
          pressure(V_flow={0.00014,0.00028,0.00056,0.00083,0.00111,0.00139,
              0.00167,0.00194}, dp={59000,58500,58000,55000,47000,40000,30000,
              20000}), power(V_flow={0.00014,0.00028,0.00056,0.00083,0.00111,
              0.00139,0.00167,0.00194}, P={60,70,90,100,102,105,105,105})))
      annotation (Placement(transformation(extent={{-96,-166},{-76,-146}})));
    Buildings.Fluid.Sensors.Pressure PIT_010(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-76,-156},{-56,-176}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_010(redeclare package Medium
        = Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-124,-164},{-104,-144}})));
    Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear ThreeAV02(
      redeclare package Medium = Medium_HTF,
      m_flow_nominal=mChilWat_flow_nominal,
      dpValve_nominal=dpNominal_3way)
      annotation (Placement(transformation(extent={{-152,-146},{-132,-166}})));
    Buildings.Fluid.FixedResistances.Junction jun1(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
      m_flow_nominal={mChilWat_flow_nominal,-mChilWat_flow_nominal,
          mChilWat_flow_nominal},
      dp_nominal={dpNominal_conj,-dpNominal_conj,dpNominal_conj})
      annotation (Placement(transformation(extent={{-42,-58},{-62,-38}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_011(redeclare package Medium
        = Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-70,-54},{-90,-34}})));
    Buildings.Fluid.Sensors.Pressure PIT_011(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-116,-44},{-96,-24}})));
    Buildings.Fluid.FixedResistances.Junction jun2(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
      m_flow_nominal={mChilWat_flow_nominal,-mChilWat_flow_nominal,-
          mChilWat_flow_nominal},
      dp_nominal={dpNominal_conj,-dpNominal_conj,-dpNominal_conj})
      annotation (Placement(transformation(extent={{-126,-54},{-146,-34}})));
    Buildings.Fluid.Sensors.MassFlowRate FIT_002(redeclare package Medium =
          Medium_HTF) annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-174,-96})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_009(redeclare package Medium
        = Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-184,-166},{-164,-146}})));
    Buildings.Fluid.Sensors.MassFlowRate FIT_003(redeclare package Medium =
          Medium_HTF) annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=180,
          origin={-204,-156})));
    Components.Decoupler_Tank.AixLib_Fluid_Storage_StorageDetailed
                                         storageDetailed(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
      redeclare package MediumHC1 = Medium_HTF,
      redeclare package MediumHC2 = Medium_HTF,
      m1_flow_nominal=mChilWat_flow_nominal,
      m2_flow_nominal=mChilWat_flow_nominal,
      useHeatingCoil1=false,
      useHeatingCoil2=false,
      useHeatingRod=false,
      TStart=fill(2 + 273.15, storageDetailed.n),
      redeclare AGRI_COOL.Components.Decoupler_Tank.AixLib.DataBase.Storage.Generic_New_2000l   data(
        hTank=0.95,
        hLowerPortDemand=0.18,
        hUpperPortDemand=0.8,
        hLowerPortSupply=0.18,
        hUpperPortSupply=0.8,
        hHC1Up=0.2,
        hHC2Up=0.2,
        hHR=0.1,
        dTank=0.45,
        sIns=0.05,
        lambdaIns=0.034,
        hTS1=0.25,
        hTS2=0.7),
      redeclare model HeatTransfer =
          AGRI_COOL.Components.Decoupler_Tank.AixLib.Fluid.Storage.BaseClasses.HeatTransferBuoyancyWetter)
      "data is rewritten_ doble check please"
      annotation (Placement(transformation(extent={{-218,-102},{-234,-82}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_006(redeclare package Medium
        = Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-276,-166},{-256,-146}})));
    Buildings.Fluid.Sensors.MassFlowRate FIT_001(redeclare package Medium =
          Medium_HTF) annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=180,
          origin={-280,-46})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_001(redeclare package Medium
        = Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-308,-56},{-328,-36}})));
    Buildings.Fluid.Sensors.Pressure PIT_001(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-336,-46},{-356,-26}})));
    Buildings.Fluid.Movers.SpeedControlled_y P02(redeclare package Medium =
          Medium_HTF, redeclare Buildings.Fluid.Movers.Data.Generic per(
          pressure(V_flow={0,0.00019444,0.00027778,0.00036111,0.00044444,
              0.00052778,0.00061111,0.00066667}, dp={355122,351198,343350,
              326673,299205,262908,216801,173637}), power(V_flow={0.000195,
              0.000278,0.000417,0.000556,0.000667}, P={335,375,450,480,480})))
      annotation (Placement(transformation(extent={{-374,-56},{-394,-36}})));
    Components.Chiller.TwoCircuitChiller twoCircuitChiller(redeclare package
        Medium_Evap = Medium_HTF, redeclare package Medium_Cond = Medium_Air,
      mChilWat_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-486,-130},{-436,-68}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_002(redeclare package Medium
        = Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-394,-164},{-374,-144}})));
    Buildings.Fluid.Sensors.Pressure PIT_002(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-398,-154},{-418,-134}})));
    Buildings.Fluid.Storage.Ice.Tank PCM01(
      redeclare package Medium = Medium_HTF,
      m_flow_nominal=mChilWat_flow_nominal,
      show_T=true,
      dp_nominal=dpNominal_PCM,
      T_start=273.15,
      SOC_start=1,
      per=UNIP_Per1,
      energyDynamicsHex=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
      tauHex=30)
      annotation (Placement(transformation(extent={{-420,-242},{-400,-222}})));
    Buildings.Fluid.Storage.Ice.Tank PCM02(
      redeclare package Medium = Medium_HTF,
      m_flow_nominal=mChilWat_flow_nominal,
      show_T=true,
      dp_nominal=dpNominal_PCM,
      T_start=273.15,
      SOC_start=1,
      per=UNIP_Per1,
      tauHex=30)
      annotation (Placement(transformation(extent={{-424,-300},{-404,-280}})));
    Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear ThreeAV01(
      redeclare package Medium = Medium_HTF,
      portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Leaving,
      portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Entering,
      portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
      m_flow_nominal=mChilWat_flow_nominal,
      dpValve_nominal=dpNominal_3way)
      annotation (Placement(transformation(extent={{-330,-164},{-350,-144}})));
    Buildings.Fluid.Sensors.Pressure PIT_003(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-346,-194},{-366,-174}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_003(redeclare package Medium
        = Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-388,-202},{-408,-182}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_004(redeclare package Medium
        = Medium_HTF, m_flow_nominal=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-372,-242},{-352,-222}})));
    Buildings.Fluid.Sensors.Pressure PIT_004(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-320,-232},{-340,-212}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort TIT_005(redeclare package Medium
        = Medium_HTF, m_flow_nominal=1)
      annotation (Placement(transformation(extent={{-374,-300},{-354,-280}})));
    Buildings.Fluid.Sensors.Pressure PIT_005(redeclare package Medium =
          Medium_HTF)
      annotation (Placement(transformation(extent={{-320,-290},{-340,-270}})));
    Buildings.Fluid.Sensors.MassFlowRate FIT_004(redeclare package Medium =
          Medium_HTF) annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=270,
          origin={-302,-220})));
    Buildings.Fluid.FixedResistances.Junction jun3(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
      m_flow_nominal={mChilWat_flow_nominal,-mChilWat_flow_nominal,
          mChilWat_flow_nominal},
      dp_nominal={dpNominal_conj,-dpNominal_conj,dpNominal_conj})
      annotation (Placement(transformation(extent={{-312,-166},{-292,-146}})));
    Buildings.Fluid.Sources.MassFlowSource_WeatherData bou(redeclare package
        Medium = Medium_Air,
      m_flow=3.43,           nPorts=2)
      annotation (Placement(transformation(extent={{-534,-36},{-514,-16}})));
    Components.PV.PvPanels pvPanels(nPV=20)
      annotation (Placement(transformation(extent={{-732,-14},{-700,10}})));
    Buildings.BoundaryConditions.WeatherData.ReaderTMY3 Mogadishu1(filNam=
          ModelicaServices.ExternalReferences.loadResource(
          "modelica://AGRI_COOL/Inputs/SOM_BN_Mogadishu.Intl.AP.632600_TMYx.2009-2023.mos"),
        computeWetBulbTemperature=false)
      annotation (Placement(transformation(extent={{-766,6},{-746,26}})));
    Components.Battery.equipmentLoad equipmentLoad
      annotation (Placement(transformation(extent={{-640,-90},{-580,-42}})));
     Components.Battery.supCapDis supCapDis(
      capacityModule=(2*3.6*3.6e6)/1600,
      Vmax=58,
      Vnom=51.8,
      Imax=4*100)
      annotation (Placement(transformation(extent={{-658,-164},{-582,-122}})));
    Modelica.Blocks.Math.Sum sum1(nin=3)
      annotation (Placement(transformation(extent={{-704,-82},{-684,-62}})));
    Modelica.Blocks.Sources.RealExpression Fan_Pump(y=P02.P + P01.P + EVAP01.fan.P
           + EVAP02.fan.P)
      annotation (Placement(transformation(extent={{-770,-92},{-750,-72}})));
    Modelica.Blocks.Sources.RealExpression PLC(y=0.1*Fan_Pump.y)
      annotation (Placement(transformation(extent={{-770,-114},{-750,-94}})));
    Components.LTES.Performance_Based.EnergyPlus_UNIP UNIP_Per
      annotation (Placement(transformation(extent={{-470,-296},{-450,-276}})));
    Modelica.Blocks.Sources.Constant const4(k=273.15 + 1)
      annotation (Placement(transformation(extent={{-246,-242},{-226,-222}})));
    Buildings.Fluid.Storage.ExpansionVessel expVes(redeclare package Medium =
          Medium_HTF, V_start(displayUnit="l") = 0.02)
                                    "Expansion vessel"
      annotation (Placement(transformation(extent={{-326,-92},{-306,-72}})));
    Buildings.Controls.OBC.CDL.Reals.PIDWithReset con3WayValve(
      final k=2,
      final Ti=10,
      controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
      yMax=1,
      yMin=0,
      final reverseActing=false) "PI controller"
      annotation (Placement(transformation(extent={{-210,-228},{-190,-208}})));
    Modelica.Blocks.Sources.BooleanExpression booleanExpression
      annotation (Placement(transformation(extent={{-246,-272},{-226,-252}})));
    Buildings.Fluid.Sensors.RelativePressure senRelPre(redeclare package Medium
        = Medium_HTF) annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=90,
          origin={-72,-92})));
    Buildings.Controls.OBC.CDL.Reals.PIDWithReset conP01(
      final k=1e-3,
      final Ti(displayUnit="s") = 20,
      controllerType=AGRI_COOL.Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
      yMax=1,
      yMin=0,
      final reverseActing=true) "PI controller"
      annotation (Placement(transformation(extent={{-100,-118},{-84,-102}})));
    Modelica.Blocks.Sources.BooleanExpression booleanExpression1
      annotation (Placement(transformation(extent={{-128,-134},{-108,-114}})));
    Modelica.Blocks.Sources.Constant const5(k=0.08*dpNominal_Total_P01)
      annotation (Placement(transformation(extent={{-132,-100},{-112,-80}})));
    Buildings.Controls.OBC.CDL.Reals.PIDWithReset conP02(
      final k=1,
      final Ti=10,
      controllerType=AGRI_COOL.Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
      yMax=1,
      yMin=0,
      final reverseActing=true) "PI controller"
      annotation (Placement(transformation(extent={{-384,20},{-368,36}})));
    Modelica.Blocks.Sources.BooleanExpression booleanExpression2
      annotation (Placement(transformation(extent={{-422,2},{-402,22}})));
    Modelica.Blocks.Sources.Constant const6(k=mChilWat_flow_nominal)
      annotation (Placement(transformation(extent={{-424,32},{-404,52}})));
    Components.Controls.CompressorStepController compressorStepController
      annotation (Placement(transformation(extent={{-672,-298},{-616,-242}})));
    Modelica.Blocks.Sources.RealExpression pvPanels_G(y=pvPanels.pv[1].panel.G)
      annotation (Placement(transformation(extent={{-776,-296},{-734,-266}})));
    Modelica.Blocks.Math.BooleanToReal booleanToReal(realTrue=0, realFalse=1)
      annotation (Placement(transformation(extent={{-506,-266},{-486,-246}})));
    Components.Controls.TempSocConditionHys tempSocCondition
      annotation (Placement(transformation(extent={{-710,-204},{-690,-184}})));
    Modelica.Blocks.Logical.Switch CompSignalEnable annotation (Placement(
          transformation(extent={{-10,-10},{10,10}}, origin={-620,-202})));
    Modelica.Blocks.Sources.Constant const2(k=0)
      annotation (Placement(transformation(extent={{-738,-260},{-718,-240}})));
    Modelica.Blocks.Sources.RealExpression HTFTemp(y=TIT_001.T)
      annotation (Placement(transformation(extent={{-820,-208},{-778,-178}})));
    Modelica.Blocks.Continuous.FirstOrder  firstOrder(T=5)
      annotation (Placement(transformation(extent={{-560,-172},{-540,-152}})));
    Components.Controls.OutOfRangeDetector outOfRangeDetector
      annotation (Placement(transformation(extent={{-560,-272},{-540,-252}})));
    Modelica.Blocks.Continuous.FirstOrder firstOrder2(T(displayUnit="s") = 5)
      annotation (Placement(transformation(extent={{-470,-206},{-450,-186}})));
    Buildings.Fluid.Sensors.RelativeHumidity senRelHum_CR(redeclare package
        Medium = Medium_Air, warnAboutOnePortConnection=false)
      annotation (Placement(transformation(extent={{146,14},{166,34}})));
    Buildings.Fluid.FixedResistances.CheckValve cheVal(
      redeclare package Medium = Medium_HTF,
      m_flow_nominal=mChilWat_flow_nominal,
      dpValve_nominal=dpNominal_CheckValve)
      annotation (Placement(transformation(extent={{-52,-164},{-36,-148}})));

    parameter Buildings.Fluid.Storage.Ice.Data.Tank.Generic UNIP_Per1(
      mIce_max=365,
      coeCha={1.76953858E-04,0,0,0,0,0},
      dtCha=10,
      coeDisCha={5.54E-05,-1.45679E-04,9.28E-05,1.126122E-03,-1.1012E-03,3.00544E-04},
      dtDisCha=10) "Tank performance data"
      annotation (Placement(transformation(extent={{-506,-308},{-486,-288}})));

    Buildings.Fluid.FixedResistances.Pipe pip(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
      m_flow_nominal=mChilWat_flow_nominal,
      dp_nominal(displayUnit="Pa") = 1000,
      thicknessIns(displayUnit="mm") = 0.02,
      lambdaIns=0.025,
      length=1)
      annotation (Placement(transformation(extent={{-250,-166},{-230,-146}})));
    Buildings.Fluid.FixedResistances.Pipe pip1(
      redeclare package Medium = Medium_HTF,
      energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
      m_flow_nominal=mChilWat_flow_nominal,
      dp_nominal(displayUnit="Pa") = 1000,
      thicknessIns(displayUnit="mm") = 0.02,
      lambdaIns=0.025,
      length=1)
      annotation (Placement(transformation(extent={{-178,-54},{-198,-34}})));
    Buildings.Utilities.Psychrometrics.X_pTphi x_pTphi(use_p_in=false)
      annotation (Placement(transformation(extent={{162,46},{182,66}})));
    Modelica.Blocks.Sources.CombiTimeTable Infiltration1(
      table=[0,0; 8*3600,0; 8*3600,1; 9*3600,1; 9*3600,0; 17*3600,0; 17*3600,1;
          18*3600,1; 18*3600,0; 24*3600,0; 32*3600,0; 32*3600,1; 33*3600,1; 33*
          3600,0; 41*3600,0; 41*3600,1; 42*3600,1; 42*3600,0; 48*3600,0],
      columns={2},
      extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic)
      annotation (Placement(transformation(extent={{-60,38},{-40,58}})));
    Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature T_amb
      annotation (Placement(transformation(extent={{-166,84},{-146,104}})));
    Buildings.BoundaryConditions.WeatherData.Bus weaBus1
               "Weather data bus"
      annotation (Placement(transformation(extent={{-150,86},{-130,106}}),
          iconTransformation(extent={{-150,86},{-130,106}})));
    Modelica.Blocks.Sources.Pulse m_out(
      amplitude=0.2777778,
      width=2.0833333,
      period(displayUnit="h") = 86400,
      offset=0,
      startTime(displayUnit="h") = 61200)
      annotation (Placement(transformation(extent={{-120,-2},{-100,18}})));
    Modelica.Blocks.Sources.RealExpression pvPanels_G1(y=pvPanels.pv[1].panel.G)
      annotation (Placement(transformation(extent={{182,-108},{140,-78}})));
  equation
    connect(Mogadishu.weaBus, coldROOM_V01.weaBus1) annotation (Line(
        points={{108,98},{116,98},{116,44},{51.4,44},{51.4,26}},
        color={255,204,51},
        thickness=0.5));
    connect(Zero.y,Mogadishu. HGloHor_in) annotation (Line(points={{79,78},{79,
            80},{87,80},{87,85}},
                              color={0,0,127}));
    connect(Zero.y,Mogadishu. HDifHor_in) annotation (Line(points={{79,78},{79,
            80},{87,80},{87,88.5}},
                                  color={0,0,127}));
    connect(Mogadishu.weaBus, infiltration.weaBus1) annotation (Line(
        points={{108,98},{116,98},{116,44},{52,44},{52,100},{16,100},{16,83}},
        color={255,204,51},
        thickness=0.5));
    connect(Mogadishu.weaBus, out.weaBus) annotation (Line(
        points={{108,98},{116,98},{116,44},{52,44},{52,100},{-56,100},{-56,108},
            {-92,108},{-92,90.2},{-84,90.2}},
        color={255,204,51},
        thickness=0.5));
    connect(loads_enhanced.port1, coldROOM_V01.heaPorAir1) annotation (Line(
          points={{2.2,22.8},{22,22.8},{22,-2},{62,-2},{62,17.6},{56,17.6}},
          color={191,0,0}));
    connect(coldROOM_V01.T_in_CR, loads_enhanced.T_in_K1) annotation (Line(
          points={{56.8,23.2},{62,23.2},{62,36},{8,36},{8,42},{-22.8,42},{-22.8,
            31.2}}, color={0,0,127}));
    connect(m_in.y, loads_enhanced.m_In1) annotation (Line(points={{-43,18},{-43,
            18.2},{-22.6,18.2}}, color={0,0,127}));
    connect(loads_enhanced.Q_people1, coldROOM_V01.Q_People) annotation (Line(
          points={{2.4,27.8},{26,27.8},{26,21.2},{35.4,21.2}}, color={0,0,127}));
    connect(infiltration.port_a_out, out.ports[1]) annotation (Line(points={{16,78},
            {8,78},{8,88.5},{-64,88.5}}, color={0,127,255}));
    connect(infiltration.port_b_out, out.ports[2]) annotation (Line(points={{16,70},
            {16,40},{-28,40},{-28,89.5},{-64,89.5}},
                                         color={0,127,255}));
    connect(TSet_Room.y, EVAP01.TSetCoo) annotation (Line(points={{-23.6,-20},{
            4,-20},{4,-139.229},{28.475,-139.229}},                     color={
            0,0,127}));
    connect(TSet_Room.y, EVAP02.TSetCoo) annotation (Line(points={{-23.6,-20},{
            -23.6,-21.2286},{24.475,-21.2286}}, color={0,0,127}));
    connect(coldROOM_V01.T_in_CR, EVAP02.TColdRoom) annotation (Line(points={{56.8,
            23.2},{90,23.2},{90,-12},{-16,-12},{-16,-31.4286},{24.2375,-31.4286}},
                        color={0,0,127}));
    connect(coldROOM_V01.T_in_CR, EVAP01.TColdRoom) annotation (Line(points={{56.8,
            23.2},{64,23.2},{64,28},{112,28},{112,-176},{28.2375,-176},{28.2375,
            -149.429}},         color={0,0,127}));
    connect(EVAP02.port_aLoa, coldROOM_V01.ports_Air_CR[4]) annotation (Line(
          points={{62,-15.8857},{68,-15.8857},{68,2},{36,2},{36,9.7}}, color={0,
            127,255}));
    connect(coldROOM_V01.ports_Air_CR[5], EVAP02.port_bLoa) annotation (Line(
          points={{36,10.0857},{20,10.0857},{20,-15.4},{23.7625,-15.4}}, color=
            {0,127,255}));
    connect(EVAP01.port_aLoa, coldROOM_V01.ports_Air_CR[6]) annotation (Line(
          points={{66,-133.886},{80,-133.886},{80,-60},{100,-60},{100,-16},{88,
            -16},{88,4},{36,4},{36,10.4714}}, color={0,127,255}));
    connect(EVAP01.port_bLoa, coldROOM_V01.ports_Air_CR[7]) annotation (Line(
          points={{27.7625,-133.4},{27.7625,-136},{16,-136},{16,-60},{100,-60},
            {100,-16},{88,-16},{88,4},{36,4},{36,10.8571}}, color={0,127,255}));
    connect(infiltration.port_b_env, coldROOM_V01.ports_Air_CR[1]) annotation (
        Line(points={{36,83},{40,83},{40,76},{48,76},{48,40},{100,40},{100,-16},
            {88,-16},{88,4},{36,4},{36,8.54286}}, color={0,127,255}));
    connect(infiltration.port_b_in, coldROOM_V01.ports_Air_CR[2]) annotation (
        Line(points={{36.2,78},{40,78},{40,76},{48,76},{48,40},{100,40},{100,
            -16},{88,-16},{88,4},{36,4},{36,8.92857}}, color={0,127,255}));
    connect(infiltration.port_a_in, coldROOM_V01.ports_Air_CR[3]) annotation (
        Line(points={{36,70},{36,76},{48,76},{48,40},{100,40},{100,-16},{82,-16},{
            82,-2},{36,-2},{36,9.31429}},color={0,127,255}));
    connect(TIT_IE1.port_b, EVAP01.port_aChiWat) annotation (Line(points={{18,-156},
            {20,-156},{20,-157.929},{28.2375,-157.929}},       color={0,127,255}));
    connect(EVAP02.port_aChiWat, TIT_IE2.port_b) annotation (Line(points={{24.2375,
            -39.9286},{8,-39.9286},{8,-70},{-2,-70}},         color={0,127,255}));
    connect(EVAP02.port_bChiWat, TIT_OE2.port_a) annotation (Line(points={{62,
            -39.6857},{66,-39.6857},{66,-40},{70,-40}}, color={0,127,255}));
    connect(TIT_IE1.port_a, jun.port_2)
      annotation (Line(points={{-2,-156},{-8,-156}},  color={0,127,255}));
    connect(jun.port_3, TIT_IE2.port_a) annotation (Line(points={{-18,-146},{-18,-88},
            {-32,-88},{-32,-70},{-22,-70}},
                                 color={0,127,255}));
    connect(P01.port_b, PIT_010.port)
      annotation (Line(points={{-76,-156},{-66,-156}}, color={0,127,255}));
    connect(P01.port_a, TIT_010.port_b)
      annotation (Line(points={{-96,-156},{-102,-156},{-102,-154},{-104,-154}},
                                                        color={0,127,255}));
    connect(TIT_010.port_a, ThreeAV02.port_2)
      annotation (Line(points={{-124,-154},{-130,-154},{-130,-156},{-132,-156}},
                                                         color={0,127,255}));
    connect(TIT_OE2.port_b, jun1.port_1) annotation (Line(points={{90,-40},{94,-40},
            {94,-48},{-42,-48}},      color={0,127,255}));
    connect(TIT_OE1.port_a, jun1.port_3) annotation (Line(points={{102,-156},{
            108,-156},{108,-112},{-52,-112},{-52,-58}}, color={0,127,255}));
    connect(jun1.port_2, TIT_011.port_a)
      annotation (Line(points={{-62,-48},{-66,-48},{-66,-44},{-70,-44}},
                                                     color={0,127,255}));
    connect(TIT_011.port_b, PIT_011.port)
      annotation (Line(points={{-90,-44},{-106,-44}}, color={0,127,255}));
    connect(PIT_011.port, jun2.port_1)
      annotation (Line(points={{-106,-44},{-126,-44}}, color={0,127,255}));
    connect(ThreeAV02.port_3, FIT_002.port_b) annotation (Line(points={{-142,-146},
            {-142,-120},{-174,-120},{-174,-106}},       color={0,127,255}));
    connect(jun2.port_3, FIT_002.port_a)
      annotation (Line(points={{-136,-54},{-136,-80},{-174,-80},{-174,-86}},
                                                       color={0,127,255}));
    connect(ThreeAV02.port_1, TIT_009.port_b)
      annotation (Line(points={{-152,-156},{-164,-156}}, color={0,127,255}));
    connect(TIT_009.port_a, FIT_003.port_b)
      annotation (Line(points={{-184,-156},{-194,-156}}, color={0,127,255}));
    connect(storageDetailed.fluidportBottom1, FIT_003.port_a) annotation (Line(
          points={{-223.3,-102.2},{-223.3,-156},{-214,-156}}, color={0,127,255}));
    connect(storageDetailed.fluidportTop2, FIT_001.port_a) annotation (Line(
          points={{-228.5,-81.9},{-228.5,-46},{-270,-46}}, color={0,127,255}));
    connect(FIT_001.port_b, TIT_001.port_a)
      annotation (Line(points={{-290,-46},{-308,-46}}, color={0,127,255}));
    connect(TIT_001.port_b, PIT_001.port)
      annotation (Line(points={{-328,-46},{-346,-46}}, color={0,127,255}));
    connect(PIT_001.port, P02.port_a)
      annotation (Line(points={{-346,-46},{-374,-46}}, color={0,127,255}));
    connect(P02.port_b, twoCircuitChiller.Evap_inlet_C1) annotation (Line(
          points={{-394,-46},{-418,-46},{-418,-99},{-435.5,-99}}, color={0,127,
            255}));
    connect(twoCircuitChiller.Evap_outlet_C2, PIT_002.port) annotation (Line(
          points={{-486,-100.86},{-504,-100.86},{-504,-160},{-428,-160},{-428,-164},
            {-408,-164},{-408,-154}},
                    color={0,127,255}));
    connect(PIT_002.port, TIT_002.port_a) annotation (Line(points={{-408,-154},{-394,
            -154}},                               color={0,127,255}));
    connect(ThreeAV01.port_3, PIT_003.port) annotation (Line(points={{-340,-164},{
            -340,-176},{-356,-176},{-356,-194}},  color={0,127,255}));
    connect(PIT_003.port, TIT_003.port_a) annotation (Line(points={{-356,-194},{-352,
            -194},{-352,-196},{-380,-196},{-380,-192},{-388,-192}},
                                      color={0,127,255}));
    connect(TIT_003.port_b, PCM01.port_a) annotation (Line(points={{-408,-192},
            {-424,-192},{-424,-196},{-434,-196},{-434,-232},{-420,-232}}, color
          ={0,127,255}));
    connect(PCM01.port_b, TIT_004.port_a)
      annotation (Line(points={{-400,-232},{-372,-232}}, color={0,127,255}));
    connect(TIT_004.port_b, PIT_004.port)
      annotation (Line(points={{-352,-232},{-330,-232}}, color={0,127,255}));
    connect(PIT_004.port, PCM02.port_a) annotation (Line(points={{-330,-232},{
            -332,-232},{-332,-262},{-436,-262},{-436,-290},{-424,-290}}, color=
            {0,127,255}));
    connect(PCM02.port_b, TIT_005.port_a)
      annotation (Line(points={{-404,-290},{-374,-290}}, color={0,127,255}));
    connect(TIT_005.port_b, PIT_005.port)
      annotation (Line(points={{-354,-290},{-330,-290}}, color={0,127,255}));
    connect(PIT_005.port, FIT_004.port_a) annotation (Line(points={{-330,-290},
            {-332,-290},{-332,-300},{-302,-300},{-302,-230}}, color={0,127,255}));
    connect(TIT_006.port_a, jun3.port_2)
      annotation (Line(points={{-276,-156},{-292,-156}}, color={0,127,255}));
    connect(FIT_004.port_b, jun3.port_3)
      annotation (Line(points={{-302,-210},{-302,-166}}, color={0,127,255}));
    connect(twoCircuitChiller.Cond_outlet_C2, out.ports[3]) annotation (Line(
          points={{-456.5,-68},{-456.5,76},{-64,76},{-64,90.5}}, color={0,127,
            255}));
    connect(twoCircuitChiller.Cond_outlet_C1, out.ports[4]) annotation (Line(
          points={{-450,-68},{-430,-68},{-430,64},{-64,64},{-64,91.5}}, color={
            0,127,255}));
    connect(Mogadishu.weaBus, bou.weaBus) annotation (Line(
        points={{108,98},{116,98},{116,44},{52,44},{52,100},{-56,100},{-56,108},
            {-140,108},{-140,112},{-544,112},{-544,-25.8},{-534,-25.8}},
        color={255,204,51},
        thickness=0.5));
    connect(bou.ports[1], twoCircuitChiller.Cond_Inlet_C2) annotation (Line(
          points={{-514,-27},{-500,-27},{-500,-36},{-479.5,-36},{-479.5,-68}},
          color={0,127,255}));
    connect(bou.ports[2], twoCircuitChiller.Cond_Inlet_C1) annotation (Line(
          points={{-514,-25},{-473,-25},{-473,-68}}, color={0,127,255}));
    connect(Mogadishu1.weaBus, pvPanels.weaBus) annotation (Line(
        points={{-746,16},{-740,16},{-740,6.9},{-727.5,6.9}},
        color={255,204,51},
        thickness=0.5));
    connect(pvPanels.P_total, equipmentLoad.pTotal) annotation (Line(points={{-702.4,
            -2.2},{-652,-2.2},{-652,-46.6},{-636.6,-46.6}},          color={0,0,
            127}));
    connect(pvPanels.P_total, supCapDis.pTotal) annotation (Line(points={{-702.4,-2.2},
            {-653.4,-2.2},{-653.4,-126.8}},                            color={0,
            0,127}));
    connect(equipmentLoad.IsinkLoad, supCapDis.iLoad) annotation (Line(points={{-598.5,
            -45.1},{-598.5,-32},{-656,-32},{-656,-88},{-676,-88},{-676,-134.6},{-653.8,
            -134.6}},        color={0,0,127}));
    connect(sum1.y, supCapDis.PLoadSW) annotation (Line(points={{-683,-72},{-672,-72},
            {-672,-143.6},{-653,-143.6}},
                      color={0,0,127}));
    connect(supCapDis.vSupCap, equipmentLoad.vSupCap) annotation (Line(points={{-584.1,
            -125.1},{-584.1,-104},{-568,-104},{-568,-87.6},{-580.2,-87.6}},
                                                                        color={
            0,0,127}));
    connect(EVAP01.port_bChiWat, TIT_OE1.port_b) annotation (Line(points={{66,
            -157.686},{66,-156},{82,-156}},
                                  color={0,127,255}));
    connect(P02.port_a, expVes.port_a) annotation (Line(points={{-374,-46},{-368,-46},
            {-368,-88},{-340,-88},{-340,-100},{-316,-100},{-316,-92}}, color={0,127,
            255}));
    connect(const4.y, con3WayValve.u_s) annotation (Line(points={{-225,-232},{
            -222,-232},{-222,-218},{-212,-218}},        color={0,0,127}));
    connect(TIT_010.T, con3WayValve.u_m) annotation (Line(points={{-114,-143},{
            -116,-143},{-116,-240},{-200,-240},{-200,-230}},        color={0,0,127}));
    connect(booleanExpression.y, con3WayValve.trigger) annotation (Line(points={{-225,
            -262},{-225,-264},{-206,-264},{-206,-230}}, color={255,0,255}));
    connect(P01.port_b, senRelPre.port_a) annotation (Line(points={{-76,-156},{-76,
            -102},{-72,-102}}, color={0,127,255}));
    connect(senRelPre.port_b, TIT_011.port_b) annotation (Line(points={{-72,-82},{
            -72,-64},{-100,-64},{-100,-44},{-90,-44}}, color={0,127,255}));
    connect(booleanExpression1.y, conP01.trigger) annotation (Line(points={{-107,-124},
            {-104,-124},{-104,-119.6},{-96.8,-119.6}}, color={255,0,255}));
    connect(senRelPre.p_rel, conP01.u_m) annotation (Line(points={{-81,-92},{-92,-92},
            {-92,-76},{-56,-76},{-56,-132},{-92,-132},{-92,-119.6}}, color={0,0,127}));
    connect(const5.y, conP01.u_s) annotation (Line(points={{-111,-90},{-111,-100},
            {-101.6,-100},{-101.6,-110}}, color={0,0,127}));
    connect(booleanExpression2.y, conP02.trigger) annotation (Line(points={{-401,12},
            {-401,14},{-392,14},{-392,18.4},{-380.8,18.4}},   color={255,0,255}));
    connect(const6.y, conP02.u_s) annotation (Line(points={{-403,42},{-404,42},{-404,
            28},{-385.6,28}},
                            color={0,0,127}));
    connect(pvPanels_G.y, compressorStepController.G) annotation (Line(points={
            {-731.9,-281},{-688,-281},{-688,-270},{-674.8,-270}}, color={0,0,
            127}));
    connect(FIT_001.m_flow, conP02.u_m) annotation (Line(points={{-280,-35},{-280,
            -16},{-376,-16},{-376,18.4}},
                                    color={0,0,127}));
    connect(TIT_002.port_b, ThreeAV01.port_2)
      annotation (Line(points={{-374,-154},{-350,-154}}, color={0,127,255}));
    connect(ThreeAV01.port_1, jun3.port_1) annotation (Line(points={{-330,-154},
            {-328,-156},{-312,-156}}, color={0,127,255}));
    connect(Fan_Pump.y, sum1.u[1]) annotation (Line(points={{-749,-82},{-712,
            -82},{-712,-72.6667},{-706,-72.6667}},
                                             color={0,0,127}));
    connect(twoCircuitChiller.Power, sum1.u[2]) annotation (Line(points={{-434.5,
            -86.6},{-424,-86.6},{-424,-56},{-568,-56},{-568,-32},{-596,-32},{
            -596,-28},{-712,-28},{-712,-72},{-706,-72}},           color={0,0,
            127}));
    connect(Fan_Pump.y, equipmentLoad.P_L) annotation (Line(points={{-749,-82},
            {-749,-84},{-712,-84},{-712,-72},{-716,-72},{-716,-56},{-672,-56},{
            -672,-48},{-660,-48},{-660,-71.6},{-640.2,-71.6}}, color={0,0,127}));
    connect(PLC.y, sum1.u[3]) annotation (Line(points={{-749,-104},{-716,-104},
            {-716,-84},{-712,-84},{-712,-71.3333},{-706,-71.3333}}, color={0,0,
            127}));
    connect(PCM02.SOC,tempSocCondition. SOC) annotation (Line(points={{-403,-294},
            {-403,-296},{-396,-296},{-396,-324},{-788,-324},{-788,-216},{-720,-216},
            {-720,-198.6},{-710.6,-198.6}},                   color={0,0,127}));
    connect(const2.y,CompSignalEnable. u3) annotation (Line(points={{-717,-250},{-717,
            -252},{-684,-252},{-684,-210},{-632,-210}}, color={0,0,127}));
    connect(HTFTemp.y,tempSocCondition. T_HTG) annotation (Line(points={{-775.9,-193},
            {-772,-192.6},{-710.6,-192.6}},       color={0,0,127}));
    connect(compressorStepController.freqNorm,CompSignalEnable. u1) annotation (
       Line(points={{-613.2,-270},{-613.2,-272},{-604,-272},{-604,-220},{-640,-220},
            {-640,-194},{-632,-194}},
                    color={0,0,127}));
    connect(tempSocCondition.y, CompSignalEnable.u2) annotation (Line(points={{-689.8,
            -194.4},{-644,-194.4},{-644,-202},{-632,-202}}, color={255,0,255}));
    connect(CompSignalEnable.y, firstOrder.u) annotation (Line(points={{-609,-202},
            {-609,-204},{-572,-204},{-572,-162},{-562,-162}}, color={0,0,127}));
    connect(firstOrder.y, twoCircuitChiller.ySet_C2) annotation (Line(points={{-539,
            -162},{-539,-164},{-508,-164},{-508,-110.16},{-488,-110.16}}, color={0,
            0,127}));
    connect(firstOrder.y, twoCircuitChiller.ySet_C1) annotation (Line(points={{-539,
            -162},{-539,-164},{-508,-164},{-508,-123.8},{-488,-123.8}}, color={0,0,
            127}));
    connect(compressorStepController.freqNorm, outOfRangeDetector.u) annotation (
        Line(points={{-613.2,-270},{-613.2,-272},{-604,-272},{-604,-262},{-562,-262}},
          color={0,0,127}));
    connect(outOfRangeDetector.y, booleanToReal.u) annotation (Line(points={{-539,
            -262},{-539,-264},{-516,-264},{-516,-256},{-508,-256}}, color={255,0,255}));
    connect(booleanToReal.y, firstOrder2.u) annotation (Line(points={{-485,-256},{
            -476,-256},{-476,-216},{-480,-216},{-480,-196},{-472,-196}}, color={0,
            0,127}));
    connect(coldROOM_V01.ports_Air_CR[1], senRelHum_CR.port) annotation (Line(
          points={{36,8.54286},{36,4},{88,4},{88,-16},{100,-16},{100,32},{136,32},
            {136,8},{156,8},{156,14}}, color={0,127,255}));
    connect(PIT_010.port, cheVal.port_a)
      annotation (Line(points={{-66,-156},{-52,-156}}, color={0,127,255}));
    connect(cheVal.port_b, jun.port_1)
      annotation (Line(points={{-36,-156},{-28,-156}}, color={0,127,255}));
    connect(Infiltration.y[1], infiltration.mAB) annotation (Line(points={{7,56},
            {8,56},{8,64},{15,64},{15,74.6}}, color={0,0,127}));
    connect(Infiltration.y[1], infiltration.mBA) annotation (Line(points={{7,56},
            {36.6,56},{36.6,74.6}}, color={0,0,127}));
    connect(firstOrder2.y, ThreeAV01.y) annotation (Line(points={{-449,-196},{-440,
            -196},{-440,-172},{-368,-172},{-368,-132},{-340,-132},{-340,-142}},
          color={0,0,127}));
    connect(con3WayValve.y, ThreeAV02.y) annotation (Line(points={{-188,-218},{
            -188,-220},{-142,-220},{-142,-168}}, color={0,0,127}));
    connect(conP01.y, P01.y) annotation (Line(points={{-82.4,-110},{-82.4,-112},
            {-72,-112},{-72,-140},{-80,-140},{-80,-136},{-86,-136},{-86,-144}},
          color={0,0,127}));
    connect(TIT_006.port_b, pip.port_a)
      annotation (Line(points={{-256,-156},{-250,-156}}, color={0,127,255}));
    connect(pip.port_b, storageDetailed.fluidportBottom2) annotation (Line(points
          ={{-230,-156},{-228.3,-156},{-228.3,-102.1}}, color={0,127,255}));
    connect(jun2.port_2, pip1.port_a)
      annotation (Line(points={{-146,-44},{-178,-44}}, color={0,127,255}));
    connect(pip1.port_b, storageDetailed.fluidportTop1) annotation (Line(points={{
            -198,-44},{-223.2,-44},{-223.2,-81.9}}, color={0,127,255}));
    connect(conP02.y, P02.y) annotation (Line(points={{-366.4,28},{-360,28},{-360,
            -20},{-384,-20},{-384,-34}}, color={0,0,127}));
    connect(coldROOM_V01.T_in_CR, x_pTphi.T) annotation (Line(points={{56.8,
            23.2},{64,23.2},{64,28},{140,28},{140,56},{160,56}}, color={0,0,127}));
    connect(senRelHum_CR.phi, x_pTphi.phi) annotation (Line(points={{167,24},{
            158,24},{158,42},{148,42},{148,50},{160,50}}, color={0,0,127}));
    connect(Infiltration1.y[1], loads_enhanced.t_people1) annotation (Line(
          points={{-39,48},{-32,48},{-32,22.2},{-22.6,22.2}}, color={0,0,127}));
    connect(Mogadishu.weaBus, weaBus1) annotation (Line(
        points={{108,98},{116,98},{116,44},{52,44},{52,100},{-56,100},{-56,108},
            {-140,108},{-140,96}},
        color={255,204,51},
        thickness=0.5));
    connect(T_amb.T, weaBus1.TDryBul) annotation (Line(points={{-168,94},{-192,
            94},{-192,96.05},{-139.95,96.05}},   color={0,0,127}), Text(
        string="%second",
        index=1,
        extent={{-6,3},{-6,3}},
        horizontalAlignment=TextAlignment.Right));
    connect(m_out.y, loads_enhanced.m_Out1) annotation (Line(points={{-99,8},{-72,
            8},{-72,0},{-32,0},{-32,14},{-23,14}}, color={0,0,127}));
    connect(pvPanels_G1.y, EVAP02.PVDayNight) annotation (Line(points={{137.9,
            -93},{108,-93},{108,-25.8429},{69.125,-25.8429}}, color={0,0,127}));
    connect(pvPanels_G1.y, EVAP01.PVDayNight) annotation (Line(points={{137.9,
            -93},{120,-93},{120,-94},{73.125,-94},{73.125,-143.843}}, color={0,
            0,127}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-780,
              -320},{140,120}}), graphics={
          Rectangle(
            extent={{-778,118},{136,-320}},
            lineColor={0,140,72},
            fillColor={0,140,72},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-748,94},{102,-294}},
            lineColor={0,140,72},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Text(
            extent={{-728,88},{82,-276}},
            textColor={0,140,72},
            textStyle={TextStyle.Bold},
            textString="System_CL")}),                             Diagram(
          coordinateSystem(preserveAspectRatio=false, extent={{-780,-320},{140,
              120}})),
      experiment(StopTime=172800, __Dymola_Algorithm="Dassl"));
  end System_CL_NightCTRL;
end System;
