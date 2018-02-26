CREATE OR REPLACE PACKAGE BODY blockchain_api AS

/*
    Oracle PL/SQL Package to demonstrate Blockchain functionality
    in an Oracle database

    Copyright (C) 2018, David Drewette, OraPro Ltd. info@orapro.co.uk

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/


    c_difficulty      CONSTANT NUMBER := 2;
    gv_id             blockchain.id%TYPE;
    gv_previoushash   blockchain.previoushash%TYPE;
    gv_timestamp      blockchain.timestamp%TYPE;
    gv_transaction    blockchain.transaction%TYPE;
    gv_hash           blockchain.hash%TYPE;
    gv_nonce          blockchain.nonce%TYPE;

    PROCEDURE initialise
        IS
    BEGIN

--get last block hash
        getlatestblock;
        
-- start mining - PROOF OF WORK
        mineblock;
        
    --validate block
        IF
            ischainvalid
        THEN
            UPDATE blockchain
                SET
                    valid = 'Y'
            WHERE
                id = gv_id;

        ELSE
            UPDATE blockchain
                SET
                    valid = 'N'
            WHERE
                id = gv_id;

        END IF;

    END;

    PROCEDURE calculatehash
        IS
    BEGIN
        gv_hash := sha256.encrypt(gv_previoushash
        || gv_timestamp
        || gv_transaction
        || gv_nonce);
    END;

    PROCEDURE mineblock IS
        l_leading_zeros   VARCHAR2(100);
    BEGIN

--get leading zeros from difficulty
        SELECT
            rpad('0',c_difficulty,'0')
        INTO
            l_leading_zeros
        FROM
            dual;

--set inital value of nonce

        gv_nonce := 1;
        calculatehash;

--cycle through hashes
        WHILE ( substr(gv_hash,1,c_difficulty) != l_leading_zeros ) LOOP
            gv_nonce := gv_nonce + 1;  --increment the none by 1
            calculatehash;
        END LOOP;

--write new nonce to table, nonce has been found

        UPDATE blockchain
            SET
                nonce = gv_nonce,
                hash = gv_hash
        WHERE
            id = gv_id;

    END;

    PROCEDURE getlatestblock
        IS
    BEGIN
        FOR r IN (
            SELECT
                id,
                previoushash,
                timestamp,
                transaction
            FROM
                (
                    SELECT
                        *
                    FROM
                        blockchain
                    ORDER BY
                        id DESC
                )
            WHERE
                ROWNUM = 1
            ORDER BY
                ROWNUM DESC
        ) LOOP
            gv_id := r.id;
            gv_previoushash := r.previoushash;
            gv_timestamp := r.timestamp;
            gv_transaction := r.transaction;
        END LOOP;
    END;

    FUNCTION ischainvalid RETURN BOOLEAN IS
        l_result       BOOLEAN := false;
        l_hash         blockchain.hash%TYPE;
        l_mined_hash   blockchain.hash%TYPE;
    BEGIN
    
    --get hash using current nonce
        SELECT
            sha256.encrypt(gv_previoushash
            || gv_timestamp
            || gv_transaction
            || gv_nonce)
        INTO
            l_hash
        FROM
            blockchain
        WHERE
            id = gv_id;

        SELECT
            hash
        INTO
            l_mined_hash
        FROM
            blockchain
        WHERE
            id = gv_id;

        IF
            ( l_hash = l_mined_hash )
        THEN
            l_result := true;
        END IF;
        RETURN l_result;
    END;

    PROCEDURE isentirechainvalid IS

        l_id             blockchain.id%TYPE;
        l_previoushash   blockchain.previoushash%TYPE;
        l_lag_hash       blockchain.previoushash%TYPE;
    BEGIN
        FOR r IN (
            SELECT
                id,
                previoushash,
                LAG(hash,1) OVER(
                    ORDER BY
                        id
                ) lag_hash
            FROM
                blockchain
        ) LOOP
            l_id := r.id;
            l_previoushash := r.previoushash;
            l_lag_hash := r.lag_hash;
            IF
                l_previoushash != l_lag_hash
            THEN
                UPDATE blockchain
                    SET
                        valid = 'N'
                WHERE
                    id = l_id;

            ELSE
                UPDATE blockchain
                    SET
                        valid = 'Y'
                WHERE
                    id = l_id;

            END IF;

        END LOOP;
    END;

END;
/