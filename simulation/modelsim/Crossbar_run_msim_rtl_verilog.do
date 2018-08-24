transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Projects/QuartusProjects/Crossbar {C:/Projects/QuartusProjects/Crossbar/Crossbar.v}

vlog -sv -work work +incdir+C:/Projects/QuartusProjects/Crossbar/simulation/modelsim {C:/Projects/QuartusProjects/Crossbar/simulation/modelsim/Crossbar.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc" Crossbar_vlg_tst

add wave *
view structure
view signals
run -all
