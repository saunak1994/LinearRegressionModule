
# Open the GUI window
win

# Synthesize and then place the design (step 4 of tutorial)
compileDesign
placeDesign -noPrePlaceOpt

# Select different views
setDrawView place
setDrawView ameba

# Fit the design in the window
fit

# Set floorplan parameters and row spacing (step 5 of tutorial)
getIoFlowFlag
setFPlanRowSpacingAndType 1.8 2
setIoFlowFlag 0
floorPlan -site core -r 0.8 0.599994 20.0 20.0 20.0 20.0

# Add power rings (step 6 of tutorial)
addRing -spacing_bottom 1 -width_left 8 -width_bottom 8 -width_top 8 -spacing_top 1 -layer_bottom M1 -stacked_via_top_layer M8 -width_right 8 -around core -jog_distance 0.1 -offset_bottom 1 -layer_top M1 -threshold 0.1 -offset_left 1 -spacing_right 1 -spacing_left 1 -offset_right 1 -offset_top 1 -layer_right M2 -nets {VDD VSS} -stacked_via_bottom_layer M1 -layer_left M2

# Place the design into the rows (step 7 of tutorial)
setPlaceMode -fp false
placeDesign -prePlaceOpt

# Pre-CTS (clock tree synthesis) optimization (step 8 of tutorial)
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -preCTS

# CTS (step 9 of tutorial)
clockDesign -genSpecOnly Clock.ctstch
clockDesign -specFile Clock.ctstch -outDir clock_report -fixedInstBeforeCTS
displayClockPhaseDelay -preRoute

# Post-CTS optimization (step 10 of tutorial)
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -postCTS

# Route wires in the design (step 11 of tutorial)
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
routeDesign -globalDetail

# Post-route optimization (step 12 of tutorial)
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -postRoute

setDrawView place
fit

report_power
report_timing

