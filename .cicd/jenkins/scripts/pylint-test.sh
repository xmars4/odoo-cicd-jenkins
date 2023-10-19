#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
cd $ODOO_WORKSPACE

show_separator "Start analyzing log file"

function analyze_log {
    # we get all info from this test -> just send log file to somewhere
    # no need to analyze anything
}

analyze_log
