# Determine root directory relative to script location
set script_dir [file dirname [info script]]
set origin_dir [file normalize "$script_dir/.."]

# 1. Recreate Vivado Project
source [file join $script_dir "build_project.tcl"]

# 2. Recreate Block Design
source [file join $script_dir "build_bd.tcl"]

# 3. Generate Block Design Wrapper & Set as Top
set bd_file [get_files *.bd]
make_wrapper -files [get_files $bd_file] -top
add_files -norecurse [file render [file rootname $bd_file]_wrapper.v]
update_compile_order -fileset sources_1
