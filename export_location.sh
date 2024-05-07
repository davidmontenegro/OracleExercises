#!/bin/ksh
LOG_FILE=export_location_199.log
rm -f $LOG_FILE

log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
	printf "%s %s\n" "[$timestamp]" "$1"
	printf "%s %s\n" "[$timestamp]" "$1" >> $LOG_FILE 2>&1
}

log "[INFO]  Start extraction of stock information for location $1."
sqlplus -s <<- END_EXPORT 1>sql_exec$1.tmp 2>>$LOG_FILE
$USERBATCH

SET TERMOUT OFF
SET PAGESIZE 0
SET LINESIZE 32767
SET TRIMSPOOL ON
SET FEEDBACK OFF
SET COLSEP ','
SET VERIFY OFF
SET FLUSH OFF
SET BUFFER LENGTH 4000
spool $1.csv

SELECT/*+ INDEX (item_loc_soh index_soh_loc) */
	item || ',' ||
	dept || ',' ||
	unit_cost || ',' || 
	stock_on_hand  || ',' ||
	ROUND(stock_on_hand*unit_cost, 2)
FROM
	item_loc_soh
WHERE
	loc < $1;
END_EXPORT


rm -f *.tmp
log "[INFO]  Stock information export finished."