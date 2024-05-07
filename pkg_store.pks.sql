CREATE OR REPLACE PACKAGE pkg_store IS
    PROCEDURE update_forenv_acc (v_location IN loc.loc%TYPE DEFAULT NULL);
END pkg_store;