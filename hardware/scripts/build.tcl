################################################################################
# build.tcl
#
# Recreates the full project by sourcing, in order:
#   1. build_project.tcl - project shell: part/board, rtl/ + cons/ sources,
#                           filesets, synth/impl runs, dashboard gadgets.
#                           (does NOT touch the block design)
#   2. build_bd.tcl       - the block design, written as a remote BD to
#                           hardware/bd/. Must run AFTER build_project.tcl,
#                           since it checks that the 'keypad_deco' RTL module
#                           is already present in the project's sources.
#
# Then generates the BD's HDL wrapper and sets it as the project's top.
#
# Usage (from anywhere):
#   vivado -mode batch -source hardware/scripts/build.tcl
################################################################################

set script_dir [file normalize [file dirname [info script]]]
set hw_dir     [file normalize "$script_dir/.."]

# Run from hardware/ so build_project.tcl's un-parameterized
# "./project_1" project directory always lands in the same place,
# regardless of the directory Vivado was launched from.
cd $hw_dir

# ------------------------------------------------------------------------
# Clean stale outputs so this script is safely re-runnable.
# - build_project.tcl's create_project has no -force, so a leftover
#   project_1/ from a previous run would error it out.
# - build_bd.tcl explicitly refuses to run if design_1.bd already exists
#   on disk (it lives in hardware/bd/, outside project_1/, so deleting
#   project_1/ alone is NOT enough for a clean rebuild).
# ------------------------------------------------------------------------
set proj_out_dir [file join $hw_dir "project_1"]
set bd_out_dir   [file join $hw_dir "bd"]

if { [file exists $proj_out_dir] } {
    puts "INFO: Removing existing $proj_out_dir"
    file delete -force $proj_out_dir
}
if { [file exists $bd_out_dir] } {
    puts "INFO: Removing existing $bd_out_dir"
    file delete -force $bd_out_dir
}

# ------------------------------------------------------------------------
# 1. Recreate the project (part/board, rtl/, cons/, runs)
#    origin_dir must point at hardware/scripts/, since build_project.tcl
#    resolves sources as $origin_dir/../rtl and $origin_dir/../cons.
# ------------------------------------------------------------------------
set ::origin_dir_loc $script_dir
source [file join $script_dir "build_project.tcl"]

# ------------------------------------------------------------------------
# 2. Recreate the block design
#    origin_dir is used directly (no "../") as the remote-BD output
#    folder, so it must point straight at hardware/bd/.
# ------------------------------------------------------------------------
set ::origin_dir_loc $bd_out_dir
source [file join $script_dir "build_bd.tcl"]

# ------------------------------------------------------------------------
# 3. Wrap the BD and set it as the project's top
#    ($design_name is set by build_bd.tcl at global scope, so it's still
#    available here - but current_bd_design is used as a more robust
#    fallback in case that ever changes.)
# ------------------------------------------------------------------------
if { ![info exists design_name] || $design_name eq "" } {
    set design_name [get_property NAME [current_bd_design]]
}

set bd_file      [get_files "${design_name}.bd"]
set wrapper_path [make_wrapper -files $bd_file -top]

add_files -norecurse $wrapper_path
update_compile_order -fileset sources_1
set_property top "${design_name}_wrapper" [current_fileset]
update_compile_order -fileset sources_1

puts "INFO: Project rebuilt successfully from build_project.tcl + build_bd.tcl"
