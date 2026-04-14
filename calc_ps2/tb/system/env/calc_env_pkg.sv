`timescale 1ns / 1ps

package calc_env_pkg;

    // --- Transaction types ---
    `include "calc_transaction.sv"
    `include "calc_result_tx.sv"

    // --- Infrastructure ---
    `include "calc_generator.sv"
    `include "calc_driver.sv"
    `include "calc_monitor.sv"
    `include "calc_scb.sv"
    `include "calc_coverage.sv"

    // --- Environment and test ---
    `include "calc_env.sv"
    `include "calc_test.sv"

endpackage
