create or replace PACKAGE BODY pkg_store IS
    PROCEDURE update_forenv_acc (v_location IN loc.loc%TYPE DEFAULT NULL) IS
       table_does_not_exist EXCEPTION;  
       PRAGMA EXCEPTION_INIT(table_does_not_exist, -942);
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Start: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
        IF v_location IS NOT NULL THEN
            EXECUTE IMMEDIATE 'CREATE TABLE item_loc_soh_' || v_location || '_' || TO_CHAR(SYSDATE, 'yyyymmddhh24miss') || ' AS SELECT /*+ INDEX (item_loc_soh index_soh_loc) */ * FROM item_loc_soh WHERE loc = ' || v_location;
        ELSE
            BEGIN
                EXECUTE IMMEDIATE 'DROP TABLE item_loc_soh_all PURGE';
            EXCEPTION
                WHEN table_does_not_exist THEN
                    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ' WARN > Table item_loc_soh_all does not exist.');
                WHEN OTHERS THEN
                    RAISE;
            END;

            EXECUTE IMMEDIATE 'CREATE TABLE item_loc_soh_all PARALLEL NOLOGGING AS
                                    SELECT
                                        item,
                                        dept,
                                        unit_cost,
                                        stock_on_hand,
                                        ROUND(stock_on_hand*unit_cost, 2) AS stock_value
                                    FROM
                                        item_loc_soh';
        END IF;
        DBMS_OUTPUT.PUT_LINE('End: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ' ERROR > ' || SUBSTR(SQLERRM, 1, 200));
                DBMS_OUTPUT.PUT_LINE('    Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END update_forenv_acc;
END pkg_store;