CREATE OR REPLACE PROCEDURE p_extract_stock_info (v_directory IN VARCHAR2 DEFAULT 'STOCK_INFO', v_location IN item_loc_soh.loc%TYPE DEFAULT NULL, v_location2 IN item_loc_soh.loc%TYPE DEFAULT NULL) IS
    location_file       utl_file.file_type;
    v_str               VARCHAR2(32000);
    header_line         VARCHAR2(500) := 'Item,Department,Unit cost, Stock on hand, Stock value';
    last_location       item_loc_soh.loc%TYPE;
    is_first_iteration  BOOLEAN := TRUE;
    line_written        BOOLEAN := FALSE;

    CURSOR c_info IS
        SELECT /*+ INDEX(item_loc_soh INDEX_SOH_LOC) PARALLEL(8) */
            loc,
            item || ',' ||
            dept || ',' ||
            unit_cost || ',' ||
            stock_on_hand  || ',' ||
            ROUND(stock_on_hand*unit_cost, 2) AS v_line
        FROM
            item_loc_soh
        WHERE
            loc BETWEEN v_location AND v_location2
        ORDER BY
            loc;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Start: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    FOR r_info IN c_info
    LOOP
        IF is_first_iteration OR r_info.loc <> last_location THEN
            IF v_str IS NOT NULL AND NOT(line_written) THEN
                utl_file.put_line(location_file, v_str);
                v_str := NULL;
            END IF;
            utl_file.fclose(location_file);
            location_file := utl_file.fopen(v_directory, r_info.loc || '.csv', 'w');
            utl_file.put_line(location_file, header_line, FALSE);

            last_location := r_info.loc;
            is_first_iteration := FALSE;
        END IF;

        IF v_str IS NULL OR LENGTH(v_str) < 31500 THEN
            v_str := v_str || r_info.v_line || CHR(10);
            line_written := FALSE;
        ELSE
            v_str := v_str || r_info.v_line;
            utl_file.put_line(location_file, v_str);
            line_written := TRUE;
            v_str := NULL;
        END IF;
    END LOOP;

    IF v_str IS NOT NULL AND NOT(line_written) THEN
        utl_file.put_line(location_file, v_str);
        v_str := NULL;
    END IF;
    utl_file.fclose(location_file);
    DBMS_OUTPUT.PUT_LINE('End: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ' ERROR > ' || SUBSTR(SQLERRM, 1, 200));
        DBMS_OUTPUT.PUT_LINE('    Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END p_extract_stock_info;